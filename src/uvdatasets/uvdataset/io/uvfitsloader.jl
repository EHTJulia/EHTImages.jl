export load_uvfits

function load_uvfits(filename::AbstractString)
    # Load pyfits
    copy!(pyfits, pyimport_conda("astropy.io.fits", "astropy"))

    # Open UVFITS file
    hdulist = pyfits.open(filename)

    # Load GroupHDU, HDUs for AIPS AN/FQ Tables
    ghdu, antab, fqtab = hdulist2hdus(hdulist)

    # Get the visibility data set from GroupHDU
    visds = hdulist2vis(ghdu)

    # Get the frequency information
    visds = concat(visds, hdulist2freq(ghdu, antab, fqtab))

    # Get the antds
    antds = hdulist2ant(antab)

    # Get the metadata
    metadata = hdulist2metadata(ghdu, antab)

    # group visds and antds in OrderedDict
    datasets = OrderedDict(:visibility => visds, :antenna => antds)

    # Form UVData
    uvdata = UVDataSet(datasets, metadata)

    # compute frequency and uvw
    compute_ν!(uvdata)
    compute_uvw!(uvdata)

    # output
    return uvdata
end

"""
    hdulist2hdus(hdulist)

Read the given hdulist (output of pyfits.io.open) and return
GroupHDU and HDUs of AIPS AN/FQ Tables.
"""
function hdulist2hdus(hdulist)
    # Number of HDUs
    nhdu = length(hdulist)

    # grouphdu
    ghdu = hdulist[1]

    # read other hdu
    antab = NaN
    fqtab = NaN
    for hdu in hdulist[2:nhdu]
        if hdu.header.get("EXTNAME") == "AIPS AN"
            if typeof(antab) == PyObject
                println("Warning: there are multiple AN tables in the UVFITS file. The latest one will be loaded.")
            end
            antab = hdu
        elseif hdu.header.get("EXTNAME") == "AIPS FQ"
            if typeof(fqtab) == PyObject
                println("Warning: there are multiple FQ tables in the UVFITS file. The latest one will be loaded.")
            end
            fqtab = hdu
        end
    end

    if typeof(antab) != PyObject
        @throwerror ValueError "The input UVFITS file does not have an AIPS FQ Table."
    end

    if typeof(fqtab) != PyObject
        @throwerror ValueError "The input UVFITS file does not have an AIPS FQ Table."
    end

    return ghdu, antab, fqtab
end

function hdulist2vis(ghdu)
    # size of visibility data
    ndata, ndec, nra, nspw, nch, npol, _ = size(ghdu.data.data)

    if (ndec > 1) || (nra > 1)
        print("Warning: GroupHDU has more than a single coordinae (Nra, Ndec) = (", nra, ", ", ndec, "). We will pick up only the first one.")
    end

    # read visibilities
    Vre = ghdu.data.data[:, 1, 1, :, :, :, 1] # Dim: data (time x baseline), spw, ch, pol 
    Vim = ghdu.data.data[:, 1, 1, :, :, :, 2]
    Vwe = ghdu.data.data[:, 1, 1, :, :, :, 3]

    # permutate dimensions
    Vre = permutedims(Vre, (3, 2, 1, 4)) # Dim: ch, spw, data (time x baseline), pol
    Vim = permutedims(Vim, (3, 2, 1, 4))
    Vwe = permutedims(Vwe, (3, 2, 1, 4))

    # compute visibility, sigma and flag
    Vcmp = ComplexF64.(Vre .+ 1im .* Vim)
    σV = (abs.(Float64.(Vwe))) .^ (-0.5)
    flag = Int8.(sign.(Vwe))

    # reset flags based on the value of sigma
    cond = σV .== NaN .|| isinf.(σV) .|| σV == 0
    idx = findall(cond)
    σV[idx] .= 0.0
    flag[idx] .= 0

    # Read random parameters
    paridxes = [-1 for i in 1:9]
    parnames = ghdu.data.parnames
    npar = length(parnames)
    pardata = DataFrame()
    for ipar in 1:npar
        parname = parnames[ipar]
        if occursin("UU", parname)
            paridxes[1] = ipar
            pardata[!, :usec] = Float64.(ghdu.data.par(ipar - 1))
        elseif occursin("VV", parname)
            paridxes[2] = ipar
            pardata[!, :vsec] = Float64.(ghdu.data.par(ipar - 1))
        elseif occursin("WW", parname)
            paridxes[3] = ipar
            pardata[!, :wsec] = Float64.(ghdu.data.par(ipar - 1))
        elseif occursin("DATE", parname)
            if paridxes[4] < 0
                paridxes[4] = ipar
                pardata[!, :mjd] = jd2mjd(Float64.(ghdu.data.par(ipar - 1)))
            elseif paridxes[5] < 0
                paridxes[5] = ipar
                pardata[!, :mjd] .+= Float64.(ghdu.data.par(ipar - 1))
            else
                println(ipar)
                @throwerror KeyError "Random Parameter have too many `DATE` columns."
            end
        elseif occursin("BASELINE", parname)
            paridxes[6] = ipar
            pardata[!, :baseline] = Float64.(ghdu.data.par(ipar - 1))
        elseif occursin("SOURCE", parname)
            paridxes[7] = ipar
            pardata[!, :source] = Int32.(ghdu.data.par(ipar - 1))
        elseif occursin("INTTIM", parname)
            paridxes[8] = ipar
            pardata[!, :inttime] = Float64.(ghdu.data.par(ipar - 1))
        elseif occursin("FREQSEL", parname)
            paridxes[9] = ipar
            pardata[!, :freqset] = Int32.(ghdu.data.par(ipar - 1))
        end
    end

    # check the loaded random parameters
    if paridxes[7] > 0
        if length(unique(pardata[:source])) > 1
            print("Warning: Group HDU contains data on more than a single source. ")
            print("It will likely cause a problem since this library assumes a single source UVFITS file.\n")
        end
    end

    if paridxes[8] < 0
        print("Warning: Group HDU do not have a random parameter for the integration time. ")
        print("It will be estimated with a minimal time interval of data.\n")
        dmjd = median(diff(sort(unique(pardata[!, :mjd]))))
        pardata[!, :dmjd] = fill(dmjd, ndata)
    else
        pardata[!, :dmjd] = pardata[!, :inttime] ./ 86400
    end

    if paridxes[9] > 0
        if length(unique(pardata[:freqset])) > 1
            print("Warning: Group HDU contains data on more than a single frequency setting. ")
            print("It will likely cause a problem since this library assumes a UVFITS file with a single frequency setup.\n")
        end
    end

    # antenna ID
    subarray = zeros(Int64, ndata)
    pardata[!, :antid1] = zeros(Int64, ndata)
    pardata[!, :antid2] = zeros(Int64, ndata)
    for i in 1:ndata
        subid, blid = modf(pardata[i, :baseline])
        subarray[i] = Int64(100 * subid + 1)
        pardata[i, :antid1] = div(blid, 256)
        pardata[i, :antid2] = rem(blid, 256)
    end
    if length(unique(subarray)) > 1
        print("Warning: Group HDU contains data on more than a single subarray. ")
        print("It will likely cause a problem since this library assumes a UVFITS file with a single subarray.\n")
    end

    # polarization
    dp = Int64(ghdu.header.get("CDELT3"))
    ipref = Int64(ghdu.header.get("CRPIX3"))
    pref = Int64(ghdu.header.get("CRVAL3"))
    polids = (dp*(1-ipref)+pref):dp:(dp*(npol-ipref)+pref)
    pol = [polid2name[string(polid)] for polid in polids]

    # form dimensional arrays
    c = Dim{:ch}(collect(1:nch))
    s = Dim{:spw}(collect(1:nspw))
    d = Dim{:data}(collect(1:ndata))
    p = Dim{:pol}(collect(1:npol))

    # ch, spw, data (time x baseline), pol
    visds = DimStack(
        DimArray(data=Vcmp, dims=(c, s, d, p), name=:visibility),
        DimArray(data=σV, dims=(c, s, d, p), name=:sigma),
        DimArray(data=σV, dims=(c, s, d, p), name=:flag),
        DimArray(data=pol, dims=(p), name=:polarization),
        DimArray(data=pardata[!, :usec], dims=(d), name=:usec),
        DimArray(data=pardata[!, :vsec], dims=(d), name=:vsec),
        DimArray(data=pardata[!, :wsec], dims=(d), name=:wsec),
        DimArray(data=pardata[!, :mjd], dims=(d), name=:mjd),
        DimArray(data=pardata[!, :dmjd], dims=(d), name=:Δmjd),
        DimArray(data=pardata[!, :antid1], dims=(d), name=:antid1),
        DimArray(data=pardata[!, :antid2], dims=(d), name=:antid2),
    )

    return visds
end

"""
    hdulist2freq(ghdu, antab, fqtab)
"""
function hdulist2freq(ghdu, antab, fqtab)
    # Load numpy
    copy!(numpy, pyimport_conda("numpy", "numpy"))

    # Reference Frequency
    reffreq = antab.header.get("FREQ")

    # Get data dimension
    _, _, _, nspw, nch, _, _ = size(ghdu.data.data)

    # Check FREQSEL
    nfreqset = length(fqtab.data["FRQSEL"])
    if nfreqset > 1
        println("Input FQ Table has more than a single Frequency setting. This library only handles a UVFITS file with a single frequency setting. The first setting will be loaded.")
    end

    function arraylize(input)
        if isa(input, Number)
            return [input]
        else
            return input
        end
    end

    # Get frequency settings
    spwfreq = arraylize(numpy.float64(fqtab.data["IF FREQ"][1]))
    chbw = arraylize(numpy.float64(fqtab.data["CH WIDTH"][1]))
    sideband = arraylize(numpy.float64(fqtab.data["SIDEBAND"][1]))

    # Axis
    s = Dim{:spw}(collect(1:nspw))

    fqds = DimStack(
        DimArray(data=reffreq .+ spwfreq, dims=s, name=:νspw),
        DimArray(data=chbw, dims=s, name=:Δνch),
        DimArray(data=sideband, dims=s, name=:sideband),
    )
    return fqds
end

"""
    hdulist2ant(antab)
"""
function hdulist2ant(antab)
    # Load numpy
    copy!(numpy, pyimport_conda("numpy", "numpy"))

    # Get the antenna infromation
    nant = length(antab.data)

    # Get the antenna name
    antname = [name for name in antab.data["ANNAME"]]
    xyz = numpy.float64(antab.data["STABXYZ"])

    # Check polarization labels
    pola = numpy.unique(antab.data["POLTYA"])
    polb = numpy.unique(antab.data["POLTYB"])
    if length(pola) > 1
        @throwerror ValueError "POLTYA have more than a single polarization across the array."
    end
    if length(polb) > 1
        @throwerror ValueError "POLTYB have more than a single polarization across the array."
    end
    pol = [pola[1], polb[1]]
    npol = length(pol)

    # Parse Field Rotation Information
    #   See AIPS MEMO 117
    #      0: ALT-AZ, 1: Eq, 2: Orbit, 3: X-Y, 4: Naismith-R, 5: Naismith-L
    #      6: Manual
    mntsta = numpy.int32(antab.data["MNTSTA"])
    fr_pa_coeff = ones(nant)
    fr_el_coeff = zeros(nant)
    fr_offset = zeros(nant)
    for i in 1:nant
        if mntsta[i] == 0  # azel
            fr_pa_coeff[i] = 1
            fr_el_coeff[i] = 0
        elseif mntsta[i] == 1  # Equatorial
            fr_pa_coeff[i] = 0
            fr_el_coeff[i] = 0
        elseif mntsta[i] == 4  # Nasmyth-R
            fr_pa_coeff[i] = 1
            fr_el_coeff[i] = 1
        elseif mntsta[i] == 5  # Nasmyth-L
            fr_pa_coeff[i] = 1
            fr_el_coeff[i] = -1
        end
    end

    # Antenna Type
    anttype = [:ground for i in 1:nant]

    # Set dimensions
    a = Dim{:ant}(collect(1:nant))
    p = Dim{:feed}(collect(1:npol))

    # create data set
    antds = DimStack(
        DimArray(data=antname, dims=a, name=:name),
        DimArray(data=xyz[:, 1], dims=a, name=:x),
        DimArray(data=xyz[:, 2], dims=a, name=:y),
        DimArray(data=xyz[:, 3], dims=a, name=:z),
        DimArray(data=anttype, dims=a, name=:type),
        DimArray(data=fr_pa_coeff, dims=a, name=:fr_pa_coeff),
        DimArray(data=fr_el_coeff, dims=a, name=:fr_el_coeff),
        DimArray(data=fr_offset, dims=a, name=:fr_offset),
        DimArray(data=pol, dims=p, name=:feed),
    )

    return antds
end

"""
    hdulist2metadata(ghdu, antab)
"""
function hdulist2metadata(ghdu, antab)
    # Output metadata
    metadata = OrderedDict()

    # Initialize
    for key in keys(uvdataset_metadata_default)
        metadata[key] = uvdataset_metadata_default[key]
    end

    metadata[:instrument] = antab.header.get("ARRNAM")
    metadata[:observer] = ghdu.header.get("OBSERVER")

    metadata[:source] = ghdu.header.get("OBJECT")
    metadata[:ra] = deg2rad(ghdu.header.get("CRVAL6"))
    metadata[:dec] = deg2rad(ghdu.header.get("CRVAL7"))

    equinox = ghdu.header.get("EQUINOX")
    epoch = ghdu.header.get("EPOCH")
    if isa(equinox, Nothing) == false
        if isa(equinox, Number)
            metadata[:equinox] = float(equinox)
        elseif isa(equinox, String)
            metadata[:equinox] = parse(Float64, replace(replace(uppercase(equinox), "J" => ""), "B" => ""))
        else
            metadata[:equinox] = -1
        end
        metadata[:coordsys] = "fk5"
    elseif isa(epoch, Nothing) == false
        if isa(epoch, Number)
            metadata[:equinox] = float(epoch)
        elseif isa(equinox, String)
            metadata[:equinox] = parse(Float64, replace(replace(uppercase(epoch), "J" => ""), "B" => ""))
        else
            metadata[:equinox] = -1
        end
    else
        metadata[:equinox] = -1
    end

    if metadata[:equinox] < 0
        metadata[:coordsys] = "icrs"
    end

    return metadata
end

polid2name = Dict(
    "+1" => "I",
    "+2" => "Q",
    "+3" => "U",
    "+4" => "V",
    "-1" => "RR",
    "-2" => "LL",
    "-3" => "RL",
    "-4" => "LR",
    "-5" => "XX",
    "-6" => "YY",
    "-7" => "XY",
    "-8" => "YX",
)
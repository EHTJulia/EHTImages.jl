export load_fits

"""
    load_fits(filename::AbstractString, hduid::Integer=1) -> IntensityImage
    load_fits(fits::FITS, hduid::Integer=1) -> IntensityImage
    load_fits(hdu::ImageHDU) -> IntensityImage

Load the input FITS image into `IntensityImage` (in-memory image data).

# Arguments
- `filename::AbstractString`: name of the input FITS file
- `hduid::Integer=1`: ID of the HDU to be loaded. Default to the primary HDU.
- `hdu::ImageHDU`: HDU to be loaded.
"""
function load_fits(filename::AbstractString, hduid::Integer=1)::IntensityImage
    f = FITS(filename, "r")
    hdu = f[hduid]
    image = load_fits(hdu)
    close(f)
    return image
end

# loader from a FITS object
function load_fits(fits::FITS, hduid::Integer=1)::IntensityImage
    hdu = fits[hduid]
    image = load_fits(hdu)
    return image
end

# loader from an ImageHDU object
function load_fits(hdu::ImageHDU)::IntensityImage
    # Check the dimension of the input HDU
    naxis = ndims(hdu)
    if naxis == 2
        nx, ny = size(hdu)
        nf = 1
        np = 1
    elseif naxis == 4
        nx, ny, nf, np = size(hdu)
    else
        @throwerror ArgumentError "The input HDU has a non-standard dimension."
    end
    nt = 1

    # Get header
    header = read_header(hdu)
    header_keys = keys(header)

    # Check the axis of the input HDU
    if occursin("RA", uppercase(header["CTYPE1"])) == false
        @throwerror ArgumentError "Non standard image FITS format: data axis 1 is apparently not RA."
    end

    if occursin("DEC", uppercase(header["CTYPE2"])) == false
        @throwerror ArgumentError "Non standard image FITS format: data axis 2 is apparently not DEC."
    end

    if naxis == 4
        if occursin("FREQ", uppercase(header["CTYPE3"])) == false
            @throwerror ArgumentError "Non standard image FITS format: data axis 3 is apparently not FREQ."
        end

        if occursin("STOKES", uppercase(header["CTYPE4"])) == false
            @throwerror ArgumentError "Non standard image FITS format: data axis 4 is apparently not STOKES."
        end
    end

    # load metadata
    metadata = default_metadata(AbstractIntensityImage)

    if "OBJECT" in header_keys
        metadata[:source] = header["OBJECT"]
    end

    if "TELESCOP" in header_keys
        metadata[:instrument] = header["TELESCOP"]
    end

    if "OBSERVER" in header_keys
        metadata[:observer] = header["OBSERVER"]
    end

    if "RADESYS" in header_keys
        metadata[:coordsys] = lowercase(header["RADESYS"])
    end

    if "EQUINOX" in header_keys
        metadata[:equinox] = header["EQUINOX"]
    end

    if "PULSETYPE" in header_keys
        metadata[:pulsetype] = header["PULSETYPE"]
    end

    # Load Time
    mjd = [datetime2mjd(now())]
    if "MJD" in header_keys
        mjd = [header["MJD"]]
    else
        date_keys = ("OBSDATE", "DATE-OBS", "DATE")
        for key in date_keys
            if key in header_keys
                try
                    mjd = [datetime2mjd(DateTime(header[key], "yyyy-mm-dd"))]
                    break
                catch
                    print("Warning: non-standard value is found for ", key, ".\n")
                end
            end
        end
    end

    # Load Frequency
    if naxis == 2
        freq = [1.0]
        freq_keys = ("OBSFREQ", "FREQ")
        for key in freq_keys
            if key in header_keys
                freq = [header[key]]
                break
            end
        end
    else
        fref = header["CRVAL3"]
        df = header["CDELT3"]
        ifref = header["CRPIX3"]
        freq = ((1-ifref)*df+fref):df:((nf-ifref)*df+fref)
    end

    # Load Polarization
    int(x) = floor(Int, x)
    stokes2pol = Dict(
        "1" => "I",
        "2" => "Q",
        "3" => "U",
        "4" => "V",
    )

    if naxis == 2
        pol = ["I"]
        for key in ("STOKES")
            if key in header_keys
                pol = [header[key]]
                break
            end
        end
    else
        sref = int(header["CRVAL4"])
        ds = int(header["CDELT4"])
        isref = int(header["CRPIX4"])
        stokesid = ((1-isref)*ds+sref):ds:((np-isref)*ds+sref)
        pol = [stokes2pol[string(i)] for i in stokesid]
    end

    # Load x and y axis
    for key in ("CRVAL1", "OBSRA", "RA")
        if key in header_keys
            metadata[:xref] = deg2rad(header[key])
            break
        end
    end

    for key in ("CRVAL2", "OBSDEC", "DEC")
        if key in header_keys
            metadata[:yref] = deg2rad(header[key])
            break
        end
    end

    if "CDELT1" in header_keys
        metadata[:dx] = abs(deg2rad(header["CDELT1"]))
    end

    if "CDELT2" in header_keys
        metadata[:dy] = abs(deg2rad(header["CDELT2"]))
    end

    if "CRPIX1" in header_keys
        metadata[:ixref] = header["CRPIX1"]
    else
        metadata[:ixref] = (nx + 1) / 2
    end

    if "CRPIX2" in header_keys
        metadata[:iyref] = header["CRPIX2"]
    else
        metadata[:iyref] = (ny + 1) / 2
    end

    metadata[:nx] = nx
    metadata[:ny] = ny
    metadata[:np] = np
    metadata[:nf] = nf
    metadata[:nt] = nt

    dimx = Dim{:x}(1:nx)
    dimy = Dim{:y}(1:ny)
    dimp = Dim{:p}(1:np)
    dimf = Dim{:f}(1:nf)
    dimt = Dim{:t}(1:nt)

    # Load Image Data
    data = read(hdu)
    if naxis == 4
        data = permutedims(data, (1, 2, 4, 3))
    end
    data = reshape(data, nx, ny, np, nf, nt)

    intensity = DimArray(
        data=data,
        dims=(dimx, dimy, dimp, dimf, dimt),
        name=:intensity,
    )
    polarization = DimArray(
        data=pol,
        dims=(dimp,),
        name=:polarization
    )
    frequency = DimArray(
        data=freq,
        dims=(dimf,),
        name=:frequency
    )
    time = DimArray(
        data=mjd,
        dims=(dimt,),
        name=:time
    )
    dimstack = DimStack(
        (intensity, polarization, frequency, time),
        metadata=metadata
    )

    # create a IntensityImage instance.
    return IntensityImage(dimstack)
end

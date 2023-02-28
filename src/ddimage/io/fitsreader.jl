export load_fits

"""
    load_fits(filename::AbstractString, hduid::Integer=1)

Load the input FITS image into DDImage (in-memory image data).

# Arguments
- `filename::AbstractString`: name of the input FITS file
- `hduid::Integer=1`: ID of the HDU to be loaded. Default to the primary HDU.
"""
function load_fits(filename::AbstractString, hduid=1)::DDImage
    f = FITS(filename, "r")
    hdu = f[hduid]
    image = load_fits(hdu)
    close(f)
    return image
end

"""
    load_fits(filename::FITS, hduid::Integer=1)

Load the input FITS image into DDImage (in-memory image data).

# Arguments
- `fits::FITS`: the input FITS data
- `hduid::Integer=1`: ID of the HDU to be loaded. Default to the primary HDU.
"""
function load_fits(fits::FITS, hduid=1)::DDImage
    hdu = fits[hduid]
    image = load_fits(hdu)
    return image
end

"""
    load_fits(hdu)

Load the input FITS image into DDImage (in-memory image data).

# Arguments
- `hdu::ImageHDU`: the input image HDU data
"""
function load_fits(hdu::ImageHDU)::DDImage
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
    metadata = default_metadata(NCImage())

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
    mjd = [datetime2julian(now()) - 2400000.5]
    if "MJD" in header_keys
        mjd = [header["MJD"]]
    else
        date_keys = ("OBSDATE", "DATE-OBS", "DATE")
        for key in date_keys
            if key in header_keys
                try
                    mjd = [datetime2julian(DateTime(header[key] - 2400000.5, "yyyy-mm-dd"))]
                    break
                catch
                    print("Warning: non-standard format is used for ", key, ".\n")
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

    xg, yg = get_xygrid(metadata)
    x = Dim{:x}(xg)
    y = Dim{:y}(yg)
    p = Dim{:p}(pol)
    f = Dim{:f}(freq)
    t = Dim{:t}(mjd)

    # Load Image Data
    data = read(hdu)
    if naxis == 4
        data = permutedims(data, (1, 2, 4, 3))
    end
    data = reshape(data, nx, ny, np, nf, nt)

    dimarray = DimArray(
        data=data,
        dims=(x, y, p, f, t),
        name=:intensity,
        metadata=metadata
    )

    # create a DDImage instance.
    return create_ddimage(dimarray)
end
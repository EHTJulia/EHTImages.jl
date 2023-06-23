export save_fits
export save_fits!


"""
    save_fits[!](image::AbstractIntensityImage, filename::AbstractString, idx=(1, 1); fitstype::Symbol=:casa)

Saving the image into a FITS file in a specifed format.

# Arguments
- `image::AbstractIntensityImage`: the input image
- `filename::AbstractString`: the name of the output FITS file
- `idx`: the index of the saved image. Should be (frequency index, time index). Default to `(1,1)`.

# Keywords
- `fitstype::Symbol`: the format type of the output FITS. Availables are `:casa` (CASA compatible).
"""
function save_fits!(image::AbstractIntensityImage, filename::AbstractString, idx=(1, 1); fitstype::Symbol=:casa)
    if fitstype == :casa
        save_fits_casa!(image, filename, idx)
    else
        @throwerror ArgumentError "`fitstype` should be `:casa`."
    end
end


# quick shortcut
save_fits = save_fits!


# saving imagedata in a CASA compatible format
function save_fits_casa!(image::AbstractIntensityImage, filename::AbstractString, idx=[1, 1])
    # size of the image and corresponding coordinates
    nx, ny, np, _ = size(image)
    fidx, tidx = idx

    # Image Metadata
    metadata = image.metadata

    #   quick shortcuts
    obsra = rad2deg(metadata[:xref])
    obsdec = rad2deg(metadata[:yref])
    reffreq = image.f[fidx]
    mjd = image.t[tidx]

    # Open FITS file in the write mode (allowing to overwrite)
    f = FITS(filename, "w")

    # Initialize headers
    header = FITSHeader(["COMMENT"], [NaN], ["This FITS file was created in EHTImages.jl."])

    # Set headers
    #   a quick shortcut
    function set!(header::FITSHeader, keyname::AbstractString, value, comment::AbstractString="")
        header[keyname] = value
        set_comment!(header, keyname, comment)
    end

    # Object Name
    set!(header, "OBJECT", metadata[:source], "The name of the object")

    # RA Axis
    set!(header, "CTYPE1", "RA---SIN",
        "data axis 1: Right Ascenction (RA)"
    )
    set!(header, "CRVAL1", obsra,
        "RA coordinate at the reference pixel")
    set!(header, "CDELT1", -rad2deg(metadata[:dx]),
        "pixel size of the RA axis")
    set!(header, "CRPIX1", metadata[:ixref],
        "refrence pixel of the RA axis")
    set!(header, "CUNIT1", "DEG",
        "unit of CRVAL1 and CDELT1")

    # Dec Axis
    set!(header, "CTYPE2", "DEC--SIN",
        "data axis 2: Declination (DEC)"
    )
    set!(header, "CRVAL2", obsdec,
        "DEC coordinate at the reference pixel")
    set!(header, "CDELT2", rad2deg(metadata[:dy]),
        "pixel size of the DEC axis")
    set!(header, "CRPIX2", metadata[:iyref],
        "refrence pixel of the DEC axis")
    set!(header, "CUNIT2", "DEG",
        "unit of CRVAL2 and CDELT2")

    # Frequency Axis
    set!(header, "CTYPE3", "FREQ",
        "data axis 3: frequency")
    set!(header, "CRVAL3", reffreq,
        "reference frequency")
    set!(header, "CDELT3", 1,
        "bandwidth of the frequency channel")
    set!(header, "CRPIX3", 1,
        "channel of the reference frequency")
    set!(header, "CUNIT3", "HZ",
        "unit of CRVAL3 and CDELT3")

    # Frequency Axis
    set!(header, "CTYPE4", "STOKES",
        "data axis 4: stokes parameters"
    )
    set!(header, "CRVAL4", 1, "")
    set!(header, "CDELT4", 1)
    set!(header, "CRPIX4", 1)
    set!(header, "CUNIT4", "", "Dimensionless")

    # OBS RA and DEC
    set!(header, "OBSRA", obsra, "Reference RA Coordinates in degree")
    set!(header, "OBSDEC", obsdec, "Reference Dec Coordinates in degree")
    set!(header, "FREQ", image.f[fidx], "Reference Frequency in Hz")

    # OBS DATE
    set!(header, "OBSDATE", Dates.format(mjd2datetime(mjd), "yyyy-mm-dd"),
        "Observation Date")
    set!(header, "MJD", mjd, "Modified Julian Date")

    # Instruments
    set!(header, "OBSERVER", metadata[:observer], "Name of the observer")
    set!(header, "TELESCOP", metadata[:instrument], "Name of the observing instrument")

    # Unit of the brightness
    set!(header, "BUNIT", "JY/PIXEL", "Unif of the intensity")

    # Equinox
    set!(header, "RADESYS", uppercase(metadata[:coordsys]), "Coordinate System")
    set!(header, "EQUINOX", metadata[:equinox], "Equinox")

    # Equinox
    set!(header, "PULSETYPE", uppercase(metadata[:pulsetype]), "Type of the pulse function")

    # Write the image with the header.
    write(f, permutedims(reshape(getindex(image.data, :, :, :, idx...), nx, ny, 1, np), (1, 2, 3, 4)), header=header)

    close(f)
end

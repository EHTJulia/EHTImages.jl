export close, close!
export load_image
export open!

"""
    open!(image[, mode])

Load image data from NCDataset specified in the input image object
with the given access mode. If image data are already opened, 
it will close it and reload data again.

# Arguments
- `image::NCImage`:
    The input image object.
- `mode::Symbol=:read`:
    The access mode to NCDataset.
    Available modes are `:read`, `:append`, `:create`.
    See help for `EHTImage.ncdmodes` for details.
"""
function open!(image::NCImage, mode::Symbol=:read)
    # get mode string
    modestr = ncdmodes[mode]

    # check if the file is already opened
    if isopen(image)
        @debug "The input image is already loaded. To be reloaded again."
        close!(image)
    end

    # open NetCDF file
    image.dataset = NCDataset(image.filename, modestr)

    # get the group
    groups = split_group(image.group)
    imds = get_group(image.dataset, groups)

    # load arrays
    image.data = imds[ncd_image_varnames[:image]].var
    image.mjd = imds[ncd_image_varnames[:t]].var
    image.freq = imds[ncd_image_varnames[:f]].var
    image.pol = imds[ncd_image_varnames[:p]].var
    image.metadata = imds.attrib

    return nothing
end

"""
    load_image(filename; [group, mode]) -> NCImage

Load image data from the specified group in the given NetCDF4 file 
with the specified access mode.

# Arguments
- `filename::AbstractString`:
    The input NetCDF4 file.
- `group::AbstractString=EHTImage.ncd_image_defaultgroup`
    The group of the image data in the input NetCDF4 file.
- `mode::Symbol=:read`:
    The access mode to NCDataset.
    Available modes are `:read`, `:append`, `:create`.
    See help for `EHTImage.ncdmodes` for details.
"""
function load_image(
    filename::AbstractString;
    group::AbstractString=ncd_image_defaultgroup,
    mode::Symbol=:read
)::NCImage
    # check modes
    if mode ∉ [:read, :append]
        @throwerror ArgumentError "`mode` should be `:read` or `:append`."
    end

    # generate image object
    image = NCImage(
        filename=filename,
        group=group,
    )

    # load image
    open!(image, mode)

    return image
end

"""
    close!(image::NCImage)

Close the access to the associated NetCDF4 file.
"""
function close!(image::NCImage)
    if isopen(image)
        Base.close(image.dataset)
    end

    return nothing
end

"""
    close(image::NCImage) 

Close the access to the associated NetCDF4 file.
This function is an alias to close!(image).
"""
function Base.close(image::NCImage)
    close!(image)

    return nothing
end

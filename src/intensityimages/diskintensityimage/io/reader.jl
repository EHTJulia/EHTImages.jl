export close, close!
export load_image
export open!

"""
    open!(image[, mode])

Load image data from NCDataset specified in the input image object
with the given access mode. If image data are already opened,
it will close it and reload data again.

# Arguments
- `image::DiskIntensityImage`:
    The input image object.
- `mode::Symbol=:read`:
    The access mode to NCDataset.
    Available modes are `:read`, `:append`, `:create`.
    See help for `EHTImage.ncdmodes` for details.
"""
function open!(image::DiskIntensityImage, mode::Symbol=:read)
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
    image.data = imds[ncd_intensity_varnames[:data]].var
    image.metadata = imds.attrib
    image.t = imds[ncd_intensity_varnames[:t]].var
    image.f = imds[ncd_intensity_varnames[:f]].var
    image.p = imds[ncd_intensity_varnames[:p]].var
    return nothing
end


"""
    load_image(filename; [group, mode]) -> DiskIntensityImage

Load image data from the specified group in the given NetCDF4 file
with the specified access mode.

# Arguments
- `filename::AbstractString`:
    The input NetCDF4 file.
- `group::AbstractString=EHTImage.ncd_intensity_defaultgroup`
    The group of the image data in the input NetCDF4 file.
- `mode::Symbol=:read`:
    The access mode to NCDataset.
    Available modes are `:read`, `:append`, `:create`.
    See help for `EHTImage.ncdmodes` for details.
"""
function load_image(
    filename::AbstractString;
    group::AbstractString=ncd_intensity_defaultgroup,
    mode::Symbol=:read
)::DiskIntensityImage
    # check modes
    if mode ∉ [:read, :append]
        @throwerror ArgumentError "`mode` should be `:read` or `:append`."
    end

    # generate image object
    image = DiskIntensityImage(
        filename=filename,
        group=group,
    )

    # load image
    open!(image, mode)

    return image
end


"""
    close!(image::DiskIntensityImage)

Close the access to the associated NetCDF4 file.
"""
function close!(image::DiskIntensityImage)
    if isopen(image)
        Base.close(image.dataset)
    end

    return nothing
end


"""
    close(image::DiskIntensityImage)

Close the access to the associated NetCDF4 file.
This function is an alias to close!(image).
"""
function Base.close(image::DiskIntensityImage)
    close!(image)

    return nothing
end

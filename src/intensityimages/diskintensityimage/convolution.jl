function convolve(
    image::DiskIntensityImage,
    filename::AbstractString,
    model::AbstractModel;
    mode::Symbol=:create,
    group::AbstractString=ncd_image_defaultgroup,
    ex=SequentialEx()
)
    # create a new file
    newim = save_netcdf(image, filename, mode=mode, group=group)

    # run convolution
    convolve!(newim, model, ex=ex)

    return newim
end


function convolve!(
    image::DiskIntensityImage,
    model::AbstractModel;
    ex=SequentialEx()
)
    # SequentialEx is not available for DiskIntensityImage
    if (ex isa SequentialEx) == false
        @throwerror ArgumentError "NetCDF4 only supports single thread writing. Please use SequentialEx."
    end

    # reopen in :append mode if not writable
    flag = iswritable(image) == false
    if flag
        open!(image, :append)
    end

    convolve_base!(image, model, ex=ex)

    # reopen in :read mode if reopened.
    if flag
        open!(image, :read)
    end

    return nothing
end

function convolve(
    image::NCImage,
    filename::AbstractString,
    model::AbstractModel;
    mode::Symbol=:create,
    group::AbstractString=ncd_image_defaultgroup,
    ex=SequentialEx()
)
    # create a new file
    newim = save_netcdf(image, filename, mode=mode, group=group)

    # open new file in :append mode
    open!(newim, :append)

    # run convolution 
    convolve!(newim, model, ex=ex)

    # reload in :read mode
    open!(newim, :read)

    return newim
end

function convolve!(
    image::NCImage,
    model::AbstractModel;
    ex=SequentialEx()
)
    # SequentialEx is not available for NCImage
    if (ex isa SequentialEx) == false
        @throwerror ArgumentError "NetCDF4 only supports single thread writing. Please use SequentialEx."
    end

    # reopen in :append mode if not writable
    flag = iswritable(image) == false
    if flag
        open!(image, :append)
    end

    convolve!_base!(image, model, ex=ex)

    # reopen in :read mode if reopened.
    if flag
        open!(image, :read)
    end

    return nothing
end
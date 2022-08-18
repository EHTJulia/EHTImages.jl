function convolve!(
    image::NCImage,
    model::AbstractModel;
    ex=SequentialEx()
)
    if (ex isa SequentialEx) == false
        @throwerror ArgumentError "NetCDF4 only supports single thread writing. Please use SequentialEx."
    end

    if iswritable(image) == false
        open!(image, :append)
    end

    convolve_base!(image, model, ex=ex)
    open!(image, :read)
end
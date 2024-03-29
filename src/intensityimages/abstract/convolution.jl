export convolve, convolve!


"""
    $(TYPEDSIGNATURES) -> AbstractIntensityImage

Convolve the input image with a given model, and return
the convolved image.

# Arguments
- `image::AbstractIntensityImage`:
   The input image. It must be not disk-based.
- `model::EHTModels.AbstractModel`:
   The model to be used as the convolution kernel.
- `ex=SequentialEx()`
    An executor of FLoops.jl.
"""
function convolve(
    image::AbstractIntensityImage,
    model::EHTModels.AbstractModel;
    ex=SequentialEx()
)::AbstractIntensityImage
    # check if the input is disk-based or not.
    if isdiskdata(image) == IsDiskData()
        @throwerror ArgumentError "Please use `convolve(image, filename, modelname; keywords)` instead."
    end

    # copy image
    newimage = copy(image)

    # run convolution
    convolve_base!(newimage, model, ex=ex)

    return newimage
end


"""
    $(TYPEDSIGNATURES)

Convolve the input image with a given model.

# Arguments
- `image::AbstractIntensityImage`:
   The input image. It must be not disk-based.
- `model::EHTModels.AbstractModel`:
   The model to be used as the convolution kernel.
- `ex=SequentialEx()`
    An executor of FLoops.jl.
"""
function convolve!(
    image::AbstractIntensityImage,
    model::EHTModels.AbstractModel;
    ex=SequentialEx()
)
    # check if the input image is writable or not.
    if iswritable(image) == false
        @throwerror ArgumentError "Input image is not writable."
    end

    # execute convolution
    convolve_base!(image, model, ex=ex)

    return nothing
end


"""
    $(TYPEDSIGNATURES)

Base function for convolving the input image with a given model.

# Arguments
- `image::AbstractIntensityImage`:
   The input image. It must be not disk-based.
- `model::EHTModels.AbstractModel`:
   The model to be used as the convolution kernel.
- `ex=SequentialEx()`
    An executor of FLoops.jl.
"""
function convolve_base!(
    image::AbstractIntensityImage,
    model::EHTModels.AbstractModel;
    ex=SequentialEx()
)
    # get the number of pixels
    nx, ny, np, nf, nt = size(image)

    # get uv gridend
    ug, vg = get_uvgrid(image, false)

    # mapout kernel
    vkernel = Matrix{ComplexF64}(undef, length(ug), length(vg))
    @floop ex for uidx = 1:nx, vidx = 1:ny
        @inbounds vkernel[uidx, vidx] = conj(visibility_point(model, ug[uidx], vg[vidx]))
    end

    # create fft plan
    fp = plan_fft(image.data[:, :, 1, 1, 1])
    ifp = plan_ifft(complex(image.data[:, :, 1, 1, 1]))

    # exectute fft-based convlution with the kernel
    @floop ex for sidx = 1:np, fidx = 1:nf, tidx = 1:nt
        @inbounds imarr = image.data[:, :, sidx, fidx, tidx]
        @inbounds vim = fp * imarr
        @inbounds vim .*= vkernel
        @inbounds image.data[:, :, sidx, fidx, tidx] = real(ifp * vim)
    end
end

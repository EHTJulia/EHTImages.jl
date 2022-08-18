export convolve, convolve!

function convolve(
    image::AbstractEHTImage,
    model::EHTModel.AbstractModel;
    ex=SequentialEx()
)::AbstractEHTImage
    imageout = copy(image)
    convolve!(imageout, model, ex)
    return imageout
end

function convolve!(
    image::AbstractEHTImage,
    model::EHTModel.AbstractModel;
    ex=SequentialEx()
)
    if iswritable(image) == false
        @throwerror ArgumentError "Input image is not writable."
    end

    convolve_base!(image, model, ex=ex)
end

function convolve_base!(
    image::AbstractEHTImage,
    model::EHTModel.AbstractModel;
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
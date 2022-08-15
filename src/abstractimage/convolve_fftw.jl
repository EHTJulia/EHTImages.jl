export convolve, convolve_gauss

function convolve!(
    image::AbstractEHTImage,
    model::AbstractModel
)
    if iswritable(image) == false
        @error "Input image is not writable. Please re-open file on a writable mode."
    end

    # get the number of pixels
    nx, ny, np, nf, nt = size(image)

    # get uv gridend
    ug, vg = get_uvgrid(image, false)

    # mapout kernel
    vkernel = Matrix{ComplexF64}(undef, length(ug), length(vg))
    @inbounds Threads.@threads for (uidx, vidx) in collect(Iterators.product(1:nx, 1:ny))
        vkernel[uidx, vidx] = conj(visibility_point(model, ug[uidx], vg[vidx]))
    end

    # create fft plan
    fp = plan_fft(image.data[:, :, 1, 1, 1])
    ifp = plan_ifft(complex(image.data[:, :, 1, 1, 1]))

    @inbounds Threads.@threads for (sidx, fidx, tidx) in collect(Iterators.product(1:np, 1:nf, 1:nt))
        imarr = image.data[:, :, sidx, fidx, tidx]
        vim = fp * imarr
        vim .*= vkernel
        image.data[:, :, sidx, fidx, tidx] = real(ifp * vim)
    end
end

function convolve_gauss!(
    image::AbstractEHTImage,
    majfwhm::Number;
    minfwhm::Number=-1,
    angle::Number=0,
    angunit=μas,
    angscale::Number=1
)
    if majsize <= 0
        @error "majsize must be positive"
    end

    if minsize > majsize
        @error "majsize must be larger than minsize"
    end

    # conversion factor
    aconv = unitconv(rad, angunit) * angscale
    majsize = majfwhm * aconv
    if minfwhm < 0
        minsize = majsize
    else
        minsize = minfwhm * aconv
    end

    # generate geometric model to convolve
    model = Gaussian()
    model = stretched(model, majsize, minsize)
    model = rotated(model, deg2rad * angle)

    convolve!(image, model)
end

#function convolve_geomodel(image::Image, geomodel::GeometricModel)
#    newimage = copy(image)
#    convolve_geomodel!(newimage, geomodel)
#    return newimage
#end
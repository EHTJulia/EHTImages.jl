function convolve_geomodel!(image::Image, geomodel::GeometricModel)
    # get the number of pixels
    nx, ny, np, nf, nt = size(image.da)

    # get uv gridend
    ug, vg = get_uvgrid(image, false)

    # mapout kernel
    vkernel = Matrix{ComplexF64}(undef, length(ug), length(vg))
    @inbounds Threads.@threads for (uidx, vidx) in collect(Iterators.product(1:nx, 1:ny))
        vkernel[uidx, vidx] = conj(eval_vis(cg, ug[uidx], vg[vidx]))
    end

    # create fft plan
    fp = plan_fft(image.da.data[:, :, 1, 1, 1])
    ifp = plan_ifft(complex(image.da.data[:, :, 1, 1, 1]))

    @inbounds Threads.@threads for (sidx, fidx, tidx) in collect(Iterators.product(1:np, 1:nf, 1:nt))
        imarr = image.da.data[:, :, sidx, fidx, tidx]
        vim = fp * imarr
        vim .*= vkernel
        image.da.data[:, :, sidx, fidx, tidx] = real(ifp * vim)
    end
end

function convolve_geomodel(image::Image, geomodel::GeometricModel)
    newimage = copy(image)
    convolve_geomodel!(newimage, geomodel)
    return newimage
end
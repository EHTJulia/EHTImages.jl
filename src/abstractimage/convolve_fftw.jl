export convolve!, convolve_gauss!

function convolve!(
    image::AbstractEHTImage,
    model::AbstractModel,
    ex=SequentialEx()
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
    @floop ex for (uidx, vidx) in collect(Iterators.product(1:nx, 1:ny))
        vkernel[uidx, vidx] = conj(visibility_point(model, ug[uidx], vg[vidx]))
    end

    # create fft plan
    fp = plan_fft(image.data[:, :, 1, 1, 1])
    ifp = plan_ifft(complex(image.data[:, :, 1, 1, 1]))

    # exectute fft-based convlution with the kernel
    @floop ex for (sidx, fidx, tidx) in collect(Iterators.product(1:np, 1:nf, 1:nt))
        imarr = image.data[:, :, sidx, fidx, tidx]
        vim = fp * imarr
        vim .*= vkernel
        image.data[:, :, sidx, fidx, tidx] = real(ifp * vim)
    end
end


"""
    convolve_gauss!(image, θmaj, [θmin, ϕ]; [θunit, ϕunit])

- `image::AbstractEHTImage`:
    The input image.
- `θmaj::Real`:
    The major-axis FWHM size of the Gaussian.
- `θmin::Real`:
    The minor-axis FWHM size of the Gaussian. If `θmin < 0`, then
    `θmin = θmax` (i.e. circular Gaussian). Default to -1.
- `ϕ::Real`:
    The position angle of the Gausian. Default to 0.
- `θunit, ϕunit::Unitful`:
    The unit for `θmaj` & `θmin` and `ϕ`, respectively. 
    Default: `θunit=rad` and `ϕ=deg`.
"""
function convolve_gauss!(
    image::AbstractEHTImage,
    θmaj::Real,
    θmin::Real=-1,
    ϕ::Real=0;
    θunit=rad,
    ϕunit=deg,
    ex=SequentialEx()
)
    if iswritable(image) == false
        @error "Input image is not writable. Please re-open file on a writable mode."
    end

    if θmaj <= 0
        @error "θmaj must be positive"
    end

    if θmin > θmaj
        @error "θmin must be larger than θmaj"
    end

    # Conversion factor for the angular scales
    fθ_rad = unitconv(θunit, rad) * σ2fwhm

    # scale major axis and minor axis sizes
    θmaj_rad = θmaj * fθ_rad
    if θmin < 0
        θmin_rad = θmaj_rad
    else
        θmin_rad = θmin * fθ_rad
    end

    # Unit conversion for the position angle
    if ϕunit == rad
        ϕ_rad = ϕ
    elseif ϕunit == deg
        ϕ_rad = deg2rad(ϕ)
    else
        ϕ_rad = ϕ * unitconv(ϕunit, rad)
    end

    # generate geometric model to convolve
    model = Gaussian()
    model = stretched(model, θmaj_rad, θmin_rad)
    model = rotated(model, ϕ_rad)

    convolve!(image, model, ex)
end

#function convolve_geomodel(image::Image, geomodel::GeometricModel)
#    newimage = copy(image)
#    convolve_geomodel!(newimage, geomodel)
#    return newimage
#end
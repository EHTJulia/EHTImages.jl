export AbstractEHTImage


"""
    AbstractEHTImage
"""
abstract type AbstractEHTImage end

function get_bconv(
    image::AbstractEHTImage;
    fluxunit::Union{Unitful.Quantity,Unitful.Units,String}=Jy,
    saunit::Union{Unitful.Quantity,Unitful.Units,String}="pixel")

    # Get scaling for the flux unit
    if fluxunit isa String
        funit = get_unit(fluxunit)
    else
        funit = fluxunit
    end

    if dimension(funit) == dimension(K)
        # pixel size in radian
        dx = image.metadata["dx"]
        dy = image.metadata["dy"]

        # frequency in Hz
        nu = image.freq # freq in Hz

        # conversion factor from Jy to K
        Jy2K = c^2 / (2 * kB) / dx / dy * 1e-26 ./ nu .^ 2
        return Jy2K * unitconv(K, funit)
    end

    fluxconv = unitconv(Jy, funit)

    # Get scaling for the solid angles
    if saunit isa String
        saunit_low = lowercase(saunit)
        if startswith(saunit_low, 'p')
            saconv = 1
        elseif startswith(saunit_low, 'b')
            # pixel size in radian
            dx = image.metadata["dx"]
            dy = image.metadata["dy"]

            # beam size in radian
            bmaj = image.metadata["beam_maj"]
            bmin = image.metadata["beam_min"]

            pixelsa = dx * dy
            beamsa = bmaj * bmin * pi / (4 * log(2))
            saconv = pixelsa / beamsa
        else
            saconv = unitconv(rad^2, get_unit(saunit))
        end
    elseif saunit isa Union{Unitful.Quantity,Unitful.Units}
        saconv = unitconv(rad^2, saunit)
    else
        error("saunit must be 'pixel', 'beam', or units for solid angles")
    end

    return fluxconv / saconv
end

function get_uvgrid(image::AbstractEHTImage, dofftshift::Bool=true)
    # nx, ny
    nx, ny = size(image.da)[1:3]

    # dx, dy
    dxrad = image.metadata["dx"]
    dyrad = image.metadata["dy"]

    ug = fftfreq(nx, -1 / dxrad)
    vg = fftfreq(ny, 1 / dyrad)

    if dofftshift
        ug = fftshift(ug)
        vg = fftshift(vg)
    end

    return (ug, vg)
end
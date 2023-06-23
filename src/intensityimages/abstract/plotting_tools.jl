export get_bconv
export get_xygrid
export get_uvgrid

"""
    get_bconv

get a conversion factor from Jy/pixel (used in AbstractIntensityImage.data)
to an arbitrary unit for the intensity. fluxunit is for the unit of
the flux density (e.g. Jy, mJy, μJy) or brightness temperture (e.g. K),
while saunit is for the unit of the solid angle (pixel, beam, mas, μJy).
"""
function get_bconv(
    image::AbstractIntensityImage;
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
        dx = image.metadata[:dx]
        dy = image.metadata[:dy]

        # frequency in Hz
        nu = image.f # frequency in Hz

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
            dx = image.metadata[:dx]
            dy = image.metadata[:dy]

            # beam size in radian
            bmaj = image.metadata[:beam_maj]
            bmin = image.metadata[:beam_min]

            pixelsa = dx * dy
            beamsa = bmaj * bmin * pi / (4 * log(2))
            saconv = pixelsa / beamsa
        else
            saconv = unitconv(rad^2, get_unit(saunit))
        end
    elseif saunit isa Union{Unitful.Quantity,Unitful.Units}
        saconv = unitconv(rad^2, saunit)
    else
        @throwerror ArgumentError "saunit must be 'pixel', 'beam', or units for solid angles"
    end

    return fluxconv / saconv
end

"""
    get_xygrid

Returning 1-dimensional StepRange objects for the grids along with x and y axis in the given angular unit specified by angunit.
"""
function get_xygrid(
    image::AbstractIntensityImage,
    angunit::Union{Unitful.Quantity,Unitful.Units,String}=rad)
    return get_xygrid(image.metadata, angunit)
end

"""
    get_uvgrid(image, dofftshift=true)

returning u and v grids corresponding to the image field of view and pixel size.
"""
function get_uvgrid(image::AbstractIntensityImage, dofftshift::Bool=true)
    return get_uvgrid(image.metadata, dofftshift)
end
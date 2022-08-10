export AbstractEHTImage
export ISDiskImage, NotDiskImage, isdiskimage

export get_xygrid
export get_bconv
export get_uvgrid

"""
    AbstractEHTImage

* Mandatory attributes
    data: 5 dimensional array [x, y, polarization, frequency, time]
    freq: frequency in GHz (coordinate for frequency axis)
    mjd: modified Julian dates (coordinate for time axis)
    pol: polarization codes in string (coordinate for polarization axis)
    metadata: Dict-like object to stock metadata  
"""
abstract type AbstractEHTImage{T,N} <: AbstractArray{T,N} end

"""
AbstractEHTImage works as an Abstract Array. To make it, 
each image type needs to have four following methods.
(see: Julia Documentation for "Interfaces")

   - size: returning a tuple containing the dimension of AbstractEHTimage.data
   - getindex: scalar or vector indexing returning AbstractEHTimage
   - setindex!: scalar or vector indexing assignment
   - firstindex: returning the first index, used in X[begin]
   - lastindex: returning the last index, used in X[end]
"""

function size(image::AbstractEHTImage)
    return Base.size(image.data)
end

function getindex end

function setindex!(image::AbstractEHTImage, value, key...)
    Base.setindex!(image.data, value, key...)
end

function firstindex(image::AbstractEHTImage, args...)
    return Base.firstindex(image.data, args...)
end

function lastindex(image::AbstractEHTImage, args...)
    return Base.lastindex(image.data, args...)
end

"""
AbstractEHTImage works as an Abstract Array. 
"""

struct IsDiskImage end

struct NotDiskImage end

function isdiskimage end

isdiskimage(image::AbstractEHTImage) = IsDiskImage()

function get_xygrid(image::AbstractEHTImage, angunit::Union{Unitful.Quantity,Unitful.Units,String}=rad)
    # Get scaling for the flux unit
    if angunit isa String
        aunit = get_unit(angunit)
    else
        aunit = angunit
    end

    aunitconv = unitconv(rad, aunit)
    dx = image.metadata["dx"]
    dy = image.metadata["dy"]
    ixref = image.metadata["ixref"]
    iyref = image.metadata["iyref"]
    nx, ny, _ = size(image)

    xg = -dx * ((i-ixref):1:(nx-ixref))
    yg = dy * ((i-iyref):1:(ny-iyref))

    return (xg, yg)
end

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
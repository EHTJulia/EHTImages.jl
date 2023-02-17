export AbstractEHTImage
export IsDiskData, NotDiskData, isdiskdata
export isopen, iswritable
export get_xygrid, get_uvgrid
export get_bconv

"""
    AbstractEHTImage

* Mandatory attributes
    data: 5 dimensional array [x, y, polarization, frequency, time]
    freq: 1 dimensional array for frequency in GHz (coordinate for frequency axis)
    mjd: 1 dimensional array for modified Julian dates (coordinate for time axis)
    pol: 1 dimensional array for polarization codes in string (coordinate for polarization axis)
    metadata: Dict-like object to stock metadata  

* Mandatory functions
    isdiskimage:
        return IsDiskImage if data are on a file in the disk (e.g. NetCDF file). 
        otherwise return NotDiskImage.
"""
#abstract type AbstractEHTImage{T,N} <: AbstractArray{T,N} end
abstract type AbstractEHTImage end

"""
AbstractEHTImage works as an Abstract Array-ish. To make it, 
each image type needs to have four following methods.
(see: Julia Documentation for "Interfaces")

   - size: returning a tuple containing the dimension of AbstractEHTimage.data
   - getindex: scalar or vector indexing
   - setindex!: scalar or vector indexing assignment
   - firstindex: returning the first index, used in X[begin]
   - lastindex: returning the last index, used in X[end]
"""
# You wouldn't need to overwrite the following 5 methods.
Base.size(image::AbstractEHTImage, args...) = Base.size(image.data, args...)
Base.setindex!(image::AbstractEHTImage, value, key...) = Base.setindex!(image.data, value, key...)
Base.firstindex(image::AbstractEHTImage, args...) = Base.firstindex(image.data, args...)
Base.lastindex(image::AbstractEHTImage, args...) = Base.lastindex(image.data, args...)
Base.IndexStyle(image::AbstractEHTImage) = Base.IndexCartesian()

# getindex would need to be overwritten to return an instance of sliced AbstractEHTImage object
# rather than slided array of AbstractEHTImage.data
Base.getindex(image::AbstractEHTImage, args...) = Base.getindex(image.data, args...)

"""
    DataStorageType

Internal type for specifying the nature of the location of data.
"""
abstract type DataStorageType end


"""
    $(TYPEDEF)

Defines a trait that a states that data is disk based.
"""
struct IsDiskData <: DataStorageType end


"""
    $(TYPEDEF)

Defines a trait that a states that data is memory based.
"""
struct NotDiskData <: DataStorageType end

"""
    isdiskdata(data)

Determines whether the data is disk-based or memory-based.
Return IsDiskData() if data is disk-based,
while return NotDiskData() if data is memory-based.
"""
@inline isdiskdata(::AbstractEHTImage) = IsDiskData()

"""
    isopen(image::AbstractEHTImage)

Check if data is accessible, return true for accessible data
and false if data is not accessible. This is relevant if
image is based on disk data.
"""
Base.isopen(::AbstractEHTImage) = false

"""
    isopen(image::AbstractEHTImage)

Check if data is accessible, return true for accessible data
and false if data is not accessible. This is relevant if
image is based on disk data.
"""
Base.iswritable(::AbstractEHTImage) = false

"""
    get_xygrid

Returning 1-dimensional StepRange objects for the grids along with x and y axis in the given angular unit specified by angunit.
"""
function get_xygrid(
    image::AbstractEHTImage,
    angunit::Union{Unitful.Quantity,Unitful.Units,String}=rad)
    return get_xygrid(image.metadata, angunit)
end

"""
    get_bconv

get a conversion factor from Jy/pixel (used in AbstractEHTImage.data)
to an arbitrary unit for the intensity. fluxunit is for the unit of
the flux density (e.g. Jy, mJy, μJy) or brightness temperture (e.g. K),
while saunit is for the unit of the solid angle (pixel, beam, mas, μJy).
"""
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
        dx = image.metadata[:dx]
        dy = image.metadata[:dy]

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
    get_uvgrid(image, dofftshift=true)

returning u and v grids corresponding to the image field of view and pixel size.
"""
function get_uvgrid(image::AbstractEHTImage, dofftshift::Bool=true)
    return get_uvgrid(image.metadata, dofftshift)
end
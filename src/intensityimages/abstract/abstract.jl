export AbstractIntensityImage
export get_xygrid
export get_uvgrid
export get_fov

"""
    $(TYPEDEF)

This defines a basic interface for intensity images. It is a subtype of `AbstractImageDataSet`.

# Mandatory fields
- `data`: 5 dimensional array for intensity [x, y, polarization, frequency, time]
- `p`: 1 dimensional array for polarization codes in string (coordinate for polarization axis)
- `f`: 1 dimensional array for frequency in Hz (coordinate for frequency axis)
- `t`: 1 dimensional array for time in modified Julian dates (coordinate for time axis)
- `metadata`: Dict-like object to stock metadata

# Mandatory methods need to be defined.
See also documentations for `AbstractImageDataSet`.
"""
abstract type AbstractIntensityImage <: AbstractImageDataSet end


"""
    get_xygrid(::AbstractIntensityImage, angunit) --> Tuple{StepRangeLen, StepRangeLen}
    get_xygrid(metadata, angunit) --> Tuple{StepRangeLen, StepRangeLen}

Returning 1-dimensional StepRangeLen objects for the grids along with x and y axis
in the given angular unit specified by angunit. The input could be a intensity image data set or
its metadata.

# Arguments
- `angunit::Union{Unitful.Quantity,Unitful.Units,String}=rad`: Angular units of the output pixel grids.
"""
function get_xygrid(
    image::AbstractIntensityImage,
    angunit::Union{Unitful.Quantity,Unitful.Units,String}=rad)
    return get_xygrid(image.metadata, angunit)
end


"""
    get_uvgrid(image::AbstractIntensityImage, dofftshift=true)
    get_uvgrid(metadata, dofftshift::Bool=true)

returning u and v grids corresponding to the image field of view and pixel size.
"""
function get_uvgrid(image::AbstractIntensityImage, dofftshift::Bool=true)
    return get_uvgrid(image.metadata, dofftshift)
end


"""
    get_fov(::AbstractIntensityImage, angunit) --> Tuple
    get_fov(metadata, angunit) --> Tuple

Returning the field of the view for the grids along with x and y axis
in the given angular unit specified by angunit. The input could be a intensity image data set or
its metadata.

# Arguments
- `angunit::Union{Unitful.Quantity,Unitful.Units,String}=rad`: Angular units of the output pixel grids.
"""
function get_fov(
    image::AbstractIntensityImage,
    angunit::Union{Unitful.Quantity,Unitful.Units,String}=rad)
    return get_fov(image.metadata, angunit)
end

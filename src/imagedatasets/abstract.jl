export AbstractImageDataSet
export isdiskdata


"""
    $(TYPEDEF)

The abstract type for image data sets handled in this module.
AbstractImageDataSet works as an Abstract Array-ish. To make it,
each image type needs to have four following methods.
(see: Julia Documentation for "Interfaces")

# Mandatory Methods that need to be defined
- `default_metadata`:
    Return the default metadata for the image data set.
- `isdiskdata`: 
    Determines whether the data is disk-based or memory-based.
    Return `IsDiskData()` if data is disk-based,
    while return `NotDiskData()` if data is memory-based.
- `isopen`:
    Check if data is accessible, return true for accessible data
    and false if data is not accessible. This is relevant if
    image is based on disk data.
- `iswritable`:
    Check if data is accessible, return `true` for accessible data
    and `false` if data is not accessible. This is relevant if
    image is based on disk data.

# Methods provided
- `size`: returning a tuple containing the dimension of `AbstractImageDataSet.data`
- `getindex`: scalar or vector indexing
- `setindex!`: scalar or vector indexing assignment
- `firstindex`: returning the first index, used in `X[begin]`
- `lastindex`: returning the last index, used in `X[end]`
- `IndexStyle`: returning the index style
"""
abstract type AbstractImageDataSet end


# You wouldn't need to overwrite the following 5 methods.
@inline Base.size(image::AbstractImageDataSet, args...) = Base.size(image.data, args...)
@inline Base.setindex!(image::AbstractImageDataSet, value, key...) = Base.setindex!(image.data, value, key...)
@inline Base.firstindex(image::AbstractImageDataSet, args...) = Base.firstindex(image.data, args...)
@inline Base.lastindex(image::AbstractImageDataSet, args...) = Base.lastindex(image.data, args...)
@inline Base.IndexStyle(::AbstractImageDataSet) = Base.IndexCartesian()

# getindex would need to be overwritten to return an instance of sliced AbstractImageDataSet object
# rather than slided array of AbstractImageDataSet.data
@inline Base.getindex(image::AbstractImageDataSet, args...) = Base.getindex(image.data, args...)


"""
    $(TYPEDSIGNATURES)

Determines whether the data is disk-based or memory-based.
Return `IsDiskData()` if data is disk-based,
while return `NotDiskData()` if data is memory-based.
"""
@inline isdiskdata(::AbstractImageDataSet) = IsDiskData()


"""
    $(TYPEDSIGNATURES)

Check if data is accessible, return `true` for accessible data
and `false` if data is not accessible. This is relevant if
image is based on disk data.
"""
@inline Base.isopen(::AbstractImageDataSet) = false


"""
    $(TYPEDSIGNATURES)

Check if data is accessible, return `true` for accessible data
and `false` if data is not accessible. This is relevant if
image is based on disk data.
"""
@inline Base.iswritable(::AbstractImageDataSet) = false


"""
    $(FUNCTIONNAME)(::Type{<:AbstractImageDataSet}) -> OrderedDict{Symbol, Any}
    $(FUNCTIONNAME)(::AbstractImageDataSet) -> OrderedDict{Symbol, Any}

Return default metadata for the image data set.
"""
function default_metadata(::Type{<:AbstractImageDataSet}) end
default_metadata(image::AbstractImageDataSet) = default_metadata(typeof(image))
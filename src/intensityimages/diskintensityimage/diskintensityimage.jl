export DiskIntensityImage

"""
    $(TYPEDEF)

A data type for five dimensional images of which data are all stored in disk using
the NetCDF4 format. This format relies on `NCDatasets` to provide an easy access of data
through many useful methods in the `NCDatasets` package.
Note that this data type could be either mutable or immutable depending on the access mode
to the NetCDF4 file.

$(TYPEDFIELDS)
"""
@with_kw mutable struct DiskIntensityImage <: AbstractIntensityImage
    "name of the corresponding NetCDF4 file"
    filename = nothing
    "group name of the corresponding image data set"
    group = nothing
    "five dimensional intensity disbrituion."
    data = nothing
    "metadata."
    metadata = nothing
    "polarization code, giving the parization axis (`:p`)."
    t = nothing
    "central frequency in Hz, giving the frequency axis (`:f`)."
    f = nothing
    "central modified Julian date, giving the time axis (`:t`)."
    p = nothing
    dataset = nothing
end


# DiskIntensityImage is a disk-based image data
isdiskdata(::DiskIntensityImage) = IsDiskData()


# This is a function to check if the image is opened.
function Base.isopen(image::DiskIntensityImage)::Bool
    if isnothing(image.dataset)
        return false
    end

    if image.dataset.ncid < 0
        return false
    else
        return true
    end
end


# This is a function to check if the image is writable.
function Base.iswritable(image::DiskIntensityImage)::Bool
    if isopen(image)
        return image.dataset.iswritable
    else
        return false
    end
end


# raise error for copy
function Base.copy(::DiskIntensityImage)::Bool
    @throwerror ArgumentError "Since DiskIntensityImage is disk-based, copy is not available. Use save_netcdf instead."
end

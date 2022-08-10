export NCDImage
export isopen

@with_kw mutable struct NCImage{T,N} <: AbstractEHTImage{T,N}
    filename = nothing
    dataset = nothing
    group = nothing
    data = nothing
    mjd = nothing
    freq = nothing
    metadata = nothing
end

# NCImage is a disk-based image data
isdiskimage(image::NCImage) = IsDiskImage()

function isopen(image::NCImage)::Bool
    if isnothing(image.dataset)
        return false
    end

    if image.dataset.ncid < 0
        return false
    else
        return true
    end
end
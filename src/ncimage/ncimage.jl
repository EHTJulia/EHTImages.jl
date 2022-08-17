export NCImage

#@with_kw mutable struct NCImage{T,N} <: AbstractEHTImage{T,N}
@with_kw mutable struct NCImage <: AbstractEHTImage
    filename = nothing
    group = nothing
    data = nothing
    mjd = nothing
    freq = nothing
    pol = nothing
    metadata = nothing
    dataset = nothing
end
#NCImage(Args...) = NCImage{Float64,5}(Args...)

# NCImage is a disk-based image data
isdiskdata(image::NCImage) = IsDiskData()

#@inline function Base.getindex(image::NCImage, I...)
#end

# This is a function to check if the image is opened.
function Base.isopen(image::NCImage)::Bool
    if isnothing(image.dataset)
        return false
    end

    if image.dataset.ncid < 0
        return false
    else
        return true
    end
end

function Base.iswritable(image::NCImage)::Bool
    if isopen(image)
        return image.dataset.iswritable
    else
        return false
    end
end
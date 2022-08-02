export NCDImage
export isopen

@with_kw mutable struct NCImage <: AbstractEHTImage
    filename = nothing
    dataset = nothing
    group = nothing
    data = nothing
    mjd = nothing
    freq = nothing
    metadata = nothing
end

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
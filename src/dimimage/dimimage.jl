# Default Image Data (all images are in memory)
mutable struct DimImage <: AbstractEHTImage
    da::DimArray{Float64,5}
end

function copy(image::DimImage)
    return DimImage(Base.copy(image.da))
end
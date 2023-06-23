export add!


function Base.map!(
    image::AbstractIntensityImage,
    model::EHTModels.AbstractModel;
    ex=SequentialEx()
)
    # get the number of pixels
    nx, ny, np, nf, nt = size(image)

    # get xy grid
    xg, yg = get_xygrid(image)

    # grid size
    dxdy = image.metadata[:dx] * image.metadata[:dy]

    # mapout kernel
    imarray = Matrix{Float64}(undef, length(xg), length(yg))
    @floop ex for xidx = 1:nx, yidx = 1:ny
        @inbounds image.data[xidx, yidx, :, :, :] .= intensity_point(model, xg[xidx], yg[yidx]) * dxdy
    end
end


function add!(
    image::AbstractIntensityImage,
    model::EHTModels.AbstractModel;
    ex=SequentialEx()
)
    # get the number of pixels
    nx, ny, np, nf, nt = size(image)

    # get xy grid
    xg, yg = get_xygrid(image)

    # grid size
    dxdy = image.metadata[:dx] * image.metadata[:dy]

    # mapout kernel
    imarray = Matrix{Float64}(undef, length(xg), length(yg))
    @floop ex for xidx = 1:nx, yidx = 1:ny
        @inbounds image.data[xidx, yidx, :, :, :] .+= intensity_point(model, xg[xidx], yg[yidx]) * dxdy
    end
end

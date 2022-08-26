export load

"""
    load(image::NCImage) --> DDImage
    
Load image data from the input disk image to memory. 

# Arguments
- `image::NCImage`: Input NCImage. 
"""
function load(image::NCImage)::DDImage
    # Open the input image in read mode
    if isopen(image) == false
        open!(image, :read)
    end

    # Load metadata
    metadata = default_metadata(NCImage())
    for key in keys(image.metadata)
        skey = Symbol(key)
        @show metadata[skey]
        @show image.metadata[skey]
        metadata[skey] = image.metadata[skey]
    end

    # define x, y grids
    xg, yg = get_xygrid(metadata)
    x = Dim{:x}(-dx * ((1-ixref):1:(nx-ixref)))
    y = Dim{:y}(+dy * ((1-iyref):1:(ny-iyref)))

    # define other axises
    p = Dim{:p}(image.pol[:])
    f = Dim{:f}(image.freq[:])
    t = Dim{:t}(image.mjd[:])

    # create DimArray data
    darr = DimArray(
        data=image.data[:, :, :, :, :],
        dims=(x, y, p, f, t),
        name=:intensity,
        metadata=metadata
    )

    # create a DDImage instance.
    ddimage = DDImage(
        dimarray=darr,
        metadata=darr.metadata,
        data=darr.data,
        pol=darr.dims[3].val.data,
        freq=darr.dims[4].val.data,
        mjd=darr.dims[5].val.data
    )

    return ddimage
end
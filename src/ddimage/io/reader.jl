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
        metadata[skey] = image.metadata[skey]
    end

    # define x, y grids
    xg, yg = get_xygrid(metadata)
    x = Dim{:x}(xg)
    y = Dim{:y}(yg)

    # define other axises
    p = Dim{:p}(image.pol[:])
    f = Dim{:f}(image.freq[:])
    t = Dim{:t}(image.mjd[:])

    # create DimArray data
    dimarray = DimArray(
        data=image.data[:, :, :, :, :],
        dims=(x, y, p, f, t),
        name=:intensity,
        metadata=metadata
    )

    # create a DDImage instance.
    return create_ddimage(dimarray)
end
export load

"""
    load(image::NCImage) --> DDImage

Load image data from the input disk image to memory.

# Arguments
- `image::NCImage`: Input NCImage.
"""
function load(image::DiskIntensityImage)::IntensityImage
    # Open the input image in read mode
    if isopen(image) == false
        open!(image, :read)
    end

    # Load metadata
    metadata = default_metadata(AbstractIntensityImage)
    for key in keys(image.metadata)
        skey = Symbol(key)
        metadata[skey] = image.metadata[skey]
    end

    # get the size of the image
    nx, ny, np, nf, nt = size(image)

    # define dimensions
    dimx = Dim{:x}(1:nx)
    dimy = Dim{:y}(1:ny)
    dimp = Dim{:p}(1:np)
    dimf = Dim{:f}(1:nf)
    dimt = Dim{:t}(1:nt)

    # create DimArray data
    intensity = DimArray(
        data=image.data[:, :, :, :, :],
        dims=(dimx, dimy, dimp, dimf, dimt),
        name=:intensity,
    )
    polarization = DimArray(
        data=image.p[:],
        dims=(dimp,),
        name=:polarization
    )
    frequency = DimArray(
        data=image.f[:],
        dims=(dimf,),
        name=:frequency
    )
    time = DimArray(
        data=image.t[:],
        dims=(dimt,),
        name=:time
    )
    dimstack = DimStack(
        (intensity, polarization, frequency, time),
        metadata=metadata
    )

    # create an `IntensityImage` instance.
    return IntensityImage(dimstack)
end

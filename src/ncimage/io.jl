export open_image
export open!
export close!, close

function open!(image::NCImage; mode="r", args...)
    # check if the file is already opened
    if isopen(image)
        close!(image)
    end

    # open NetCDF file
    image.dataset = NCDataset(image.filename, mode, args...)

    # open subdataset
    groups = get_groups(image.group)
    imds = get_subdataset(image.dataset, groups)

    # reload arrays
    image.data = imds["image"].var
    image.mjd = imds["mjd"].var
    image.freq = imds["freq"].var
    image.metadata = imds.attrib
end

function close!(image::NCImage)
    if isopen(image)
        Base.close(image.dataset)
    end
end

function close(image::NCImage)
    close!(image)
end

function open_image(
    filename::AbstractString;
    mode::AbstractString="r",
    group::AbstractString="image",
    args...
)::NCImage
    # genrate image object
    image = NCImage(
        filename=filename,
        group=group,
    )

    # load image
    open!(image, mode=mode, args...)
    return image
end

function get_groups(group::AbstractString)::Vector{String}
    groups = splitpath(group)
    groups = deleteat!(groups, findall(x -> x == "/", groups))
    groups = deleteat!(groups, findall(x -> x == "", groups))
    return groups
end

function get_subdataset(dataset::NCDataset, groups)::NCDataset
    curds = dataset
    if length(groups) > 0
        for group in groups
            curds = curds.group[group]
        end
    end
    return curds
end

function gen_subdataset(dataset::NCDataset, groups)::NCDataset
    ds = dataset
    if length(groups) > 0
        for group in groups
            defGroup(ds, group)
            ds = ds.group[group]
        end
    end
    return ds
end
export concat, append

"""
    concat(dataset1::DimStack, dataset2::DimStack)
"""
function concat(dataset1::DimStack, dataset2::DimStack)
    keys1 = keys(dataset1)
    keys2 = keys(dataset2)
    ds = DimStack(
        [dataset1[key] for key in keys1 if key ∉ keys2]...,
        [dataset2[key] for key in keys2]...,
    )
    return ds
end

function append(ds::DimStack, array::DimArray)
    name = array.name
    key_list = keys(ds)
    outds = DimStack(
        [ds[key] for key in key_list if key != name]...,
        array
    )
    return outds
end

function Base.append!(ds::DimStack, array::DimArray)
    ds = append(ds, array)
end
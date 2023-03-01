export concat, append

"""
    concat(dataset1::DimStack, dataset2::DimStack)

Concatanate two DimStack data sets. If keys are duplicated, dimarrays of dataset1
will be overwritten.
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

"""
    append(dataset::DimStack, array::DimArray)

Append a DimArray data into the given DimStack data set.
"""
function append(ds::DimStack, array::DimArray)
    name = array.name
    key_list = keys(ds)
    outds = DimStack(
        [ds[key] for key in key_list if key != name]...,
        array
    )
    return outds
end

"""
    Base.append!(dataset::DimStack, array::DimArray)

Append a DimArray data into the given DimStack data set.
"""
function Base.append!(ds::DimStack, array::DimArray)
    ds = append(ds, array)
end
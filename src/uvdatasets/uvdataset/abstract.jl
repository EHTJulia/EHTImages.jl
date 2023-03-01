export UVDataSet
export compute_ν, compute_ν!
export compute_uvw, compute_uvw!

struct UVDataSet <: AbstractUVDataSet
    datasets::OrderedDict
    metadata::OrderedDict
end

const uvdataset_metadata_default = (
    format="EHT UVDATA NetCDF4 Format",
    version=v"0.1.0",
    source="Nameless Source",
    instrument="Nameless Instrument",
    observer="Nameless Observer",
    coordsys="icrs",
    equinox=-1,
    ra=0.0,
    dec=0.0,
    radecunit="rad"
)

# Quick short cuts
Base.keys(uvd::UVDataSet) = keys(uvd.datasets)
Base.getindex(uvd::UVDataSet, key::Symbol) = getindex(uvd.datasets, key)
Base.setindex!(uvd::UVDataSet, val, key::Symbol) = setindex!(uvd.datasets, val, key)
Base.show(io::IO, uvdata::UVDataSet) = print(io,
    "UVDataSet including ", length(uvdata.datasets), " Datasets\n",
    ["  :" * string(key) * "\n" for key in keys(uvdata)]...
)

# copy
function Base.copy(uvd::UVDataSet)
    return UVDataSet(
        copy(datasets),
        copy(metadata)
    )
end

# compute frequency
function compute_ν(ds::DimStack)
    c, s, _ = dims(ds)
    nch, nspw, _ = size(ds)

    ν = zeros(nch, nspw)
    ch = collect(0:(nch-1))
    for ispw in 1:nspw
        νspw = ds[:νspw].data[ispw]
        sideband = ds[:sideband].data[ispw]
        Δνch = ds[:Δνch].data[ispw]
        ν[:, ispw] .= νspw .+ sideband .* Δνch .* ch
    end

    ν = DimArray(data=ν, dims=(c, s), name=:ν)
    outds = append(ds, ν)
    return outds
end

function compute_ν!(uvdata::UVDataSet, datakeys=nothing)
    if isnothing(datakeys)
        updatekeys = keys(uvdata)
    else
        updatekeys = datakeys
    end

    availables = [:visibility]
    for key in updatekeys
        if key ∈ availables
            uvdata[key] = compute_ν(uvdata[key])
        end
    end

    return
end

function compute_ν(uvdata::UVDataSet, datakeys=nothing)
    outuvdata = copy(uvdata)
    compute_ν!(outuvdata, datakeys)
end

function compute_uvw(ds::DimStack)
    # get size
    nch, nspw, ndata, _ = size(ds)
    c, s, d, _ = dims(ds)

    # define uvw
    u = zeros(nch, nspw, ndata)
    v = zeros(nch, nspw, ndata)
    w = zeros(nch, nspw, ndata)

    for idata in 1:ndata, ispw in 1:nspw, ich in 1:nch
        ν = ds[:ν].data[ich, ispw]
        u[ich, ispw, idata] = ν * ds[:usec].data[idata]
        v[ich, ispw, idata] = ν * ds[:vsec].data[idata]
        w[ich, ispw, idata] = ν * ds[:wsec].data[idata]
    end

    uvdist = .√(u .^ 2 .+ v .^ 2)

    uvw = DimStack(
        DimArray(data=u, dims=(c, s, d), name=:u),
        DimArray(data=v, dims=(c, s, d), name=:v),
        DimArray(data=w, dims=(c, s, d), name=:w),
        DimArray(data=uvdist, dims=(c, s, d), name=:uvdist),
    )

    outds = concat(ds, uvw)

    return outds
end

function compute_uvw!(uvdata::UVDataSet)
    if :visibility ∈ keys(uvdata)
        uvdata[:visibility] = compute_uvw(uvdata[:visibility])
    end

    return
end

function compute_uvw(uvdata::UVDataSet)
    outuvdata = copy(uvdata)
    compute_uvw!(outuvdata)
    return outuvdata
end
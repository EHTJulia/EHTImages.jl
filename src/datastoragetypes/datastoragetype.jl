"""
    $(TYPEDEF)

Internal type for specifying the nature of the location of data.
"""
abstract type DataStorageType end


"""
    $(TYPEDEF)

Defines a trait that a states that data is disk based.
"""
struct IsDiskData <: DataStorageType end


"""
    $(TYPEDEF)

Defines a trait that a states that data is memory based.
"""
struct NotDiskData <: DataStorageType end
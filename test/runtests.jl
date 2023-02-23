using Pkg
ENV["PYTHON"]=""
Pkg.build("PyCall")
using PyPlot

using EHTImages
using Test

@testset "EHTImages.jl" begin
    # Write your tests here.
end

# Colorfy.jl

[![Build Status](https://github.com/eliascarv/Colorfy.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/eliascarv/Colorfy.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/eliascarv/Colorfy.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/eliascarv/Colorfy.jl)

Colorfy.jl is a package to map Julia objecets into colors defined by [Colors.jl](https://github.com/JuliaGraphics/Colors.jl).

## Usage

The use of this package is centralized in the `Colorfier` struct.
This type stores the necessary info to convert a list of values into a list of colors.
To extract the colors mapped from colorfier, use the `Colorfy.colors` function:

```julia
julia> values = rand(5)
5-element Vector{Float64}:
 0.6725922579880301
 0.48419175677473947
 0.555196651363384
 0.9391048282597594
 0.06139286380440967

julia> colorfier = Colorfier(values);

julia> Colorfy.colors(colorfier)
5-element Array{RGBA{Float64},1} with eltype ColorTypes.RGBA{Float64}:
 RGBA{Float64}(0.25686927730139364,0.744083158641258,0.4461059964847054,1.0)
 RGBA{Float64}(0.13396134240010413,0.5479273380822499,0.5536215374839386,1.0)
 RGBA{Float64}(0.12033938235581829,0.6238620558326493,0.534269659829833,1.0)
 RGBA{Float64}(0.993248,0.906157,0.143936,1.0)
 RGBA{Float64}(0.267004,0.004874,0.329415,1.0)

julia> colorfier = Colorfier(values, alphas=0.5);

julia> Colorfy.colors(colorfier)
5-element Array{RGBA{Float64},1} with eltype ColorTypes.RGBA{Float64}:
 RGBA{Float64}(0.25686927730139364,0.744083158641258,0.4461059964847054,0.5)
 RGBA{Float64}(0.13396134240010413,0.5479273380822499,0.5536215374839386,0.5)
 RGBA{Float64}(0.12033938235581829,0.6238620558326493,0.534269659829833,0.5)
 RGBA{Float64}(0.993248,0.906157,0.143936,0.5)
 RGBA{Float64}(0.267004,0.004874,0.329415,0.5)
```

For convenience, the `colorfy` function is defined. This function
creates a `Colorfier` instance and call the `Colorfy.colors` function:

```julia
julia> values = [:red, :green, :blue];

julia> colorfy(values, alphas=[0.5, 0.6, 0.7])
3-element Array{RGBA{N0f8},1} with eltype ColorTypes.RGBA{FixedPointNumbers.N0f8}:
 RGBA{N0f8}(1.0,0.0,0.0,0.5)
 RGBA{N0f8}(0.0,0.502,0.0,0.6)
 RGBA{N0f8}(0.0,0.0,1.0,0.7)
```

See the `Colorfier` docstring for a description of all options.

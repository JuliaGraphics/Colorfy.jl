# Colorfy.jl

[![Build Status](https://github.com/JuliaGraphics/Colorfy.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/JuliaGraphics/Colorfy.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/JuliaGraphics/Colorfy.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/JuliaGraphics/Colorfy.jl)

Colorfy.jl is a package for mapping Julia objects into colors
defined by [Colors.jl](https://github.com/JuliaGraphics/Colors.jl).

## Usage

The `colorfy` function takes a vector of values with options
(e.g., `alpha`, `colorscheme`) and converts them into valid colors:

```julia
julia> values = [:red, :green, :blue];

julia> colorfy(values, alpha=[0.5, 0.6, 0.7])
3-element Array{RGBA{N0f8},1} with eltype ColorTypes.RGBA{FixedPointNumbers.N0f8}:
 RGBA{N0f8}(1.0,0.0,0.0,0.5)
 RGBA{N0f8}(0.0,0.502,0.0,0.6)
 RGBA{N0f8}(0.0,0.0,1.0,0.7)
```

Please check the `colorfy` docstring for more details.

Developers can register colorful representations for their
types by implementing methods for the `Colorfy.repr` function.

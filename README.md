# Colorfy.jl

[![Build Status](https://github.com/JuliaGraphics/Colorfy.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/JuliaGraphics/Colorfy.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/JuliaGraphics/Colorfy.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/JuliaGraphics/Colorfy.jl)

Colorfy.jl is a utility package to convert vectors of values into
[Colors.jl](https://github.com/JuliaGraphics/Colors.jl) colors.

It supports missing values, units, and other data types through
package extensions.

## Usage

The `colorfy` function takes a vector of values with options
(e.g., `alpha`, `colorscheme`) and converts them into valid colors:

```julia
julia> values = [:red, :green, :blue];

julia> colorfy(values, alpha=[0.5, 0.6, 0.7])
3-element Vector{RGBA{FixedPointNumbers.N0f8}}:
 RGBA(1.0, 0.0, 0.0, 0.502)
 RGBA(0.0, 0.502, 0.0, 0.6)
 RGBA(0.0, 0.0, 1.0, 0.698)
```

Please check the `colorfy` docstring for more details.

## Contributing

Developers can register colorful representations for their types
by adding methods to the `Colorfy.repr` function in package extensions.
Please check the `ext` folder for examples.

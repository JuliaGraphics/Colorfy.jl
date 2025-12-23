using Colorfy
using Colors
using ColorSchemes
using FixedPointNumbers
using CategoricalArrays
using Distributions
using Unitful
using Dates
using Test

@testset "Colorfy.jl" begin
  @testset "Colorfier" begin
    values = rand(10)
    colorfier = Colorfier(values)
    @test Colorfy.values(colorfier) == values
    @test Colorfy.alphas(colorfier) == fill(1, 10)
    @test Colorfy.colorscheme(colorfier) == colorschemes[:viridis]
    @test Colorfy.colorrange(colorfier) == :extrema

    colors = [Gray(rand()) for _ in 1:10]
    colorfier = Colorfier(colors)
    @test eltype(Colorfy.values(colorfier)) <: Gray
    @test eltype(eltype(Colorfy.values(colorfier))) <: AbstractFloat
    @test Colorfy.values(colorfier) == colors
    @test Colorfy.alphas(colorfier) == fill(1, 10)
    @test Colorfy.colorscheme(colorfier) == colorschemes[:viridis]
    @test Colorfy.colorrange(colorfier) == :extrema

    colors = [Gray(rand(Q0f7)) for _ in 1:10]
    colorfier = Colorfier(colors)
    @test eltype(Colorfy.values(colorfier)) <: Gray
    @test eltype(eltype(Colorfy.values(colorfier))) <: AbstractFloat
    @test Colorfy.values(colorfier) == colors
    @test Colorfy.alphas(colorfier) == fill(1, 10)
    @test Colorfy.colorscheme(colorfier) == colorschemes[:viridis]
    @test Colorfy.colorrange(colorfier) == :extrema

    colors = [Gray(rand(Q0f15)) for _ in 1:10]
    colorfier = Colorfier(colors)
    @test eltype(Colorfy.values(colorfier)) <: Gray
    @test eltype(eltype(Colorfy.values(colorfier))) <: AbstractFloat
    @test Colorfy.values(colorfier) == colors
    @test Colorfy.alphas(colorfier) == fill(1, 10)
    @test Colorfy.colorscheme(colorfier) == colorschemes[:viridis]
    @test Colorfy.colorrange(colorfier) == :extrema

    colors = [Gray(rand(Q0f31)) for _ in 1:10]
    colorfier = Colorfier(colors)
    @test eltype(Colorfy.values(colorfier)) <: Gray
    @test eltype(eltype(Colorfy.values(colorfier))) <: AbstractFloat
    @test Colorfy.values(colorfier) == colors
    @test Colorfy.alphas(colorfier) == fill(1, 10)
    @test Colorfy.colorscheme(colorfier) == colorschemes[:viridis]
    @test Colorfy.colorrange(colorfier) == :extrema

    colors = [Gray(rand(Q0f63)) for _ in 1:10]
    colorfier = Colorfier(colors)
    @test eltype(Colorfy.values(colorfier)) <: Gray
    @test eltype(eltype(Colorfy.values(colorfier))) <: AbstractFloat
    @test Colorfy.values(colorfier) == colors
    @test Colorfy.alphas(colorfier) == fill(1, 10)
    @test Colorfy.colorscheme(colorfier) == colorschemes[:viridis]
    @test Colorfy.colorrange(colorfier) == :extrema

    colorfier = Colorfier(values, alphas=0.5)
    @test Colorfy.values(colorfier) == values
    @test Colorfy.alphas(colorfier) == fill(0.5, 10)
    @test Colorfy.colorscheme(colorfier) == colorschemes[:viridis]
    @test Colorfy.colorrange(colorfier) == :extrema

    colorfier = Colorfier(values, colorscheme=:grays)
    @test Colorfy.values(colorfier) == values
    @test Colorfy.alphas(colorfier) == fill(1, 10)
    @test Colorfy.colorscheme(colorfier) == colorschemes[:grays]
    @test Colorfy.colorrange(colorfier) == :extrema

    colorfier = Colorfier(values, colorscheme="grays")
    @test Colorfy.values(colorfier) == values
    @test Colorfy.alphas(colorfier) == fill(1, 10)
    @test Colorfy.colorscheme(colorfier) == colorschemes[:grays]
    @test Colorfy.colorrange(colorfier) == :extrema

    colorfier = Colorfier(values, colorscheme=["black", "white"])
    @test Colorfy.values(colorfier) == values
    @test Colorfy.alphas(colorfier) == fill(1, 10)
    @test Colorfy.colorscheme(colorfier)[0.0] == colorant"black"
    @test Colorfy.colorscheme(colorfier)[1.0] == colorant"white"
    @test Colorfy.colorrange(colorfier) == :extrema

    colorfier = Colorfier(values, colorrange=(0.25, 0.75))
    @test Colorfy.values(colorfier) == values
    @test Colorfy.alphas(colorfier) == fill(1, 10)
    @test Colorfy.colorscheme(colorfier) == colorschemes[:viridis]
    @test Colorfy.colorrange(colorfier) == (0.25, 0.75)

    colorfier = Colorfier(values, colorrange=(0, 0.5))
    @test Colorfy.values(colorfier) == values
    @test Colorfy.alphas(colorfier) == fill(1, 10)
    @test Colorfy.colorscheme(colorfier) == colorschemes[:viridis]
    @test Colorfy.colorrange(colorfier) == (0.0, 0.5)

    alphas = rand(10)
    colorfier = Colorfier(values; alphas, colorscheme=colorschemes[:grays], colorrange=(0.25, 0.75))
    @test Colorfy.values(colorfier) == values
    @test Colorfy.alphas(colorfier) == alphas
    @test Colorfy.colorscheme(colorfier) == colorschemes[:grays]
    @test Colorfy.colorrange(colorfier) == (0.25, 0.75)

    # error: the number of alphas must be equal to the number of values
    alphas = rand(9)
    @test_throws ArgumentError Colorfier(values; alphas)
  end

  @testset "Colorfy.colors" begin
    values = rand(10)
    colorfier = Colorfier(values)
    colors = get(colorschemes[:viridis], values, :extrema)
    @test Colorfy.colors(colorfier) == coloralpha.(colors, 1)

    colorfier = Colorfier(values, colorscheme=:grays, colorrange=(0.25, 0.75))
    colors = get(colorschemes[:grays], values, (0.25, 0.75))
    @test Colorfy.colors(colorfier) == coloralpha.(colors, 1)

    colors = [colorant"red", colorant"green", colorant"blue", colorant"white", colorant"black"]
    values = ["red", "green", "blue", "white", "black"]
    colorfier = Colorfier(values)
    @test Colorfy.colors(colorfier) == coloralpha.(colors, 1)

    values = [:red, :green, :blue, :white, :black]
    colorfier = Colorfier(values, alphas=0.5)
    @test Colorfy.colors(colorfier) == coloralpha.(colors, 0.5)

    values = colors
    alphas = rand(5)
    colorfier = Colorfier(values; alphas)
    @test Colorfy.colors(colorfier) == coloralpha.(colors, alphas)

    values = coloralpha.(colors, alphas)
    colorfier = Colorfier(values)
    @test Colorfy.colors(colorfier) == values

    # error: unsupported values
    values = [nothing, nothing, nothing]
    colorfier = Colorfier(values)
    @test_throws ArgumentError Colorfy.colors(colorfier)
    values = Any[:red, :green, :blue] # vector with non-concrete eltype
    colorfier = Colorfier(values)
    @test_throws ArgumentError Colorfy.colors(colorfier)
  end

  @testset "colorfy" begin
    values = rand(10)
    colors = get(colorschemes[:viridis], values, :extrema)
    @test colorfy(values) == coloralpha.(colors, 1)

    colors = get(colorschemes[:grays], values, (0.25, 0.75))
    @test colorfy(values, colorscheme=:grays, colorrange=(0.25, 0.75)) == coloralpha.(colors, 1)
  end

  @testset "Invalid values" begin
    values = [0.1, missing, 0.2, NaN, 0.3, Inf, 0.4, -Inf, 0.5]
    colors = colorfy(values, alphas=0.5)
    @test colors[2] == colorant"transparent"
    @test colors[4] == colorant"transparent"
    @test colors[6] == colorant"transparent"
    @test colors[8] == colorant"transparent"

    # Vector{Union{Missing,T}} whitout missing values
    values = Union{Missing,Int}[1, 2, 3, 4, 5]
    @test colorfy(values) == colorfy([1, 2, 3, 4, 5])
  end

  @testset "Dates" begin
    values = now() .+ Day.(1:10)
    colors = colorfy(datetime2unix.(values))
    @test colorfy(values) == colors
    @test colorfy(values, alphas=0.5) == coloralpha.(colors, 0.5)

    values = today() .+ Day.(1:10)
    colors = colorfy(datetime2unix.(DateTime.(values)))
    @test colorfy(values) == colors
    @test colorfy(values, alphas=0.5) == coloralpha.(colors, 0.5)
  end

  @testset "CategoricalArrays" begin
    values = categorical(["n", "n", "y", "y", "n", "y"], levels=["y", "n"])
    categcolors = colorschemes[:viridis][range(0, 1, length=2)]
    colors = categcolors[[2, 2, 1, 1, 2, 1]]
    @test colorfy(values) == coloralpha.(colors, 1)
    @test colorfy(values, alphas=0.5) == coloralpha.(colors, 0.5)

    values = categorical([2, 1, 1, 3, 1, 3, 3, 2, 1, 2], levels=1:3)
    categcolors = colorschemes[:viridis][range(0, 1, length=3)]
    colors = categcolors[[2, 1, 1, 3, 1, 3, 3, 2, 1, 2]]
    @test colorfy(values) == coloralpha.(colors, 1)
    @test colorfy(values, alphas=0.5) == coloralpha.(colors, 0.5)

    values = categorical([1, 1, 1, 1, 1], levels=[1])
    categcolors = colorschemes[:viridis][range(0, 0, length=1)]
    colors = categcolors[[1, 1, 1, 1, 1]]
    @test colorfy(values) == coloralpha.(colors, 1)
    @test colorfy(values, alphas=0.5) == coloralpha.(colors, 0.5)
  end

  @testset "Distributions" begin
    means = rand(10)
    stds = rand(10)
    values = Normal.(means, stds)
    alphas = 1 .- (stds .- minimum(stds)) ./ (maximum(stds) - minimum(stds))
    colors = colorfy(means)
    @test colorfy(values) == coloralpha.(colors, alphas)
    @test colorfy(values, alphas=0.5) == coloralpha.(colors, 0.5)

    values = Normal.(means, fill(0.5, 10))
    @test colorfy(values) == coloralpha.(colors, 1)
    @test colorfy(values, alphas=0.5) == coloralpha.(colors, 0.5)

    values = [missing, Normal(0.5, 0.5), Normal(0.6, 0.6), Normal(0.7, 0.7), missing]
    colors = [colorant"transparent"; colorfy([0.5, 0.6, 0.7]); colorant"transparent"]
    alphas = [0.0, 1.0, 0.5, 0.0, 0.0]
    colors = colorfy(values)
    @test colorfy(values) == coloralpha.(colors, alphas)
    @test colorfy(values, alphas=0.5) == coloralpha.(colors, [0.0, 0.5, 0.5, 0.5, 0.0])
  end

  @testset "Unitful" begin
    values = rand(10) * u"m"
    @test colorfy(values) == colorfy(ustrip.(values))
    @test colorfy(values, alphas=0.5) == colorfy(ustrip.(values), alphas=0.5)
    @test colorfy(values, colorrange=(0.25, 0.75)) == colorfy(ustrip.(values), colorrange=(0.25, 0.75))
    @test colorfy(values, colorrange=(0.25u"m", 0.75u"m")) == colorfy(ustrip.(values), colorrange=(0.25, 0.75))
  end
end

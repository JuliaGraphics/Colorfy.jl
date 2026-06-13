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
  @testset "Handle arguments" begin
    values = rand(10)
    vs, αs, s, r = Colorfy.handleargs(values, 1.0, :viridis, :extrema)
    @test vs == values
    @test αs == fill(1, 10)
    @test s == colorschemes[:viridis]
    @test r == :extrema

    values = [Gray(rand()) for _ in 1:10]
    vs, αs, s, r = Colorfy.handleargs(values, 1.0, :viridis, :extrema)
    @test eltype(vs) <: Gray
    @test eltype(eltype(vs)) <: AbstractFloat
    @test vs == values
    @test αs == fill(1, 10)
    @test s == colorschemes[:viridis]
    @test r == :extrema

    for Q in (Q0f7, Q0f15, Q0f31, Q0f63)
      values = [Gray(rand(Q)) for _ in 1:10]
      vs, αs, s, r = Colorfy.handleargs(values, 1.0, :viridis, :extrema)
      @test eltype(vs) <: Gray
      @test eltype(eltype(vs)) <: AbstractFloat
      @test vs == values
      @test αs == fill(1, 10)
      @test s == colorschemes[:viridis]
      @test r == :extrema
    end

    values = rand(10)
    vs, αs, s, r = Colorfy.handleargs(values, 0.5, :viridis, :extrema)
    @test αs == fill(0.5, 10)

    values = rand(10)
    vs, αs, s, r = Colorfy.handleargs(values, 1.0, :grays, :extrema)
    @test s == colorschemes[:grays]

    values = rand(10)
    vs, αs, s, r = Colorfy.handleargs(values, 1.0, "grays", :extrema)
    @test s == colorschemes[:grays]

    values = rand(10)
    vs, αs, s, r = Colorfy.handleargs(values, 1.0, ["black", "white"], :extrema)
    @test s[0.0] == colorant"black"
    @test s[1.0] == colorant"white"

    values = rand(10)
    vs, αs, s, r = Colorfy.handleargs(values, 1.0, :viridis, (0.25, 0.75))
    @test r == (0.25, 0.75)

    values = rand(10)
    vs, αs, s, r = Colorfy.handleargs(values, 1.0, :viridis, (0, 0.5))
    @test r == (0.0, 0.5)

    values = rand(10)
    alphas = rand(10)
    vs, αs, s, r = Colorfy.handleargs(values, alphas, colorschemes[:grays], (0.25, 0.75))
    @test vs == values
    @test αs == alphas
    @test s == colorschemes[:grays]
    @test r == (0.25, 0.75)

    # error: the number of alphas must be equal to the number of values
    values = rand(10)
    alphas = rand(9)
    @test_throws ArgumentError Colorfy.handleargs(values, alphas, :viridis, :extrema)
  end

  @testset "Basic tests" begin
    values = rand(10)
    colors = colorfy(values)
    result = get(colorschemes[:viridis], values, :extrema)
    @test colors == coloralpha.(result, 1)

    values = rand(10)
    colors = colorfy(values, colorscheme=:grays, colorrange=(0.25, 0.75))
    result = get(colorschemes[:grays], values, (0.25, 0.75))
    @test colors == coloralpha.(result, 1)

    values = ["red", "green", "blue", "white", "black"]
    colors = colorfy(values)
    result = [colorant"red", colorant"green", colorant"blue", colorant"white", colorant"black"]
    @test colors == coloralpha.(result, 1)

    values = [:red, :green, :blue, :white, :black]
    colors1 = colorfy(values)
    colors2 = colorfy(values, alpha=0.5)
    @test colors2 == coloralpha.(colors1, 0.5)

    values = [:red, :green, :blue, :white, :black]
    alphas = rand(5)
    colors1 = colorfy(values)
    colors2 = colorfy(values, alpha=alphas)
    @test colors2 == coloralpha.(colors1, alphas)

    # invalid values (missing, NaN, Inf) are made transparent
    values = [0.1, missing, 0.2, NaN, 0.3, Inf, 0.4, -Inf, 0.5]
    colors = colorfy(values, alpha=0.5)
    @test colors[2] == colorant"transparent"
    @test colors[4] == colorant"transparent"
    @test colors[6] == colorant"transparent"
    @test colors[8] == colorant"transparent"

    # if all values are invalid, return transparent colors
    values = [missing, NaN, Inf, -Inf]
    colors = colorfy(values)
    @test all(c -> c == colorant"transparent", colors)
    values = [missing, missing, missing, missing]
    colors = colorfy(values)
    @test all(c -> c == colorant"transparent", colors)

    # Vector{Union{Missing,T}} whitout missing values
    values = Union{Missing,Int}[1, 2, 3, 4, 5]
    @test colorfy(values) == colorfy([1, 2, 3, 4, 5])

    # error: unsupported values
    values = [nothing, nothing, nothing]
    @test_throws ArgumentError colorfy(values)
    values = Any[:red, :green, :blue] # vector with non-concrete eltype
    @test_throws ArgumentError colorfy(values)
  end

  @testset "Dates" begin
    values = now() .+ Day.(1:10)
    colors1 = colorfy(values)
    colors2 = colorfy(datetime2unix.(values))
    @test colors1 == colors2
    @test colorfy(values, alpha=0.5) == coloralpha.(colors1, 0.5)

    values = today() .+ Day.(1:10)
    colors1 = colorfy(values)
    colors2 = colorfy(DateTime.(values))
    @test colors1 == colors2
    @test colorfy(values, alpha=0.5) == coloralpha.(colors1, 0.5)
  end

  @testset "CategoricalArrays" begin
    values = categorical(["n", "n", "y", "y", "n", "y"], levels=["y", "n"])
    lcolors = colorschemes[:viridis][range(0, 1, length=2)]
    result = lcolors[[2, 2, 1, 1, 2, 1]]
    @test colorfy(values) == coloralpha.(result, 1)
    @test colorfy(values, alpha=0.5) == coloralpha.(result, 0.5)

    values = categorical([2, 1, 1, 3, 1, 3, 3, 2, 1, 2], levels=1:3)
    lcolors = colorschemes[:viridis][range(0, 1, length=3)]
    result = lcolors[[2, 1, 1, 3, 1, 3, 3, 2, 1, 2]]
    @test colorfy(values) == coloralpha.(result, 1)
    @test colorfy(values, alpha=0.5) == coloralpha.(result, 0.5)

    values = categorical([1, 1, 1, 1, 1], levels=[1])
    lcolors = colorschemes[:viridis][range(0, 0, length=1)]
    result = lcolors[[1, 1, 1, 1, 1]]
    @test colorfy(values) == coloralpha.(result, 1)
    @test colorfy(values, alpha=0.5) == coloralpha.(result, 0.5)
  end

  @testset "Distributions" begin
    values = Normal.(rand(10), rand(10))
    μs = location.(values)
    σs = scale.(values)
    a, b = extrema(σs)
    colors = colorfy(μs, alpha=1 .- (σs .- a) ./ (b .- a))
    alphas = map(Colors.alpha, colors)
    @test colorfy(values) == colors
    @test colorfy(values, alpha=0.5) == coloralpha.(colors, 0.5 * alphas)

    values = [missing, Normal(0.5, 0.5), Normal(0.6, 0.6), Normal(0.7, 0.7), missing]
    colors = colorfy(values)
    @test colors[1] == colorant"transparent"
    @test colors[2] != colorant"transparent"
    @test colors[3] != colorant"transparent"
    @test colors[4] != colorant"transparent"
    @test colors[5] == colorant"transparent"
  end

  @testset "Unitful" begin
    values = rand(10) * u"m"
    @test colorfy(values) == colorfy(ustrip.(values))
    @test colorfy(values, alpha=0.5) == colorfy(ustrip.(values), alpha=0.5)
    @test colorfy(values, colorrange=(0.25, 0.75)) == colorfy(ustrip.(values), colorrange=(0.25, 0.75))
    @test colorfy(values, colorrange=(0.25u"m", 0.75u"m")) == colorfy(ustrip.(values), colorrange=(0.25, 0.75))
  end
end

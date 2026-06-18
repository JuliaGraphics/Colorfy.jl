using Colorfy
using Colors
using ColorSchemes
using FixedPointNumbers
using CategoricalArrays
using Distributions
using Unitful
using CoDa
using Dates
using Test

@testset "Colorfy.jl" begin
  @testset "Handle arguments" begin
    values = rand(10)
    vs, αs, cs, cr = Colorfy.preprocess(values, 1.0, :viridis, :extrema)
    @test vs == values
    @test αs == fill(1, 10)
    @test cs == colorschemes[:viridis]
    @test cr == :extrema

    values = [Gray(rand()) for _ in 1:10]
    vs, αs, cs, cr = Colorfy.preprocess(values, 1.0, :viridis, :extrema)
    @test eltype(vs) <: Gray
    @test eltype(eltype(vs)) <: AbstractFloat
    @test vs == values
    @test αs == fill(1, 10)
    @test cs == colorschemes[:viridis]
    @test cr == :extrema

    for Q in (Q0f7, Q0f15, Q0f31, Q0f63)
      values = [Gray(rand(Q)) for _ in 1:10]
      vs, αs, cs, cr = Colorfy.preprocess(values, 1.0, :viridis, :extrema)
      @test eltype(vs) <: Gray
      @test eltype(eltype(vs)) <: AbstractFloat
      @test vs == values
      @test αs == fill(1, 10)
      @test cs == colorschemes[:viridis]
      @test cr == :extrema
    end

    values = rand(10)
    vs, αs, cs, cr = Colorfy.preprocess(values, 0.5, :viridis, :extrema)
    @test αs == fill(0.5, 10)

    values = rand(10)
    vs, αs, cs, cr = Colorfy.preprocess(values, 1.0, :grays, :extrema)
    @test cs == colorschemes[:grays]

    values = rand(10)
    vs, αs, cs, cr = Colorfy.preprocess(values, 1.0, "grays", :extrema)
    @test cs == colorschemes[:grays]

    values = rand(10)
    vs, αs, cs, cr = Colorfy.preprocess(values, 1.0, ["black", "white"], :extrema)
    @test cs[0.0] == colorant"black"
    @test cs[1.0] == colorant"white"

    values = rand(10)
    vs, αs, cs, cr = Colorfy.preprocess(values, 1.0, :viridis, (0.25, 0.75))
    @test cr == (0.25, 0.75)

    values = rand(10)
    vs, αs, cs, cr = Colorfy.preprocess(values, 1.0, :viridis, (0, 0.5))
    @test cr == (0.0, 0.5)

    values = rand(10)
    alphas = rand(10)
    vs, αs, cs, cr = Colorfy.preprocess(values, alphas, colorschemes[:grays], (0.25, 0.75))
    @test vs == values
    @test αs == alphas
    @test cs == colorschemes[:grays]
    @test cr == (0.25, 0.75)

    # error: the number of alphas must be equal to the number of values
    values = rand(10)
    alphas = rand(9)
    @test_throws ArgumentError Colorfy.preprocess(values, alphas, :viridis, :extrema)
  end

  @testset "Basic tests" begin
    values = rand(10)
    colors = colorfy(values)
    result = get(colorschemes[:viridis], values, :extrema)
    @test colors == coloralpha.(result, 1)
    @test isempty(Colorfy.levels(values))

    values = rand(10)
    colors = colorfy(values, colorscheme=:grays, colorrange=(0.25, 0.75))
    result = get(colorschemes[:grays], values, (0.25, 0.75))
    @test colors == coloralpha.(result, 1)
    @test isempty(Colorfy.levels(values))

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

    values = [colorant"red", colorant"green", colorant"blue", colorant"white", colorant"black"]
    colors = colorfy(values)
    @test colors == coloralpha.(values, 1)

    # invalid values (missing, NaN, Inf) are made transparent
    values = [0.1, missing, 0.2, NaN, 0.3, Inf, 0.4, -Inf, 0.5]
    colors = colorfy(values, alpha=0.5)
    @test colors[2] == colorant"transparent"
    @test colors[4] == colorant"transparent"
    @test colors[6] == colorant"transparent"
    @test colors[8] == colorant"transparent"
    @test isempty(Colorfy.levels(values))

    # if all values are invalid, return transparent colors
    values = [missing, NaN, Inf, -Inf]
    colors = colorfy(values)
    @test all(c -> c == colorant"transparent", colors)
    @test isequal(Colorfy.nominal(values), [missing, missing, missing, missing])
    @test isempty(Colorfy.levels(values))
    values = [missing, missing, missing, missing]
    colors = colorfy(values)
    @test all(c -> c == colorant"transparent", colors)
    @test isequal(Colorfy.nominal(values), [missing, missing, missing, missing])
    @test isempty(Colorfy.levels(values))

    # Vector{Union{Missing,T}} without missing values
    values = Union{Missing,Int}[1, 2, 3, 4, 5]
    @test colorfy(values) == colorfy([1, 2, 3, 4, 5])
    @test Colorfy.nominal(values) == [1, 2, 3, 4, 5]
    @test isempty(Colorfy.levels(values))

    # Vector{<:AbstractFloat} with NaN and Inf values
    values = [0.1, 0.2, 0.3, NaN, Inf, -Inf]
    colors = colorfy(values)
    @test colors[1:3] == colorfy(values[1:3])
    @test colors[4] == colorant"transparent"
    @test colors[5] == colorant"transparent"
    @test colors[6] == colorant"transparent"
    @test isequal(Colorfy.nominal(values), [0.1, 0.2, 0.3, missing, missing, missing])
    @test isempty(Colorfy.levels(values))

    # vector with non-concrete eltype
    values = Any[:red, :green, :blue]
    colors = colorfy(values)
    @test colors[1] == coloralpha(colorant"red", 1)
    @test colors[2] == coloralpha(colorant"green", 1)
    @test colors[3] == coloralpha(colorant"blue", 1)
  end

  @testset "Dates" begin
    values = now() .+ Day.(1:10)
    colors1 = colorfy(values)
    colors2 = colorfy(datetime2unix.(values))
    @test colors1 == colors2
    @test colorfy(values, alpha=0.5) == coloralpha.(colors1, 0.5)
    @test Colorfy.nominal(values) == datetime2unix.(values)
    @test isempty(Colorfy.levels(values))

    values = today() .+ Day.(1:10)
    colors1 = colorfy(values)
    colors2 = colorfy(DateTime.(values))
    @test colors1 == colors2
    @test colorfy(values, alpha=0.5) == coloralpha.(colors1, 0.5)
    @test Colorfy.nominal(values) == datetime2unix.(DateTime.(values))
    @test isempty(Colorfy.levels(values))
  end

  @testset "CategoricalArrays" begin
    values = categorical(["n", "n", "y", "y", "n", "y"], levels=["y", "n"])
    cs = colorschemes[:viridis][range(0, 1, length=2)]
    colors = cs[[2, 2, 1, 1, 2, 1]]
    @test colorfy(values) == coloralpha.(colors, 1)
    @test colorfy(values, alpha=0.5) == coloralpha.(colors, 0.5)
    @test Colorfy.nominal(values) == [2, 2, 1, 1, 2, 1]
    @test Colorfy.levels(values) == ["y", "n"]

    values = categorical([2, 1, 1, 3, 1, 3, 3, 2, 1, 2])
    cs = colorschemes[:viridis][range(0, 1, length=3)]
    colors = cs[[2, 1, 1, 3, 1, 3, 3, 2, 1, 2]]
    @test colorfy(values) == coloralpha.(colors, 1)
    @test colorfy(values, alpha=0.5) == coloralpha.(colors, 0.5)
    @test Colorfy.nominal(values) == [2, 1, 1, 3, 1, 3, 3, 2, 1, 2]
    @test Colorfy.levels(values) == [1, 2, 3]

    values = categorical([1, 1, 1, 1, 1])
    cs = colorschemes[:viridis][range(1, 1, length=1)]
    colors = cs[[1, 1, 1, 1, 1]]
    @test colorfy(values) == coloralpha.(colors, 1)
    @test colorfy(values, alpha=0.5) == coloralpha.(colors, 0.5)
    @test Colorfy.nominal(values) == [1, 1, 1, 1, 1]
    @test Colorfy.levels(values) == [1]
  end

  @testset "Distributions" begin
    # Normal distribution
    values = [Normal(0.0, 0.1), Normal(0.5, 0.2)]
    ms = location.(values)
    hs = entropy.(values)
    a, b = extrema(hs)
    αs = 1.0 .- (hs .- a) ./ (b .- a)
    colors = colorfy(ms, alpha=αs)
    alphas = map(Colors.alpha, colors)
    @test colorfy(values) == colors
    @test colorfy(values, alpha=0.5) == coloralpha.(colors, 0.5 * alphas)
    @test Colorfy.nominal(values) == ms
    @test isempty(Colorfy.levels(values))

    # constant dispersion leads to constant transparency
    values = [Normal(1.0, 0.1), Normal(2.0, 0.1)]
    colors = colorfy(values)
    alphas = map(Colors.alpha, colors)
    @test all(==(1.0), alphas)
    @test Colorfy.nominal(values) == location.(values)
    @test isempty(Colorfy.levels(values))

    # Bernoulli distribution
    values = Bernoulli.(rand(10))
    ms = mode.(values)
    hs = entropy.(values)
    a, b = 0.0, log(2)
    αs = 1.0 .- (hs .- a) ./ (b - a)
    colors = colorfy(ms .+ 1, alpha=αs)
    alphas = map(Colors.alpha, colors)
    @test colorfy(values) == colors
    @test colorfy(values, alpha=0.5) == coloralpha.(colors, 0.5 * alphas)
    @test Colorfy.nominal(values) == ms
    @test Colorfy.levels(values) == [0, 1]

    # Categorical distribution
    values = Categorical.([rand(Dirichlet([1.0, 1.0, 1.0])) for _ in 1:10])
    ms = mode.(values)
    hs = entropy.(values)
    a, b = 0.0, log(3)
    αs = 1.0 .- (hs .- a) ./ (b - a)
    colors = colorfy(ms, alpha=αs)
    alphas = map(Colors.alpha, colors)
    @test colorfy(values) == colors
    @test colorfy(values, alpha=0.5) == coloralpha.(colors, 0.5 * alphas)
    @test Colorfy.nominal(values) == ms
    @test Colorfy.levels(values) == [1, 2, 3]

    # Categorical with single category
    values = [Categorical([1.0])]
    ms = mode.(values)
    hs = entropy.(values)
    a, b = 0.0, log(1)
    αs = fill(1.0, length(hs))
    colors = colorfy(ms, alpha=αs)
    alphas = map(Colors.alpha, colors)
    @test colorfy(values) == colors
    @test colorfy(values, alpha=0.5) == coloralpha.(colors, 0.5 * alphas)
    @test Colorfy.nominal(values) == ms
    @test Colorfy.levels(values) == [1]

    # Diract delta distribution
    values = [Dirac(1), Dirac(2), Dirac(3)]
    colors = colorfy(values)
    @test colors[1] != colorschemes[:viridis][0.0]
    @test colors[2] != colorschemes[:viridis][0.5]
    @test colors[3] != colorschemes[:viridis][1.0]
    @test Colorfy.nominal(values) == [1, 2, 3]
    @test Colorfy.levels(values) == [1]
  end

  @testset "Unitful" begin
    values = rand(10) * u"m"
    @test colorfy(values) == colorfy(ustrip.(values))
    @test colorfy(values, alpha=0.5) == colorfy(ustrip.(values), alpha=0.5)
    @test colorfy(values, colorrange=(0.25, 0.75)) == colorfy(ustrip.(values), colorrange=(0.25, 0.75))
    @test colorfy(values, colorrange=(0.25u"m", 0.75u"m")) == colorfy(ustrip.(values), colorrange=(0.25, 0.75))
    @test Colorfy.nominal(values) == ustrip.(values)
    @test isempty(Colorfy.levels(values))
  end

  @testset "CoDa" begin
    values = [Composition(1, 1, 1), Composition(1, 0, 0)]
    colors = colorfy(values)
    alphas = map(Colors.alpha, colors)
    @test alphas[1] < alphas[2]
    @test Colorfy.nominal(values) == [1, 1]
    @test Colorfy.levels(values) == [:w1, :w2, :w3]
  end

  @testset "Advanced tests" begin
    # distributions and missing values
    values = [missing, Normal(0.5, 0.5), Normal(0.6, 0.6), Normal(0.7, 0.7), missing]
    colors = colorfy(values)
    @test colors[1] == colorant"transparent"
    @test colors[2] != colorant"transparent"
    @test colors[3] != colorant"transparent"
    @test colors[4] != colorant"transparent"
    @test colors[5] == colorant"transparent"
    @test isequal(Colorfy.nominal(values), [missing, 0.5, 0.6, 0.7, missing])
    @test isempty(Colorfy.levels(values))

    # distributions and NaN/Inf values
    values = Dirac.([0.1, 0.2, 0.3, NaN, Inf, -Inf])
    colors = colorfy(values)
    @test colors[1:3] == colorfy(values[1:3])
    @test colors[4] == colorant"transparent"
    @test colors[5] == colorant"transparent"
    @test colors[6] == colorant"transparent"
    @test isequal(Colorfy.nominal(values), [0.1, 0.2, 0.3, missing, missing, missing])
    @test Colorfy.levels(values) == [1]
  end
end

using Colorfy
using Colors
using ColorSchemes
using CategoricalArrays
using Unitful
using Test

@testset "Colorfy.jl" begin
  @testset "Colorfier" begin
    values = rand(10)
    colorfier = Colorfier(values)
    @test Colorfy.values(colorfier) == values
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

    alphas = rand(5)
    colorfier = Colorfier(colors; alphas)
    @test Colorfy.colors(colorfier) == coloralpha.(colors, alphas)
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
  end

  @testset "Unitful" begin
    values = rand(10) * u"m"
    @test colorfy(values) == colorfy(ustrip.(values))
    @test colorfy(values, alphas=0.5) == colorfy(ustrip.(values), alphas=0.5)
    @test colorfy(values, colorrange=(0.25, 0.75)) == colorfy(ustrip.(values), colorrange=(0.25, 0.75))
  end

  @testset "CategoricalArrays" begin
    values = categorical(["n", "n", "y", "y", "n", "y"], levels=["y", "n"])
    colors = colorschemes[:viridis][[2, 2, 1, 1, 2, 1]]
    @test colorfy(values) == coloralpha.(colors, 1)
    @test colorfy(values, alphas=0.5) == coloralpha.(colors, 0.5)
  end
end

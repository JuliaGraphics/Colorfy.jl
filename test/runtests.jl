using Colorfy
using Colors
using ColorSchemes
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

  @testset "get" begin
    values = rand(10)
    colorfier = Colorfier(values)
    colors = get(colorschemes[:viridis], values, :extrema)
    @test get(colorfier) == coloralpha.(colors, 1)

    colorfier = Colorfier(values, colorscheme=:grays, colorrange=(0.25, 0.75))
    colors = get(colorschemes[:grays], values, (0.25, 0.75))
    @test get(colorfier) == coloralpha.(colors, 1)

    colors = [colorant"red", colorant"green", colorant"blue", colorant"white", colorant"black"]
    values = ["red", "green", "blue", "white", "black"]
    colorfier = Colorfier(values)
    @test get(colorfier) == coloralpha.(colors, 1)

    values = [:red, :green, :blue, :white, :black]
    colorfier = Colorfier(values, alphas=0.5)
    @test get(colorfier) == coloralpha.(colors, 0.5)

    alphas = rand(5)
    colorfier = Colorfier(colors; alphas)
    @test get(colorfier) == coloralpha.(colors, alphas)
  end

  @testset "colorfy" begin
    values = rand(10)
    colors = get(colorschemes[:viridis], values, :extrema)
    @test colorfy(values) == coloralpha.(colors, 1)

    colors = get(colorschemes[:grays], values, (0.25, 0.75))
    @test colorfy(values, colorscheme=:grays, colorrange=(0.25, 0.75)) == coloralpha.(colors, 1)
  end
end

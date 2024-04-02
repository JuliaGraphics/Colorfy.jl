using Colorfy
using Colors
using ColorSchemes
using Test

@testset "Colorfy.jl" begin
  @testset "Colormap" begin
    values = rand(10)
    cmap = Colormap(values)
    @test Colorfy.values(cmap) == values
    @test Colorfy.alphas(cmap) == fill(1, 10)
    @test Colorfy.colorscheme(cmap) == colorschemes[:viridis]
    @test Colorfy.colorrange(cmap) == :extrema

    cmap = Colormap(values, alphas=0.5)
    @test Colorfy.values(cmap) == values
    @test Colorfy.alphas(cmap) == fill(0.5, 10)
    @test Colorfy.colorscheme(cmap) == colorschemes[:viridis]
    @test Colorfy.colorrange(cmap) == :extrema

    cmap = Colormap(values, colorscheme=:grays)
    @test Colorfy.values(cmap) == values
    @test Colorfy.alphas(cmap) == fill(1, 10)
    @test Colorfy.colorscheme(cmap) == colorschemes[:grays]
    @test Colorfy.colorrange(cmap) == :extrema

    cmap = Colormap(values, colorscheme="grays")
    @test Colorfy.values(cmap) == values
    @test Colorfy.alphas(cmap) == fill(1, 10)
    @test Colorfy.colorscheme(cmap) == colorschemes[:grays]
    @test Colorfy.colorrange(cmap) == :extrema

    alphas = rand(10)
    cmap = Colormap(values; alphas, colorscheme=colorschemes[:grays], colorrange=(0.25, 0.75))
    @test Colorfy.values(cmap) == values
    @test Colorfy.alphas(cmap) == alphas
    @test Colorfy.colorscheme(cmap) == colorschemes[:grays]
    @test Colorfy.colorrange(cmap) == (0.25, 0.75)

    # error: the number of alphas must be equal to the number of values
    alphas = rand(9)
    @test_throws ArgumentError Colormap(values; alphas)
  end

  @testset "Colorfy.get" begin
    values = rand(10)
    cmap = Colormap(values)
    colors = get(colorschemes[:viridis], values, :extrema)
    @test Colorfy.get(cmap) == coloralpha.(colors, 1)

    cmap = Colormap(values, colorscheme=:grays, colorrange=(0.25, 0.75))
    colors = get(colorschemes[:grays], values, (0.25, 0.75))
    @test Colorfy.get(cmap) == coloralpha.(colors, 1)

    colors = [colorant"red", colorant"green", colorant"blue", colorant"white", colorant"black"]
    values = ["red", "green", "blue", "white", "black"]
    cmap = Colormap(values)
    @test Colorfy.get(cmap) == coloralpha.(colors, 1)

    values = [:red, :green, :blue, :white, :black]
    cmap = Colormap(values, alphas=0.5)
    @test Colorfy.get(cmap) == coloralpha.(colors, 0.5)

    alphas = rand(5)
    cmap = Colormap(colors; alphas)
    @test Colorfy.get(cmap) == coloralpha.(colors, alphas)
  end

  @testset "colorfy" begin
    values = rand(10)
    colors = get(colorschemes[:viridis], values, :extrema)
    @test colorfy(values) == coloralpha.(colors, 1)

    colors = get(colorschemes[:grays], values, (0.25, 0.75))
    @test colorfy(values, colorscheme=:grays, colorrange=(0.25, 0.75)) == coloralpha.(colors, 1)
  end
end

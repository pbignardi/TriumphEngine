using Test
using TriumphEngine
using Random

# Cards related tests
@testset "Cards" begin
    # Test suit constants
    @test string(spade) == "Spade"
    @test string(bastoni) == "Bastoni"
    @test string(coppe) == "Coppe"
    @test string(denari) == "Denari"
    # Test cards construction
    @test 1S == Card(Rank(7), S)
    @test 4B == Card(Rank(0), B)
    @test 2C == Card(2, C)
    # Test rank and suit functions
    @test rank(1S) == 7
    @test rank(7C) == 3
    @test suit(5D) == denari
    @test suit(9B) == bastoni
    # Test issuit class of functions
    @test issuit(6D, D) == true
    @test issuit(9C, D) == false
    @test issuit(10B, B) == true
end

@testset "Trumps" begin
    ## Test single card trumps
    # Test trumps
    trump_card = settrump(4S; trump=spade)
    other_card = settrump(3B; trump=spade)
    @test trump_card > other_card

    ## Test array of cards
    cards = settrump.([1S, 5S, 6S, 8S, 2S, 3B]; trump=spade)
    @test all(card > last(cards) for card in first(cards, 5))
end

@testset "Card scoring" begin
    cards = [1S, 5C, 2B, 8D, 9D, 4D, 5D]
    correct_points = [1//1, 0//1, 1//3, 1//3, 1//3, 0//1, 0//1]
    @test all(points.(cards) .== correct_points)
    # count points of all deck
    deck = [Card(r, s) for r in ranks for s in suits]
    @test sum(points.(deck)) == 4 * (1+5//3)
    @test sum(points.(ordered_deck())) == 4 * (1+5//3)
end

@testset "Trick-taking" begin
    trick = settrump.([3C, 4C, 1C, 5S]; trump=spade)
    @test all(evaltrick(trick) .== [89, 80, 87, 129])
    # check the maximum is the right one
    (maxval, maxind) = findwinning(trick)
    @test maxval == 129
    @test maxind == 4
end

@testset "Utility" begin
    first_hand = [5B, 6C, 9D]
    other_hand = [10S, 1D, 2D, 4B]
    third_hand = [4D, 5C, 9B, 1S]
    @test whostarts(first_hand, other_hand, third_hand) == 3
end

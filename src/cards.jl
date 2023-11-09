# suit, card structs
export Rank, Suit, Card, Trick
# access functions
export rank, suit, id, cards
# consts
export spade, coppe, denari, bastoni, suits, ranks, card_ids, ranknames
# shortcuts
export S, C, D, B
# utility functions
export points, deal, ordered_deck, shuffled_deck
export issuit, isspade, iscoppe, isdenari, isbastoni, istrump
export evaltrick, findwinning, settrump

"""
Rank

Represent the rank of a card as a 8-bit integer.
Valid ranks are as follows:
0: 4
1: 5
2: 6
3: 7
4: Fante (J)
5: Cavallo (Q)
6: Re (K)
7: Asso (A)
8: 2
9: 3

Only 10 ranks are used in Trionfo, so 8, 9, 10 cards are not used.
"""
struct Rank
    i::UInt8
    Rank(i::Integer) = begin
        i in 0:9 ? new(i) : throw("$i not a valid rank")
    end
end

"""
Suit

Represent a generic suit as an unsigned 8-bit integer (from 0 to 3)
"""
struct Suit
    i::UInt8
    Suit(i::Integer) = begin
        i in 0:3 ? new(i<<4) : throw("$i not a valid suit")
    end
end

"""
Card

Cards are represented as a UInt8 as follows:
- bits 1 to 4: represent the rank of the card.
- bits 5 and 6: represent the suit of the card.
- bits 7: represents if the card is the first card played
- bits 8: represents if the card is of trump suit
"""
struct Card
    i::UInt8
end

Card(r::Rank, s::Suit) = Card(s.i | r.i)

"""
Constructor for Card type. This is convenient for user inputs
Card(rank::Int64, suit::Suit)

rank:
1: Asso, 2: 2, 3: 3, ..., 8: Fante, 9: Cavallo, 10: Re

suit:
spade, coppe, bastoni, denari

"""
Card(i::Int64, s::Suit) = Card(Rank(mod(i-3-1,10)), s)

# Define suits constants
const spade = Suit(0)
const coppe = Suit(1)
const denari = Suit(2)
const bastoni = Suit(3)

const TRUMPBITS = 0x80
const FIRSTHANDBITS = 0x40
const SUITBITS = 0x30
const RANKBITS = 0x0f

# Define suits shortcuts
const S = spade
const C = coppe
const D = denari
const B = bastoni

# Overload concatenation operator for definition of cards
Base.:*(r::Int64, s::Suit) = Card(r, s)

const suits = ( spade, coppe, denari, bastoni )
const ranks = Rank.(0:9)
# rank names, from least to most important
const ranknames = Dict(0 => "4", 1 => "5", 2 => "6", 3 => "7", 
                       4 => "Fante", 5 => "Cavallo", 6 => "Re", 
                       7 => "Asso", 8 => "2", 9 => "3")

# Access functions for the new types
id(c::Card) = c.i
id(r::Rank) = r.i
id(s::Suit) = s.i
rank(c::Card) = Rank(id(c) & RANKBITS) # keep only last 4 bits
suit(c::Card) = Suit((id(c) & SUITBITS) >> 4) # keep bits 5 & 6

# Overload comparison operator
# Suit to suit compare
Base.:(==)(s1::Suit, s2::Suit) = s1.i == s2.i
# Rank to ints compare
Base.:(==)(r::Rank, n::Int64) = id(r) == n
Base.:(==)(r::Rank, n::UInt8) = id(r) == n
Base.:(>)(r::Rank, n::Int64) = id(r) > n
Base.:(>)(r::Rank, n::UInt8) = id(r) > n
Base.:(<)(r::Rank, n::Int64) = id(r) < n
Base.:(<)(r::Rank, n::UInt8) = id(r) < n
# Card to card compare
Base.:(>)(c1::Card, c2::Card) = id(c1) > id(c2)
Base.:(<)(c1::Card, c2::Card) = id(c1) < id(c2)
Base.:(==)(c1::Card, c2::Card) = id(c1) == id(c2) # maybe pointless

# Overload Base.string function for the new types
Base.string(s::Suit) = begin
    if s == spade
        "Spade"
    elseif s == coppe
        "Coppe"
    elseif s == denari
        "Denari"
    elseif s == bastoni
        "Bastoni"
    end
end

Base.string(r::Rank) = begin
    ranknames[r.i]
end

Base.string(c::Card) = begin
    rankname = Base.string(rank(c))
    suitname = Base.string(suit(c))
    return "$rankname di $suitname"
end

# Overload show for pretty print
Base.show(io::IO, r::Rank) = print(io, Base.string(r))
Base.show(io::IO, s::Suit) = print(io, Base.string(s))
Base.show(io::IO, c::Card) = print(io, Base.string(c))

# Utility functions
"""
Return true if given card is of the given suit
"""
issuit(c::Card, s::Suit) = suit(c) == s
# Instance for every suit
isspade(c::Card) = issuit(c, spade)
iscoppe(c::Card) = issuit(c, coppe)
isdenari(c::Card) = issuit(c, denari)
isbastoni(c::Card) = issuit(c, bastoni)

"""
Check if card is trump or not. Bitshift to the right 7 times and check last bit
"""
istrump(c::Card) = ( id(c) >> 7 ) > 0

"""
Return new card with relevant bit set to 1 for given suit
"""
settrump(card::Card; trump::Suit) = begin
    if suit(card) == trump
        return Card(id(card) | TRUMPBITS)
    else return card
    end
end

"""
Compute winning card id
By comparing who wins in pairs
"""
findwinning(cards::Vector{Card}) = findmax(evaltrick(cards))

"""
Compute the id of each card in the trick.
Return a vector of UInt8 with 2nd most relevant bit set
"""
evaltrick(trick::Vector{Card}) = begin
    map(trick) do card
        if suit(card) == suit(first(trick))
            id(card) | FIRSTHANDBITS
        else
            id(card)
        end
    end
end

"""
Return points of a given card as rationals
"""
points(c::Card) = begin
    p = 0//1
    if rank(c) > 3
        p += 1//3
    end
    if rank(c) == 7
        p += 2//3
    end
    return p
end

"""
Return ordered deck by varying ranks first, and suits last

e.g.:
ordered_deck() = Card(1, spade), Card(2, spade), Card(3, spade), ...
"""
ordered_deck() = [Card(r, s) for s in suits for r in ranks]

"""
Return shuffled deck
"""
shuffled_deck() = Random.shuffle(ordered_deck())

"""
Deal deck cards to the four players
"""
deal(d) = collect.(IterTools.partition(d, 10))

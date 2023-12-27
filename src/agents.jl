export Agent, Environment

mutable struct Agent
    hand::Vector{Card}
    id::UInt8
end

hand(agent::Agent) = agent.hand

mutable struct Environment
    points::Vector{Int32}
    card_history::Dict{Int, Vector{Card}}
    table::Vector{Card}
    agents_order::Vector{UInt8} # array of ids of agents, in the order of play
    trump_suit::Suit
end

# TODO initialize the environment
# TODO initialize the agents
# TODO set the trump suit
# TODO set the trump to all the cards (or set it only when finding the tricktacker?)

"""
Random policy - pick a random card from agent hand
"""
random_policy(agent::Agent, env::Environment) = begin
    return rand(hand(agent))
end

"""
Let agent play a card onto the environment's table, following given policy
"""
play!(agent::Agent, env::Environment; policy=random_policy) = begin
    card = policy(agent, env)
    card_id = findfirst(==(card), hand(agent))
    deleteat!(agent.hand, card_id)
    push!(env.table, card)
end

# TODO logic here is unclear to me.
# - respect single responsability principle
# - who does all the orchestration? (calling flush, give points, ...)

"""
Find which agent wins this round
"""
findtricktaker(env::Environment) = begin
    
end

""" 
Give points to the trick taker (or the pair)
"""
givepoints!(env::Environment) = begin
    
end

"""
Remove all cards from the table
"""
flushtable!(env::Environment) = begin
    
end

"""
set playing order for the next round
"""
setagentsorder!(env::Environment) = begin
    
end


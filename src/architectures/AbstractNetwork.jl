abstract type AbstractNetwork end

show(network::AbstractNetwork) = println("Network\n- N = $(network.N)")
display(network::AbstractNetwork) = show(network)

AdjArrays
=========

Enables quick creation of adjacency matrices and vector of different
network architectures.
Also provides extra funcionalities.

## Instalation
```julia
pkg> dev https://github.com/JoaoAPS/AdjacencyArrays.jl
```

#### Currently available architectures:
- Empty
- Global
- Regular
- Erdős–Rényi (random)
- Watts-Strogatz (small-world)

#### Available functions
- ##### adjMat(network)
Return the adjacency matrix of the network

- ##### adjVet(network)
Return the adjacency vector of the network

- ##### numnodes(network)
Return the number of nodes on the network

- ##### numconnections(network)
Return the number of connections on the network

- ##### maxconnections(network)
Return the maximum number of connections the network could possibly have

- ##### isdirected(network)
Return wheter the network is directed or not

- ##### numshortcuts(network)
(small-world networks only) Return the number of shortcuts added/rewired on the network

- ##### connectivity(network, idx_node::Integer; dir_behaviour::Symbol=:total)
Return the number of connections that the node of index `idx_node` gas.
If the network is directed, the keywork argument `dir_behaviour` can be passed to specify the 
type of connectivity desired. It can be :total, :in, :out, :mean, :both, or :bi.

- ##### connectivity(network; dir_behaviour::Symbol=:total)
Return the average connectivity of the network.

- ##### connectivities(network; dir_behaviour::Symbol=:total)
Return the connectivities of all nodes.

- ##### clusteringcoefficient(network)
Return the average clusteringcoefficient of the network.

- ##### clusteringcoefficient(network, idx_node::Integer)
Return the clustering coefficient of the specified node.

- ##### clusteringcoefficients(network)
Return the clustering coefficient of every node on the network.

- ##### transitivity(network)
Return the transitivity of the network.

- ##### shortestpath(network, source::Integer,	target::Integer=nothing)
Return the length of the shortest paths from the source node the every other node.
If `target` is specified, only the path from the source to the target is returned.

- ##### shortestpath(network)
Return the average shortest path length of the network.

- ##### averagepathlength(network)
Return the average shortest path length of the network.

- ##### sigma(network)
Compare the network with an equivalent random network and return
the small-world-ness measure ``σ = (C / C_ran) / (L / L_ran)``

- ##### omega(network)
Compare the network with an equivalent random and an equivalent lattice network
and return the small-world-ness measure ``ω = (L_ran / L) - (C / C_reg)``

- ##### smallworldness(network; verbose::Bool=true)
Return the small-world-ness measures σ and ω.
If `verbose` is true, also print an analysis.


- ##### adjMatToVet(mat)
Return the corresponding adjacency vector of the adjacency matrix passed.

- ##### adjVetToMat(vet, N)
Return the corresponding adjacency matrix of the adjacency vector passed.


## Use

First create a object of the desired architecture

``` julia
# Creates a erdos-renyi network with 10 nodes and probability 0.4
net = ErdosRenyiNetwork(10, 0.4)
```

Call the desired functions on the network object

``` julia
# Gets the adjacency matrix and vector of the created network
v = adjVet(net)
m = adjMat(net)
```


## References

### EmptyNetwork
A network with no connections between the nodes.

```julia
EmptyNetwork(N)
```
- `N :: Integer` : Number of nodes

### GlobalNetwork
A network in which all nodes are connected to all others.

```julia
GlobalNetwork(N; directed=false)
```
- `N :: Integer` : Number of nodes
- `directed :: Bool` : (default=false) Whether the connections are directed or not

### RegularNetwork
A ring network in which all nodes are connected to the k nearest nodes.

```julia
RegularNetwork(N, k; directed=false)
```
- `N :: Integer` : Number of nodes
- `k :: Integer` : Connectivity of the nodes. Must be even.
- `directed :: Bool` : (default=false) Whether the connections are directed or not

### ErdosRenyiNetwork (Random)
A network with random connections, following the Erdős–Rényi method.

```julia
ErdosRenyiNetwork(N, p; directed=false, seed=-1)
ErdosRenyiNetwork(N, numConnections; directed=false, seed=-1)
```
- `N :: Integer` : Number of nodes
- `p :: Float`   : Connection probability
- `numConnections :: Integer` : Number of connections
- `directed :: Bool` : (default=false) Whether the connections are directed or not
- `seed :: Integer` : (default=-1) The seed for the random creation. Negative for a random seed.

### WattsStrogatzNetwork (Small-world)
A network contructed via the Watts-Strogatz method. May be of small-world archtecture.

```julia
WattsStrogatzNetwork(N, k, β; directed=false, seed=-1)
WattsStrogatzNetwork(N, k, numShortcuts; directed=false, seed=-1)
```
- `N :: Integer` : Number of nodes
- `k :: Integer` : Mean connectivity of the network. Must be even.
- `β :: Float`   : Rewiring probability
- `numShortcuts :: Integer` : Number of shortcuts rewired
- `directed :: Bool` : (default=false) Whether the connections are directed or not
- `seed :: Integer` : (default=-1) The seed for the random creation. Negative for a random seed.


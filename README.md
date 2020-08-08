AdjArrays
=========

Enables quick creation of adjacency matrices and vector of different
network architectures.
Also provides extra funcionalities.

#### Currently available architectures:
- Empty
- Global
- Regular
- Erdős–Rényi (random)
- Watts-Strogatz (small-world)

#### Available functions
- `numnodes(network)` : Return the number of nodes on the network
- `numconnections(network)` : Return the number of connections on the network
- `isdirected(network)` : Return wheter the network is directed or not
- `meanconnectivity(network)` : Return the number of nodes on the network
- `numshortcuts(network)` : (small-world networks only) Return the number of shortcuts added/rewired on the network

- `adjMat(network)` : Return the adjacency matrix of the network
- `adjVet(network)` : Return the adjacency vector of the network
- `adjMatToVet(mat)` : Return the corresponding adjacency vector of the adjacency matrix passed
- `adjVetToMat(vet, N)` : Return the corresponding adjacency matrix of the adjacency vector passed

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

#### EmptyNetwork
A network with no connections between the nodes.

```julia
EmptyNetwork(N)
```
- `N :: Integer` : Number of nodes

#### GlobalNetwork
A network in which all nodes are connected to all others.

```julia
GlobalNetwork(N; directed=false)
```
- `N :: Integer` : Number of nodes
- `directed :: Bool` : (default=false) Whether the connections are directed or not

#### RegularNetwork
A ring network in which all nodes are connected to the k nearest nodes.

```julia
RegularNetwork(N, k; directed=false)
```
- `N :: Integer` : Number of nodes
- `k :: Integer` : Connectivity of the nodes. Must be even.
- `directed :: Bool` : (default=false) Whether the connections are directed or not

#### ErdosRenyiNetwork (Random)
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

#### WattsStrogatzNetwork (Small-world)
A network contructed via the Watts-Strogatz method. May be of small-world archtecture.

```julia
WattsStrogatzNetwork(N, k, β; directed=false, seed=-1)
WattsStrogatzNetwork(N, k, numShortcuts; directed=false, seed=-1)
```
- `N :: Integer` : Number of nodes
- `k :: Integer` : Mean connectivity of the network. Must be even.
- `β :: Float`   : Rewiring probability &beta;
- `numShortcuts :: Integer` : Number of shortcuts rewired
- `directed :: Bool` : (default=false) Whether the connections are directed or not
- `seed :: Integer` : (default=-1) The seed for the random creation. Negative for a random seed.


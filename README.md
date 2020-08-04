AdjArrays
=========

Enables quick creation of adjacency matrices and vector of different
network architectures.
Also provides extra funcionalities.

#### Currently available architectures:
- Global
- Random (Erdős–Rényi)

#### Funcionalities
- Convertion between adjacency matrices and adjacency vectors


## Use

First create a object of the desired architecture

``` julia
# Creates a erdos-renyi network with 10 nodes and probability 0.4
net = ErdosRenyiNetwork(10, 0.4)
```

Call the functions `adjMat` and `adjVet` on the network object

``` julia
v = adjVet(net)
m = adjMat(net)
```


## References

### Architectures

#### GlobalNetwork
```julia
GlobalNetwork(N)
```
- `N :: Integer` : Number of nodes

#### ErdosRenyiNetwork (Random)
```julia
ErdosRenyiNetwork(N, p; directed, seed)
ErdosRenyiNetwork(N, numConnections; ...)
```
- `N :: Integer` : Number of nodes
- `p :: Float`   : Connection probability
- `numConnections :: Integer` : Number of connections
- `directed :: Bool` : (default=false) Wheter the connections are directed or not
- `seed :: Integer` : (default=-1) The seed for the random creation. Negative for a random seed.


### Functionalities
#### Adjacency matrix and Vector
``` julia
adjMat(network)
adjVet(network)
```


#### Convertion
##### Adjacency matrix to adjacency vector
``` julia
adjMatToVet(mat)
```

- `mat :: BitArray{2}` : Adjacency matrix

##### Adjacency vector to adjacency matrix
``` julia
adjVetToMat(vet, N)
```
- `vet :: Vector{<:Integer}` : Adjacency vector
- `N :: Integer` : Number of nodes


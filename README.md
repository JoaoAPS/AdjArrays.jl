AdjArrays
=========

Enables quick creation of adjacency matrices and vector of different
network architectures.
Also provides extra funcionalities.

#### Currently available architectures:
- Global

#### Funcionalities
- Convertion between adjacency matrices and adjacency vectors


## Use

First create a object of the desired architecture

``` julia
# Creates a global network with 10 nodes
g = GlobalNetwork(10)
```

Call the functions `adjMat` and `adjVet` on the network object

``` julia
v = adjVet(g)
m = adjMat(g)
```


## References

### Architectures

#### GlobalNetwork
```julia
GlobalNetwork(N)
```

- `N :: Integer` : Number of nodes

### Functionalities

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


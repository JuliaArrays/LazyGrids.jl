```@meta
CurrentModule = LazyGrids
```

# LazyGrids.jl Documentation

## Overview

This Julia module exports a method `ndgrid`
for generating lazy versions of grids
from a collection of 1D vectors
(any `AbstractVector` type).


For a lazy version akin to `meshgrid`,
simply add this line of code:

```julia
meshgrid(y,x) = (ndgrid(x,y)[[2,1]]...,)
```


See the
[Examples](@ref 1-ndgrid)
tab to the left for details.

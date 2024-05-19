# LazyGrids.jl
A Julia package for representing multi-dimensional grids.

https://github.com/JuliaArrays/LazyGrids.jl

[![docs-stable][docs-stable-img]][docs-stable-url]
[![docs-dev][docs-dev-img]][docs-dev-url]
[![action status][action-img]][action-url]
[![pkgeval status][pkgeval-img]][pkgeval-url]
[![codecov][codecov-img]][codecov-url]
[![license][license-img]][license-url]
[![Aqua QA][aqua-img]][aqua-url]
[![code-style][code-blue-img]][code-blue-url]
[![deps](https://juliahub.com/docs/LazyGrids/deps.svg)](https://juliahub.com/ui/Packages/LazyGrids)
[![version](https://juliahub.com/docs/LazyGrids/version.svg)](https://juliahub.com/ui/Packages/LazyGrids)
[![pkgeval](https://juliahub.com/docs/LazyGrids/pkgeval.svg)](https://juliahub.com/ui/Packages/LazyGrids)

## Methods

This package exports the following methods:
* `ndgrid` : a "lazy" version of `ndgrid` that returns a tuple of
  [`AbstractArray`](https://docs.julialang.org/en/v1/manual/interfaces/#man-interface-array)
   objects essentially instantly with just a few bytes of memory allocated.
* `ndgrid_array` : return a traditional tuple of `Array` objects,
  which takes much longer to create and can use a *lot* of memory.
  It is not recommended, but is included for comparison purposes.

See the documentation linked in the blue badges above for examples,
and for a 1-line lazy version of `meshgrid`.

As shown in the examples, the lazy version typically is as fast,
if not faster, than using conventional dense `Array` objects.

## Example
```julia
julia> using LazyGrids
(xg, yg) = ndgrid(1:2, 3:0.5:4)
([1 1 1; 2 2 2], [3.0 3.5 4.0; 3.0 3.5 4.0])

julia> xg
2×3 LazyGrids.GridUR{Int64, 1, 2}:
 1  1  1
 2  2  2

julia> yg
2×3 LazyGrids.GridSL{Float64, 2, 2, Base.TwicePrecision{Float64}, Base.TwicePrecision{Float64}}:
 3.0  3.5  4.0
 3.0  3.5  4.0

julia> x = range(-1,1,1001)
-1.0:0.002:1.0

julia> (xg, yg, zg) = ndgrid(x, x, x)
{... lots of output ...}

julia> size(xg) # show array dimensions
(1001, 1001, 1001)

julia> sizeof(xg) # show number of bytes used
72
```

## Related packages

* https://github.com/JuliaArrays/LazyArrays.jl
* https://github.com/mcabbott/LazyStack.jl
* https://github.com/ChrisRackauckas/VectorizedRoutines.jl
* https://github.com/JuliaArrays/RangeArrays.jl


### Compatibility

Tested with Julia ≥ 1.10.


<!-- URLs -->
[action-img]: https://github.com/JuliaArrays/LazyGrids.jl/workflows/CI/badge.svg
[action-url]: https://github.com/JuliaArrays/LazyGrids.jl/actions
[build-img]: https://github.com/JuliaArrays/LazyGrids.jl/workflows/CI/badge.svg?branch=main
[build-url]: https://github.com/JuliaArrays/LazyGrids.jl/actions?query=workflow%3ACI+branch%3Amain
[pkgeval-img]: https://juliaci.github.io/NanosoldierReports/pkgeval_badges/L/LazyGrids.svg
[pkgeval-url]: https://juliaci.github.io/NanosoldierReports/pkgeval_badges/L/LazyGrids.html
[code-blue-img]: https://img.shields.io/badge/code%20style-blue-4495d1.svg
[code-blue-url]: https://github.com/invenia/BlueStyle
[codecov-img]: https://codecov.io/github/JuliaArrays/LazyGrids.jl/coverage.svg?branch=main
[codecov-url]: https://codecov.io/github/JuliaArrays/LazyGrids.jl?branch=main
[docs-stable-img]: https://img.shields.io/badge/docs-stable-blue.svg
[docs-stable-url]: https://JuliaArrays.github.io/LazyGrids.jl/stable
[docs-dev-img]: https://img.shields.io/badge/docs-dev-blue.svg
[docs-dev-url]: https://JuliaArrays.github.io/LazyGrids.jl/dev
[license-img]: https://img.shields.io/badge/license-MIT-brightgreen.svg
[license-url]: LICENSE
[aqua-img]: https://img.shields.io/badge/Aqua.jl-%F0%9F%8C%A2-aqua.svg
[aqua-url]: https://github.com/JuliaTesting/Aqua.jl

# GoldenSequences.jl
Generalized golden sequences, a form of low discrepancy sequence or quasi random numbers

Golden sequence
===============
```
julia> GoldenSequence(0.0)[1]
0.6180339887498949
```

Shifted golden sequence starting in 0.5
```
julia>  GoldenSequence(0.5)[0]
0.5

julia>  GoldenSequence(0.5)[1]
0.1180339887498949
```

`GoldenSequence` returns an infinite iterator:
```
julia> collect(take(GoldenSequence(0.0), 10))
10-element Array{Float64,1}:
 0.0                
 0.6180339887498949
 0.2360679774997898
 0.8541019662496847
 0.4721359549995796
 0.09016994374947451
 0.7082039324993694
 0.3262379212492643
 0.9442719099991592
 0.5623058987490541
```

2D golden sequence
==================

```
julia>  GoldenSequence(2)[1]
(0.7548776662466927, 0.5698402909980532)
```

As low discrepancy series these number are well distributed (left), better than random numbers (right):

```julia
using Makie
n = 155
x = collect(Iterators.take(GoldenSequence(2), n))
p1 = scatter(x, markersize=0.02)
y = [(rand(),rand()) for i in 1:n]
p2 = scatter(y, markersize=0.02, color=:red)
vbox(p1, p2)
```

Interface
=========

```
GoldenSequence(n::Int) # Float64 n-dimensional golden sequence
GoldenSequence(x0::Number) # 1-d golden sequence shifted by `x0`
GoldenSequence(x0) # length(x)-d golden sequence shifted/starting in 'x0'
```

using GoldenSequences
using Base.Iterators
using LinearAlgebra
using Statistics
using Test
using Random
using Base.MathConstants
min_dist(x) = minimum(norm(x[i] .- x[j]) for (i,j) in product(eachindex(x), eachindex(x)) if i != j)

Random.seed!(1)
for d in 1:6
    @testset "dim d=$d" begin
        n = 5000
        xrand = [ntuple(d) do i rand() end for i in 1:n]
        xgolden = collect(take(GoldenSequence(d), n))
        @test all(isa.(xgolden, Ref(eltype(GoldenSequence(d)))))
        xgolden_ = reshape(reinterpret(Float64, xgolden), (d, n))
        xrand_ = reshape(reinterpret(Float64, xrand), (d, n))

        # Var(rand()) = 1/12

        @test all(xgolden_[1:d, 1] .== xgolden[1])
        @test norm(mean(xgolden_, dims=2) .- 0.5) < 1/sqrt(n)
        @test norm(cov(xgolden_') - I/12) < 1/sqrt(n)
        @test norm(mean(xgolden_, dims=2) .- 0.5) < norm(mean(xrand_, dims=2) .- 0.5)

        @test min_dist(xgolden) > min_dist(xrand)
        #@test norm(cov(xgolden_') - I/12) <  norm(cov(xrand_') - I/12)
    end
end

@testset "Numbers" begin
    @test collect(take(GoldenSequence(0.0), 10))[2] ≈ 1/golden
end
function f()
    g = GoldenSequence((0.,0.,0.))
    x, s = iterate(g)
    xsum = x[1] + x[2] + x[3]
    for i in 1:1000-1
        x, s = iterate(g, s)
        xsum += x[1] + x[2] + x[3]
    end
    xsum
end

@testset "Allocation" begin
    @test f() ≈ 1498.3407019608956
    @test  (@allocated f()) < 200
end
nothing

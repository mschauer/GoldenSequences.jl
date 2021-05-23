module GoldenSequences
#using Random
using FixedPointNumbers
using Roots
using Base.Iterators
using Base.MathConstants
export GoldenIntSequence, GoldenSequence, GoldenCartesianSequence

"""
	nextodd(x)

Next odd integer or next fixpoint number with odd representation.
"""
nextodd(i::Integer) = i >> 1 << 1 + one(i)
nextodd(z::T) where {T<:Normed} = reinterpret(T, nextodd(z.i))
prevodd(i::Integer) = i >> 1 << 1 - one(i)
prevodd(z::T) where {T<:Normed} = reinterpret(T, prevodd(z.i))

"""
    closecoprime(r, q)

Find number coprime to `q` close to `r`.
"""
function closecoprime(r, q)
	i = zero(r)
	while true
		gcd(r + i, q) == 1 && return r + i
		gcd(r - i, q) == 1 && return r - i
	    i += 1
	end # ends at r == 1 or r == q
end

struct GoldenSequence{T}
	x0::T
	coeff::T
end
Iterators.eltype(::Type{GoldenSequence{T}}) where {T} = T
Iterators.IteratorEltype(::Type{GoldenSequence{T}}) where {T} = Base.HasEltype()
Iterators.IteratorSize(::Type{GoldenSequence{T}}) where {T} = Iterators.IsInfinite()

struct GoldenIntSequence{T}
	x0::T
	coeff::T
end
Iterators.eltype(::Type{GoldenIntSequence{T}}) where {T} = T
Iterators.IteratorEltype(::Type{GoldenIntSequence{T}}) where {T} = Base.HasEltype()
Iterators.IteratorSize(::Type{GoldenIntSequence{T}}) where {T} = Iterators.IsInfinite()

f(x, d) = x^(d+1) - (x + one(x))

"""
GoldenCartesianSequence(dims...)

Golden Cartesian sequence on `CartesianIndices(dims)`.
Iterates `CartesianIndex`.
Spacefilling with  period `prod(dims...)`
if `dims` are coprime.

"""
struct GoldenCartesianSequence{T,S}
	coeff::T
	R::CartesianIndices{S}
end
Iterators.eltype(::Type{GoldenCartesianSequence{T,S}}) where {T,S} = T
Iterators.IteratorSize(::Type{GoldenCartesianSequence{T,S}}) where {T,S} = Iterators.IsInfinite()
Iterators.IteratorEltype(::Type{GoldenCartesianSequence{T,S}}) where {T,S} = Base.HasEltype()


"""
Compute or look up solution to x^(d+1) = x + 1
"""
function Phi(d)
	if d <= length(phis)
		phis[d]
	else
		find_zero(x->f(x, d), (1.0, 2.0))
	end
end
Phi(_, d) = Phi(d)

function GoldenSequence(x0)
	phi = Phi(eltype(T), n)
	t = ntuple(n) do i
	       T(phi^(-i))
	end
	GoldenSequence{typeof(t)}(x0, false*x0 .+ t)
end
function GoldenSequence(x0::NTuple{N,T}) where {N, T}
	phi = Phi(T, N)
	t = ntuple(N) do i
	       T(phi^(-i))
	end
	GoldenSequence{typeof(x0)}(x0, t)
end
GoldenSequence(n::Int) = GoldenSequence(ntuple(n) do i; 0.0 end)
GoldenSequence(T, n) = GoldenSequence(ntuple(n) do i; zero(T) end)

function GoldenSequence(x0::T) where {T <: Number}
	GoldenSequence{T}(x0, convert(T, 1/golden))
end

function GoldenSequence(::Type{T}, n) where {T<:Normed}
	phi = Phi(T, n)
	t = ntuple(n) do i
	       prevodd(T(phi^(-i)))
	end
	GoldenSequence{typeof(t)}(t)
end


function GoldenIntSequence(::Type{T}, n) where {T<:Unsigned}
	phi = Phi(T, n)
	t = ntuple(n) do i
	       (round(T, (typemax(T)+1.0)*phi^(-i)))
	end
	GoldenIntSequence{typeof(t)}(zero.(t), t)
end

GoldenCartesianSequence(R) = GoldenCartesianSequence(CartesianIndices(R))
function GoldenCartesianSequence(R::CartesianIndices)
	n = ndims(R)
	phi = Phi(n)
	t = ntuple(n) do i
	    	closecoprime(round(Int, size(R, i)*phi^(-i)), size(R, i))
	end
	GoldenCartesianSequence(t, R)
end

function Base.getindex(g::GoldenSequence{<:Tuple}, ind)
    ntuple(length(g.coeff)) do i
         (g.x0[i] + g.coeff[i]*ind) % true
    end
end
function Base.getindex(g::GoldenSequence, ind)
     (g.x0 .+ g.coeff.*ind) % true
end

function Base.iterate(g::GoldenSequence, val=g.x0)
	 state = (g.coeff .+ val) .% true
	 val, state
end
function Base.iterate(g::GoldenIntSequence, val=g.x0)
	 state = g.coeff .+ val # intentional overflow
	 val, state
end

function Base.iterate(g::GoldenCartesianSequence, val=g.R[1])
	state = mod.(g.coeff .+ Tuple(val), g.R.indices)
	val, typeof(val)(state)
end


const phis = [
1.618033988749895 # MathConstants.golden
1.324717957244746 # plastic number
1.2207440846057596
1.1673039782614187
1.1347241384015196
1.1127756842787055
1.09698155779856
1.085070245491451
1.0757660660868373
1.0682971889208415
1.0621691678642553
1.0570505752212285
1.0527109201475584
1.0489849347570346
1.045751024156342
1.0429177323017866
1.0404149477818474
1.0381880194364501
1.0361937171306836
1.034397396133807
1.032770966441043
1.0312914124792476
1.0299396966705234
1.0286999355282511
1.0275587723930215
1.0265048941462673
1.0255286547645814
1.0246217791365844
1.0237771278614651
1.0229885088662907
1.022250525317837
1.0215584519243472
1.020908133630809
1.0202959021164726
1.0197185065485594
1.0191730558310543
1.0186569701821966
1.0181679403286723
1.0177038929544147
1.0172629613133726
1.0168434601276772
1.0164438640594171
1.0160627891762175
1.0156989769358962
1.015351280299597
1.0150186516505193
1.0147001322501537
1.0143948430084788
1.0141019763809709
1.0138207892351239
1.013550596553797
1.0132907658630492
1.0130407122890395
1.0127998941626677
1.0125678091024284
1.0123439905158556
1.0121280044682868
1.0119194468747255
1.0117179409765626
1.0115231350700071
1.0113347004574071
1.01115232959636
1.010975734424683
1.0108046448420556
1.0106388073314982
1.0104779837058908
1.0103219499664957
1.0101704952619777
1.0100234209377514
1.00988053966664
1.0097416746528447
1.009606658902116
1.0094753345517855
1.009347552255012
1.009223170614191
1.0091020556590062
1.0089840803650738
1.0088691242095444
1.008757072760392
1.00864781729645
1.0085412544555385
1.0084372859082966
1.008335818055544
1.0082367617472274
1.0081400320211664
1.0080455478599986
1.0079532319648552
1.0078630105444437
1.0077748131183248
1.0076885723332831
1.0076042237917846
1.007521705891604
1.007440959675782
1.007361928692145
1.0072845588616808
1.0072087983551326
1.0071345974772095
1.0070619085578796
1.006990685850238
1.0069208854344955
]

end

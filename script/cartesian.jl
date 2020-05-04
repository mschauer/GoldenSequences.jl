using Makie
function img(m, n)
	a = zeros(Int, m, n)
	for (i, z) in enumerate(GoldenCartesianSequence((m, n)))
		a[z] = i
		i > m*n && break
	end
	!any(a .== 0) && @warn("Not spacefilling")
	a
end

m, n = 359, 451
m, n = @. denominator(rationalize(GoldenSequences.phis[2]^(-[1, 2]), tol=0.0000001))
@assert gcd(m, n) == 1
a = img(m, n)

heatmap( -a[1:200, 1:200] )
save("cartesian1.png")

pt(c) = Point2f0(c[1], c[2])


scatter(pt.(take(GoldenCartesianSequence((m, n)), 20*20)), color=:red, markersize=20.0)
scatter!(pt.(take(GoldenCartesianSequence((m, n)), m*n ÷ 525)), markersize=7.0)
#scatter!(pt.(take(GoldenCartesianSequence((m, n)), m*n ÷ 2)), grid=false, markersize=1.0)

save("cartesian2.png")


"""
Projects the values in p to within the generation limits, with a slack generator
to account for total power balance.

Assumes that the last entry of p is the slack generator for now.
"""
function reproject(ref::NetworkReference, p)
    @assert length(p) > 1
    @assert ref.ngen == length(p)
    totalpower = sum(p[i] for i in 1:(ref.ngen-1))
    newp = zeros(Float64, ref.ngen)
    for i in 1:(ref.ngen-1)
        newp[i] = max(pmin(ref,i), min(pmax(ref,i), p[i]))
    end
    newp[ref.ngen] = p[ref.ngen] + totalpower - sum(newp)
    newp
end

function ntransmissionviolations(ref, p, ω::Vector; atol::Float64 = 1e-4)
    f = lineflow(ref, p, ω)
    sum(abs(f[l]) > rate(ref,l) + atol for l in 1:ref.nline)
end

function ntransmissionviolations(ref, p, ω::Matrix; atol::Float64 = 1e-4)
    sum(ntransmissionviolations(ref, p, ω[i,:], atol=atol) for i in 1:size(ω,1))
end

function ngenerationviolations(ref, p; atol::Float64 = 1e-4)
    sum(pmin(ref,i) - atol > p[i] for i in 1:ref.ngen) +
    sum(pmax(ref,i) + atol < p[i] for i in 1:ref.ngen)
end
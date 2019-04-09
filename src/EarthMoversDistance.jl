# 
# EarthMoversDistance.jl
# Copyright 2018, 2019 Mirko Bunse
# 
# 
# This package wraps the original implementation of the Earth Mover's Distance (EMD)
# by Rubner et. al.
# 
# 
# EarthMoversDistance.jl is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with EarthMoversDistance.jl.  If not, see <http://www.gnu.org/licenses/>.
# 
# 
# The original implementation wrapped here remains courtesy of its authors.
# 
module EarthMoversDistance

using Distances

export EarthMovers, evaluate, earthmovers, earthmovers_flow
include("wrapper.jl") # wrap the C implementation to be called in Julia


"""
    EarthMovers(ground_distance::Union{Function, PreMetric})

Create an Earth Mover's Distance (EMD) semi-metric.

The EMD is defined over a `ground_distance` which computes the distance between elements
of signatures `a` and `b`, e.g. between the levels of two histograms.
"""
struct EarthMovers <: SemiMetric
    ground_distance::Function # compute distance between elements of signatures a and b
end


# implement the interface of Distances.jl - emd_flow is defined in wrapper.jl
Distances.evaluate(dist::EarthMovers, a::AbstractVector{T}, b::AbstractVector{T}) where {T<:Number} =
  earthmovers_flow(a, b, dist.ground_distance)[1] # only return EMD, drop flow


"""
    earthmovers(a, b, ground_distance::Union{Function, PreMetric})

Evaluate the Earth Mover's Distance (EMD) semi-metric between signatures `a` and `b`.

The EMD is defined over a `ground_distance` which computes the distance between elements
of signatures `a` and `b`, e.g. between the levels of two histograms.
"""
earthmovers(a::AbstractVector{T}, b::AbstractVector{T}, g::Function) where {T<:Number} =
  evaluate(EarthMovers(g), a, b) # shorthand


# allow PreMetric arguments instead of Function arguments
convert(::Type{Function}, g::PreMetric) = (ai, bi) -> evaluate(g, ai, bi) # conversion
EarthMovers(g::PreMetric) = EarthMovers(convert(Function, g)) # constructor
earthmovers(a::AbstractVector{T}, b::AbstractVector{T}, g::PreMetric) where {T<:Number} =
  earthmovers(a, b, convert(Function, g))
earthmovers_flow(a::AbstractVector{T}, b::AbstractVector{T}, g::PreMetric) where {T<:Number} =
  earthmovers_flow(a, b, convert(Function, g))


# mark deprecations
@deprecate emd      earthmovers
@deprecate emd_flow earthmovers_flow


end # module

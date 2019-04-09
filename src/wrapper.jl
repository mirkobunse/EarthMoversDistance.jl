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
using Libdl

FLOW_ARRAY_SIZE = 100 # flow operations reserved in C array = max size of signature


# add deps directory to the load path
function __init__()
    libpath = normpath(dirname(pathof(@__MODULE__)), "..", "deps")
    libfile = joinpath(libpath, "emd.$(Libdl.dlext)") # extension depends on OS
    if !isfile(libfile)
        error("Could not find $libfile. Check the build.log for an error during the build.")
    end
    if !in(libpath, Libdl.DL_LOAD_PATH) # only add once
        push!(Libdl.DL_LOAD_PATH, libpath)
    end
end


# input type of the EMD implementation
struct CSignature
    num_features::Cint
    features::Ptr{Cfloat}
    weights::Ptr{Cfloat}
end

# flow output type of the EMD implementation
struct CFlow
    from::Cint
    to::Cint
    amount::Cfloat
end

# 'Julian' flow type
struct Flow
    from::Int64
    to::Int64
    amount::Float64
end

convert(::Type{Flow}, cflow::CFlow) =
  Flow(cflow.from+1, cflow.to+1, cflow.amount)
convert(::Type{CSignature}, array::AbstractVector{T}) where {T<:Number} =
  CSignature( length(array),
              pointer(Base.convert(Vector{Cfloat}, 1:length(array))),
              pointer(Base.convert(Vector{Cfloat}, array)) )


# implement the wrapping
function emd_flow(a::CSignature, b::CSignature, g::Function)
    
    # create C function pointer to the ground distance function g
    cfunctionpointer = @cfunction $g Cfloat (Ref{Cfloat}, Ref{Cfloat})
    cflowsizeptr = Ref{Cint}(0)
    cflow = Array{CFlow}(undef, FLOW_ARRAY_SIZE)
    
    # call the C function emd, returning a Cfloat that is cast to Float64
    res = ccall((:emd, :emd), # function name and library name
                Cfloat,       # return type
                (Ref{CSignature}, Ref{CSignature}, Ptr{Nothing}, Ref{CFlow}, Ref{Cint}), # arg types
                Ref(a), Ref(b), cfunctionpointer, cflow, cflowsizeptr) # arguments
    
    # read out the flow that induces the EMD
    flow = map(x -> convert(Flow, x),
               cflow[1:min(cflowsizeptr[], FLOW_ARRAY_SIZE)]) # convert to the 'Julian' flow type
    
    return Base.convert(Float64, res), flow # return tuple of EMD and flow
    
end


# make the wrapper accessible with standard argument types
emd_flow(a::AbstractVector{T}, b::AbstractVector{T}, g::Function) where {T<:Number} =
  emd_flow(convert(CSignature, a), convert(CSignature, b), g)


@doc """
    emd_flow(a, b, ground_distance::Union{PreMetric, Function})

Return a tuple `(d, F)` of the Earth Mover's Distance `d` between the two signatures `a` and `b`
and an array `F` of flow operations that induces `d`.

The EMD is defined over a `ground_distance` which computes the distance between elements
of signatures `a` and `b`, e.g. between the levels of two histograms.
""" emd_flow # also provide documentation

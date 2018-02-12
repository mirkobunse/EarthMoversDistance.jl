# 
# EarthMoversDistance.jl
# Copyright 2018 Mirko Bunse
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


export emd, emd_flow


# number of flow operations reserved in the C flow array
FLOW_ARRAY_SIZE = 100 # max size of signature in emd library


# add deps directory to the load path
SO_PATH = joinpath(Pkg.dir("EarthMoversDistance"), "deps")
if !in(SO_PATH, Libdl.DL_LOAD_PATH) # only add once
    push!(Libdl.DL_LOAD_PATH, SO_PATH)
end


# input type of the EMD implementation
immutable CSignature
    num_features::Cint
    features::Ptr{Cfloat}
    weights::Ptr{Cfloat}
end

# flow output type of the EMD implementation
immutable CFlow
    from::Cint
    to::Cint
    amount::Cfloat
end

# 'julian' flow type
immutable Flow
    from::Int64
    to::Int64
    amount::Float64
end
Base.convert(::Type{Flow}, cflow::CFlow) = Flow(cflow.from+1, cflow.to+1, cflow.amount)


# convert histogram array to CSignature
Base.convert{T<:Number}(::Type{CSignature}, array::AbstractArray{T,1}) =
    CSignature(length(array), pointer(convert(Array{Cfloat,1}, 1:length(array))),
                              pointer(convert(Array{Cfloat,1}, array)))


"""
    emd(arr1, arr2, distance)

Compute the Earth Mover's Distance between the two histogram arrays. The `distance` function
computes the distance between two levels of the histogram.
"""
emd(any1, any2, distance::Function) =
    emd_flow(CSignature(any1), CSignature(any2), distance)[1] # only return EMD, drop flow

"""
    emd_flow(signature1, signature2, distance)

Return a tuple of the Earth Mover's Distance between the two signatures and an array of flow
operations that induces the EMD. The `distance` function computes the distance between two
levels of the histogram.
"""
function emd_flow(signature1::CSignature, signature2::CSignature, distance::Function)
    
    # create C function pointer to the distance function
    cfunctionpointer = cfunction((x::Cfloat, y::Cfloat) -> convert(Cfloat, distance(x, y)),
                                 Cfloat, (Ref{Cfloat}, Ref{Cfloat}))
    cflowsizeptr = Ref{Cint}(0)
    cflow = Array{CFlow}(FLOW_ARRAY_SIZE)
    
    # call the C function emd, returning a Cfloat that is cast to Float64
    res = ccall((:emd, :emd), # function name and library name
                Cfloat,       # return type
                (Ref{CSignature}, Ref{CSignature}, Ptr{Void}, Ref{CFlow}, Ref{Cint}),    # argument types
                Ref(signature1), Ref(signature2), cfunctionpointer, cflow, cflowsizeptr) # arguments
    
    # read out the flow that induces the EMD
    flow = map(Flow, cflow[1:min(cflowsizeptr[], FLOW_ARRAY_SIZE)]) # convert to 'Julian' flow type
    
    return convert(Float64, res), flow # return tuple of EMD and flow
    
end


end # module

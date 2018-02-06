module EarthMoverDistance

using Distances


# add deps directory to the load path of dynamic libraries
SO_PATH = joinpath(Pkg.dir("EarthMoverDistance"), "deps")
if !in(SO_PATH, Libdl.DL_LOAD_PATH) # only add once
    push!(Libdl.DL_LOAD_PATH, SO_PATH)
end


immutable Signature
    num_features::Cint
    features::Ptr{Cfloat}
    weights::Ptr{Cfloat}
end

immutable Flow
    from::Cint
    to::Cint
    amount::Cfloat
end


# ling2007efficient:
# 
# "Histograms can be viewed as a special type of signatures in that each histogram bin
# corresponds to an element in a signature. In this view, the histogram values are treated
# as the weights w_j in a signature S, and the grid locations (indices of bins) are treated
# as positions m_j in S."
Base.convert{T<:Number}(::Type{Signature}, array::AbstractArray{T,1}) =
    Signature(length(array), pointer(convert(Array{Cfloat,1}, 1:length(array))),
                             pointer(convert(Array{Cfloat,1}, array)))


"""
    emd(...)

Compute the Earth Mover Distance
"""
function emd(signature1::Signature, signature2::Signature, distance::Function)
    
    # create C function pointer to the distance function
    cfunctionpointer = cfunction(distance, Cfloat, (Ref{Cfloat}, Ref{Cfloat}))
    flowsizeptr = Ref{Cint}(0)
    flowptr = Ref(Flow(0, 0, 0.0)) # TODO Ref to array
    
    # call the C function emd, returning a Cfloat that is cast to Float64
    res = ccall((:emd, :emd), # function name and library name
                Cfloat,       # return type
                (Ref{Signature}, Ref{Signature}, Ptr{Void}, Ref{Flow}, Ref{Cint}),        # argument types
                Ref(signature1), Ref(signature2), cfunctionpointer, flowptr, flowsizeptr) # arguments
    println(flowsizeptr[], " flow operations were needed")
    println(flowptr[]) # TODO retrieve full array of flows
    return convert(Float64, res)
    
end

emd(any1, any2, distance::Function=cityblock) = emd(Signature(any1), Signature(any2), distance)


end # module

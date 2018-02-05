module EarthMoverDistance


# add deps directory to the load path of dynamic libraries
SO_PATH = joinpath(Pkg.dir("EarthMoverDistance"), "deps")
if !in(SO_PATH, Libdl.DL_LOAD_PATH) # only add once
    push!(Libdl.DL_LOAD_PATH, SO_PATH)
end


"""
    emd(...)

Compute the Earth Mover Distance
"""
function emd()
    
    # TODO create signatures for histograms
    # TODO cast these to C structs
    
    # example: foo just prints to the console
    ccall((:foo, :emd), Void, ())
    
    # ccall((:emd, :emd), Float32, (...))
    
end


end # module

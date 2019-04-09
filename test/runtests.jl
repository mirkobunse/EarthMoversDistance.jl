using Test, Distances, EarthMoversDistance

# size of histogram arrays
NUM_LEVELS = 16

# cityblock distance from Distances.jl
cityblock = Cityblock() # (x, y) -> abs(x - y)

# simple case 1)
# in each histogram, only one level is 1.0, the others are 0.0
for i in 1:NUM_LEVELS, j in 1:NUM_LEVELS
    
    # construct histograms
    histogram1 = zeros(Float64, NUM_LEVELS)
    histogram1[i] = 1.0
    histogram2 = zeros(Float64, NUM_LEVELS)
    histogram2[j] = 1.0
    
    # test cityblock distance
    dist = evaluate(cityblock, i, j)
    emd  = EarthMoversDistance.earthmovers(histogram1, histogram2, cityblock)
    
    if dist != emd
        @warn "Case 1 failing" i j
    end
    @test dist == emd
    
end

# simple case 2)
# one histogram like before, but the other has two levels that are 0.5
for i in 1:NUM_LEVELS, j in 1:NUM_LEVELS, k in 1:NUM_LEVELS
    
    # construct histograms
    histogram1 = zeros(Float64, NUM_LEVELS)
    histogram1[i] = 1.0
    histogram2 = zeros(Float64, NUM_LEVELS)
    histogram2[j] = 0.5
    histogram2[k] = 0.5
    
    # test cityblock distance
    dist = evaluate(cityblock, i, j) * 0.5 + evaluate(cityblock, i, k) * 0.5
    emd  = EarthMoversDistance.earthmovers(histogram1, histogram2, cityblock)
    
    if dist != emd
        @warn "Case 2 failing" i j k
    end
    @test dist == emd
    
end

# case 3: random histograms with single flow)
for i in 1:100 # test hundred times
    histogram1 = rand(Float64, NUM_LEVELS)
    histogram2 = copy(histogram1)
    
    from = rand(1:NUM_LEVELS)
    to   = rand(setdiff(1:NUM_LEVELS, [from]))
    flow = rand(Float64) * min(histogram2[from], 1 - histogram2[to])
    histogram2[from] = histogram2[from] - flow
    histogram2[to]   = histogram2[to]   + flow
    cost = flow * evaluate(cityblock, from, to)

    emd  = EarthMoversDistance.earthmovers(histogram1, histogram2, cityblock)
    upperbound = cost / sum(histogram1) # only upper bound because min flow could come from elsewhere
    if emd > upperbound && !isapprox(emd, upperbound, atol=1e-6)
        println(histogram1)
        println("$from -> $to: $flow")
        println(histogram2)
        @warn "Case 3 failing" emd upperbound emd-upperbound
    end
    @test emd <= upperbound || isapprox(emd, upperbound, atol=1e-6)
end

# case 4: random histograms with 10 flows)
for i in 1:100 # test hundred times
    histogram1 = rand(Float64, NUM_LEVELS)
    histogram2 = copy(histogram1)
    totalcost  = 0.0
    
    for j in 1:10
        from = rand(1:NUM_LEVELS)
        to   = rand(setdiff(1:NUM_LEVELS, [from]))
        flow = rand(Float64) * min(histogram2[from], 1 - histogram2[to])
        histogram2[from] = histogram2[from] - flow
        histogram2[to]   = histogram2[to]   + flow
        totalcost += flow * evaluate(cityblock, from, to)
    end

    emd  = EarthMoversDistance.earthmovers(histogram1, histogram2, cityblock)
    upperbound = totalcost / sum(histogram1)
    if emd > upperbound && !isapprox(emd, upperbound, atol=1e-6)
        @warn "Case 4 failing" emd upperbound emd-upperbound
    end
    @test emd <= upperbound || isapprox(emd, upperbound, atol=1e-6)
end


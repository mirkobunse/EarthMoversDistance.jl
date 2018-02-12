using Base.Test, EarthMoversDistance, EarthMoversDistance.FLOW_ARRAY_SIZE

# size of histogram arrays
NUM_LEVELS = 16

# cityblock distance
cityblock = (x, y) -> abs(x - y)

# simple case 1)
# in each histogram, only one level is 1.0, the others are 0.0
for i in 1:NUM_LEVELS, j in 1:NUM_LEVELS
    
    # construct histograms
    histogram1 = zeros(Float64, NUM_LEVELS)
    histogram1[i] = 1.0
    histogram2 = zeros(Float64, NUM_LEVELS)
    histogram2[j] = 1.0
    
    # test cityblock distance
    dist = cityblock(i, j)
    emd  = EarthMoversDistance.emd(histogram1, histogram2, cityblock)
    
    if dist != emd
        warn("Case 1 failing for cityblock distance with i = $i, j = $j")
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
    dist = cityblock(i, j) * 0.5 + cityblock(i, k) * 0.5
    emd  = EarthMoversDistance.emd(histogram1, histogram2, cityblock)
    
    if dist != emd
        warn("Case 2 failing with i = $i, j = $j, k = $k")
    end
    @test dist == emd
    
end

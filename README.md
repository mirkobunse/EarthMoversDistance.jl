[![Build Status](https://travis-ci.org/mirkobunse/EarthMoversDistance.jl.svg?branch=master)](https://travis-ci.org/mirkobunse/EarthMoversDistance.jl)
[![codecov](https://codecov.io/gh/mirkobunse/EarthMoversDistance.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/mirkobunse/EarthMoversDistance.jl)

# EarthMoversDistance.jl

This project wraps the original implementation of the Earth Mover's Distance (EMD) by Rubner
et. al. for Julia.

Please cite the original paper if you use this project:

      @inproceedings{rubner1998metric,
        title={A metric for distributions with applications to image databases},
        author={Rubner, Yossi and Tomasi, Carlo and Guibas, Leonidas J},
        booktitle={Computer Vision, 1998. Sixth International Conference on},
        pages={59--66},
        year={1998},
        organization={IEEE}
      }


### Usage

Clone this package from the Julia REPL (version 0.7 and above):

      using Pkg
      Pkg.clone("https://github.com/mirkobunse/EarthMoversDistance.jl.git")

The EMD requires a measure of distance between signature features (the _ground distance_,
e.g., between levels of a histogram). You can define your own distance measure as a
function, or you can use the methods from [Distances.jl](https://github.com/JuliaStats/Distances.jl).

      using EarthMoversDistance
      
      histogram1 = rand(8)
      histogram2 = rand(8)
      emd(histogram1, histogram2, (x, y) -> abs(x - y)) # custom ground distance function
      
      using Distances
      emd(histogram1, histogram2, cityblock) # distance function from the Distances package

In the above example, the values of `x` and `y` will be the indices of the two histograms.


### Limitations and Future Work

Currently, only the EMD between one-dimensional histograms is computed.
However, the project is easily extensible - Feel free to contribute!

Since Rubner's paper, several algorithms computing the EMD have been proposed.
Most of them are limited to special cases, but tremendously improve on efficiency.
Who would not love to see some native Julia implementations of these algorithms?
`EarthMoversDistance.jl` can help in testing these during development.


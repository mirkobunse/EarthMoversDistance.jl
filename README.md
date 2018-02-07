# EarthMoverDistance.jl

This project wraps the original implementation of the Earth Mover Distance (EMD) by Rubner
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

Clone this package from the Julia REPL:

    Pkg.clone("git://github.com/mirkobunse/EarthMoverDistance.jl.git")

Open the REPL documentation for more information:
    
    using EarthMoverDistance
    ?emd
    ?emd_flow


### Limitations

Currently, only the EMD between onedimensional histograms can be computed.
However, the project is easily extensible - Feel free to contribute!
Only little Julia skills are needed.


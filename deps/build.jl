using Libdl

# where to get the C source files from
HEADER_URL         = "http://robotics.stanford.edu/~rubner/emd/emd.h"
IMPLEMENTATION_URL = "http://robotics.stanford.edu/~rubner/emd/emd.c"

# clean up
rm("src", force=true, recursive=true)

# download the source files
mkdir("src")
download(HEADER_URL,         "src/" * basename(HEADER_URL))
download(IMPLEMENTATION_URL, "src/" * basename(IMPLEMENTATION_URL))

# feature type should be float (funny -i'' works on both Linux and Mac)
run(`sed -i\'\' 's/typedef int feature_t;/typedef float feature_t;/g' src/emd.h`)

# create a shared library: compile and link
libfile = "emd.$(Libdl.dlext)" # extension depends on OS
run(`gcc -Wall -fpic -shared -o $libfile src/emd.c`)

# check for successful creation of the library
if !isfile(libfile)
    error("The shared library $libfile was not created during the build")
end

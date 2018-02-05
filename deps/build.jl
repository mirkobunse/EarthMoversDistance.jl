# where to get the C source files from
HEADER_URL         = "http://robotics.stanford.edu/~rubner/emd/emd.h"
IMPLEMENTATION_URL = "http://robotics.stanford.edu/~rubner/emd/emd.c"

# clean up
rm("src", force=true, recursive=true)

# download the source files
mkdir("src")
run(`wget --directory-prefix=src/ $HEADER_URL $IMPLEMENTATION_URL`)

# feature type should be float
run(`sed -i 's/typedef int feature_t;/typedef float feature_t;/g' src/emd.h`)

# create a shared library: compile and link
run(`gcc -Wall -fpic -shared -o emd.so src/emd.c`)

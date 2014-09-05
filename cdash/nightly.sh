#!/bin/bash

# load environment variables
source /usr/local/etc/bash_profile
module load cmake/latest
module load mpich3/3.1.2-thread-multiple
module load parmetis/mpich3.1.2/4.0.3
module load zoltan/mpich3.1.2/3.8
module load simmetrix/simModSuite
module load netcdf
module load llvm/latest

#add my custom Git install to the PATH
#since the version on avatar is very old
export PATH=/lore/dibanez/bin:$PATH

#cdash output root
cd /lore/dibanez/cdash

#run nightly.cmake script
ctest -VV -D Nightly -S /lore/dibanez/core/cdash/nightly.cmake &> log

#core repository checked out by nightly.cmake
cd /lore/dibanez/cdash/build/core
#build the Doxygen html documentation
make doc
#remove the old web documentation
rm -rf /net/web/public/dibanez/core
#replace it with the generated one
cp -r doc/html /net/web/public/dibanez/core

#remove compilation directories created by nightly.cmake
cd /lore/dibanez/cdash
rm -rf build/

cd /lore/dibanez
find meshes/phasta -name "*procs_case" | xargs rm -rf
find meshes/phasta -name "out_mesh" | xargs rm -rf

# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder, Pkg

name = "HAMdetector_model_binaries"
version = v"0.1.0"

# Collection of sources required to complete build
sources = [
    GitSource("https://github.com/HAMdetector/Escape.jl.git", "27c98e5cd34a015d66ab0898e49b50736acd89aa"),
    ArchiveSource("https://github.com/stan-dev/cmdstan/releases/download/v2.27.0/cmdstan-2.27.0.tar.gz", "ff71f4d255cf26c2d8366a8173402656a659399468871305056aa3d56329c1d5")
]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir
cd cmdstan-2.27.0/

echo 'CXX=c++' >> make/local
echo 'TBB_CXX_TYPE=c++' >> make/local
echo 'STAN_THREADS=true' >> make/local

cd stan/lib/stan_math/lib/tbb_2020.3/build/
cp linux.inc x86_64-linux-gnu.inc
cp linux.gcc.inc x86_64-linux-gnu.c++.inc
cd ../../../../../..

make build
make runtime=cc5.2.0_libc2.12.2_kernel5.11.12177.current ../Escape.jl/models/model_4
make runtime=cc5.2.0_libc2.12.2_kernel5.11.12177.current ../Escape.jl/models/model_3
make runtime=cc5.2.0_libc2.12.2_kernel5.11.12177.current ../Escape.jl/models/model_2
make runtime=cc5.2.0_libc2.12.2_kernel5.11.12177.current ../Escape.jl/models/model_1

cd ../Escape.jl/models/

mkdir ${bindir}
mkdir ${libdir}

cp model_4 ${bindir}/model_4
cp model_3 ${bindir}/model_3
cp model_2 ${bindir}/model_2
cp model_1 ${bindir}/model_1

cd ../../cmdstan-2.27.0/stan/lib/stan_math/lib/tbb

cp libtbb.so.2 ${libdir}/libtbb.so.2
cp libtbbmalloc.so.2 ${libdir}/libtbbmalloc.so.2
cp libtbbmalloc_proxy.so.2 ${libdir}/libtbbmallo_proxy.so.2

install_license ${WORKSPACE}/srcdir/cmdstan-2.27.0/LICENSE

exit
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = [
    Platform("x86_64", "linux"; libc = "glibc")
]

platforms = expand_cxxstring_abis(platforms)

# The products that we will ensure are always built
products = [
    ExecutableProduct("model_2", :model_2),
    ExecutableProduct("model_1", :model_1),
    ExecutableProduct("model_3", :model_3),
    ExecutableProduct("model_4", :model_4)
]

# Dependencies that must be installed before this package can be built
dependencies = Dependency[
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies; julia_compat="1.6", preferred_gcc_version = v"5.2.0")

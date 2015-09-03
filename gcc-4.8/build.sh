# Install gcc to its very own prefix.
# GCC must not be installed to the same prefix as the environment,
# because $GCC_PREFIX/include is automatically considered to be a
# "system" header path.
# That could cause -I$PREFIX/include to be essentially ignored in users' recipes
# (It would still be on the search path, but it would be in the wrong position in the search order.)
GCC_PREFIX="$PREFIX/gcc"
mkdir "$GCC_PREFIX"

ln -s "$PREFIX/lib" "$PREFIX/lib64"

if [ "$(uname)" == "Darwin" ]; then
    export LDFLAGS="-Wl,-headerpad_max_install_names"
    export BOOT_LDFLAGS="-Wl,-headerpad_max_install_names"
    export DYLD_FALLBACK_LIBRARY_PATH="$PREFIX/lib"

    ./configure \
        --prefix="$GCC_PREFIX" \
        --with-gxx-include-dir="$GCC_PREFIX/include/c++" \
        --bindir="$PREFIX/bin" \
        --datarootdir="$PREFIX/share" \
        --libdir="$PREFIX/lib" \
        --with-gmp="$PREFIX" \
        --with-mpfr="$PREFIX" \
        --with-mpc="$PREFIX" \
        --with-isl="$PREFIX" \
        --with-cloog="$PREFIX" \
        --with-boot-ldflags=$LDFLAGS \
        --with-stage1-ldflags=$LDFLAGS \
        --enable-checking=release \
        --with-tune=generic \
        --disable-multilib
else
    # For reference during post-link.sh, record some
    # details about the OS this binary was produced with.
    mkdir -p "${PREFIX}/share"
    cat /etc/*-release > "${PREFIX}/share/conda-gcc-build-machine-os-details"
    ./configure \
        --prefix="$GCC_PREFIX" \
        --with-gxx-include-dir="$GCC_PREFIX/include/c++" \
        --bindir="$PREFIX/bin" \
        --datarootdir="$PREFIX/share" \
        --libdir="$PREFIX"/lib \
        --with-gmp="$PREFIX" \
        --with-mpfr="$PREFIX" \
        --with-mpc="$PREFIX" \
        --with-isl="$PREFIX" \
        --with-cloog="$PREFIX" \
        --enable-checking=release \
        --with-tune=generic \
        --disable-multilib
fi
make -j$CPU_COUNT
make install
rm "$PREFIX"/lib64

# Link cc to gcc
(cd "$PREFIX"/bin && ln -s gcc cc)

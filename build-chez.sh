#!/bin/sh

PETITE=1

set -e

if ! [ -x "$(command -v node)" ]; then
    echo 'node is not installed.' >&2
    echo 'Please install it at https://nodejs.org/en/' >&2
    exit 1
fi

if ! [ -x "$(command -v make)" ]; then
    echo 'make is not installed.' >&2
    exit 1
fi

if ! [ -x "$(command -v emcc)" ]; then
    echo 'emcc is not installed.' >&2
    echo 'Please install it at https://emscripten.org/docs/getting_started/downloads.html' >&2
    exit 1
fi

git submodule update

cd ChezScheme
git submodule update

if [ $PETITE ]; then
    empetite='--empetite'
fi

./configure --emscripten $empetite

make

echo 'Finished make'

cd em-pb/c

# The default build doesn't quite work for us, so we create our own.
emcc -DDISABLE_ICONV -Wpointer-arith -Wall -Wextra -Wno-implicit-fallthrough \
    -Os \
    -s USE_ZLIB=1 \
    -s EXIT_RUNTIME=1 \
    -s ALLOW_MEMORY_GROWTH=1 \
    -s MODULARIZE=1 \
    -s EXPORT_ES6=1 \
    -s EXPORTED_RUNTIME_METHODS='["FS", "FS_getMode", "removeRunDependency", "addRunDependency"]' \
    -o ../bin/pb/scheme.js ../boot/pb/main.o ../boot/pb/libkernel.a ../lz4/lib/liblz4.a

echo 'Finished building'

cd ..

mkdir -p ../../src/chez/
cp bin/pb/scheme.wasm ../../src/chez/
cp bin/pb/scheme.js ../../src/chez/
cp boot/pb/petite.boot ../../src/chez/
if ! [ $PETITE ]; then
    cp boot/pb/scheme.boot ../../src/chez/
fi


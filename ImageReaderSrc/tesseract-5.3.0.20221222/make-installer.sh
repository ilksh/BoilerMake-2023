#!/bin/sh

TAG=$(git describe | sed s/-.*//).$(date +%Y%m%d)

git tag -a v$TAG -m "Tesseract $TAG"

ARCHS="i686 x86_64"

./autogen.sh

for ARCH in $ARCHS; do
  HOST=$ARCH-w64-mingw32
  BUILDDIR=bin/ndebug/$HOST-$TAG

  rm -rf $BUILDDIR
  mkdir -p $BUILDDIR
  (
  cd $BUILDDIR
  # Disable OpenMP (see https://github.com/tesseract-ocr/tesseract/issues/1662).
  ../../../configure --disable-openmp --host=$HOST --prefix=/usr/$HOST CXX=$HOST-g++-posix CXXFLAGS="-fno-math-errno -Wall -Wextra -Wpedantic -g -O2"
  make install-jars install training-install html prefix=$PWD/usr/$HOST
  (
  cd $PWD/usr/$HOST/bin
  for file in *.exe *.dll; do
    signcode $file
  done
  )
  make winsetup prefix=$PWD/usr/$HOST SIGNCODE=signcode
  )
done

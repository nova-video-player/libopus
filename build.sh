#!/bin/bash

source ../../AVP/android-setup-light.sh

if [ ! -d "opus" ]
then
  git clone https://github.com/xiph/opus.git
  # get a fixed version after 1.3.1 to get cmake support
  cd opus
  git checkout 2554a89
  cd ..
fi

API_LEVEL=21

for ABI in armeabi-v7a arm64-v8a x86 x86_64
do
  if [ ! -f "lib/${ABI}/libopus.so" ]
  then
    rm -rf build-${ABI}
    mkdir -p build-${ABI}
    pushd build-${ABI}
    ${CMAKE_PATH}/bin/cmake \
      -GNinja \
      -DBUILD_SHARED_LIBS=ON \
      -DANDROID_ABI=${ABI} \
      -DANDROID_NDK=${NDK_PATH} \
      -DCMAKE_LIBRARY_OUTPUT_DIRECTORY=../lib/${ABI} \
      -DCMAKE_BUILD_TYPE=Debug  \
      -DCMAKE_TOOLCHAIN_FILE=${NDK_PATH}/build/cmake/android.toolchain.cmake \
      -DANDROID_NATIVE_API_LEVEL=${API_LEVEL} \
      ../opus
    ninja
    popd
  else
    echo "Already built for ${ABI}"
  fi
done

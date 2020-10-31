#!/bin/bash

if [ ! -d "opus" ]
then
  git clone https://github.com/xiph/opus.git
  # get a fixed version after 1.3.1 to get cmake support
  cd opus
  git checkout fad505e8ed6190062515668e3a480ada583e1637
  cd ..
fi

if [ ! -d "${ANDROID_HOME}/cmake" ]
then
  cmake=$(pkg="cmake"; ${ANDROID_HOME}/tools/bin/sdkmanager --list | grep ${pkg} | sed "s/^.*\($pkg;[0-9\.]*\).*$/\1/g" | head -n 1)
  ${ANDROID_HOME}/tools/bin/sdkmanager --install "${cmake}"
fi

[ ! -d "${ANDROID_HOME}/ndk" ] && ${ANDROID_HOME}/tools/bin/sdkmanager --install ndk-bundle

# latest cmake and ndk
CMAKE_PATH=$(ls -d ${ANDROID_HOME}/cmake/* | sort -V | tail -n 1)
echo CMAKE_PATH is ${CMAKE_PATH}
NDK_PATH=$(ls -d ${ANDROID_HOME}/ndk/* | sort -V | tail -n 1)
echo NDK_PATH is ${NDK_PATH}

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
      -DCMAKE_C_FLAGS="-s" \
      ../opus
    ninja
    popd
  else
    echo "Already built for ${ABI}"
  fi
done

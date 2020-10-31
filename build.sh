#!/bin/bash

[ ! -d "opus" ] && git clone https://github.com/xiph/opus.git

if [ ! -d "${ANDROID_HOME}/cmake" ]
then
  cmake=$(pkg="cmake"; ${ANDROID_HOME}/tools/bin/sdkmanager --list | grep ${pkg} | sed "s/^.*\($pkg;[0-9\.]*\).*$/\1/g" | head -n 1)
  ${ANDROID_HOME}/tools/bin/sdkmanager --install "${cmake}"
fi

if [ ! -d "${ANDROID_HOME}/ndk" ]
then
  # ndk-bundle is special, no need of version number
  ${ANDROID_HOME}/tools/bin/sdkmanager --install ndk-bundle
fi

# latest cmake and ndk
CMAKE_PATH=$(ls -d ${ANDROID_HOME}/cmake/* | sort -V | tail -n 1)
echo CMAKE_PATH is ${CMAKE_PATH}
NDK_PATH=$(ls -d ${ANDROID_HOME}/ndk/* | sort -V | tail -n 1)
echo NDK_PATH is ${NDK_PATH}

API_LEVEL=23

for ABI in armeabi-v7a arm64-v8a x86 x86_64
do
  if [ ! -d "build-${ABI}" ]
  then
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
    exit 0
  fi
done

rm -rf opus

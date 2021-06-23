#!/usr/bin/env sh
export ANDROID_NDK="$ANDROID_NDK"
export ANDROID_SDK_ROOT="$ANDROID_SDK_ROOT"
export GRPC_ROOT="$GRPC_ROOT"

function build {
  ABI=$1
  echo "ANDROID_NDK $ANDROID_NDK"
  echo "ANDROID_SDK_ROOT $ANDROID_SDK_ROOT"
  echo "GRPC_ROOT $OPENCV_ROOT"
  pushd $GRPC_ROOT

  echo "Building gRPC for $ABI"
  mkdir build_$ABI
  pushd build_$ABI
  mkdir install

  cmake -DANDROID_ABI=$ABI \
        -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK}/build/cmake/android.toolchain.cmake \
        -DANDROID_NDK=${ANDROID_NDK} \
        -DANDROID_STL="c++_shared" \
        -DANDROID_NATIVE_API_LEVEL="24" \
        -DANDROID_PLATFORM="24" \
        -DCMAKE_POSITION_INDEPENDENT_CODE="TRUE" \
        -Dprotobuf_BUILD_PROTOC_BINARIES="OFF" \
        -DgRPC_BUILD_CODEGEN="OFF" \
        -DgRPC_INSTALL="ON" \
        -DgRPC_USE_PROTO_LITE="ON" \
        -DgRPC_BUILD_TESTS="OFF" \
        -DgRPC_BUILD_GRPC_CSHARP_PLUGIN="OFF" \
        -DCMAKE_BUILD_TYPE="Release" \
        -DCMAKE_C_FLAGS="-Os" \
        -DCMAKE_CXX_FLAGS="-std=c++17 -frtti -fexceptions -Os" \
        -DCMAKE_EXE_LINKER_FLAGS="-s" \
        -DCMAKE_INSTALL_PREFIX="$GRPC_ROOT/build_$ABI/install" \
        ..

  make -j8
  make install

  popd
  popd
}

DIST_DIR=`dirname ${BASH_SOURCE[0]}`
DIST_DIR=`realpath $DIST_DIR`

pushd $GRPC_ROOT
git apply $DIST_DIR/patch/000-fix.patch
popd

build x86_64
build arm64-v8a

#ANDROID_NDK=~/Library/Android/sdk/ndk/21.4.7075529 ANDROID_SDK_ROOT=~/Library/Android/sdk GRPC_ROOT=~/gits/grpc/ ./build.sh
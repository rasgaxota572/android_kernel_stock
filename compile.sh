#!/bin/sh

# Option on whether to upload the produced build to a file hosting service [Useful for CI builds]
UPLD=1
	if [ $UPLD = 1 ]; then
		UPLD_PROV="https://oshi.at"
        UPLD_PROV2="https://transfer.sh"
	fi

sudo apt-get install ccache

# Clone toolchain from its repository
mkdir clang && curl -Lsq https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/refs/heads/android11-release/clang-r383902.tar.gz -o - | tar -xzf - -C clang
git clone --depth=1 https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 -b android11-release binutils
git clone --depth=1 https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9 -b android11-release binutils-32

# Clone AnyKernel3
git clone --depth=1 https://github.com/100Daisy/AnyKernel3 -b sunburn-$1

# Export the PATH variable
export PATH="$(pwd)/clang/bin:$(pwd)/binutils/bin:$(pwd)/binutils-32/bin:$PATH"

# Clean up out
find out -delete
mkdir out

# Compile the kernel
build_clang() {
    make -j$(nproc --all) \
    O=out \
    ARCH=arm64 \
    CC=clang \
    HOSTCC=clang \
    CLANG_TRIPLE=aarch64-linux-gnu- \
    CROSS_COMPILE=aarch64-linux-android- \
    CROSS_COMPILE_ARM32=arm-linux-androideabi-
}

make vendor/sunburn-$1_defconfig ARCH=arm64 O=out CC=clang
build_clang

if [ $? -ne 0 ]; then
    echo "The kernel has failed to compile. Please check the terminal output for further details."
    exit 1
fi

#!/bin/bash

export ARCH=arm64
export SUBARCH=arm64
export CC=clang
export LLVM=1
export CROSS_COMPILE=aarch64-linux-gnu-
export CROSS_COMPILE_ARM32=arm-linux-gnueabi-

make sunburn-guamp_defconfig
make -j$(nproc) CC=clang LLVM=1

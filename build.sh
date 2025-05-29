#!/bin/bash
function compile()
{
source ~/.bashrc && source ~/.profile
export LC_ALL=C
export USE_CCACHE=1
export CCACHE_DIR=~/.ccache
ccache -M 40G
ccache -o compression=true
export ARCH=arm64
export KBUILD_BUILD_HOST="pop-os"
export KBUILD_BUILD_USER="luks"
TANGGAL=$(date +"%Y%m%d-%H")
clangbin=clang/bin/clang
if ! [ -a $clangbin ]; then git clone --depth=1 https://gitlab.com/RismaPwd/clang.git clang
fi	
rm -rf out
rm -rf AnyKernel
make O=out ARCH=arm64 salaa_defconfig
PATH="${PWD}/clang/bin:${PATH}" \
make -j$(nproc --all) O=out \
                      ARCH=arm64 \
                      CC="clang" \
                      LLVM=1 \
                      LLVM_IAS=1 \
                      LD=ld.lld \
                      AR=llvm-ar \
                      NM=llvm-nm \
                      STRIP=llvm-strip \
                      OBJCOPY=llvm-objcopy \
                      OBJDUMP=llvm-objdump \
                      CROSS_COMPILE=aarch64-linux-gnu- \
                      CROSS_COMPILE_ARM32=arm-linux-gnueabi- \
                      CONFIG_NO_ERROR_ON_MISMATCH=y
}
function zupload()
{
zimage=out/arch/arm64/boot/Image.gz-dtb
if ! [ -a $zimage ];
then
echo  " Failed To Compile Kernel"
else
echo -e " Kernel Compile Successful"
git clone --depth=1 https://github.com/Luks-organization/KerneSU_AnyKernel3 AnyKernel
cp out/arch/arm64/boot/Image.gz-dtb AnyKernel
cd AnyKernel
zip -r9 Lineage_salaa-KernelSU-Next-${TANGGAL}.zip *
cd ../
make clean && make mrproper
fi
}
compile
zupload

#!/bin/bash
function compile()
{
source ~/.bashrc && source ~/.profile
export LC_ALL=C && export USE_CCACHE=1
ccache -M 50G
export ARCH=arm64
export KBUILD_BUILD_HOST="android-build-mtk"
export KBUILD_BUILD_USER="Luks"
export DEVICE=salaa
DATE=$(date '+%Y%m%d-%H%M')

clangbin=clang/bin/clang
if ! [ -a $clangbin ]; then git clone --depth=1 https://gitlab.com/LeCmnGend/clang.git -b clang-19 clang
fi
	
rm -rf out
make O=out ARCH=arm64 salaa_defconfig
mkdir tmp
cp -r out/.config tmp/final_config
find out -type f -name "*.ko" -delete
make O=out ARCH=arm64 tmp/final_config
rm -rf tmp 

CCACHE_EXEC=$(which ccache)

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
	              modules \
	              Image.gz-dtb modules \
                      CONFIG_NO_ERROR_ON_MISMATCH=y 2>&1 | tee error.log
}
function zupload()
{
rm -rf AnyKernel
git clone --depth=1 https://github.com/Luks-organization/AnyKernel3 AnyKernel
mkdir -p AnyKernel/modules/system/vendor/lib/modules
find out -type f -name "*.ko" -exec cp -f {} AnyKernel/modules/system/vendor/lib/modules \;
cp out/arch/arm64/boot/Image.gz-dtb AnyKernel
cd AnyKernel
zip -r9 4.14.456-Openela-KERNEL-${DEVICE}-${DATE}-BKA.zip * -x '*.git*' README.md *placeholder
cd ../
make clean && make mrproper
}
compile
zupload

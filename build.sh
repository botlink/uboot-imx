#!/usr/bin/env bash

#set -o xtrace
set -o errexit -o nounset -o pipefail -o errtrace
IFS=$'\n\t'

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# git checkout xrd2

if [ ! -v CROSS_COMPILE ] || [ ! -v ARCH ] ; then
    echo "Set up build environment first."
    exit 1
fi

if [ ! -e .config ] ; then
    make xrd2_defconfig
fi

make -j $(nproc)

deploy_image_dir=/workdir/build/tmp/deploy/images/imx8mp-var-dart/
boot_tools=${deploy_image_dir}/imx-boot-tools

# # $deploy_dir_image
# u-boot.bin -> u-boot-sd-1.0-r0.bin
# u-boot.bin-sd -> u-boot-sd-1.0-r0.bin
# u-boot-imx8mp-var-dart.bin -> u-boot-sd-1.0-r0.bin
# u-boot-imx8mp-var-dart.bin-sd -> u-boot-sd-1.0-r0.bin
# u-boot-sd-1.0-r0.bin
# u-boot-spl.bin -> u-boot-spl.bin-imx8mp-var-dart-1.0-r0-sd-1.0-r0
# u-boot-spl.bin-imx8mp-var-dart -> u-boot-spl.bin-imx8mp-var-dart-1.0-r0-sd-1.0-r0
# u-boot-spl.bin-imx8mp-var-dart-1.0-r0-sd-1.0-r0
# u-boot-spl.bin-imx8mp-var-dart-sd -> u-boot-spl.bin-imx8mp-var-dart-1.0-r0-sd-1.0-r0
# u-boot-spl.bin-sd -> u-boot-spl.bin-imx8mp-var-dart-1.0-r0-sd-1.0-r0

# # boot_tools
# bl31-imx8mp.bin
# imx8mp-var-dart.dtb
# imx8mp-var-som.dtb
# lpddr4_pmu_train_1d_dmem_201904.bin
# lpddr4_pmu_train_1d_imem_201904.bin
# lpddr4_pmu_train_2d_dmem_201904.bin
# lpddr4_pmu_train_2d_imem_201904.bin
# mkimage_fit_atf.sh
# mkimage_imx8
# mkimage_uboot
# signed_dp_imx8m.bin
# signed_hdmi_imx8m.bin
# soc.mak
# u-boot-imx8mp-var-dart.bin-sd
# u-boot-nodtb.bin-imx8mp-var-dart-sd
# u-boot-spl.bin-imx8mp-var-dart-sd

cp -vf u-boot.bin "$deploy_image_dir/u-boot.bin"
cp -vf spl/u-boot-spl.bin "$deploy_image_dir/u-boot-spl.bin"

cp -vf arch/arm/dts/imx8mp-var-dart.dtb "$boot_tools/imx8mp-var-dart.dtb"
cp -vf arch/arm/dts/imx8mp-var-som.dtb "$boot_tools/imx8mp-var-som.dtb"
cp -vf u-boot-nodtb.bin "$boot_tools/u-boot-nodtb.bin-imx8mp-var-dart-sd"

echo
echo "Run 'bitbake -c cleansstate imx-boot && bitbake imx-boot'"
echo "Output file is 'imx-boot-imx8mp-var-dart-sd.bin-flash_evk' in '$deploy_image_dir'"
echo "Flash with 'dd if=binfile of=/dev/sdX bs=1k seek=32 conv=fsync'"

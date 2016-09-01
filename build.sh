#
# This software is licensed under the terms of the GNU General Public
# License version 2, as published by the Free Software Foundation, and
# may be copied, distributed, and modified under those terms.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# Please maintain this if you use this script or any part of it
#
Start=$(date +"%s")
yellow='\033[0;33m'
white='\033[0m'
red='\033[0;31m'
gre='\e[0;32m'
KERNEL_DIR=$PWD
zimage=$KERNEL_DIR/arch/arm64/boot/Image
DTBTOOL=$KERNEL_DIR/dtbToolCM
toolchain ()
{
clear
echo -e " "
echo -e "$gre Welcome to Kernel building program$white"
echo -e " "
echo -e "$yellow Select which toolchain you want to build with?$white"
echo -e "$yellow 1.UBERTC AARCH64$white"
echo -e "$yellow 2.LINARO AARCH64"
echo -e "$yellow 3.GOOGLE AARCH64"
echo -n " Enter your choice:"
read choice
case $choice in
1) export CROSS_COMPILE="/home/vivek/toolchain/aarch64-linux-ubertc-android-4.9/bin/aarch64-linux-android-"
   export LD_LIBRARY_PATH=home/vivek/toolchain/aarch64-linux-ubertc-android-4.9/lib/
   STRIP="/home/vivek/toolchain/aarch64-linux-ubertc-android-4.9/bin/aarch64-linux-android-strip"
   echo -e "$gre You selected UBERTC$white" ;;
2) export CROSS_COMPILE="/home/vivek/toolchain/aarch64-linux-linaro-android-4.9/bin/aarch64-linux-android-"
   export LD_LIBRARY_PATH=home/vivek/toolchain/aarch64-linux-linaro-android-4.9/lib/
   STRIP="/home/vivek/toolchain/aarch64-linux-linaro-android-4.9/bin/aarch64-linux-android-strip"
   echo -e "$gre You selected LINARO$white" ;;
3) export CROSS_COMPILE="/home/vivek/toolchain/aarch64-linux-google-android-4.9/bin/aarch64-linux-android-"
   export LD_LIBRARY_PATH=home/vivek/toolchain/aarch64-linux-google-android-4.9/lib/
   STRIP="/home/vivek/toolchain/aarch64-linux-google-android-4.9/bin/aarch64-linux-android-strip"
   echo -e "$gre You selected GOOGLE$white" ;;
*) toolchain ;;
esac
}
toolchain
export ARCH=arm64
export SUBARCH=arm64
device ()
{
echo -e " "
echo -e "$yellow Select which device you want to build for?$white"
echo -e "$yellow 1.tomato$white"
echo -e "$yellow 2.lettuce"
echo -n " Enter your choice:"
read ch
case $ch in
1) echo -e "$gre You selected tomato$white"
   make clean
   make cyanogenmod_tomato-64_defconfig ;;
2) echo -e "$gre You selected lettuce$white"
   make clean
   make cyanogenmod_lettuce-64_defconfig 
export KBUILD_BUILD_HOST=9991
export KBUILD_BUILD_USER=vivek;;
*) device ;;
esac
}
device
make -j4
make Image -j4
make dtbs -j4
make modules -j4
$DTBTOOL -2 -o $KERNEL_DIR/arch/arm64/boot/dt.img -s 2048 -p $KERNEL_DIR/scripts/dtc/ $KERNEL_DIR/arch/arm/boot/dts/
lettuce()
{
echo -e "$gre Running new lettuce function$white"
mv arch/arm64/boot/dt.img ~/outl/tools
cp drivers/staging/prima/wlan.ko ~/outl/system/lib/modules/
cp fs/nls/nls_utf8.ko ~/outl/system/lib/modules/
cp arch/arm64/boot/Image ~/outl/tools/zImage
cd ~/outl/
cd modules/
$STRIP --strip-unneeded *.ko
cd ~/outl/
case $choice in
1) zip -r Thunderbird-uc-lettuce.zip * ;;
2) zip -r Thunderbird-lc-lettuce.zip * ;;
3) zip -r Thunderbird-gc-lettuce.zip * ;;
*) echo -e "error" ;;
esac
mv *.zip ~/final/
}
tomato()
{
echo -e "$gre Running new tomato function$white"
mv arch/arm64/boot/dt.img ~/out/dtb
cp drivers/staging/prima/wlan.ko ~/out/modules/
cp fs/nls/nls_utf8.ko ~/out/modules/
cp arch/arm64/boot/Image ~/out/zImage
cd ~/out/
cd modules/
$STRIP --strip-unneeded *.ko
cd ~/out/
case $choice in
1) zip -r Thunderbird-uc-tomato.zip * ;;
2) zip -r Thunderbird-lc-tomato.zip * ;;
3) zip -r Thunderbird-gc-tomato.zip * ;;
*) echo -e "error" ;;
esac
mv *.zip ~/final/
}
case $ch in
1) tomato ;;
2) lettuce ;;
*) echo -e "Error in function" ;;
esac
cd $KERNEL_DIR
End=$(date +"%s")
Diff=$(($End - $Start))
if ! [ -a $zimage ];
then
echo -e "$red<<Failed to compile zImage, fix the errors first>>$white"
else
echo -e "$gre<<Build completed in $(($Diff / 60)) minutes and $(($Diff % 60)) seconds>>$white"
fi

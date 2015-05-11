#!/bin/sh

lcd_key=lcd
ctp_key=ctp
sysconfig_key=sysconfig
pmu_key=pmu
wait_any_key_reboot=0
base_dir=/media/buildserver/yuxin/


help(){
	echo "Usage                 : $0 [$lcd_key|$ctp_key|$sysconfig_key|$pmu_key]"
	echo "Param $lcd_key|$ctp_key|$sysconfig_key|$pmu_key"
	exit 1

} 

execute_cmd()
{
	echo "$@"
	$@
	#if [ $? -ne 0   ];then
	#	echo "execute $@ failed! please check what happened!"
	#	exit 1
	#fi
}

is_module_insmod()
{
	execute_cmd adb shell lsmod | grep -q $1
	return $?
}

module_insmod()
{
	execute_cmd adb shell insmod $1
	return $?
}

module_rmmod()
{
	execute_cmd adb shell rmmod $1
	return $?
}

if [ $# -ne 1 ]; then
	help
fi

case $1 in
	$lcd_key)
		MODULE_PATH=${base_dir}/lichee/linux-3.4/drivers/video/sunxi/
		cd $MODULE_PATH

		module_list="disp/disp.ko lcd/lcd.ko hdmi/hdcp.ko"

		execute_cmd adb remount
		for module in $module_list; do
			execute_cmd adb push $module /vendor/modules/$module
			execute_cmd adb shell chmod 600 /vendor/modules/$module
		done
		;;

	$ctp_key)
		MODULE_PATH=${base_dir}/lichee/linux-3.4/drivers/input/touchscreen/gslx680
		cd $MODULE_PATH

		execute_cmd adb remount
		execute_cmd adb push gslX680.ko /vendor/modules/gslX680.ko
		execute_cmd adb shell chmod 600 /vendor/modules/gslX680.ko
		;;
	$sysconfig_key)
		SYSCONFIG_BIN=${base_dir}/lichee/tools/pack/out/sys_config.bin
		MOUNT_POINT="/data/bootloader"
		execute_cmd adb shell "mkdir $MOUNT_POINT"
		execute_cmd adb shell "mount -t vfat /dev/block/by-name/bootloader  $MOUNT_POINT"
		execute_cmd adb push $SYSCONFIG_BIN $MOUNT_POINT/script.bin
		execute_cmd adb shell umount $MOUNT_POINT
		;;
	$pmu_key)
		MODULE_PATH=${base_dir}/lichee/linux-3.4/drivers/power/axp_power
		MODULE_ANDROID_PATH=/vendor/modules
		cd $MODULE_PATH

		module_list="virtual15.ko virtual15_dev.ko virtual22.ko virtual22_dev.ko"

		execute_cmd adb remount
		for module in $module_list; do
			execute_cmd adb push $module $MODULE_ANDROID_PATH/$module
			execute_cmd adb shell chmod 600 $MODULE_ANDROID_PATH/$module
		done

		echo ""
		echo ""

		#for module in $module_list; do
		#	module_rmmod=${module%.ko}
		#	is_module_insmod $module_rmmod
		#	if [ $? -eq 0 ]; then
		#		module_rmmod $MODULE_ANDROID_PATH/$module_rmmod
		#	fi
		#	module_insmod $MODULE_ANDROID_PATH/$module
		#done

		#for module in $module_list; do
		#	echo "check module($module) is ismod"
		#	is_module_insmod $module 
		#	if [ $? -eq 0 ]; then
		#		echo "module($module) rmmod"
		#		module_rmmod $module
		#	fi
		#	echo "module($module) insmod"
		#	module_insmod $1
		#done
		#exit 0
		;;
	*)
		help
		;;
esac

adb shell sync

if [ $wait_any_key_reboot -eq 1 ]; then
	echo press any key to reboot
	read anykey
fi

adb reboot


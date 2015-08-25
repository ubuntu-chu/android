#!/bin/sh

lcd_key=lcd
ctp_key=ctp
motor_key=motor
camera_key=camera
ft6188_key=ft6188
vfe_key=vfe
sysconfig_key=sysconfig
pmu_key=pmu
module_4g_key=4g
cpu_key=cpu
wait_any_key_reboot=0
base_dir=/media/buildserver/A83t-Android4.4/
MODULE_ANDROID_PATH=/vendor/modules

action_push_key=push
action_insmod_key=insmod
action_rmmod_key=rmmod
action_reboot_key=reboot
action_remount_key=remount

help(){
	echo "Usage : $0 [$action_push_key|$action_insmod_key|$action_rmmod_key|$action_reboot_key|$action_remount_key] [$lcd_key|$ctp_key|$sysconfig_key|$pmu_key]"
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

module_rmmod()
{
	execute_cmd adb shell rmmod $1
	return $?
}

module_push()
{
	execute_cmd adb remount
	for module in $1; do
		execute_cmd adb push $2/$module $MODULE_ANDROID_PATH/$(basename $module)
		execute_cmd adb shell chmod 644 $MODULE_ANDROID_PATH/$(basename $module)
	done

	adb shell sync
}

module_insmod()
{
	for module in $1; do
		execute_cmd adb shell insmod $MODULE_ANDROID_PATH/$module
	done
}

module_rmmod()
{
	for module in $1; do
		execute_cmd adb shell rmmod $MODULE_ANDROID_PATH/$module
	done
}

var_set_4g_key()
{
	MODULE_PATH=${base_dir}/lichee/linux-3.4/drivers/net/usb
	module_list="ttyxin.ko xin100.ko"
}

var_set_camera()
{
	MODULE_PATH=${base_dir}/lichee/linux-3.4/drivers/media/video/sunxi-vfe/device
	module_list="ov13850.ko ov5648.ko ../actuator/dw9714_act.ko"
}

var_set_vfe()
{
	MODULE_PATH=${base_dir}/lichee/linux-3.4/drivers/media/video/sunxi-vfe/
	module_list="vfe_os.ko vfe_subdev.ko vfe_v4l2.ko"
}

var_set_cci()
{
	MODULE_PATH=${base_dir}/lichee/linux-3.4/drivers/media/video/sunxi-vfe/csi_cci/
	module_list="cci.ko"
}

var_set_motor()
{
	MODULE_PATH=${base_dir}/lichee/linux-3.4/drivers/misc
	module_list="sunxi-vibrator.ko"
}

var_set_ctp()
{
	MODULE_PATH=${base_dir}/lichee/linux-3.4/drivers/input/touchscreen/ft5x
	module_list="ft5x_ts.ko"
}

var_set_lcd()
{
	MODULE_PATH=${base_dir}/lichee/linux-3.4/drivers/video/sunxi/
	module_list="disp/disp.ko lcd/lcd.ko hdmi/hdcp.ko"
}

var_set_pmu()
{
	MODULE_PATH=${base_dir}/lichee/linux-3.4/drivers/power/axp_power
	module_list="virtual15.ko virtual15_dev.ko virtual22.ko virtual22_dev.ko"
}

var_set_ft6188()
{
	MODULE_PATH=${base_dir}/lichee/linux-3.4/drivers/spi
	module_list="spi-ft6188.ko"
}

push_done()
{
	case $1 in
		$module_4g_key)
			var_set_4g_key
			module_push "$module_list" "$MODULE_PATH"
			;;

		$ft6188_key)
			var_set_ft6188
			module_push "$module_list" "$MODULE_PATH"
			exit 0
			;;

		$camera_key)
			var_set_camera
			module_push "$module_list" "$MODULE_PATH"
			exit 0
			;;

		$vfe_key)
			var_set_vfe
			module_push "$module_list" "$MODULE_PATH"
			var_set_cci
			module_push "$module_list" "$MODULE_PATH"
			;;

		$motor_key)
			var_set_motro
			module_push "$module_list" "$MODULE_PATH"
			exit 0
			;;
			
		$lcd_key)
			var_set_lcd
			module_push "$module_list" "$MODULE_PATH"
			;;

		$ctp_key)
			var_set_ctp
			module_push "$module_list" "$MODULE_PATH"
			exit 0
			;;

		$pmu_key)
			var_set_pmu
			module_push "$module_list" "$MODULE_PATH"
			;;

		$cpu_key)
			execute_cmd adb remount
			execute_cmd adb push /home/chum/work/android/cpu-tools.sh /system/bin/
			execute_cmd adb shell chmod 777 /system/bin/cpu-tools.sh
			adb shell sync
			exit 0
			;;
		*)
			help
			;;
	esac
	return 0
}

insmod_done()
{
	case $1 in
		$module_4g_key)
			var_set_4g_key
			module_insmod "$module_list" 
			exit 0
			;;

		$ft6188_key)
			var_set_ft6188
			module_insmod "$module_list" 
			exit 0
			;;
		$camera_key)
			var_set_ov13
			module_insmod "$module_list" 
			exit 0
			;;

		$vfe_key)
			var_set_vfe
			module_insmod "$module_list" 
			;;

		$motor_key)
			var_set_motro
			module_insmod "$module_list" 
			exit 0
			;;
			
		$lcd_key)
			var_set_lcd
			module_insmod "$module_list" 
			;;

		$ctp_key)
			var_set_ctp
			module_insmod "$module_list" 
			exit 0
			;;

		$pmu_key)
			var_set_pmu
			module_insmod "$module_list" 
			;;
		*)
			help
			;;
	esac
	return 0
}

rmmod_done()
{
	case $1 in
		$module_4g_key)
			var_set_4g_key
			module_rmmod "$module_list" 
			exit 0
			;;

		$ft6188_key)
			var_set_ft6188
			module_rmmod "$module_list" 
			;;

		$camera_key)
			var_set_ov13
			module_rmmod "$module_list" 
			;;

		$vfe_key)
			var_set_vfe
			module_rmmod "$module_list" 
			;;

		$motor_key)
			var_set_motro
			module_rmmod "$module_list" 
			;;
			
		$lcd_key)
			var_set_lcd
			module_rmmod "$module_list" 
			;;

		$ctp_key)
			var_set_ctp
			module_rmmod "$module_list" 
			;;

		$pmu_key)
			var_set_pmu
			module_rmmod "$module_list" 
			;;
		*)
			help
			;;
	esac
	exit 0
}

if [ $# -ne 1 -a $# -ne 2 ]; then
	help
fi

case $1 in
	$action_push_key)
		push_done $2
		;;

	$action_insmod_key)
		insmod_done $2
		;;

	$action_rmmod_key)
		rmmod_done $2
		;;

	$action_reboot_key)
		adb reboot
		exit 0
		;;

	$action_remount_key)
		adb remount
		exit 0
		;;

	*)
		help
		;;
esac


if [ $wait_any_key_reboot -eq 1 ]; then
	echo press any key to reboot
	read anykey
fi

adb reboot

#$sysconfig_key)
#SYSCONFIG_BIN=${base_dir}/lichee/tools/pack/out/sys_config.bin
#MOUNT_POINT="/data/bootloader"
#execute_cmd adb shell "mkdir $MOUNT_POINT"
#execute_cmd adb shell "mount -t vfat /dev/block/by-name/bootloader  $MOUNT_POINT"
#execute_cmd adb push $SYSCONFIG_BIN $MOUNT_POINT/script.bin
#execute_cmd adb shell umount $MOUNT_POINT
#;;


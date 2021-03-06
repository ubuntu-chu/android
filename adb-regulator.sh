#!/bin/sh

#####!/sbin/busybox sh

summary_key=summary
set_key=set
disable_key=disable
enable_key=enable
info_key=info
help_key=help
lookup_key=whois
list_key=list

ubuntu_key="ubuntu"
android_key="android"
run_env=$ubuntu_key
#run_env=$android_key

dump_tmp_file="./.regulator_dump"
regulator_class_path=/sys/class/regulator
regulator_device_path=/sys/devices/platform
	
help()
{
	echo "Mapping               : axp809 <--> axp22; axp806 <--> axp15"
	echo "Usage                 : $0 [$summary_key|$set_key|$lookup_key|$help_key|$info_key|$list_key|$disable_key|$enable_key]"
	echo "Param $summary_key: list regulators status"
	echo "Param $set_key: <regulator_name> <uV>"
	echo "Param $info_key: <regulator_name>"
	echo "Param $lookup_key: <regulator_name-SUPPLY>"
	echo "Param $list_key: list regulators name in system"
	echo "Param $disable_key: <regulator_name> disable regulators output"
	echo "Param $enable_key: <regulator_name> enable regulators output"
	echo ""

	exit 1
} 

execute_cmd()                                                                                                              
{
    echo "$@"
    $@
    #if [ $? -ne 0    ];then
    #   echo "execute $@ failed! please check what happened!"
    #   exit 1
    #fi

}

name_convert()
{
	echo $1 | grep -q "axp22"
	if [ $? -eq 0 ]; then
		regulator_input=`echo $1  | sed -n "s/axp22_/reg-22-cs-/p"`
	fi

	echo $1 | grep -q "axp15"
	if [ $? -eq 0 ]; then
		regulator_input=`echo $1  | sed -n "s/axp15/reg-15-cs-/p"`
	fi

	echo $1 | grep -q "axp806"
	if [ $? -eq 0 ]; then
		regulator_input=`echo $1  | sed -n "s/axp806_/reg-15-cs-/p"`
	fi
	echo $1 | grep -q "axp809"
	if [ $? -eq 0 ]; then
		regulator_input=`echo $1  | sed -n "s/axp809_/reg-22-cs-/p"`
	fi
	#echo $1 | sed -n "s/axp809_/reg-22-cs-/p"
	#echo $1 | sed -n "s/axp806_/reg-15-cs-/p"
	#regulator_input=`echo $1 | sed -en "s/axp809_/reg-22-cs-/gp;s/axp806_/reg-15-cs-/gp"`
	echo $regulator_input
}

enable_regulator()
{
	name_convert $1
	volt=$2
	dev_attr_file=enable
	if [ $run_env = $ubuntu_key ]; then
		echo adb shell "echo $volt > $regulator_device_path/$regulator_input/$dev_attr_file"
		adb shell "echo $volt > $regulator_device_path/$regulator_input/$dev_attr_file"
	else
		echo "echo $volt > $regulator_device_path/$regulator_input/$dev_attr_file"
		echo $volt > $regulator_device_path/$regulator_input/$dev_attr_file
	fi
}

set_volt()
{
#	regulator_input=$1
	name_convert $1
	volt=$2
	dev_attr_file=min_microvolts
	if [ $run_env = $ubuntu_key ]; then
		echo adb shell "echo $volt > $regulator_device_path/$regulator_input/$dev_attr_file"
		adb shell "echo $volt > $regulator_device_path/$regulator_input/$dev_attr_file"
		#设置电压时 程序内部有最大 最小值校验机制
		#if [ $? -eq 0 ]; then
		#	echo "volt: $volt modify success!"
		#else
		#	echo "volt: $volt modify failed!"
		#fi
	else
		echo "echo $volt > $regulator_device_path/$regulator_input/$dev_attr_file"
		echo $volt > $regulator_device_path/$regulator_input/$dev_attr_file
	fi
}

if [ $run_env != $ubuntu_key -a $run_env != $android_key ]; then
	echo "run_env must be $ubuntu_key or $android_key"
	exit 1
fi

if [ $# -eq 0 ]; then
	help
fi

case $1 in
	$list_key)
		if [ $run_env = $ubuntu_key ]; then
			adb shell "busybox find  /sys/devices/platform/ -name "reg-*" | busybox grep -v reg-dummy | busybox cut -d / -f 5 | busybox sed -e \"s/reg-22-cs-/axp809_/g;s/reg-15-cs-/axp806_/g\""
		else
			find  /sys/devices/platform/ -name "axp8*_*" | cut -d / -f 5 | sed -e "s/reg-22-cs-/axp809_/g;s/reg-15-cs-/axp806_/g" 
		fi
		;;

	$summary_key)
		#打印系统中当前的 supply 与 consumer 列表
		#adb shell "cat /d/regulator/supply_map"
		#打印系统中当前的 supply 列表
		echo ""
		echo "name      enable/disable    use_count     voltage     slave_supply_list"
		echo ""

		#adb shell "cat /sys/class/regulator/dump" > $dump_tmp_file
		#sed -n "regulator.*-SUPPLY/p" $dump_tmp_file
		#ldoio1 gpio0ldo

		if [ $run_env = $ubuntu_key ]; then
			adb shell cat $regulator_class_path/dump | sed -e "s/axp22/axp809/g;s/axp15/axp806/g;s/ldoio1/gpio1ldo/g;s/ldoio0/gpio0ldo/g"
			#adb shell "cat $regulator_class_path/dump"
		else
			cat $regulator_class_path/dump | sed -e "s/axp22/axp809/g;s/axp15/axp806/g;s/ldoio1/gpio1ldo/g;s/ldoio0/gpio0ldo/g"
		fi
		;;
	
	$lookup_key)
		if [ $# -ne 2 ]; then
			help
		fi
		regulator_input=$2
		regulator_label=${regulator_input%-SUPPLY}
		regulator_label=$(echo $regulator_label | tr '[A-Z]' '[a-z]') 

		if [ $run_env = $ubuntu_key ]; then
			regulator_name=`adb shell cat $regulator_class_path/$regulator_label/name`
		else
			regulator_name=`cat $regulator_class_path/$regulator_label/name`
		fi
		echo "$regulator_label = $regulator_name" 
		;;

	$set_key)
		if [ $# -ne 3 ]; then
			help
		fi
		echo $3 | grep -q "[a-z,A-Z]"
		if [ $? -eq 0 ]; then
			echo "$3 contain char!"
			exit 1
		fi
		set_volt $2 $3
		;;

	$disable_key)
		if [ $# -ne 2 ]; then
			help
		fi
		enable_regulator $2 0
		;;

	$enable_key)
		if [ $# -ne 2 ]; then
			help
		fi
		enable_regulator $2 1
		;;

	$info_key)
		if [ $# -ne 2 ]; then
			help
		fi
		dev_attr_file=info
		name_convert $2
		if [ $run_env = $ubuntu_key ]; then
			execute_cmd adb shell cat $regulator_device_path/$regulator_input/$dev_attr_file | sed -e "s/axp22/axp809/g;s/axp15/axp806/g"
		else
			execute_cmd cat $regulator_device_path/$regulator_input/$dev_attr_file | sed -e "s/axp22/axp809/g;s/axp15/axp806/g"
		fi
		;;

	*)
		help
		;;
esac



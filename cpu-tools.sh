#!/sbin/busybox sh

monitor_key="monitor"
budget_key="budget"
temp_key="temp"
mainkey_key="mainkey"
#监控间隔时间 s
monitor_interval_s=1

cpu_sys_path=/sys/devices/system/cpu
	
help()
{
	echo "Usage                 : $0 [$monitor_key|$budget_key|$temp_key|$mainkey_key]"
	echo "Param $monitor_key: monitor cpus status"
	echo "Param $budget_key: print cpus budget table"
	echo "Param $temp_key: print cpu temp"
	echo "Param $mainkey_key: print mainkey config from sysconfig.fex"
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

monitor_cpus()
{
	execute_cmd cd ${cpu_sys_path}
	while true;
	do
		processor=0
		echo "-------------------cpus monitor list-------------------"
		while :;
		do
			if [ ${processor} -le ${processors_count} ]; 
			then
				online=`cat cpu${processor}/online`
				if [ $online -eq 1 ]; then
					cpuinfo_max_freq=`cat cpu${processor}/cpufreq/cpuinfo_max_freq`
					cpuinfo_min_freq=`cat cpu${processor}/cpufreq/cpuinfo_min_freq`
					cpuinfo_cur_freq=`cat cpu${processor}/cpufreq/cpuinfo_cur_freq`
					cpuinfo_max_freq=`expr ${cpuinfo_max_freq} / 1000`
					cpuinfo_min_freq=`expr ${cpuinfo_min_freq} / 1000`
					cpuinfo_cur_freq=`expr ${cpuinfo_cur_freq} / 1000`

					scaling_max_freq=`cat cpu${processor}/cpufreq/scaling_max_freq`
					scaling_min_freq=`cat cpu${processor}/cpufreq/scaling_min_freq`
					scaling_cur_freq=`cat cpu${processor}/cpufreq/scaling_cur_freq`
					scaling_max_freq=`expr ${scaling_max_freq} / 1000`
					scaling_min_freq=`expr ${scaling_min_freq} / 1000`
					scaling_cur_freq=`expr ${scaling_cur_freq} / 1000`

					scaling_governor=`cat cpu${processor}/cpufreq/scaling_governor`

					scaling_available_frequencies=`cat cpu${processor}/cpufreq/scaling_available_frequencies`
					echo "cpu${processor} online: scaling_available_frequencies = $scaling_available_frequencies"
					#echo "cpu${processor} online:"
					echo "        cpufreq(MHz)    : max = ${cpuinfo_max_freq}; min = ${cpuinfo_min_freq}; cur = ${cpuinfo_cur_freq}"
					echo "        scalingfreq(MHz): max = ${scaling_max_freq}; min = ${scaling_min_freq}; cur = ${scaling_cur_freq}"
					echo "        scaling_governor: ${scaling_governor}"
				fi
			else
				break;
			fi
			processor=`expr ${processor} + 1`
		done
		echo ""
		sleep ${monitor_interval_s}
	done
}

if [ $# -eq 0 ]; then
	help
fi

processors_count=`cat $cpu_sys_path/kernel_max`
echo "processors_count = $processors_count"

#action=$monitor_key
action=$1


case $action in
	$monitor_key)
		monitor_cpus
		#if [ $# -ne 3 ]; then
		#	help
		#fi
		;;

	$budget_key)
		cat /sys/devices/platform/sunxi-budget-cooling/online	
		;;

	$temp_key)
		while true
		do
			echo "thermal_zone0 temp: `cat /sys/class/thermal/thermal_zone0/temp`"
			echo "thermal_zone1 temp: `cat /sys/class/thermal/thermal_zone1/temp`"
			sleep ${monitor_interval_s}
		done
		;;

	$mainkey_key)
		if [ $# -ne 3 ]; then
			help
		fi
		echo $2 > /sys/class/script/dump && cat /sys/class/script/dump
		;;

	*)
		help
		;;
esac



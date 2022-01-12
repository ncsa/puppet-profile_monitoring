#!/bin/bash

tfile=$(mktemp /tmp/inventory.XXXXXXX)
sudo dmidecode > ${tfile}

# CMDB and script not ready for VM data collection, so exit for now
if grep -q "Product Name:.*Virtual Platform" "${tfile}"; then
	exit
fi

hostname=$(hostname -f)
product_uuid=$(sudo cat /sys/devices/virtual/dmi/id/product_uuid)
manufacturer=$(grep "Vendor" ${tfile}  | head -1 | cut -d' ' -f 2-)
model=$(grep "Product Name" ${tfile} | head -1 | cut -d' ' -f 3-)
serial_number=$(sudo dmidecode -t 1 | grep "Serial Number" | cut -d' ' -f 3)
bios_version=$(grep -A 2 "BIOS Information" ${tfile} | grep "Version:" |  head -1 | cut -d' ' -f 2)
height=$(grep "Height" ${tfile} | head -1 | cut -d' ' -f 2- | sed 's/\ //g')
cpu=$(grep "model name" /proc/cpuinfo | head -n 1 | cut -d' ' -f 3- | sed 's/ \+/\ /g')
cores_per_cpu=$(grep "cpu cores" /proc/cpuinfo | head -n 1 | cut -d' ' -f 3)
socket_count=$(grep "physical id" /proc/cpuinfo | cut -d' ' -f 3- | sort -u | wc -l)
dimm_size=$(sudo dmidecode -t 17 | grep "Size:" | grep -v "No Module Installed" | head -n 1 | cut -d' ' -f 2-)
dimm_count=$(sudo dmidecode -t 17 | grep -A 5 "Memory Device" | grep "Size" | grep -v "No Module Installed" | wc -l)
ip_addrs=$(ip addr | grep "inet " | awk '{print $2}' | grep -v "127.0.0.1" | cut -d'/' -f 1 | xargs)
ip_nets=$(ip addr | grep "inet " | awk '{print $2}' | grep -v "127.0.0.1" | xargs)
mac_addrs=$(ifconfig | grep ether | awk '{print $2}' | xargs)
psu_count=$(ipmitool fru print | grep "PWR SPLY" | wc -l)
psu_size=$(ipmitool fru print | grep "PWR SPLY" | cut -d',' -f 2 | sort -u | xargs | sed 's/\ /,/g')
pcie_slots=$(grep -A5 "System Slot Information" ${tfile} | grep "Designation: PCI" | grep -v SSD | wc -l)

## PSU Info
if [ "${manufacturer}" == "Dell Inc." ]; then
	psu_count=$(ipmitool fru print | grep "PWR SPLY" | wc -l)
	psu_size=$(ipmitool fru print | grep "PWR SPLY" | cut -d',' -f 2 | sort -u | xargs | sed 's/\ /,/g')
elif [ "${manufacturer}" == "HP" ]; then
	ipmitool sdr > ${tfile}
	psu_count=$(grep "Power Supply" ${tfile} | wc -l)
	psu_size=$(grep "Power Supply" ${tfile} | head -n 1 | cut -d' ' -f 7,8 | sed 's/\ /_/g')
elif [ "${manufacturer}" == "LENOVO" ]; then
	psu_count=$(ipmitool sdr | grep PSU | wc -l)
	psu_size=unkown
else
	psu_count=unkown
	psu_size=unkown
fi

## OS Info
if [ -f "/etc/redhat-release" ]; then
	os_version=$(cat /etc/redhat-release)
	kernel_version=$(uname -a | awk '{print $3}')
elif [ -f "/etc/osb-release" ]; then
	os_version=$(cat /etc/osb-release)
	kernel_version=$(uname -a | awk '{print $3}')
else
	os_version=Unknown
fi

## GPFS Info
rpm=$(rpm -qa | grep "gpfs.base" | cut -d'-' -f 2,3 | cut -d'.' -f 1,2,3  | head -n 1)
if [ -z "${rpm}" ]; then
	gpfs=none
else
	gpfs=${rpm}
fi

timestamp=$(date +'%Y-%m-%d %H:%M:%S')

echo "ncsa_inventory,product_uuid=${product_uuid} hostname=\"${hostname}\",serial_number=\"${serial_number}\",manufacturer=\"${manufacturer}\",model=\"${model}\",bios_version=\"${bios_version}\",height=\"${height}\",cpu_model=\"${cpu}\",cores_per_cpu=${cores_per_cpu},socket_count=${socket_count},dimm_size=\"${dimm_size}\",dimm_count=${dimm_count},pcie_slots=${pcie_slots},ip_addrs=\"${ip_addrs}\",ip_nets=\"${ip_nets}\",mac_addrs=\"${mac_addrs}\",psu_count=${psu_count},psu_size=\"${psu_size}\",os_version=\"${os_version}\",kernel_version=\"${kernel_version}\",gpfs_version=\"${gpfs}\",time_collected=\"${timestamp}\""

rm -rf ${tfile}


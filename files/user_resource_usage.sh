#!/bin/bash
# Script from https://git.ncsa.illinois.edu/ici-monitoring/ici-developed-checks/-/blob/main/login_nodes/login_node_resource_check.sh

tfile=$(mktemp /tmp/user_resource.XXXXXXXXX)
users=($(ps axo user:20 | sort -u | grep -v USER))
ps axo user:20,pid,pcpu,pmem,rssize > "${tfile}"

for u in ${users[@]}
do
	cpu_percent=$(egrep -w ^${u} ${tfile} | awk '{SUM+=$3}END{print SUM}')
	mem_percent=$(egrep -w ^${u} ${tfile} | awk '{SUM+=$4}END{print SUM}')
	mem_kb=$(egrep -w ^${u} ${tfile} | awk '{ sum+=$5} END {print int(sum)}')
	num_processes=$(egrep -w ^${u} ${tfile} | wc -l)
	echo "login_node_user_resource_usage,user=${u} cpu_percent=${cpu_percent},mem_percent=${mem_percent},mem_kb=${mem_kb},num_processes=${num_processes}"
done

rm -rf ${tfile}

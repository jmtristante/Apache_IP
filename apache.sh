#!/bin/bash

#fichero="recortado.log"
regexIP='^([0-9]{1,3}\.){3}[0-9]{1,3}' #Expresion regular para filtrar IPs

if [ -n "$1" ]; then
	fichero=$1
else
	echo "Proporciona fichero de log"
	exit 1
fi

#Delaramos un hashmap
declare -A map

function show_map(){
	#Se muestra el map
	echo -ne "\nSe han analizado $ilines lineas de log\n"
	for k in "${!map[@]}"; do
	        printf "%-18s%s\n" $k  ${map[$k]}
	done
}


#Para el porcentaje de completitud
nlines=$(wc -l < $fichero) 	#Lineas totales del fichero
ilines=0			#Lineas analizadas
BAR='####################'
SPACES='                   '


trap ctrl_c INT
function ctrl_c() {
	show_map
	exit 0
}

#Recorremos el fichero, extrayendo las IP e incluyendolas en el map. Si ya existen se suma 1 a su contador
while IFS='' read -r linea || [[ -n "$linea" ]]; do
	ip=$(echo ${linea} | egrep -o ${regexIP})
	if [[ -n $ip ]];then
		#echo "$ip"
		if [ ${map[$ip]+_} ];then
        		#echo "existe"
        		((map[$ip]++))
		else
	        	map[$ip]=1
		fi
	fi
	((ilines++))
	porcentaje=$((ilines*100/nlines))
	cuadrados=$((${#BAR}*porcentaje/100))
	espacios=$((${#BAR}-cuadrados))
	echo -ne "\r[${BAR:0:$cuadrados}${SPACES:0:$espacios}] ${porcentaje}% $ilines/$nlines"
done < $fichero

#Se muestra el map
show_map


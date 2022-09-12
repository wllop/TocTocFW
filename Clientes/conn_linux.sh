#!/bin/bash
if [ "$#" -eq 0 ] || [ $# -lt 2 ];then
  echo "Sintaxis:"
  echo "wllop@esat$./conn_linux.sh IP comb1,comb2,combn"
  exit
fi
#Comprobamos comando curl
if ! type curl &>/dev/null ;then
  echo "Necesito el comando: curl para continuar."
  echo "Prueba, según distribución, a instalarlo: apt-get install curl // dnf install curl"
  exit
fi

#Comprobamos IP
check=$(ping $1 -w1 -c1 -n &>/dev/null||echo $?)
if [ "$check" == "2" ]; then
  echo Error: IP Incorrecta.
  echo "Sintaxis:"
  echo "wllop@esat$./conn_linux.sh IP comb1,comb2,combn"
  exit
fi
#Conectamos al equipo:
#Regularizamos espacios en las combinaciones y convertimos a array:
puertos=($(echo $2|tr -d " "|tr , " "))
for puerto in ${puertos[*]}; do
  curl --connect-timeout 0,300 -s http://$1:$puerto
done
echo "Combinación realizada con éxito."



#!/bin/bash
if [ "$#" -eq 0 ] || [ $# -lt 2 ];then
  read -p "Introduzca el nombre del servidor: " servidor
  read -p "Introduzca la secuencia de puertos separada por comas (ej: 40,50,60): " pass
else
 servidor=$1
 pass=$2
fi
#Comprobamos comando curl
if ! type curl &>/dev/null ;then
  echo "Necesito el comando: curl para continuar."
  echo "Prueba, según distribución, a instalarlo: apt-get install curl // dnf install curl"
  exit
fi

#Comprobamos IP
check=$(ping $servidor -w1 -c1 -n &>/dev/null||echo $?)
if [ "$check" == "2" ]; then
  echo Error: IP/Servidor Incorrecto.
  echo "Sintaxis:"
  echo "wllop@esat$./conn_linux.sh <servidor> comb1,comb2,combn"
  exit
fi
#Conectamos al equipo:
#Regularizamos espacios en las combinaciones y convertimos a array:
puertos=($(echo $pass|tr -d " "|tr , " "))
for puerto in ${puertos[*]}; do
  curl --connect-timeout 0.300 -s http://$servidor:$puerto ||  curl --connect-timeout 0,300 -s http://$servidor:$puerto 
  echo http://$servidor:$puerto
done
echo "Combinación realizada con éxito."



#!/bin/bash
fin=0
ruta=$(dirname $(realpath $0))
puertos(){
 echo "Habilitando puertos locales (localhost)"
 for linea in $(netstat -l4ntu|awk '{print $1,$4}'|grep 127.0.0.1|tr " " _); do
 #permito todos los puertos locales by default
 protocolo=$(echo $linea|cut -d_ -f1) 
 puerto=$(echo $linea|cut -d_ -f2)
 iptables &>/dev/null -C INPUT -i lo -p $protocolo --dport $puerto -j ACCEPT || iptables &>/dev/null -I INPUT  1 -i lo -p $protocolo --dport $puerto -j ACCEPT 
 done
 ip=$(curl -s ifconfig.me)
 echo "Habilitando puertos acceso remoto (0.0.0.0 y $ip)"
 for linea in $(netstat -l4ntu|awk '{print $1,$4}'|grep -e 0.0.0.0 -e $ip|tr " " _); do
 #permito todos los puertos locales by default
 protocolo=$(echo $linea|cut -d_ -f1) 
 puerto=$(echo $linea|cut -d_ -f2)
 puertos_toctoc=$(grep -P -v "^#" $ruta/toctoc.cfg|cut -d: -f2|tr "," " "|xargs echo)
 long_puertos=${#puertos_toctoc} #Veo longitud de cadena
 post_puertos=$(echo ${puertos_toctoc/$(echo $linea|cut -d: -f2)/})
 long_post_puertos=${#post_puertos}
 if [ "$long_puertos" -eq "$long_post_puertos" ]; then #Sin long es = es que el puerto NO está controlado por toctoc
   iptables &>/dev/null -C INPUT -p $protocolo -s 0.0.0.0/0 --dport $puerto -j ACCEPT || iptables &>/dev/null -I INPUT  1 -p $protocolo -s 0.0.0.0/0 --dport $puerto -j ACCEPT 
 fi
 done
}
reset(){
if [ -e $ruta/.toctoc.cfg.old ]; then
   for passcode in $(grep -P -v "^#" $ruta/.toctoc.cfg.old |cut -d= -f2-) ; do
   arr_pass=($(echo $passcode|cut -d: -f1|tr  "," " "))
   arr_ports=($(echo $passcode|cut -d: -f2|tr "," " "))
   persistencia=$(echo $passcode|cut -d: -f3|tr "," " ")
   for ((i=0;i<$(expr ${#arr_pass[*]});i++));do
      if [ $i -eq 0 ];then
         iptables &>/dev/null -C INPUT -p tcp --dport ${arr_pass[$i]} -m recent --name pass${arr_pass[$i]} --set -j DROP && iptables -D INPUT -p tcp --dport ${arr_pass[$i]} -m recent --name pass${arr_pass[$i]} --set -j DROP
      else
         iptables &>/dev/null -C INPUT -p tcp --dport ${arr_pass[$i]} -m recent --rcheck --name pass${arr_pass[$(expr $i - 1)]} -j pj${arr_pass[$i]} && iptables -D INPUT -p tcp --dport ${arr_pass[$i]} -m recent --rcheck --name pass${arr_pass[$(expr $i - 1)]} -j pj${arr_pass[$i]}
         iptables &>/dev/null -C pj${arr_pass[$i]} -m recent --name pass${arr_pass[$i]} --set && iptables -D pj${arr_pass[$i]} -m recent --name pass${arr_pass[$i]} --set #es el último grupo
         iptables &>/dev/null -C pj${arr_pass[$i]} -m recent --name pass${arr_pass[$(expr $i - 1)]} --remove -j DROP && iptables -D pj${arr_pass[$i]} -m recent --name pass${arr_pass[$(expr $i - 1)]} --remove -j DROP
      fi
      fin=$i
   done
   for ((i=0;i<${#arr_ports[*]};i++));do #Ahora ELIMINAMOS las reglas de los servicios indicados en el array.
      #Sin persistencia:
         if [ "$persistencia" ==  "0" ]; then
            iptables &>/dev/null -C INPUT -p tcp --dport ${arr_ports[$i]} -m recent --rcheck --name pass${arr_pass[$fin]}   -j ok$(echo ${arr_pass[*]}|tr -d " ") &&iptables -D INPUT -p tcp --dport ${arr_ports[$i]} -m recent --rcheck  --name pass${arr_pass[$fin]}  -j ok$(echo ${arr_pass[*]}|tr -d " ")
         else
            iptables &>/dev/null -C INPUT -p tcp --dport ${arr_ports[$i]} -m recent --update --name pass${arr_pass[$fin]} --seconds 3600 -j ok$(echo ${arr_pass[*]}|tr -d " ") &&iptables -D INPUT -p tcp --dport ${arr_ports[$i]} -m recent --update --name pass${arr_pass[$fin]} --seconds 3600 -j ok$(echo ${arr_pass[*]}|tr -d " ")
         fi
   done
   if [ "$persistencia" ==  "0" ]; then
      iptables &>/dev/null -C ok$(echo ${arr_pass[*]}|tr -d " ") -m recent --name pass${arr_pass[$fin]} --remove && iptables -D ok$(echo ${arr_pass[*]}|tr -d " ") -m recent --name pass${arr_pass[$fin]} --remove
      iptables &>/dev/null -C ok$(echo ${arr_pass[*]}|tr -d " ") -j ACCEPT && iptables -D ok$(echo ${arr_pass[*]}|tr -d " ") -j ACCEPT
   else
      iptables &>/dev/null -C ok$(echo ${arr_pass[*]}|tr -d " ") -j ACCEPT && iptables -D ok$(echo ${arr_pass[*]}|tr -d " ") -j ACCEPT
   fi
   iptables -X ok$(echo ${arr_pass[*]}|tr -d " ") &>/dev/null #Elimino cadenas iptables
   for pass in ${arr_pass[*]}; do 
      iptables -X pj$pass 2>/dev/null
   done
   IFS=$IFS_old
done
fi
}
if [ $UID -ne 0 ];then
   echo "Debes ser root"
   exit
fi
#
#passcode=pto1,pto2,pto3,pton
#passcode=3000,4000,5000,6000,8000:21,80
#passcode2=3000,4000,5000,6000,8000:21,80
#
iptables -P INPUT ACCEPT
iptables -F
if ! [ -e  $ruta/toctoc.cfg ];then
   #No existe fichero de configuracion
  echo No existe el fichero de configuracion toctoc.cfg
  exit
fi
IFS_old=$IFS
puertos
if diff -rq $ruta/toctoc.cfg $ruta/.toctoc.cfg.old &>/dev/null; then
 reset
 exit
else
 reset
fi
cp -f $ruta/toctoc.cfg $ruta/.toctoc.cfg.old &>/dev/null
iptables -P INPUT DROP
#Recorremos todos los posibles passcodes del fichero de configuracion
for passcode in $(grep -P -v "^#" $ruta/toctoc.cfg|cut -d= -f2-) ; do
   arr_pass=($(echo $passcode|cut -d: -f1|tr  "," " "))
   arr_ports=($(echo $passcode|cut -d: -f2|tr "," " "))
   persistencia=$(echo $passcode|cut -d: -f3|tr "," " ")
   #creo la cadena de acpetación
   iptables -N ok$(echo ${arr_pass[*]}|tr -d " ") &>/dev/null
   IFS=,
   #Permito conexiones que ya esten establecidas
   iptables -C INPUT -m state --state "established,related" -j ACCEPT &>/dev/null || iptables -I INPUT 1 -m state --state "ESTABLISHED,RELATED" -j ACCEPT
   for pass in ${arr_pass[*]}; do 
      iptables -N pj$pass 2>/dev/null
   done
   for ((i=0;i<$(expr ${#arr_pass[*]});i++));do
      if [ $i -eq 0 ];then
         iptables &>/dev/null -C INPUT -p tcp --dport ${arr_pass[$i]} -m recent --name pass${arr_pass[$i]} --set -j DROP || iptables -A INPUT -p tcp --dport ${arr_pass[$i]} -m recent --name pass${arr_pass[$i]} --set -j DROP
      else
         iptables &>/dev/null -C INPUT -p tcp --dport ${arr_pass[$i]} -m recent --rcheck --name pass${arr_pass[$(expr $i - 1)]} -j pj${arr_pass[$i]} || iptables -A INPUT -p tcp --dport ${arr_pass[$i]} -m recent --rcheck --name pass${arr_pass[$(expr $i - 1)]} -j pj${arr_pass[$i]}
         iptables &>/dev/null -C pj${arr_pass[$i]} -m recent --name pass${arr_pass[$i]} --set || iptables -A pj${arr_pass[$i]} -m recent --name pass${arr_pass[$i]} --set #es el último grupo
         iptables &>/dev/null -C pj${arr_pass[$i]} -m recent --name pass${arr_pass[$(expr $i - 1)]} --remove -j DROP || iptables -A pj${arr_pass[$i]} -m recent --name pass${arr_pass[$(expr $i - 1)]} --remove -j DROP
      fi
      fin=$i
   done 
   #Ahora vamos habilitando puertos con último pass${arr_pass[$fin]}
   for ((i=0;i<${#arr_ports[*]};i++));do #Ahora activamos las reglas de los servicios indicados en el array.
      #Sin persistencia:
         if [ "$persistencia" ==  "0" ]; then
            iptables &>/dev/null -C INPUT -p tcp --dport ${arr_ports[$i]} -m recent --rcheck --name pass${arr_pass[$fin]}   -j ok$(echo ${arr_pass[*]}|tr -d " ") ||iptables -A INPUT -p tcp --dport ${arr_ports[$i]} -m recent --rcheck  --name pass${arr_pass[$fin]}  -j ok$(echo ${arr_pass[*]}|tr -d " ")
         else
            iptables &>/dev/null -C INPUT -p tcp --dport ${arr_ports[$i]} -m recent --update --name pass${arr_pass[$fin]} --seconds 3600 -j ok$(echo ${arr_pass[*]}|tr -d " ") ||iptables -A INPUT -p tcp --dport ${arr_ports[$i]} -m recent --update --name pass${arr_pass[$fin]} --seconds 3600 -j ok$(echo ${arr_pass[*]}|tr -d " ")
         fi
   done
   if [ "$persistencia" ==  "0" ]; then
      iptables &>/dev/null -C ok$(echo ${arr_pass[*]}|tr -d " ") -m recent --name pass${arr_pass[$fin]} --remove || iptables -A ok$(echo ${arr_pass[*]}|tr -d " ") -m recent --name pass${arr_pass[$fin]} --remove
      iptables &>/dev/null -C ok$(echo ${arr_pass[*]}|tr -d " ") -j ACCEPT || iptables -A ok$(echo ${arr_pass[*]}|tr -d " ") -j ACCEPT
   else
      iptables &>/dev/null -C ok$(echo ${arr_pass[*]}|tr -d " ") -j ACCEPT || iptables -A ok$(echo ${arr_pass[*]}|tr -d " ") -j ACCEPT
   fi
   IFS=$IFS_old
done
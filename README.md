<!-- Improved compatibility of back to top link: See: https://github.com/othneildrew/Best-README-Template/pull/73 -->
<a name="readme-top"></a>
<!--
*** Thanks for checking out the Best-README-Template. If you have a suggestion
*** that would make this better, please fork the repo and create a pull request
*** or simply open an issue with the tag "enhancement".
*** Don't forget to give the project a star!
*** Thanks again! Now go create something AMAZING! :D
-->



<!-- PROJECT SHIELDS -->
<!--
*** I'm using markdown "reference style" links for readability.
*** Reference links are enclosed in brackets [ ] instead of parentheses ( ).
*** See the bottom of this document for the declaration of the reference variables
*** for contributors-url, forks-url, etc. This is an optional, concise syntax you may use.
*** https://www.markdownguide.org/basic-syntax/#reference-style-links
-->

<!-- PROJECT LOGO -->
<br />
<div align="center">

<h2 align="center">TocTocFW</h2>

  <p align="left">
     Script realizado en bash para la automatización de la configuración de la técnica "Port knocking" haciendo uso de iptables.
  </p>
</div>


<!-- ABOUT THE PROJECT -->
## Proyecto
La técnica conocida como "port knocking" permite la conexión a ciertos puertos SIEMPRE que el usuario haya realizado una serie de conexiones previas. La idea es similar a la de las cajas fuertes donde, a pesar de tener la llave de apertura, sin la combinación necesaria es IMPOSIBLE su apertura.<br> 
toctocfw.sh es un script realizado en bash para la automatización de Port-Knocking con iptables, permitiendo una fácil determinación de combinación, puerto secreto y persistencia, a través del fichero de configuración toctoc.cfg.<br>
A pesar de que dichas conexiones previas pueden realizarse con cualquier cliente, he incluido 2 clientes uno para Windows (bat) y otro para Linux/Mac (bash) para facilitar aun más su uso. <br />

<p align="right">(<a href="#readme-top">Back to top</a>)</p>



<!-- GETTING STARTED -->
## 

Para el correcto funcionamiento del script deberemos disponer de credenciales de administrador y tener correctamente configurado el fichero toctoc.cfg <br>

### Instalación

1. Clonar el repositorio de GitHub.
   ```sh
   git clone https://github.com/wllop/toctocfw.git
   ```
2. Configurar el fichero toctoc.cfg (que estará ubicado en la misma ruta que el script toctocfw.sh).
   
3. Aplicar los permisos de ejecución al fichero del script.
   ```sh
   chmod a+x toctocfw.sh
   ```
4. Ejecutar el script.
   ```sh
   ./toctocfw.sh
   ```

<p align="right">(<a href="#readme-top">Back to top</a>)</p>



<!-- Configuración toctoc.cfg -->
## Fichero configuración toctoc.cfg

El fichero toctoc.cfg se utiliza para configurar tanto la secuencia mágica de apertura del puerto a proteger, el propio puerto o puertos a proteger con la secuencia indicada y su persistencia.<br>
La **estructura del fichero** es la siguiente:
passcode=combinacion1,combinacion2,combinacionN:puertoaproteger1,puertoaproteger2:(0|1) persistencia <br>
**Ejemplo:**<BR>
passcode=3000,5000,8000:22:0
<br>
- [ ] Combinacion1,combinacionN --> Aquí indicarmos tanto el orden como los puertos a los que el cliente deberá conectarse antes de que pueda conectarse al puerto "protegido". <br>
Ejemplo:
    - [ ] **3000,5000,8000** --> La combinación necesaria para conectarse al puerto protegido será una conexión a los puertos 3000, 5000 y 8000 en ese orden.
- [ ] PuertoaProteger, PuertoaProtegerN --> Aquí indicarmos el puerto o puertos que sólo permitirán su conexión si previamente se ha realizado la secuencia indicada en el anterior parámetro.<br>
Ejemplo:
    - [ ] **22** --> Un cliente **sólo** podrá conectarse al puerto 22 (SSH) sí y sólo sí, previamente ha realizado las conexiones a los puertos indicados en el campo "combinación".<br>
- [ ] Persistencia --> Este parámetro nos permite indicar al programa la posibilidad de que una vez establecida la conexión, cualquier nuevo intento de conexión desde esa misma IP origen será aceptada sin necesidad de conexiones previas (este modo será el persistente=1). En el caso de que queramos que cualquier nueva conexión deba repetir las conexiones previas, deberemos utilizar el modo NO Persistente (modo=0).<br>
Ejemplo:
    - [ ] **0** --> Teniendo en cuenta el ejemplo del puerto protegido 22, al indicar que el modo es NO PERSISTENTE, si estamos conectados al servidor por SSH y cerramos la conexión, debermos VOLVER a repetir la secuencia de puertos previos a la conexión. Este sería el modo recomendado para las conexiones SSH. Por el contrario para conexiones HTTP/HTTPS recomiendo el modo PERSISTENTE. <br>

<b>Más Ejemplos:</b><BR>
passcode=6666,7777,8888:21,20:1 #Permite conexiones FTP previa combinación de conexiones a los puertos 6666,7777 y 8888. Además se ha habilitado la persistencia, por lo que una vez realizada la combinación "mágica" toda nueva conexión será aceptada.

<p align="right">(<a href="#readme-top">Back to top</a>)</p>



<!-- ROADMAP -->
## Estado de la versión y pruebas.

El script lo he probado en sistemas Debian y Fedora, por lo que no debería dar problemas en otros sistemas Linux. Lo único que hay que tener en cuenta es que hace cambios en las reglas IPTABLES, por lo quederías hacer una copia de las reglas actuales para evitar "sustos" ;)<br>
A pesar de lo dicho en el párrafo anterior, esta es una primera versión de un script que todavía se le puede dar más vueltas (lo haré) y que hay que probar más puesto que tiene alguna cosita más por "refinar".... todo llegará :)<br>

<p align="right">(<a href="#readme-top">Back to top</a>)</p>



<!-- CONTRIBUTING -->
## Mejoras, comentarios....

Ni que decir tiene que aquí hemos venido a compartir y mejorar, por lo que cualquier comentario que queráis indicarme, cualquier mejora que se podría implementar es más que <B>bienvenido.</B><br>Podéis enviarme un mail a mi correo: **wllop@esat.es**.<br>Muchas gracias!<br> <p align="right">(<a href="#readme-top">Back to top</a>)</p>



<!-- LICENSE -->
## License

Distributed under the Apache 2 License. See `LICENSE.txt` for more information.

<p align="right">(<a href="#readme-top">Back to top</a>)</p>



<!-- CONTACT -->
## Contact

Walter Llop - [@wllop](https://twitter.com/wllop) - wllop@esat.es

Enlace Proyecto: [https://github.com/wlop/toctocfw](https://github.com/wllop/toctocfw)

<p align="right">(<a href="#readme-top">Back to top</a>)</p>

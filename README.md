#Scripts de fútbol

####fecha.sh (requiere tener instalado xpath)

Obtené los resultados/fixture de la liga.

Modo de uso:
./fecha.sh [liga] [n° fecha]

Ejemplo:
./fecha.sh premier 4


####posiciones.sh (requiere tener instalado xpath)

Obtené las posiciones de la liga.

Modo de uso:
./posiciones.sh [liga] 

Ejemplo:
./posiciones.sh calcio


**Ligas disponibles:**
+ Argentina
+ Uruguay
+ Italia as Calcio
+ Inglaterra as Premier
+ España
+ Alemania as Bundesliga
+ Chile
+ Ecuador
+ Paraguay
+ Bolivia
+ Peru
+ Venezuela



####xpath

* Debian/Ubuntu (y derivados): `sudo aptitude install libxml-xpath-perl`
* Fedora: `yum install perl-XML-XPath`
* Gentoo¹: `emerge dev-perl/XML-XPath`
* Arch/Manjaro: `pacman -S perl-xml-xpath`

1. Para que los scripts puedan trabajar correctamente, se debe aplicar [este parche](https://gist.github.com/aaferrari/2bee720d1b8bac7a09ee) en el archivo /usr/bin/xpath
Si el archivo xpath no existe en el directorio especificado, entonces se lo puede buscar con el comando `which xpath`.
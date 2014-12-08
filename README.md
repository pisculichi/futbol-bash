#Scripts de futbol

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



####Copa Libertadores

Observa la fase de grupos, resultados de cada grupo, así como también las fases eliminatorias

Modo de uso:
./libertadores.sh posiciones //Muestra las posiciones de cada grupo

./libertadores.sh grupo 1    //Muestra el fixture y resultados del grupo 1 

./libertadores.sh octavos    //Muestra la llave de octavos de final
./libertadores.sh cuartos    //Muestra la llave de cuartos de final
./libertadores.sh semi       //Muestra la llave de semifinales
./libertadores.sh final      //Muestra la llave final

####xpath

Debian/Ubuntu

$sudo aptitude install libxml-xpath-perl



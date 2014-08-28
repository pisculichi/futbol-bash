#!/bin/bash
# -*- ENCODING: UTF-8 -*-
if [ -z $2  ]
then
  fecha="1"
elif [ $2 -gt "38" ]
then
    fecha="1"
else
  fecha=$2
fi
case "$1" in
  [Aa][r][g][e][n][t][i][n][a] ) url="http://estadisticas.tycsports.com/proceso/incoming/html/primeraa/fixture.html"
    partidosFecha=10
    ;;
  [Ee][s][p][a][ñ][a] )    url="http://estadisticas.tycsports.com/proceso/incoming/html/espana/fixture.html"
    partidosFecha=10
    ;;
  [Pp][r][e][m][i][e][r] )    url="http://estadisticas.tycsports.com/proceso/incoming/html/premierleague/fixture.html"
    partidosFecha=10
    ;;
  [Cc][a][l][c][i][o] )    url="http://estadisticas.tycsports.com/proceso/incoming/html/italia/fixture.html"
    partidosFecha=10
    ;;
  [Bb][u][n][d][e][s][l][i][g][a] )    url="http://estadisticas.tycsports.com/proceso/incoming/html/alemania/fixture.html"
    partidosFecha=9
    ;;
  [Uu][r][u][g][u][a][y] )    url="http://estadisticas.tycsports.com/proceso/incoming/html/uruguay/fixture.html"
    partidosFecha=8
    ;;
  * )	url="http://estadisticas.tycsports.com/proceso/incoming/html/primeraa/fixture.html"
    partidosFecha=10
    ;;
esac



rm /tmp/fixture.tmp* /tmp/fixture.html 2> /dev/null
wget -O /tmp/fixture.tmp -c -nv $url 2> /dev/null 

iconv -t utf8 /tmp/fixture.tmp -o /tmp/fixture.tmp.utf8

sed -n '/<div id="datos_/,/<\/div>/p' /tmp/fixture.tmp.utf8 | tr "&" " " > /tmp/fixture.tmp2
sed '1c<div>\n<div>\n<table>' /tmp/fixture.tmp2 | sed '/<td class="gol vis"><span> nbsp;/c<td class="gol vis"><span>-</span></td>'  | sed '/<td class="gol loc"><span> nbsp;/c<td class="gol loc"><span>-</span></td>' | sed '/<td class="escudo">/d' | sed '/<td xmlns=/d' | sed '/<div id="datos/c<div>\n<table>' > /tmp/fixture.html
echo "</div>" >> /tmp/fixture.html

local=( `xpath -q -e '//td[@class="equipo"]//span[@class="local"]/text()' /tmp/fixture.html | tr " " "_"` )

gol_local=( `xpath -q -e '//td[@class="gol loc"]//span/text()' /tmp/fixture.html | tr " " "_"` )

gol_visita=( `xpath -q -e '//td[@class="gol vis"]//span/text()' /tmp/fixture.html | tr " " "_"` )

visita=( `xpath -q -e '//td[@class="equipo"]//span[@class="visitante"]/text()' /tmp/fixture.html | tr " " "_"` )

dias=( `xpath -q -e '//td[@class="dia"]/text()' /tmp/fixture.html | tr " " "_"` )

horas=( `xpath -q -e '//td[@class="hora"]/text()' /tmp/fixture.html | tr " " "_"` )

header="|  %-20s | %-2s | %-2s | %-3s| %-20s | %-12s | %-20s |\n"
content="|  %-20s | %-2s | %-2s | %-2s | %-20s | %-11s | %-20s |\n"

printf "%40s\n\n" "Resultados Fecha N° $fecha"

printf "$header" "Local" " " "vs" " " "Visitante" "Día" "Hora"

ini=`expr "($fecha -1)*$partidosFecha"`
fin=`expr "$fecha*$partidosFecha"`
for (( i=$ini;i<$fin;i++ ))
do
	printf "$content" "`echo ${local[$i]} | tr "_" " "`" "${gol_local[$i]}" "vs" "${gol_visita[$i]}" "`echo ${visita[$i]} | tr "_" " "`" "${dias[$i]}" "`echo ${horas[$i]} | tr "_" " "`"
done
printf "\n"
exit

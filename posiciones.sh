#!/bin/bash
# -*- ENCODING: UTF-8 -*-

case "$1" in
  [Ee][s][p][a][ñ][a] )    url="http://estadisticas.tycsports.com/proceso/incoming/html/espana/posiciones.html"
    ;;
  [Pp][r][e][m][i][e][r] )    url="http://estadisticas.tycsports.com/proceso/incoming/html/premierleague/posiciones.html"
    ;;
  [Cc][a][l][c][i][o] )    url="http://estadisticas.tycsports.com/proceso/incoming/html/italia/posiciones.html"
    ;;
  [Bb][u][n][d][e][s][l][i][g][a] )    url="http://estadisticas.tycsports.com/proceso/incoming/html/alemania/posiciones.html"
    ;;
  [Uu][r][u][g][u][a][y] )    url="http://estadisticas.tycsports.com/proceso/incoming/html/uruguay/posiciones.html"
    ;;
  [Aa][r][g][e][n][t][i][n][a] )	url="http://estadisticas.tycsports.com/proceso/incoming/html/primeraa/posiciones.html"
    ;;
  * )  url="http://estadisticas.tycsports.com/proceso/incoming/html/primeraa/posiciones.html"
esac

rm /tmp/posiciones.tmp* /tmp/posiciones.html* 2> /dev/null

wget -O /tmp/posiciones.tmp -c -nv $url 2> /dev/null 

iconv -t utf8 /tmp/posiciones.tmp -o /tmp/posiciones.tmp.utf8

sed -n '/<div class="contenido">/,/<\/div>/p' /tmp/posiciones.tmp.utf8 | tr "&" " " > /tmp/posiciones.html2
sed '/<span class="p_champions/d' /tmp/posiciones.html2 | sed '/<span class="p_europa/d' | sed '/<span class="p_desciende/d' > /tmp/posiciones.html
echo "</div>" >> /tmp/posiciones.html

equipos=( `xpath -q -e '/div/div/table/tr/td//span/text()' /tmp/posiciones.html | tr " " "_"` )

header="|%4s | %20s | %3s| %3s| %3s| %3s| %3s| %3s| %3s|\n"
content="|%4s | %20s | %-2s | %-2s | %-2s | %-2s | %-2s | %-2s | %-2s | \n"

printf "%40s\n\n" "POSICIONES"
printf "$header" "POS" "EQUIPO" "PTS" "PJ" "PG" "PE" "PP" "GF" "GC"

for (( i=10;i<${#equipos[*]};i++ ))
do
	printf "$content" ${equipos[$i]} "`echo ${equipos[$i+1]} | tr "_" " "`" ${equipos[$i+2]} ${equipos[$i+3]} ${equipos[$i+4]} ${equipos[$i+5]} ${equipos[$i+6]} ${equipos[$i+7]} ${equipos[$i+8]}
	let i=$i+8
done
printf "\n"
exit

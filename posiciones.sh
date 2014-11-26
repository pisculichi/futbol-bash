#!/bin/bash
# -*- ENCODING: UTF-8 -*-

case "$1" in
  [Ee][s][p][a][ñ][a] )    url="http://estadisticas-deportes.tycsports.com/html/v3/htmlCenter/data/deportes/futbol/espana/pages/es/posiciones.html"
    ;;
  [Pp][r][e][m][i][e][r] )    url="http://estadisticas-deportes.tycsports.com/html/v3/htmlCenter/data/deportes/futbol/premierleague/pages/es/posiciones.html"
    ;;
  [Cc][a][l][c][i][o] )    url="http://estadisticas-deportes.tycsports.com/html/v3/htmlCenter/data/deportes/futbol/italia/pages/es/posiciones.html"
    ;;
  [Bb][u][n][d][e][s][l][i][g][a] )    url="http://estadisticas-deportes.tycsports.com/html/v3/htmlCenter/data/deportes/futbol/alemania/pages/es/posiciones.html"
    ;;
  [Uu][r][u][g][u][a][y] )    url="http://estadisticas-deportes.tycsports.com/html/v3/htmlCenter/data/deportes/futbol/uruguay/pages/es/posiciones.html"
    ;;
  [Aa][r][g][e][n][t][i][n][a] )	url="http://estadisticas-deportes.tycsports.com/html/v3/htmlCenter/data/deportes/futbol/primeraa/pages/es/posiciones.html"
    ;;
  * )  url="http://estadisticas-deportes.tycsports.com/html/v3/htmlCenter/data/deportes/futbol/primeraa/pages/es/posiciones.html"
esac

rm /tmp/posiciones.tmp* /tmp/posiciones.html* 2> /dev/null

wget -O /tmp/posiciones.tmp -c -nv $url 2> /dev/null

iconv -t utf8 /tmp/posiciones.tmp -o /tmp/posiciones.tmp.utf8

sed -n '/<table class="tabla_fase table table-condensed" id="pos_n1">/,/<\/table>/p' /tmp/posiciones.tmp.utf8 | tr "&" " " > /tmp/posiciones.html2
sed  '/<img src=/d' /tmp/posiciones.html2 | sed 's/<\/div>//g' | sed 's/<div class="border">//g' | sed 's/<span class="badge">//g' | sed 's/<\/span>//g' |sed '/<span class="p_europa/d' | sed '/<span class="p_desciende/d' > /tmp/posiciones.html

equipos=( `xpath -q -e '/table/tr//td/text()' /tmp/posiciones.html | tr " " "_"` )

header="|%4s | %20s | %3s| %3s| %3s| %3s| %3s| %3s| %3s|\n"
content="|%4s | %20s | %-2s | %-2s | %-2s | %-2s | %-2s | %-2s | %-2s | \n"

printf "\n%40s\n\n" "POSICIONES"
printf "$header" "POS" "EQUIPO" "PTS" "PJ" "PG" "PE" "PP" "GF" "GC"

for (( i=0;i<${#equipos[*]};i++ ))
do
	printf "$content" ${equipos[$i]} "`echo ${equipos[$i+1]} | tr "_" " "`" ${equipos[$i+2]} ${equipos[$i+3]} ${equipos[$i+4]} ${equipos[$i+5]} ${equipos[$i+6]} ${equipos[$i+7]} ${equipos[$i+8]}
	let i=$i+8
done
printf "\n"
exit

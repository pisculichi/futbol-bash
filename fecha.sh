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
  [Aa][r][g][e][n][t][i][n][a] ) url="http://estadisticas-deportes.tycsports.com/html/v3/htmlCenter/data/deportes/futbol/primeraa/pages/es/fixture.html"
    partidosFecha=10
    ;;
  [Ee][s][p][a][ñ][a] )    url="http://estadisticas-deportes.tycsports.com/html/v3/htmlCenter/data/deportes/futbol/espana/pages/es/fixture.html"
    partidosFecha=10
    ;;
  [Pp][r][e][m][i][e][r] )    url="http://estadisticas-deportes.tycsports.com/html/v3/htmlCenter/data/deportes/futbol/premierleague/pages/es/fixture.html"
    partidosFecha=10
    ;;
  [Cc][a][l][c][i][o] )    url="http://estadisticas-deportes.tycsports.com/html/v3/htmlCenter/data/deportes/futbol/italia/pages/es/fixture.html"
    partidosFecha=10
    ;;
  [Bb][u][n][d][e][s][l][i][g][a] )    url="http://estadisticas-deportes.tycsports.com/html/v3/htmlCenter/data/deportes/futbol/alemania/pages/es/fixture.html"
    partidosFecha=9
    ;;
  [Uu][r][u][g][u][a][y] )    url="http://estadisticas-deportes.tycsports.com/html/v3/htmlCenter/data/deportes/futbol/uruguay/pages/es/fixture.html"
    partidosFecha=8
    ;;
  [Cc][h][i][l][e] )    url="http://estadisticas-deportes.tycsports.com/html/v3/htmlCenter/data/deportes/futbol/chile/pages/es/fixture.html"
    partidosFecha=9
    ;;
  [Ee][c][u][a][d][o][r] )	url="http://estadisticas-deportes.tycsports.com/html/v3/htmlCenter/data/deportes/futbol/ecuador/pages/es/fixture.html"
    partidosFecha=6
    ;;
  [Pp][a][r][a][g][u][a][y] )	url="http://estadisticas-deportes.tycsports.com/html/v3/htmlCenter/data/deportes/futbol/paraguay/pages/es/fixture.html"
    partidosFecha=6
    ;;
  [Bb][o][l][i][v][i][a] ) url="http://estadisticas-deportes.tycsports.com/html/v3/htmlCenter/data/deportes/futbol/bolivia/pages/es/fixture.html"
    partidosFecha=6
    ;;
  [Pp][e][r][u] )	url="http://estadisticas-deportes.tycsports.com/html/v3/htmlCenter/data/deportes/futbol/peru/pages/es/fixture.html"
    partidosFecha=8
    ;;
  [Vv][e][n][e][z][u][e][l][a] )	url="http://estadisticas-deportes.tycsports.com/html/v3/htmlCenter/data/deportes/futbol/venezuela/pages/es/fixture.html"
    partidosFecha=9
    ;;
  * )	url="http://estadisticas-deportes.tycsports.com/html/v3/htmlCenter/data/deportes/futbol/primeraa/pages/es/fixture.html"
    partidosFecha=10
    ;;
esac


rm /tmp/fixture.tmp* /tmp/fixture.html 2> /dev/null
wget -O /tmp/fixture.tmp -c -nv $url 2> /dev/null 

iconv -t utf8 /tmp/fixture.tmp -o /tmp/fixture.tmp.utf8

sed -n '/<div class="fase n1 col-md-12  show">/,/<div class="footerCtn">/p' /tmp/fixture.tmp.utf8 | tr "&" " " > /tmp/fixture.tmp2
sed '1c<div>\n<div>\n' /tmp/fixture.tmp2 | sed '/<img src/d' | sed 's/ nbsp;/-/g' | sed 's/<\/ul><\/div><\/nav>//g' | sed '/<div class="footerCtn">/d' > /tmp/fixture.html

local=( `xpath -q -e '//div[@class="col-md-5 col-sm-5 col-xs-10 local"]//div[@class="equipo col-xs-4"]/text()' /tmp/fixture.html | tr " " "_"` )

gol_local=( `xpath -q -e '//div[@class="col-md-5 col-sm-5 col-xs-10 local"]//div[@class="resultado col-xs-3"]/text()' /tmp/fixture.html | tr " " "_"` )

gol_visita=( `xpath -q -e '//div[@class="col-md-5  col-sm-5 col-xs-10 visitante"]//div[@class="resultado col-xs-3"]/text()' /tmp/fixture.html | tr " " "_"` )

visita=( `xpath -q -e '//div[@class="col-md-5  col-sm-5 col-xs-10 visitante"]//div[@class="equipo col-xs-4"]/text()' /tmp/fixture.html | tr " " "_"` )

dias=( `xpath -q -e '//div[@class="dia col-md-3 col-sm-3 col-xs-4 mc-date"]//text()' /tmp/fixture.html | tr " " "_"` )

horas=( `xpath -q -e '//div[@class="hora col-md-3 col-sm-3 col-xs-4 mc-time"]//text()' /tmp/fixture.html | tr " " "_"` )

header="|  %-25s | %-2s | %-2s | %-3s| %-25s | %-12s | %-10s |\n"
content="|  %-25s | %-2s | %-2s | %-2s | %-25s | %-11s | %-10s |\n"

printf "\n%40s\n\n" "Resultados Fecha N° $fecha"

printf "$header" "Local" " " "vs" " " "Visitante" "Día" "Hora"

ini=`expr "($fecha -1)*$partidosFecha"`
fin=`expr "$fecha*$partidosFecha"`
for (( i=$ini;i<$fin;i++ ))
do
	printf "$content" "`echo ${local[$i]} | tr "_" " "`" "${gol_local[$i]}" "vs" "${gol_visita[$i]}" "`echo ${visita[$i]} | tr "_" " "`" "${dias[$i]}" "`echo ${horas[$i]} | tr "_" " "`"
done
printf "\n"
exit

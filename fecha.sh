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

# Detectamos el mapa de caracteres que se esta usando
codificacion=`locale | grep -E -i -o "armscii8|big5(hkscs)?|cp125[1-5]|euc(jp|kr|tw)|gb(18030|2312|k)|georgianps|iso8859[1-9][0-5]?|koi8[rtu]|pt154|tis620|utf-?8|tcvn57121|rk1048" |sort -u`
iconv -f latin1 -t $codificacion /tmp/fixture.tmp -o /tmp/fixture.tmp.utf8

sed -n '/<div class="fase n1 col-md-12  show">/,/<div class="footerCtn">/p' /tmp/fixture.tmp.utf8 | tr "&" " " > /tmp/fixture.tmp2
sed '1c<div>\n<div>\n' /tmp/fixture.tmp2 | sed '/<img src/d' | sed 's/ nbsp;/-/g' | sed 's/<\/ul><\/div><\/nav>//g' | sed '/<div class="footerCtn">/d' > /tmp/fixture.html

parseador="xpath -q -e '%s' /tmp/fixture.html | tr "'" " "_"'

local=($( sh -c "`printf "$parseador" '//div[@class="col-md-5 col-sm-5 col-xs-10 local"]//div[@class="equipo col-xs-4"]/text()'`" ))

gol_local=($( sh -c "`printf "$parseador" '//div[@class="col-md-5 col-sm-5 col-xs-10 local"]//div[@class="resultado col-xs-3"]/text()'`" ))

gol_visita=($( sh -c "`printf "$parseador" '//div[@class="col-md-5  col-sm-5 col-xs-10 visitante"]//div[@class="resultado col-xs-3"]/text()'`" ))

visita=($( sh -c "`printf "$parseador" '//div[@class="col-md-5  col-sm-5 col-xs-10 visitante"]//div[@class="equipo col-xs-4"]/text()'`" ))

dias=($( sh -c "`printf "$parseador" '//div[@class="dia col-md-3 col-sm-3 col-xs-4 mc-date"]//text()'`" ))

horas=($( sh -c "`printf "$parseador" '//div[@class="hora col-md-3 col-sm-3 col-xs-4 mc-time"]//text()'`" ))

cabecera_local="Local"
ancho_local=${#cabecera_local}
cabecera_visitante="Visitante"
ancho_visitante=${#cabecera_visitante}
ini=`expr "($fecha -1)*$partidosFecha"`
fin=`expr "$fecha*$partidosFecha"`

for (( i=$ini;i<$fin;i++ ))
do
    if [ ${#local[$i]} -ge $ancho_local ]; then
        ancho_local=${#local[$i]}
    fi
    if [ ${#visita[$i]} -ge $ancho_visitante ]; then
        ancho_visitante=${#visita[$i]}
    fi
done

header="|  %-""$ancho_local""s | %-2s | %-2s | %-3s| %-""$ancho_visitante""s | %-12s | %-7s |\n"
content="|  %-""$ancho_local""s | %-2s | %-2s | %-2s | %-""$ancho_visitante""s | %-11s | %-6s |\n"

printf "\n%40s\n\n" "Resultados Fecha N° $fecha"

printf "$header" $cabecera_local " " "vs" " " $cabecera_visitante "Día" "Hora"

for (( i=$ini;i<$fin;i++ ))
do
	awk 'BEGIN{printf "'"$content"'", "'"${local[$i]//_/ }"'", "'${gol_local[$i]}'", "vs", "'${gol_visita[$i]}'", "'"${visita[$i]//_/ }"'", "'${dias[$i]}'", "'"${horas[$i]//_/ }"'"}'
done
printf "\n"
exit


#!/bin/bash
# -*- ENCODING: UTF-8 -*-

case "$1" in
  [Aa][r][g][e][n][t][i][n][a] ) url="http://estadisticas-deportes.tycsports.com/html/v3/htmlCenter/data/deportes/futbol/primeraa/pages/es/fixture.html"
    partidosFecha=15
    fechasLiga=30
    ;;
  [Ee][s][p][a][ñ][a] )    url="http://estadisticas-deportes.tycsports.com/html/v3/htmlCenter/data/deportes/futbol/espana/pages/es/fixture.html"
    partidosFecha=10
    fechasLiga=38
    ;;
  [Pp][r][e][m][i][e][r] )    url="http://estadisticas-deportes.tycsports.com/html/v3/htmlCenter/data/deportes/futbol/premierleague/pages/es/fixture.html"
    partidosFecha=10
    fechasLiga=38
    ;;
  [Cc][a][l][c][i][o] )    url="http://estadisticas-deportes.tycsports.com/html/v3/htmlCenter/data/deportes/futbol/italia/pages/es/fixture.html"
    partidosFecha=10
    fechasLiga=38
    ;;
  [Bb][u][n][d][e][s][l][i][g][a] )    url="http://estadisticas-deportes.tycsports.com/html/v3/htmlCenter/data/deportes/futbol/alemania/pages/es/fixture.html"
    partidosFecha=9
    fechasLiga=34
    ;;
  [Uu][r][u][g][u][a][y] )    url="http://estadisticas-deportes.tycsports.com/html/v3/htmlCenter/data/deportes/futbol/uruguay/pages/es/fixture.html"
    partidosFecha=8
    fechasLiga=15
    ;;
  [Cc][h][i][l][e] )    url="http://estadisticas-deportes.tycsports.com/html/v3/htmlCenter/data/deportes/futbol/chile/pages/es/fixture.html"
    partidosFecha=9
    fechasLiga=15
    ;;
  [Vv][e][n][e][z][u][e][l][a] )	url="http://estadisticas-deportes.tycsports.com/html/v3/htmlCenter/data/deportes/futbol/venezuela/pages/es/fixture.html"
    partidosFecha=10
    fechasLiga=19
    ;;
  [Cc][o][l][o][m][b][i][a] )	url="http://estadisticas-deportes.tycsports.com/html/v3/htmlCenter/data/deportes/futbol/colombia/pages/es/fixture.html"
    partidosFecha=10
    fechasLiga=19
    ;;
  [Mm][e][x][i][c][o] ) url="http://estadisticas-deportes.tycsports.com/html/v3/htmlCenter/data/deportes/futbol/mexico/pages/es/fixture.html"
    partidosFecha=9
    fechasLiga=19
    ;;
  [Bb][n][a][c][i][o][n][a][l] ) url="http://estadisticas-deportes.tycsports.com/html/v3/htmlCenter/data/deportes/futbol/nacionalb/pages/es/fixture.html"
    partidosFecha=11
    fechasLiga=42
    ;;
  [Bb][r][a][s][i][l] ) url="http://estadisticas-deportes.tycsports.com/html/v3/htmlCenter/data/deportes/futbol/brasileirao/pages/es/fixture.html"
    partidosFecha=9
    fechasLiga=38
    ;;
  * )	url="http://estadisticas-deportes.tycsports.com/html/v3/htmlCenter/data/deportes/futbol/primeraa/pages/es/fixture.html"
    partidosFecha=15
    ;;
esac


rm /tmp/fixture.tmp* /tmp/fixture.html 2> /dev/null
wget -O /tmp/fixture.tmp -c -nv $url 2> /dev/null 

# Detectamos el mapa de caracteres que se esta usando
codificacion=`locale | grep -E -i -o "armscii8|big5(hkscs)?|cp125[1-5]|euc(jp|kr|tw)|gb(18030|2312|k)|georgianps|iso8859[1-9][0-5]?|koi8[rtu]|pt154|tis620|utf-?8|tcvn57121|rk1048" |sort -u`
iconv -f latin1 -t $codificacion /tmp/fixture.tmp -o /tmp/fixture.tmp.utf8

fecha_act=`grep '="active' /tmp/fixture.tmp.utf8 | grep nivel1 | uniq | xpath -q -e '*/a/text()'`
fecha_sig=`expr $fecha_act + 1`

if [ $fecha_act -eq $fechasLiga ]
then
	sed -n '/<div class="col-md-12 fecha" data-fase="nivel_1" data-fecha="nivel1_fecha'$fecha_act'">/,/<div class="footerCtn">/p' /tmp/fixture.tmp.utf8 | sed '1c<div>\n<div><div>' | tr "&" " " > /tmp/fixture.tmp2
else
	sed -n '/<div class="col-md-12 fecha show" data-fase="nivel_1" data-fecha="nivel1_fecha'$fecha_act'">/,/<div class="col-md-12 fecha" data-fase="nivel_1" data-fecha="nivel1_fecha'$fecha_sig'">/p' /tmp/fixture.tmp.utf8 | sed 's/<div class="col-md-12 fecha" data-fase="nivel_1" data-fecha="nivel1_fecha'$fecha_sig'">//g' | tr "&" " " > /tmp/fixture.tmp2
fi

sed '1c<div><div><div>\n' /tmp/fixture.tmp2 | sed '/<img src/d' | sed 's/ nbsp;/-/g' | sed 's/ e_[0-9]*//g' | sed '/<div class="footerCtn">/d' > /tmp/fixture.html
echo "</div></div>" >> /tmp/fixture.html

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
ini=0
fin=$partidosFecha

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

printf "\n%40s\n\n" "Resultados Fecha N° $fecha_act"

printf "$header" $cabecera_local " " "vs" " " $cabecera_visitante "Día" "Hora"

for (( i=$ini;i<$fin;i++ ))
do
	awk 'BEGIN{printf "'"$content"'", "'"${local[$i]//_/ }"'", "'${gol_local[$i]}'", "vs", "'${gol_visita[$i]}'", "'"${visita[$i]//_/ }"'", "'${dias[$i]}'", "'"${horas[$i]//_/ }"'"}'
done
printf "\n"
exit


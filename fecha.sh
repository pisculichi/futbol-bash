#!/bin/bash
# -*- ENCODING: UTF-8 -*-

case "$1" in
  [Aa][r][g][e][n][t][i][n][a] ) url="http://estadisticas-deportes.tycsports.com/html/v3/htmlCenter/data/deportes/futbol/primeraa/pages/es/fixture.html"
    partidosFecha=14
    fechasLiga=27
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
    partidosFecha=8
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
    fechasLiga=17
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
    partidosFecha=14
    fechasLiga=37
    ;;
esac

rm /tmp/fixture.tmp* /tmp/fixture.html 2> /dev/null
wget -O /tmp/fixture.tmp -c -nv $url 2> /dev/null 
# Detectamos el mapa de caracteres que se esta usando
codificacion=`locale | grep -E -i -o "armscii8|big5(hkscs)?|cp125[1-5]|euc(jp|kr|tw)|gb(18030|2312|k)|georgianps|iso8859[1-9][0-5]?|koi8[rtu]|pt154|tis620|utf-?8|tcvn57121|rk1048" |sort -u`
iconv -f latin1 -t $codificacion /tmp/fixture.tmp -o /tmp/fixture.tmp.utf8

fecha_act=`grep '="active' /tmp/fixture.tmp.utf8 | grep nivel1 | uniq | xpath -q -e '*/a/text()'`
fecha_sig=`expr $fecha_act + 1`
fecha_ant=`expr $fecha_act - 1`

# Si no se recibe la fecha o es mayor a las que posee la liga se usará la fecha actual.
if [ -z $2  ]
then
  fecha=$fecha_act
elif [ $2 -gt $fechasLiga ]
then
    fecha=$fecha_act
else
  fecha=$2
fi

# tag_aper y tag cierre son los tag que determinan el contenido de la fecha en un div.
# Sirve para solo quedarnos con el texto que interesa parsear.

# tag_aper depende de la fecha
if [ $fecha -eq $fecha_act ]
then
    tag_aper='<div class="col-md-12 fecha show" data-fase="nivel_1" data-fecha="nivel1_fecha'$fecha'">'
else
    tag_aper='<div class="col-md-12 fecha" data-fase="nivel_1" data-fecha="nivel1_fecha'$fecha'">'
fi

# tag_cierre depende de la fecha
if [ $fecha -eq $fechasLiga ]
then
    tag_cierre='<div class="footerCtn">'
elif [ $fecha -eq $fecha_ant ]
then
    tag_cierre='<div class="col-md-12 fecha show" data-fase="nivel_1" data-fecha="nivel1_fecha'$fecha_act'">'
else
    tag_cierre='<div class="col-md-12 fecha" data-fase="nivel_1" data-fecha="nivel1_fecha'`expr $fecha + 1`'">'
fi

# Obtengo el contenido de la fecha a parsear.
sed -n '/'"$tag_aper"'/,/'"$tag_cierre"'/p' /tmp/fixture.tmp.utf8 | sed 's/'"$tag_cierre"'//g' | tr "&" " " > /tmp/fixture.tmp2
sed '1c<div><div><div>\n' /tmp/fixture.tmp2 | sed 's/<\/img>//g' | sed 's/<img src//g' | sed 's/ nbsp;/-/g' | sed 's/ e_[0-9]*//g' | sed '/<div class="footerCtn">/d' > /tmp/fixture.html
if [ $fecha -eq $fechasLiga ]
then
    head -n -3 /tmp/fixture.html > /tmp/fixture1.html
    mv /tmp/fixture1.html /tmp/fixture.html
fi
echo "</div></div>" >> /tmp/fixture.html

parseador="xpath -q -e '%s' /tmp/fixture.html | sed -e 's/Ã¡/á/g' -e 's/Ã­/í/g' -e 's/Ã³/ó/g' -e 's/Ã©/é/g' -e 's/Ãº/ú/g' | tr "'" " "_"'

local=($( sh -c "`printf "$parseador" '//div[@class="col-md-5 col-sm-5 col-xs-10 local"]//div[@class="equipo col-xs-4"]/text()'`" ))

gol_local=($( sh -c "`printf "$parseador" '//div[@class="col-md-5 col-sm-5 col-xs-10 local"]//div[@class="resultado col-xs-3"]/text()'`" ))

gol_visita=($( sh -c "`printf "$parseador" '//div[@class="col-md-5  col-sm-5 col-xs-10 visitante"]//div[@class="resultado col-xs-3"]/text()'`" ))

visita=($( sh -c "`printf "$parseador" '//div[@class="col-md-5  col-sm-5 col-xs-10 visitante"]//div[@class="equipo col-xs-4"]/text()'`" ))

dias=($( sh -c "`printf "$parseador" '//div[@class="dia col-md-3 col-sm-3 col-xs-4 mc-date"]//text()'`" ))

horas=($( sh -c "`printf "$parseador" '//div[@class="hora col-md-3 col-sm-3 col-xs-4 mc-time"]//text()'`" ))

cabecera_local="LOCAL"
ancho_local=${#cabecera_local}
cabecera_visitante="VISITANTE"
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

header="|  %-""$ancho_local""s    [ %-1s ] %-2s [ %-1s ]    %-""$ancho_visitante""s  | %-11s | %-7s |\n"
content="|  \033[1;31m%-""$ancho_local""s\033[0m    [ \033[1;31m%-1s\033[0m ] %-2s [ \033[1;34m%-1s\033[0m ]    \033[1;34m%-""$ancho_visitante""s\033[0m  | %-11s | %-7s |\n"

printf "\n\e[1m%50s\e[0m\n\n" "Resultados Fecha N° $fecha"

printf "%78s\n" | tr " " -

printf "$header" $cabecera_local "-" " vs " "-" $cabecera_visitante "DIA" "HORA"

printf "%78s\n" | tr " " -

for (( i=$ini;i<$fin;i++ ))
do
	awk 'BEGIN{printf "'"$content"'", "'"${local[$i]//_/ }"'", "'${gol_local[$i]}'", " vs ", "'${gol_visita[$i]}'", "'"${visita[$i]//_/ }"'", "'${dias[$i]}'", "'"${horas[$i]//_/ }"'"}'
	printf "%78s\n" | tr " " - 
done
exit

#!/bin/bash
# -*- ENCODING: UTF-8 -*-

function playoff {
    url=$1
    fase_ini=$2
    fase_fin=`expr $fase_ini + 1`
    nombre_fase=$3
    rm /tmp/fixture.tmp* /tmp/fixture.html 2> /dev/null
    wget -O /tmp/fixture.tmp -c -nv $url 2> /dev/null

    codificacion=`locale | grep -E -i -o "armscii8|big5(hkscs)?|cp125[1-5]|euc(jp|kr|tw)|gb(18030|2312|k)|georgianps|iso8859[1-9][0-5]?|koi8[rtu]|pt154|tis620|utf-?8|tcvn57121|rk1048" | sort -u`
#    iconv -f latin1 -t $codificacion /tmp/fixture.tmp -o /tmp/fixture.tmp.utf8
    cp /tmp/fixture.tmp /tmp/fixture.tmp.utf8
    sed 's/ show//g' /tmp/fixture.tmp.utf8 > /tmp/fixture.tmp
    sed -n '/<div class="fase n'"$fase_ini"' col-md-12 ">/,/<div class="fase n'"$fase_fin"' col-md-12 ">/p' /tmp/fixture.tmp | sed '/<script/,/<\/script>/d' | tr "&" " " > /tmp/fixture.tmp2
    sed 's/<\/img>//g' /tmp/fixture.tmp2 | sed 's/<img src//g' | sed 's/ nbsp;/-/g' | sed 's/ e_[0-9]*//g' | sed '/<div class="footerCtn">/d' | sed '/<div class="fase n'"$fase_fin"'/d' > /tmp/fixture.html
    if [ $2 -gt 5 ]
    then
        sed '1c<div><div><div><div><div>' /tmp/fixture.html > /tmp/fixture.html2
        sed -i '2d ' /tmp/fixture.html2
    else
        sed '1c<div><div><div>\n' /tmp/fixture.html > /tmp/fixture.html2
    fi
    mv /tmp/fixture.html2 /tmp/fixture.html
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
    cant_partidos=${#local[*]}

    for (( i=0;i<$cant_partidos;i++ ))
    do
	if [ ${#local[$i]} -ge $ancho_local ]; then
	    ancho_local=${#local[$i]}
	fi
	if [ ${#visita[$i]} -ge $ancho_visitante ]; then
	    ancho_visitante=${#visita[$i]}
	fi
    done

    header="|  %-""$ancho_local""s | %-2s | %-2s | %-3s| %-""$ancho_visitante""s | %-12s |  %-5s  |\n"
    content="|  %-""$ancho_local""s | %-2s | %-2s | %-2s | %-""$ancho_visitante""s | %-11s | %-7s |\n"

    printf "\n%40s\n" "$nombre_fase"

    for (( i=0;i<$cant_partidos;i++ ))
    do
	let j=$((($i/2)+1))
	if [ $(($i % 2)) -eq 0 ]
	then
	    printf "\n%40s\n" "Llave  $j"
	    printf "$header" "Local" " " "vs" " " "Visitante" "Día" "Hora"
	fi
	awk 'BEGIN{printf "'"$content"'", "'"${local[$i]//_/ }"'", "'${gol_local[$i]}'", "vs", "'${gol_visita[$i]}'", "'"${visita[$i]//_/ }"'", "'${dias[$i]}'", "'"${horas[$i]//_/ }"'"}'
    done
    printf "\n"
}

url="http://estadisticas-deportes.tycsports.com/html/v3/htmlCenter/data/deportes/futbol/sudamericana/pages/es/fixture.html"
case "$1" in
  [Rr][e][p][e][c][h][a][j][e] )
    playoff $url 1 "Repechajes"
    ;;
  [1][6][a][v][o][s] )
    playoff $url 2 "16° de Final"
    ;;
  [Oo][c][t][a][v][o][s] )
    playoff $url 3 "8° de Final"
    ;;
  [Cc][u][a][r][t][o][s] )
    playoff $url 4 "4° de Final"
    ;;
  [Ss][e][m][i] )
    playoff $url 5 "Semifinal"
    ;;
  [Ff][i][n][a][l])
    playoff $url 6 "Final"
    ;;
  * )
    ;;
esac

exit

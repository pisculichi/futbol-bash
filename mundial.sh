#!/bin/bash
# -*- ENCODING: UTF-8 -*-

function playoff {
    url=$1
    fase_ini=$2
    fase_fin=`expr $fase_ini + 1`
    nombre_fase=$3
    cantidad_partidos=$4
    index=$5
    rm /tmp/fixture.tmp* /tmp/fixture.html 2> /dev/null
    wget -O /tmp/fixture.tmp -c -nv $url 2> /dev/null 

    codificacion=`locale | grep -E -i -o "armscii8|big5(hkscs)?|cp125[1-5]|euc(jp|kr|tw)|gb(18030|2312|k)|georgianps|iso8859[1-9][0-5]?|koi8[rtu]|pt154|tis620|utf-?8|tcvn57121|rk1048" | sort -u`
    iconv -f latin1 -t $codificacion /tmp/fixture.tmp -o /tmp/fixture.tmp.utf8
    sed 's/ show//g' /tmp/fixture.tmp.utf8 > /tmp/fixture.tmp
    sed -n '/<div class="fase moduleCtn n2 col-md-12 ">/,/<div class="footerCtn">/p' /tmp/fixture.tmp | tr "&" " " > /tmp/fixture.tmp2
    sed 's/<\/img>//g' /tmp/fixture.tmp2 | sed 's/<img src//g' | sed 's/ nbsp;/-/g' | sed 's/ e_[0-9]*//g' | sed '/<div class="footerCtn">/d' > /tmp/fixture.html
    if [ $2 -eq 8 ]; then
        sed '1c<div><div><div>\n' /tmp/fixture.html > /tmp/fixture.html2
    else
        sed '1c<div><div><div>\n' /tmp/fixture.html > /tmp/fixture.html2
    fi
    mv /tmp/fixture.html2 /tmp/fixture.html
    parseador="xpath -q -e '%s' /tmp/fixture.html | tr "'" " "_"'

    local=($( sh -c "`printf "$parseador" '//div[@class="teams mc-teams"]//div[@class="first clearfix mc-homeTeam"]//span[@class="name mc-name"]/text()'`" ))

    gol_local=($( sh -c "`printf "$parseador" '//div[@class="teams mc-teams"]//div[@class="first clearfix mc-homeTeam"]//span[@class="number mc-score"]/text()'`" ))

    gol_visita=($( sh -c "`printf "$parseador" '//div[@class="teams mc-teams"]//div[@class="second clearfixmc-awayTeam"]//span[@class="name mc-score"]/text()'`" ))

    visita=($( sh -c "`printf "$parseador" '//div[@class="teams mc-teams"]//div[@class="second clearfix mc-awayTeam"]//span[@class="name mc-name"]/text()'`" ))

    dias=($( sh -c "`printf "$parseador" '//div[@class="mc-matchContainer"]//span[@class="date"]//span[@class="mc-date"]/text()'`" ))

    horas=($( sh -c "`printf "$parseador" '//div[@class="mc-matchContainer"]//span[@class="date"]//span[@class="mc-time"]/text()'`" ))

    cabecera_local="Local"
    ancho_local=${#cabecera_local}
    cabecera_visitante="Visitante"
    ancho_visitante=${#cabecera_visitante}

    tam_max=$(($index+$cantidad_partidos*2))

#    for (( i=0;i<$cantidad_partidos;i++ ))
    for i in $(seq $index $tam_max)
    do
	if [ ${#local[$i]} -ge $ancho_local ]; then
	    ancho_local=${#local[$i]}
	fi
	if [ ${#visita[$i]} -ge $ancho_visitante ]; then
	    ancho_visitante=${#visita[$i]}
	fi
    done

    header="|  %-""$ancho_local""s | %-2s | %-2s | %-3s| %-""$ancho_visitante""s | %-12s | %-6s |\n"
    content="|  %-""$ancho_local""s | %-2s | %-2s | %-2s | %-""$ancho_visitante""s | %-11s | %-6s |\n"

    printf "\n%40s\n" "$nombre_fase"
    j=$index
    for (( i=0;i<$cantidad_partidos;i++ ))
    do
        printf "\n%40s %s\n" "Llave  " $(($i+1))
        printf "$header" "Local" " " "vs" " " "Visitante" "Día" "Hora"
	    awk 'BEGIN{printf "'"$content"'", "'"${local[$j]//_/ }"'", "'${gol_local[$j]}'", "vs", "'${gol_visita[$j]}'", "'"${visita[$j]//_/ }"'", "'${dias[$j]}'", "'"${horas[$j]//_/ }"'"}'
        let j=$(($j+1))
    done
    printf "\n"
}

function resultados_grupo {
    url=$1
    num_grupo=$2
    rm /tmp/fixture.tmp* /tmp/fixture.html 2> /dev/null
    wget -O /tmp/fixture.tmp -c -nv $url 2> /dev/null 

    codificacion=`locale | grep -E -i -o "armscii8|big5(hkscs)?|cp125[1-5]|euc(jp|kr|tw)|gb(18030|2312|k)|georgianps|iso8859[1-9][0-5]?|koi8[rtu]|pt154|tis620|utf-?8|tcvn57121|rk1048" |sort -u`
    iconv -f latin1 -t $codificacion /tmp/fixture.tmp -o /tmp/fixture.tmp.utf8
    sed 's/ show//g' /tmp/fixture.tmp.utf8 > /tmp/fixture.tmp
    sed -n '/<div class="fase n1 col-md-12 ">/,/<div class="fase moduleCtn n2 col-md-12 ">/p' /tmp/fixture.tmp | tr "&" " " > /tmp/fixture.tmp2
    sed '1c<div>\n' /tmp/fixture.tmp2 | sed 's/<\/img>//g' | sed 's/<img src//g' | sed 's/ nbsp;/-/g' | sed 's/ e_[0-9]*//g' | sed '/<div class="footerCtn">/d' | sed '/<div class="fase moduleCtn n2/d' > /tmp/fixture.html

    parseador="xpath -q -e '%s' /tmp/fixture.html | tr "'" " "_"'

    local=($( sh -c "`printf "$parseador" '//div[@class="col-lg-6 col-md-12 fecha"][@data-grupo="'$num_grupo'"]//div[@class="col-md-5 col-sm-5 col-xs-10 local"]//div[@class="equipo col-xs-4"]/text()'`" ))

    gol_local=($( sh -c "`printf "$parseador" '//div[@class="col-lg-6 col-md-12 fecha"][@data-grupo="'$num_grupo'"]//div[@class="col-md-5 col-sm-5 col-xs-10 local"]//div[@class="resultado col-xs-3"]/text()'`"))

    gol_visita=($( sh -c "`printf "$parseador" '//div[@class="col-lg-6 col-md-12 fecha"][@data-grupo="'$num_grupo'"]//div[@class="col-md-5  col-sm-5 col-xs-10 visitante"]//div[@class="resultado col-xs-3"]/text()'`" ))

    visita=($( sh -c "`printf "$parseador" '//div[@class="col-lg-6 col-md-12 fecha"][@data-grupo="'$num_grupo'"]//div[@class="col-md-5  col-sm-5 col-xs-10 visitante"]//div[@class="equipo col-xs-4"]/text()'`" ))

    dias=($( sh -c "`printf "$parseador" '//div[@class="col-lg-6 col-md-12 fecha"][@data-grupo="'$num_grupo'"]//div[@class="dia col-md-3 col-sm-3 col-xs-4 mc-date"]//text()'`"))

    horas=($( sh -c "`printf "$parseador" '//div[@class="col-lg-6 col-md-12 fecha"][@data-grupo="'$num_grupo'"]//div[@class="hora col-md-3 col-sm-3 col-xs-4 mc-time"]//text()'`"))

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
    header="|  %-"$ancho_local"s | %-2s | %-2s | %-3s| %-"$ancho_visitante"s | %-12s |  %-5s  |\n"
    content="|  %-"$ancho_local"s | %-2s | %-2s | %-2s | %-"$ancho_visitante"s | %-11s | %-7s |\n"

    printf "\n%40s\n" "GRUPO N° $num_grupo"
    for (( i=0;i< $cant_partidos ;i++ ))
    do
	let j=$((($i/2)+1))
	if [ $(($i % 2)) -eq 0 ]
	then
	    printf "\n%40s\n" "Fecha  $j"
	    printf "$header" $cabecera_local " " "vs" " " $cabecera_visitante "Día" "Hora"
	fi
	awk 'BEGIN{printf "'"$content"'", "'"${local[$i]//_/ }"'", "'${gol_local[$i]}'", "vs", "'${gol_visita[$i]}'", "'"${visita[$i]//_/ }"'", "'${dias[$i]}'", "'"${horas[$i]//_/ }"'"}'
    done
    printf "\n"
}

function posiciones {
    url=$1
    rm /tmp/posiciones.tmp* /tmp/posiciones.html* 2> /dev/null

    wget -O /tmp/posiciones.tmp -c -nv $url 2> /dev/null

    iconv -f  iso-8859-1  -t utf8 /tmp/posiciones.tmp -o /tmp/posiciones.tmp.utf8

    sed -n '/<table class="tabla_fase table table-condensed" id="pos_n1">/,/<\/table>/p' /tmp/posiciones.tmp.utf8 | tr "&" " " > /tmp/posiciones.html2
    sed  '/<img src=/d' /tmp/posiciones.html2 | sed 's/nbsp;//g' | sed 's/<\/div>//g' | sed 's/<div class="border">//g' | sed 's/<span class="badge">//g' | sed 's/<\/span>//g' | sed '/<tr><td colspan="20"><span class="leyenda">/d' | sed '/<span class="p_europa/d' | sed '/<span class="p_desciende/d' | sed '/><table/c<table>' > /tmp/posiciones.html

    equipos=( `xpath -q -e '/table/tr//td/text()' /tmp/posiciones.html | tr " " "_"` )
    
    cabecera_equipo="Equipo"
    ancho_equipo=${#cabecera_equipo}
    cant_equipos=${#equipos[*]}

    for (( i=0;i<$cant_equipos;i++ ))
    do
	if [ ${#equipos[$i]} -ge $ancho_equipo ]; then
	    ancho_equipo=${#equipos[$i]}
	fi
    done
    
    header="|%4s | %"$ancho_equipo"s |%3s |%3s |%3s |%3s |%3s |%3s |%3s |%3s |\n"
    content="|%4s | %"$ancho_equipo"s | %2s | %2s | %2s | %2s | %2s | %2s | %2s | %2s | \n"

    printf "\n"

    for (( i=0;i<8;i++ ))
    do
	printf "%40s \n\n" "Grupo `expr $i + 1`" 
	printf "$header" "POS" $cabecera_equipo "PTS" "PJ" "PG" "PE" "PP" "GF" "GC" "DF"
	for (( j=$i*10*4;j<10*4*($i+1);j++))
	do
	    awk 'BEGIN{printf "'"$content"'", "'${equipos[$j]}'", "'"${equipos[$j+1]//_/ }"'", "'${equipos[$j+2]}'", "'${equipos[$j+3]}'", "'${equipos[$j+4]}'", "'${equipos[$j+5]}'", "'${equipos[$j+6]}'", "'${equipos[$j+7]}'", "'${equipos[$j+8]}'", "'${equipos[$j+9]}'"}'
	    let j=$j+9
	done
	printf "\n"
    done
    printf "\n"
}

url="http://estadisticas-deportes.tycsports.com/html/v3/htmlCenter/data/deportes/futbol/mundial/pages/es/fixture.html"
case "$1" in
  [Pp][o][s][i][c][i][o][n][e][s] ) url="http://estadisticas-deportes.tycsports.com/html/v3/htmlCenter/data/deportes/futbol/mundial/pages/es/posiciones.html"
    posiciones $url
    ;;
  [Rr][e][p][e][c][h][a][j][e] )
    playoff $url 1 "Repechajes"
    ;;
  [Gg][r][u][p][o] )
    # $2 seria el numero del grupo
    resultados_grupo $url $2
    ;;
  [Oo][c][t][a][v][o][s] )
    playoff $url 0 "8° de Final" 8 0
    ;;
  [Cc][u][a][r][t][o][s] )
    playoff $url 1 "4° de Final" 4 8
    ;;
  [Ss][e][m][i] )
    playoff $url 2 "Semifinal" 2 12
    ;;
  [Ff][i][n][a][l])
    playoff $url 3 "Final" 2 14
    ;;
  * )
    ;;
esac

exit

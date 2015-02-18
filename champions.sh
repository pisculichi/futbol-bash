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
    iconv -f latin1 -t $codificacion /tmp/fixture.tmp -o /tmp/fixture.tmp.utf8
    sed 's/ show//g' /tmp/fixture.tmp.utf8 > /tmp/fixture.tmp
    sed -n '/<div class="fase n'"$fase_ini"' col-md-12 ">/,/<div class="fase n'"$fase_fin"' col-md-12 ">/p' /tmp/fixture.tmp | tr "&" " " > /tmp/fixture.tmp2
    sed '1c<div><div>\n' /tmp/fixture.tmp2 | sed '/<img src/d' | sed 's/ nbsp;/-/g' | sed 's/ e_[0-9]*//g' | sed '/<div class="footerCtn">/d' | sed 's/\(.*\)<\/div><\/div><\/div>//g' | sed '/<div class="fase n'"$fase_fin"'/d' > /tmp/fixture.html

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

    header="|  %-""$ancho_local""s | %-2s | %-2s | %-3s| %-""$ancho_visitante""s | %-12s | %-6s |\n"
    content="|  %-""$ancho_local""s | %-2s | %-2s | %-2s | %-""$ancho_visitante""s | %-11s | %-6s |\n"

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

function resultados_grupo {
    url=$1
    num_grupo=$2
    rm /tmp/fixture.tmp* /tmp/fixture.html 2> /dev/null
    wget -O /tmp/fixture.tmp -c -nv $url 2> /dev/null 

    codificacion=`locale | grep -E -i -o "armscii8|big5(hkscs)?|cp125[1-5]|euc(jp|kr|tw)|gb(18030|2312|k)|georgianps|iso8859[1-9][0-5]?|koi8[rtu]|pt154|tis620|utf-?8|tcvn57121|rk1048" |sort -u`
    iconv -f latin1 -t $codificacion /tmp/fixture.tmp -o /tmp/fixture.tmp.utf8
    sed 's/ show//g' /tmp/fixture.tmp.utf8 > /tmp/fixture.tmp
    sed -n '/<div class="fase n1 col-md-12 ">/,/<div class="fase n2 col-md-12 ">/p' /tmp/fixture.tmp | tr "&" " " > /tmp/fixture.tmp2
    sed '1c<div>\n' /tmp/fixture.tmp2 |sed '/<img src/d' | sed 's/ nbsp;/-/g' | sed 's/ e_[0-9]*//g' | sed '/<div class="footerCtn">/d' | sed '/<div class="fase n2/d' > /tmp/fixture.html

    parseador="xpath -q -e '%s' /tmp/fixture.html | tr "'" " "_"'

    local=($( sh -c "`printf "$parseador" '//div[@class="col-lg-6 col-md-12 fecha"][@data-grupo="'$num_grupo'"]//div[@class="col-md-5 col-sm-5 col-xs-10 local"]//div[@class="equipo col-xs-4"]/text()'`" ))
    gol_local=($( sh -c "`printf "$parseador" '//div[@class="col-lg-6 col-md-12 fecha"][@data-grupo="'$num_grupo'"]//div[@class="col-md-5 col-sm-5 col-xs-10 local"]//div[@class="resultado col-xs-3"]/text()'`"))
    gol_visita=($( sh -c "`printf "$parseador" '//div[@class="col-lg-6 col-md-12 fecha"][@data-grupo="'$num_grupo'"]//div[@class="col-md-5  col-sm-5 col-xs-10 visitante"]//div[@class="resultado col-xs-3"]/text()'`" ))
    visita=($( sh -c "`printf "$parseador" '//div[@class="col-lg-6 col-md-12 fecha"][@data-grupo="'$num_grupo'"]//div[@class="row match-inner"]//div[2]//div[@class="equipo col-xs-4"]/text()'`" ))
    dias=($( sh -c "`printf "$parseador" '//div[@class="col-lg-6 col-md-12 fecha"][@data-grupo="'$num_grupo'"]//div[@class="dia col-md-3 col-sm-3 col-xs-4 mc-date"]//text()'`"))
    horas=($( sh -c "`printf "$parseador" '//div[@class="col-lg-6 col-md-12 fecha"][@data-grupo="'$num_grupo'"]//div[@class="hora col-md-3 col-sm-3 col-xs-4 mc-time"]//text()'`"))
    header="|  %-25s | %-2s | %-2s | %-3s| %-25s | %-12s | %-10s |\n"
    content="|  %-25s | %-2s | %-2s | %-2s | %-25s | %-11s | %-10s |\n"

    printf "\n%40s\n" "GRUPO N° $num_grupo"
    for (( i=0;i<12;i++ ))
    do
	let j=$((($i/2)+1))
	if [ $(($i % 2)) -eq 0 ]
	then
	    printf "\n%40s\n" "Fecha  $j"
	    printf "$header" "Local" " " "vs" " " "Visitante" "Día" "Hora"
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

    header="|%4s | %30s |%3s |%3s |%3s |%3s |%3s |%3s |%3s |%3s |\n"
    content="|%4s | %30s | %2s | %2s | %2s | %2s | %2s | %2s | %2s | %2s | \n"

    printf "\n"

    for (( i=0;i<8;i++ ))
    do
	printf "%40s \n\n" "Grupo `expr $i + 1`" 
	printf "$header" "POS" "EQUIPO" "PTS" "PJ" "PG" "PE" "PP" "GF" "GC" "DF"
	for (( j=$i*10*4;j<10*4*($i+1);j++))
	do
	    awk 'BEGIN{printf "'"$content"'", "'${equipos[$j]}'", "'"${equipos[$j+1]//_/ }"'", "'${equipos[$j+2]}'", "'${equipos[$j+3]}'", "'${equipos[$j+4]}'", "'${equipos[$j+5]}'", "'${equipos[$j+6]}'", "'${equipos[$j+7]}'", "'${equipos[$j+8]}'", "'${equipos[$j+9]}'"}'
	    let j=$j+9
	done
	printf "\n"
    done
    printf "\n"
}


case "$1" in
  [Pp][o][s][i][c][i][o][n][e][s] ) url="http://estadisticas-deportes.tycsports.com/html/v3/htmlCenter/data/deportes/futbol/champions/pages/es/posiciones.html"
    posiciones $url
    ;;
  [Gg][r][u][p][o] ) url="http://estadisticas-deportes.tycsports.com/html/v3/htmlCenter/data/deportes/futbol/champions/pages/es/fixture.html"
    # $2 seria el numero del grupo
    resultados_grupo $url $2
    ;;
  [Oo][c][t][a][v][o][s] )    url="http://estadisticas-deportes.tycsports.com/html/v3/htmlCenter/data/deportes/futbol/champions/pages/es/fixture.html"
    playoff $url 2 "8° de Final"
    ;;
  [Cc][u][a][r][t][o][s] )    url="http://estadisticas-deportes.tycsports.com/html/v3/htmlCenter/data/deportes/futbol/champions/pages/es/fixture.html"
    playoff $url 3 "4° de Final"
    ;;
  [Ss][e][m][i] )    url="http://estadisticas-deportes.tycsports.com/html/v3/htmlCenter/data/deportes/futbol/champions/pages/es/fixture.html"
    playoff $url 4 "Semifinal"
    ;;
  [Ff][i][n][a][l])    url="http://estadisticas-deportes.tycsports.com/html/v3/htmlCenter/data/deportes/futbol/champions/pages/es/fixture.html"
    playoff $url 5 "Final"
    ;;
  * )
    ;;
esac

exit

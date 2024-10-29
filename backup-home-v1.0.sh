#!/bin/bash

# Funcion que devuelve la hora actual en formato UTC.
# Ejemplo: 2021-05-14_16-26-31Z
function now() {
  date -u +"%Y-%m-%d_%H-%M-%S"Z
}

#Toma el directorio actual como base de ejecucion
BASEDIR=$(dirname "$0")
#Toma el nombre de este mismo script
BASENAME=$(basename -- "$0")
#Compone los paths de logs
LOGDIR=$BASEDIR/$BASENAME'.logs'
LOGFILE=$LOGDIR/$BASENAME'_'`now`.log
ORIGEN=/home
DESTINO=/media/backups

#Funcion que escribe los logs
function writelog() {
	echo "$BASENAME: $(now) - $1" >&1 | tee -a $LOGFILE
}


# Se valida la existencia del directorio de logs. Se crea en
# caso de ser necesario
if [ ! -d $LOGDIR ]; then
	mkdir $LOGDIR
fi

writelog "--------------------------------------"
writelog "--Iniciando script de sincronización--"
writelog "--------------------------------------"

# Se indican los argumentos obligatorios que recibira rsync
#-v: modo verbose muestra que va haciendo
#-r: lo hace recursivamente
#-z: comprime durante la transferencia
#-a: copia todo incluidos links simbolicos
ARGUMENTOSRSYNC=-vrza

# Se indican los argumentos opcionales que recibira rsync
# Aca verifico si tengo un argumento 
if [ $# -eq 1 ]; then
  archivo_exclusiones="$1"
  writelog "Argumento de exclusiones detectado, leyendo exclusiones..."
  # Verifica si el archivo existe
  if [ ! -f "$archivo_exclusiones" ]; then
    writelog "El archivo de exclusiones indicado '$archivo_exclusiones' no existe."
    exit 1
  fi
  # Construir las opciones --exclude para rsync
  while read -r linea; do
    ARGUMENTOSRSYNC+=" --exclude '$linea'"
  done < "$archivo_exclusiones"
fi

ARGUMENTOSRSYNC+="$ORIGEN/"
ARGUMENTOSRSYNC+="$DESTINO/"

writelog "Los argumentos finales para rsync son: $ARGUMENTOSRSYNC"

# Se arma la ejecucion de rsync. Se indican argumentos, origen,
# destino y se envian las salidas std y err al archivo de log
#rsync $ARGUMENTOSRSYNC
exit 0
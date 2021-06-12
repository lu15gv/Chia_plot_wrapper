#!/bin/bash

set -e
BASEDIR=$(dirname "$0")

echo "Base directory: $BASEDIR"

for ARGUMENT in "$@"
do
  KEY=$(echo $ARGUMENT | cut -f1 -d=)
  VALUE=$(echo $ARGUMENT | cut -f2 -d=)
  case "$KEY" in
  	madmax)								MAD_MAX=${VALUE} ;; 
    parallel)           	PARALLEL=${VALUE} ;; 
    queues)           		QUEUE_SIZE=${VALUE} ;; 
    tmpdir)              	TEMP=${VALUE} ;;
		tmpdir2)              TEMP_2=${VALUE} ;;
    tmpdir-list)   				TEMP_LIST=${VALUE} ;;
    finaldir)  						FINAL_DIRECTORY=${VALUE} ;;
    finaldir-list)        FINAL_DIRECTORY_LIST=${VALUE} ;;
    push) 								PUSH=${VALUE} ;;
    ram)            		  RAM=${VALUE} ;;
    threads)              THREADS=${VALUE} ;;
    ksize)                K_SIZE=${VALUE} ;;
    *)   
  esac    
done

# chia madmax=true parallel=1 queues=1 tmpdir=/ssd1/ tmpdir2=/ssd1/ finaldir=/hdd1/ push=true ram=15000 threads=12 ksize=32

###################### Instructions ######################
### 1.- Set chia exectubale directory
###		Windows
		CHIA_ON_WINDOWS=C:/Users/luis1/AppData/Local/chia-blockchain/app-1.1.5/resources/app.asar.unpacked/daemon/chia.exe
###		MAC
		CHIA_ON_MAC=/Applications/Chia.app/Contents/Resources/app.asar.unpacked/daemon/chia
###		Linux
		CHIA_ON_LINUX=chia
		
### 2.- Only change it if you want to cahnge logs directory
		LOGS_DIR=${BASEDIR}/logs/


#########################################################
# Files generated:
#
# Chia_plot_wrapper
#   |-plot.pid
#   |-logs
#       |-plots.csv
#       |-A.log
#       |-B.log
#       |-C.log
#       |-...
#
#########################################################

unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     		MACHINE=Linux;;
    Darwin*)    		MACHINE=Mac;;
    CYGWIN*)    		MACHINE=Cygwin;;
    MINGW64_NT-10.0*)	MACHINE=Windows;;
    *)          MACHINE="UNKNOWN:${unameOut}"
esac

if [ "$MACHINE" = "Windows" ]; then
	CHIA=${CHIA_ON_WINDOWS}
fi
if [ "$MACHINE" = "Mac" ]; then
	CHIA=${CHIA_ON_MAC}
fi
if [ "$MACHINE" = "Linux" ]; then
	BASEDIR="/usr/lib/Chia_plot_wrapper"
 #    cd /usr/lib/chia-blockchain
 #    . ./activate
 #    chia init
    CHIA=${CHIA_ON_LINUX}
fi

PLOTS_LOG="$LOGS_DIR/plots.csv"

if [ ! -f "$PLOTS_LOG" ]; then
    touch $PLOTS_LOG
	echo "ID,Ploter,Queue,Description,k,Temp dir, Temp dir 2, Final dir,RAM,Threads,Start,End" >> $PLOTS_LOG
fi

if [ ! -z "${TEMP_LIST}" ]; then
	SIZE=${#TEMP_LIST[@]}
	if [ $SIZE -lt $PARALLEL ]; then
		echo "TEMP_LIST size: $SIZE, but must be: $PARALLEL"
		exit 1
	fi
fi

if [ ! -z "${FINAL_DIRECTORY_LIST}" ]; then
	SIZE=${#FINAL_DIRECTORY_LIST[@]}
	if [ $SIZE -lt $PARALLEL ]; then
		echo "FINAL_DIRECTORY_LIST size: $SIZE, but must be: $PARALLEL"
		exit 1
	fi
fi

if [ -z "${TEMP_2}" -o "${TEMP_2}" = "" ]; then
	TEMP_2=${TEMP}
fi

echo "Running on: $MACHINE"

LETTERS=( 'A' 'B' 'C' 'D' 'E' 'F' 'G' 'H' 'I' 'J' 'K' 'L' 'M' 'N' 'O' 'P' 'Q' 'R' 'S' 'T' 'U' 'V' 'W' 'X' 'Y' 'Z')
PIDs=()

for ((i=0; i<PARALLEL; i++)); do
	if [ ! -z "${TEMP_LIST}" ]; then
		TEMP=${TEMP_LIST[$i]}
	fi
	if [ ! -z "${FINAL_DIRECTORY_LIST}" ]; then
		FINAL_DIRECTORY=${FINAL_DIRECTORY_LIST[$i]}
	fi
	if [ ! -z "${QUEUE_SIZE_LIST}" ]; then
		QUEUE_SIZE=${QUEUE_SIZE_LIST[$i]}
	fi

   	$BASEDIR/plot.sh id=${LETTERS[$i]} description="Running $PARALLEL in parallel" \
   	k=$K_SIZE \
   	tempdir=$TEMP \
   	tempdir2=$TEMP_2 \
   	final=$FINAL_DIRECTORY \
   	ram=$RAM threads=$THREADS \
   	log=$LOGS_DIR \
   	queue_size=$QUEUE_SIZE \
   	chia=$CHIA \
   	machine=$MACHINE \
   	push=$PUSH \
   	madmax=$MAD_MAX &

	PIDs+=($!)
done

rm -f ${BASEDIR}/plot.pid
echo ${PIDs[@]} >> ${BASEDIR}/plot.pid
wait

echo "All queues finished"

# if [ "$MACHINE" = "Linux" ]; then
#     deactivate
# fi

if [ "$PUSH" = true ]; then
	source "${BASEDIR}/keys.sh"
    curl https://api.pushback.io/v1/send \
	-u "${ACCESS_TOKEN}:" \
	-d "id=${USER_ID}" \
	-d "title=All queues finished" \
	-d "body=MACHINE: ${MACHINE}"
fi

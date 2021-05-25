#!/bin/bash

set -e
BASEDIR=$(dirname "$0")

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

### 3.- Parallel builds
		PARALLEL=7

### 4.- Set how many plots you want for each queue in parallel
		QUEUE_SIZE=1

		# QUEUE_SIZE_LIST=( 9 9 9 9 9 7 7 7 7 7 )

### 5.- Temporal directory
		TEMPORAL_DIRECTORY="G:/"
		# This is optional, only uncomment it if you want to choice different directories for each parallel chia ploter. List size must match PARALLEL
		TEMPORAL_DIRECTORY_LIST=( '/ssd1/' '/ssd1/' '/ssd1/' '/ssd1/' '/ssd1/' '/ssd1/' )

### 6.- Final directory
		FINAL_DIRECTORY="I:/"
		# This is optional, only uncomment it if you want to choice different directories for each parallel chia ploter. List size must match PARALLEL
		FINAL_DIRECTORY_LIST=( '/hdd1/' '/hdd1/' '/hdd1/' '/hdd1/' '/hdd1/' '/hdd1/' )

###	7.- Push notification
		PUSH=true
### 8.- RAM
		RAM=7000
### 9.- Threads
		THREADS=2
### 10.- K
		K_SIZE=32

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
	echo "ID,Queue,Description,k,Temporal dir,Final dir,RAM,Threads,Start,End" >> $PLOTS_LOG
fi

echo "Running on: $MACHINE"
echo "Base directory: $BASEDIR"

LETTERS=( 'A' 'B' 'C' 'D' 'E' 'F' 'G' 'H' 'I' 'J' 'K' 'L' 'M' 'N' 'O' 'P' 'Q' 'R' 'S' 'T' 'U' 'V' 'W' 'X' 'Y' 'Z')
PIDs=()

for ((i=0; i<PARALLEL; i++)); do
	if [ ! -z "${TEMPORAL_DIRECTORY_LIST}" ]; then
		TEMPORAL_DIRECTORY=${TEMPORAL_DIRECTORY_LIST[$i]}
	fi
	if [ ! -z "${FINAL_DIRECTORY_LIST}" ]; then
		FINAL_DIRECTORY=${FINAL_DIRECTORY_LIST[$i]}
	fi
	if [ ! -z "${QUEUE_SIZE_LIST}" ]; then
		QUEUE_SIZE=${QUEUE_SIZE_LIST[$i]}
	fi

   	$BASEDIR/plot.sh id=${LETTERS[$i]} description="Running $PARALLEL in parallel" \
   	k=$K_SIZE \
   	temp=$TEMPORAL_DIRECTORY \
   	final=$FINAL_DIRECTORY \
   	ram=$RAM threads=$THREADS \
   	log=$LOGS_DIR \
   	queue_size=$QUEUE_SIZE \
   	chia=$CHIA \
   	machine=$MACHINE \
   	push=$PUSH &

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
	source "${BASEDIR}/push_keys.sh"
    curl https://api.pushback.io/v1/send \
	-u "${ACCESS_TOKEN}:" \
	-d "id=${USER_ID}" \
	-d "title=All queues finished" \
	-d "body=MACHINE: ${MACHINE}"
fi

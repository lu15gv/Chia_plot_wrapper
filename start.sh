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
		PARALLEL=10

### 4.- Set how many plots you want for each queue in parallel
		QUEUE_SIZE=3

### 5.- Temporal directory
		TEMPORAL_DIRECTORY="G:/"
		# This is optional, only uncomment it if you want to choice different directories for each parallel chia ploter. List size must match PARALLEL
		TEMPORAL_DIRECTORY_LIST=( '/ssd1/' '/ssd1/' '/ssd1/' '/ssd1/' '/ssd1/' '/ssd2/' '/ssd2/' '/ssd2/' '/ssd2/' '/ssd2/' )

### 6.- Final directory
		FINAL_DIRECTORY="I:/"
		# This is optional, only uncomment it if you want to choice different directories for each parallel chia ploter. List size must match PARALLEL
		FINAL_DIRECTORY_LIST=( '/hdd1/' '/hdd1/' '/hdd1/' '/hdd1/' '/hdd1/' '/hdd1/' '/hdd1/' '/hdd1/' '/hdd1/' '/hdd1/' )

###	7.- Push notification
		PUSH=true
### 8.- RAM
		RAM=5000
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
    Linux*)     		machine=Linux;;
    Darwin*)    		machine=Mac;;
    CYGWIN*)    		machine=Cygwin;;
    MINGW64_NT-10.0*)	machine=Windows;;
    *)          machine="UNKNOWN:${unameOut}"
esac

if [ "$machine" = "Windows" ]; then
	CHIA=${CHIA_ON_WINDOWS}
fi
if [ "$machine" = "Mac" ]; then
	CHIA=${CHIA_ON_MAC}
fi
if [ "$machine" = "Linux" ]; then
	BASEDIR="/usr/lib/Chia_plot_wrapper"
    cd /usr/lib/chia-blockchain
    . ./activate
    chia init
    CHIA=CHIA_ON_LINUX
fi
if [ "$PUSH" = true ]; then
	source "${BASEDIR}/push_keys.sh"
fi

PLOTS_LOG="$LOGS_DIR/plots.csv"

if [ ! -f "$PLOTS_LOG" ]; then
    touch $PLOTS_LOG
	echo "ID,Queue,Description,k,Temporal dir,Final dir,RAM,Threads,Start,End" >> $PLOTS_LOG
fi

echo "Running on: $machine"
echo "Base directory: $BASEDIR"

LETTERS=( 'A' 'B' 'C' 'D' 'E' 'F' 'G' 'H' 'I' 'J' 'K' 'L' 'M' 'N' 'O' 'P' 'Q' 'R' 'S' 'T' 'U' 'V' 'W' 'X' 'Y' 'Z')
PIDs=()

for ((i=0; i<PARALLEL; i++)); do
	echo $i
	if [ ! -z "${TEMPORAL_DIRECTORY_LIST}" ]; then
		TEMPORAL_DIRECTORY=${TEMPORAL_DIRECTORY_LIST[$i]}
	fi
	if [ ! -z "${FINAL_DIRECTORY_LIST}" ]; then
		FINAL_DIRECTORY=${FINAL_DIRECTORY_LIST[$i]}
	fi
   	$BASEDIR/plot.sh id=${LETTERS[$i]} description="Running $PARALLEL in parallel" k=$K_SIZE temp=$TEMPORAL_DIRECTORY final=$FINAL_DIRECTORY ram=$RAM threads=$THREADS log=$LOGS_DIR queue_size=$QUEUE_SIZE chia=$CHIA &
	PIDs+=($!)
done

rm -f ${BASEDIR}/plot.pid
echo ${PIDs[@]} >> ${BASEDIR}/plot.pid
wait

echo "All queues finished"

if [ "$machine" = "Linux" ]; then
    deactivate
fi

if [ "$PUSH" = true ]; then
    curl https://api.pushback.io/v1/send \
	-u "${ACCESS_TOKEN}:" \
	-d "id=${USER_ID}" \
	-d "title=All queues finished" \
	-d "body=Machine: ${machine}"
fi

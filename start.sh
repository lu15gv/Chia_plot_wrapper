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
		LOGS_DIR=${BASEDIR}/logs/plots.csv

### 3.- Parallel builds
		PARALLEL=6

### 4.- Set how many plots you want for each queue in parallel
		QUEUE_SIZE=3

### 5.- Temporal directory
		TEMPORAL_DIRECTORY="G:/"
		# This is optional, only uncomment it if you want to choice different directories for each parallel chia ploter. List size must match PARALLEL
		# TEMPORAL_DIRECTORY_LIST=( '/ssd1/' '/ssd1/' '/ssd1/' '/ssd2/' '/ssd2/' '/ssd2/' )

### 6.- Final directory
		FINAL_DIRECTORY="I:/"
		# This is optional, only uncomment it if you want to choice different directories for each parallel chia ploter. List size must match PARALLEL
		# FINAL_DIRECTORY_LIST=( '/hdd1/' '/hdd1/' '/hdd1/' '/hdd2/' '/hdd2/' '/hdd2/' )

### 7.- Temporal directory
		FINAL_DIRECTORY="F:/"

###	8.- Push notification
		PUSH=true
### 9.- RAM
		RAM=3900
### 10.- Threads
		THREADS=2
### 11.- K
		K_SIZE=32

#########################################################

echo "Running on: $machine"
echo "Base directory: $BASEDIR"

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
    cd /usr/lib/chia-blockchain
    . ./activate
    chia init
    CHIA=CHIA_ON_LINUX
fi
if [ "$PUSH" = true ]; then
	source "${BASEDIR}/push_keys.sh"
fi
if [ ! -f "$LOGS_DIR" ]; then
    touch $LOGS_DIR
	echo "ID,Queue,Description,k,Temporal dir,Final dir,RAM,Threads,Start,End" >> $LOGS_DIR
fi

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

echo "All queues have finished"

if [ "$machine" = "Linux" ]; then
    deactivate
fi

if [ "$PUSH" = true ]; then
    curl https://api.pushback.io/v1/send \
	-u "${ACCESS_TOKEN}:" \
	-d "id=${USER_ID}" \
	-d "title=All queus have finished" \
	-d "body=Machine: ${machine}"
fi

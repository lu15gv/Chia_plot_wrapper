BASEDIR=$(dirname "$0")

set -e

unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     		machine=Linux;;
    Darwin*)    		machine=Mac;;
    CYGWIN*)    		machine=Cygwin;;
    MINGW64_NT-10.0*)	machine=MinGw;;
    *)          machine="UNKNOWN:${unameOut}"
esac
echo "Running on: $machine"
###### Instructions ######
### 1.- Set chia exectubale directory
###		Windows
		if [ "$machine" = "Linux" ]; then
			CHIA=C:/Users/luis1/AppData/Local/chia-blockchain/app-1.1.5/resources/app.asar.unpacked/daemon/chia.exe
		fi
###		MacOS
		if [ "$machine" = "Mac" ]; then
			CHIA=/Applications/Chia.app/Contents/Resources/app.asar.unpacked/daemon/chia
		fi
###		Linux
		if [ "$machine" = "Linux" ]; then
		    cd /usr/lib/chia-blockchain
		    . ./activate
		    chia init
		    CHIA=chia
		fi
### 2.- Only change it if you want to cahnge logs directory
		LOGS_DIR=${BASEDIR}/logs/plots.csv
### 2.- This was set for 6 parallel queues.
### 3.- Set how many plots you want for each queue: 
### 	For example, queue_size=3 will produce 3 plots for each queue, that means
###		6 parallel queues X 3 plots per queue = 18 plots in total.
		QUEUE_SIZE=3
###	4.- Push notification
		PUSH=false
		if [ "$PUSH" = true ]; then
			source push_keys.sh
		fi
### 5.- Other params, like temporal/final directory, threads and RAM, can be edited below.

if [ ! -f "$LOGS_DIR" ]; then
    touch $LOGS_DIR
	echo "ID,Queue,Description,k,Temporal dir,Final dir,RAM,Threads,Start,End" >> $LOGS_DIR
fi

# $BASEDIR/plot.sh id="A" description="Running 11 in parallel" k=32 temp="D:/" final="F:/" ram=5000 threads=2 log=$LOGS_DIR queue_size=$QUEUE_SIZE chia=$CHIA &
# $BASEDIR/plot.sh id="B" description="Running 11 in parallel" k=32 temp="D:/" final="F:/" ram=5000 threads=2 log=$LOGS_DIR queue_size=$QUEUE_SIZE chia=$CHIA &
# $BASEDIR/plot.sh id="C" description="Running 11 in parallel" k=32 temp="D:/" final="F:/" ram=5000 threads=2 log=$LOGS_DIR queue_size=$QUEUE_SIZE chia=$CHIA &
# $BASEDIR/plot.sh id="D" description="Running 11 in parallel" k=32 temp="G:/" final="F:/" ram=5000 threads=2 log=$LOGS_DIR queue_size=$QUEUE_SIZE chia=$CHIA &
# $BASEDIR/plot.sh id="E" description="Running 11 in parallel" k=32 temp="G:/" final="F:/" ram=5000 threads=2 log=$LOGS_DIR queue_size=$QUEUE_SIZE chia=$CHIA &
# $BASEDIR/plot.sh id="F" description="Running 11 in parallel" k=32 temp="G:/" final="F:/" ram=5000 threads=2 log=$LOGS_DIR queue_size=$QUEUE_SIZE chia=$CHIA &
# $BASEDIR/plot.sh id="G" description="Running 11 in parallel" k=32 temp="G:/" final="F:/" ram=5000 threads=2 log=$LOGS_DIR queue_size=$QUEUE_SIZE chia=$CHIA &
# $BASEDIR/plot.sh id="H" description="Running 11 in parallel" k=32 temp="G:/" final="F:/" ram=5000 threads=2 log=$LOGS_DIR queue_size=$QUEUE_SIZE chia=$CHIA &
# $BASEDIR/plot.sh id="I" description="Running 11 in parallel" k=32 temp="G:/" final="F:/" ram=5000 threads=2 log=$LOGS_DIR queue_size=$QUEUE_SIZE chia=$CHIA &
# $BASEDIR/plot.sh id="J" description="Running 11 in parallel" k=32 temp="G:/" final="F:/" ram=5000 threads=2 log=$LOGS_DIR queue_size=$QUEUE_SIZE chia=$CHIA &
# $BASEDIR/plot.sh id="K" description="Running 11 in parallel" k=32 temp="G:/" final="F:/" ram=5000 threads=2 log=$LOGS_DIR queue_size=$QUEUE_SIZE chia=$CHIA &

# wait

echo "All queues have finished"

if [ "$machine" = "Linux" ]; then
    deactivate
fi

if [ "$PUSH" = true ]; then
    curl https://api.pushback.io/v1/send \
	-u "${ACCESS_TOKEN}:" \
	-d "id=${USER_ID}" \
	-d 'title=All queus have finished' \
	-d 'body=:)'
fi
set -e

###### Instructions ######
### 2.- Set chia exectubale directory
###		Windows
		CHIA=C:/Users/luis1/AppData/Local/chia-blockchain/app-1.1.5/resources/app.asar.unpacked/daemon/chia.exe
###		MacOS
###		CHIA=/Applications/Chia.app/Contents/Resources/app.asar.unpacked/daemon/chia
### 1.- Set where you want to create the logs. This directory must exist!!
		LOGS_DIR=C:/Users/luis1/Documents/chia/logs/plots.csv
### 2.- This was set for 6 parallel queues.
### 3.- Set how many plots you want for each queue: 
### 	For example, queue_size=3 will produce 3 plots for each queue, that means
###		6 parallel queues X 3 plots per queue = 18 plots in total.
		QUEUE_SIZE=3
### 4.- Other params, like temporal/final directory, threads and RAM, can be edited below.

PLOTS_LOG=$LOGS_DIR/plots.csv
if [ ! -f "$PLOTS_LOG" ]; then
    touch $PLOTS_LOG
	echo "ID,k,Temporal dir,Final dir,RAM,Threads,Start,End" >> $PLOTS_LOG
fi

$BASEDIR/plot.sh id="A" k=32 temp="D:/" final="F:/" ram=4500 threads=2 log=$PLOTS_LOG queue_size=$QUEUE_SIZE chia=$CHIA &
$BASEDIR/plot.sh id="B" k=32 temp="D:/" final="F:/" ram=4500 threads=2 log=$PLOTS_LOG queue_size=$QUEUE_SIZE chia=$CHIA &
$BASEDIR/plot.sh id="C" k=32 temp="D:/" final="F:/" ram=4500 threads=2 log=$PLOTS_LOG queue_size=$QUEUE_SIZE chia=$CHIA &
$BASEDIR/plot.sh id="D" k=32 temp="G:/" final="F:/" ram=4500 threads=2 log=$PLOTS_LOG queue_size=$QUEUE_SIZE chia=$CHIA &
$BASEDIR/plot.sh id="F" k=32 temp="G:/" final="F:/" ram=4500 threads=2 log=$PLOTS_LOG queue_size=$QUEUE_SIZE chia=$CHIA &
$BASEDIR/plot.sh id="G" k=32 temp="G:/" final="F:/" ram=4500 threads=2 log=$PLOTS_LOG queue_size=$QUEUE_SIZE chia=$CHIA &

wait

echo "All queues have finished"
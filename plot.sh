set -e

BASEDIR=$(dirname "$0")

for ARGUMENT in "$@"
do
    KEY=$(echo $ARGUMENT | cut -f1 -d=)
    VALUE=$(echo $ARGUMENT | cut -f2 -d=)
    case "$KEY" in
            id)          ID=${VALUE} ;;
            k)           K=${VALUE} ;;
            temp)        TEMP=${VALUE} ;; 
            final)       FINAL=${VALUE} ;;
            log)         LOG=${VALUE} ;;
            ram)         RAM=${VALUE} ;;
            threads)     THREADS=${VALUE} ;;
            queue_size)  QUEUE=${VALUE} ;;
            chia)        CHIA=${VALUE} ;;
            description) DESCRIPTION=${VALUE} ;;
            machine)     MACHINE=${VALUE} ;;
            push)        PUSH=${VALUE} ;;
            *)   
    esac    
done

# CHIA_LOG="$LOG/${ID}.log"
# rm -f "$CHIA_LOG"

for i in $(seq 1 $QUEUE); do 
    START_TIME=$(date '+%Y-%m-%d %H:%M:%S')
    $CHIA plots create -k $K -b $RAM -r $THREADS -t $TEMP -d $FINAL #| tee "$CHIA_LOG"
    END_TIME=$(date '+%Y-%m-%d %H:%M:%S')
    echo "$ID,$i,$DESCRIPTION,$K,$TEMP,$FINAL,$RAM,$THREADS,$START_TIME,$END_TIME" >> "$LOG/plots.csv"
    if [ "$PUSH" = true ]; then
        source "${BASEDIR}/push_keys.sh"
        curl https://api.pushback.io/v1/send \
        -u "${ACCESS_TOKEN}:" \
        -d "id=${USER_ID}" \
        -d "title=${MACHINE}: ${ID}" \
        -d "body=Queue ${i} of ${QUEUE} finished. Start: ${START_TIME} End: ${END_TIME}"
    fi
done

# echo "Queue $ID finished" >> "$CHIA_LOG"
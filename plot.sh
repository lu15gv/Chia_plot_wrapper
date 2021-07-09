set -e

BASEDIR=$(dirname "$0")

for ARGUMENT in "$@"
do
    KEY=$(echo $ARGUMENT | cut -f1 -d=)
    VALUE=$(echo $ARGUMENT | cut -f2 -d=)
    case "$KEY" in
            id)          ID=${VALUE} ;;
            k)           K=${VALUE} ;;
            tempdir)     TEMP=${VALUE} ;; 
            tempdir2)    TEMP_2=${VALUE} ;; 
            final)       FINAL=${VALUE} ;;
            log)         LOG=${VALUE} ;;
            ram)         RAM=${VALUE} ;;
            threads)     THREADS=${VALUE} ;;
            queue_size)  QUEUE=${VALUE} ;;
            chia)        CHIA=${VALUE} ;;
            description) DESCRIPTION=${VALUE} ;;
            machine)     MACHINE=${VALUE} ;;
            push)        PUSH=${VALUE} ;;
            madmax)      MAD_MAX=${VALUE} ;;
            contract)    CONTRACT_ADDRESS=${VALUE} ;;
            *)   
    esac    
done

if [ -f "${BASEDIR}/keys.sh" ]; then
  source "${BASEDIR}/keys.sh"
fi

if [ -z "${FARMER_PUBLIC_KEY}" ]; then
  FARMER_PUBLIC_KEY=aa711bae71d947a5c6806bc57ac5391722129e2ccf5cfdf068e324d65d723e0bef645d39ad8312785e36d95eb0127435
fi

if [ -z "${CONTRACT_ADDRESS}" ]; then
  if [ -z "${POOL_PUBLIC_KEY}" ]; then
    POOL_PUBLIC_KEY=a72a54629d9090b7eca7d123ce62c3d46ce253cc2b4b5c86face704787a49b41dccb39f1b6f949e7f8467f5ef7f70c4c
  fi
fi

send_push() {
  BODY=$1
  if [ "$PUSH" = true ]; then
    curl https://api.pushback.io/v1/send \
    -u "${ACCESS_TOKEN}:" \
    -d "id=${USER_ID}" \
    -d "title=${MACHINE}: ${ID}" \
    -d $BODY
  fi
}
# CHIA_LOG="$LOG/${ID}.log"
# rm -f "$CHIA_LOG"

if [ -z "${MAD_MAX}" -o "${MAD_MAX}" = false ]; then
  for i in $(seq 1 $QUEUE); do 
    START_TIME=$(date '+%Y-%m-%d %H:%M:%S')
    $CHIA plots create -k $K -b $RAM -r $THREADS -t $TEMP -2 $TEMP_2 -d $FINAL #| tee "$CHIA_LOG"
    END_TIME=$(date '+%Y-%m-%d %H:%M:%S')
    echo "$ID,"Oficial",$i,$DESCRIPTION,$K,$TEMP,$TEMP_2,$FINAL,$RAM,$THREADS,$START_TIME,$END_TIME" #>> "$LOG/plots.csv"
    BODY="body=Queue ${i} of ${QUEUE} finished. Start: ${START_TIME} End: ${END_TIME}"
    send_push $BODY || true
  done
else
  START_TIME=$(date '+%Y-%m-%d %H:%M:%S')
  echo "Mad Max"
  if [ -z "${CONTRACT_ADDRESS}" ]; then
    chia_plot -n $QUEUE -r $THREADS -t $TEMP -2 $TEMP_2 -d $FINAL -p $POOL_PUBLIC_KEY -f $FARMER_PUBLIC_KEY
  else
    chia_plot -n $QUEUE -r $THREADS -t $TEMP -2 $TEMP_2 -d $FINAL -c $CONTRACT_ADDRESS -f $FARMER_PUBLIC_KEY
  fi
  END_TIME=$(date '+%Y-%m-%d %H:%M:%S')
  echo "$ID,"MadMax",$QUEUE,$DESCRIPTION,$K,$TEMP,$TEMP_2,$FINAL,"-",$THREADS,$START_TIME,$END_TIME" #>> "$LOG/plots.csv"
  BODY="body=MadMax finished. Start: ${START_TIME} End: ${END_TIME}"
  send_push $BODY || true
fi


# echo "Queue $ID finished" >> "$CHIA_LOG"
#!/bin/sh

. /usr/share/ul3deg/rpcd_ubus.sh

CMD=$1
shift

while true ; do
  case "$1" in
    -h|--help)
      echo "help"
      shift 1
      ;;
    -i|--ip)
      IP=$2
      shift 2
      ;;
    --user)
      USER=$2
      shift 2
      ;;
    --password)
      PASSWORD=$2
      shift 2
      ;;
    --random)
      RANDOM=$2
      shift 2
      ;;
    '')
      break
      ;;
    *)
      break
      ;;
  esac
done

# rpc login
token="$(request_token $IP $USER $PASSWORD)"
if [ $? != 0 ]; then
	echo "failed to register token"
	exit 1
fi

# now call procedure 
case $CMD in
  "get_free_prefix") get_free_prefix $token $IP $RANDOM ;;
   *) echo "Usage: ul3degc get_free_prefix --ip ... --user ... --password ... --random ... " ;;
esac

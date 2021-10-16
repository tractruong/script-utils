#!/bin/bash

LOG_FILE=`pwd`/log.txt
SERVICE_NAME=start-after-reboot.service
SERVICE_FILE=/etc/systemd/system/$SERVICE_NAME
SCRIPT_FILE=`pwd`/sars-script.sh
exp=$1
if [ -z $exp ]; then
	exp="run"
fi

case $exp in
  "install")
	#Script to run app
	echo "#!/bin/bash" > $SCRIPT_FILE
	echo "date >> $LOG_FILE" >> $SCRIPT_FILE
	echo "systemctl disable $SERVICE_NAME" >> $SCRIPT_FILE
	echo "Created ->" $SCRIPT_FILE

	#Service to start when startup
	echo "[Unit]" > $SERVICE_FILE
	echo "After=network.service" >> $SERVICE_FILE
	echo "" >> $SERVICE_FILE
	echo "[Service]" >> $SERVICE_FILE
	echo "ExecStart=$SCRIPT_FILE" >> $SERVICE_FILE
	echo "" >> $SERVICE_FILE
	echo "[Install]" >> $SERVICE_FILE
	echo "WantedBy=default.target" >> $SERVICE_FILE
	echo "Created ->" $SERVICE_FILE

	chmod 744 $SCRIPT_FILE
	chmod 664 $SERVICE_FILE
	systemctl daemon-reload
 	systemctl enable $SERVICE_NAME
    ;;
  "run")
	systemctl enable $SERVICE_NAME && reboot -f
    ;;
  "uninstall")
	systemctl stop $SERVICE_NAME
    	systemctl disable $SERVICE_NAME
    	rm -v $SCRIPT_FILE
    	rm -v $SERVICE_FILE
	rm -v $LOG_FILE
    ;;
  *)
    echo -n "unknown"
    ;;

esac


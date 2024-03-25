#!/bin/sh

TS_FORMAT="%Y-%m-%dT%H:%M:%S%z "

if [ -e /etc/logrotate.conf ]; then
	echo "Using mounted /etc/logrotate.conf:" | ts "${TS_FORMAT}"
else
	if [ -z $LOGROTATE_FILE_PATTERN]; then
		echo "LOGROTATE_FILE_PATTERN must be specified"
		exit 1
	fi
	echo "Using templated /etc/logrotate.conf:" | ts "${TS_FORMAT}"
	cat >/etc/logrotate.conf <<EOF
${LOGROTATE_FILE_PATTERN}
{
  size ${LOGROTATE_FILESIZE}
  missingok
  notifempty
  copytruncate
  rotate ${LOGROTATE_FILENUM}
}
EOF
fi

echo "$(cat /etc/logrotate.conf)"

if [ -z "$CRON_EXPR" ]; then
	CRON_EXPR="*/5 *	* * *"
	echo "CRON_EXPR environment variable is not set. Set to default: $CRON_EXPR"
else
	echo "CRON_EXPR environment variable set to $CRON_EXPR"
fi

echo "$CRON_EXPR	/usr/sbin/logrotate -v /etc/logrotate.conf" >>/etc/crontabs/root

exec crond -d ${CROND_LOGLEVEL:-7} -f 2>&1 | ts "${TS_FORMAT}"

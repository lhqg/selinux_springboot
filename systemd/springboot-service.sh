#!/bin/bash
#################################################################
# Springboot application control script.
#
# This is called by systemmd to start the application at boot time
#
# It is also used to perform pre-start checks, post-start checks
#   and cleanup operations.
#
# restart/reload operations will be perfomed calling systemctl
#
# Usage:
# ./springboot-service.sh SpringBoot_AppName stop|start|restart|status
#
##################################################################

function usage {
	echo "Usage: $0 SpringBoot-AppName {start|precheck|postcheck|cleanup|restart|reload}"
}

SPRINGBOOT_ROOT=/opt/springboot
SPRINGBOOT_LOGROOT=/var/log/springboot

if [ $# -eq 2 ]
then
	PATH=/usr/bin:/usr/sbin:/bin:/sbin:$PATH

	APP_NAME="$1"

	APP_BASE="${SPRINGBOOT_ROOT}/${APP_NAME}"
	APP_LOGDIR="${SPRINGBOOT_LOGROOT}/${APP_NAME}"
	STARTUP_POSTCHECK_TIMEOUT="${STARTUP_POSTCHECK_TIMEOUT:-5}"

	#
	# Check environment (as set by SystemD)
	#

	if echo "${APP_NAME}" | egrep -q '&|;|>|<' ; then
		echo "FATAL: The application name contains forbidden characters."
		exit 127
	fi

	if [ -z "${JAVA_HOME}" ]
	then
		echo "FATAL: JAVA_HOME is not set."
		exit 127
	fi

	if [ -z "${APP_JAR_FILEPATH}" ]
	then
		echo "FATAL: APP_JAR_FILEPATH is not set."
		exit 127
	fi

	if [ -z "${LOG_PATH}" ]
	then
		echo "FATAL: LOG_PATH is not set."
		exit 127
	fi

	if [ -z "${LOADER_PATH}" ]
	then
		echo "FATAL: LOADER_PATH is not set."
		exit 127
	fi

	if [ -z "${JAVA_TMPDIR}" ]
	then
		echo "FATAL: JAVA_TMPDIR is not set."
		exit 127
	fi

	if [ -z "${JAVA_SECURITY_FILE}" ]
	then
		echo "FATAL: JAVA_SECURITY_FILE is not set."
		exit 127
	fi

	#
	# Declare functions
	#

	# Returns PID of Springboot application Java process
	function get_pid {
		regex_escaped_APP_NAME=$(sed -r 's/([\x5d.+?*:{}\[])/\\\1/g' <<< "$APP_NAME")
		pgrep -f "^([^/]*/)*java\s+(.*?\s+)?-DAPP_NAME=${regex_escaped_APP_NAME}(\s|$)"
	}

	# Cleanup the application temporary files directory
	function cleanup {
		if [ -d "${JAVA_TMPDIR}" ]
		then
			find "${JAVA_TMPDIR}" -type f -mtime +10 -print0 | xargs -r -0 rm -f
			find "${JAVA_TMPDIR}" -mindepth 2 -type d -empty -print0 | xargs -r -0 rmdir
			find "${JAVA_TMPDIR}" -mindepth 1 -type d \! -name 'dynlib' -empty -print0 | xargs -r -0 rmdir 
		fi

		return 0
	}

	# Performs sanity checks before starting the Springboot applicatio,
	function precheck {
		app_PID=$(get_pid)

		if [[ "$app_PID" != "" ]]; then
			echo "Application appears to still be running with PID $app_PID. Precheck failed."
			return 2
		fi

		if [[ ! -d "${JAVA_HOME}" ]] ; then
			echo "The JAVA_HOME variable points to non existent directory. Precheck failed."
			return 2
		fi

		if [[ ! -d "${JAVA_TMPDIR}" ]] ; then
			echo "The JAVA_TMPDIR variable points to non existent directory. Precheck failed."
			return 2
		fi

		if [[ ! -r "${APP_JAR_FILEPATH}" ]] ; then
			echo "The APP_JAR_FILEPATH variable points to non existent file. Precheck failed."
			return 2
		fi

		if echo "${JAVA_EXTRA_ARGS}" | egrep -q '&|;|>|<' ; then
			echo "The JAVA_EXTRA_ARGS variable contains forbidden characters. Precheck failed."
			return 3
		fi

		if [[ -n "${SPRING_CONFIG_LOCATION}" && ! -r "${SPRING_CONFIG_LOCATION}" ]] ; then
			echo "The SPRING_CONFIG_LOCATION variable points to non existent file. Precheck failed."
			return 3
		fi

		echo "Environment seems OK. Precheck succeeded."
		return 0
	}

	# Performs checks after the Springboot application was freshly started
	function postcheck {
		count=0

		while [[ ${count} < ${STARTUP_POSTCHECK_TIMEOUT} ]] ; do
			sleep 1
			app_PID=$(get_pid)
			count=$(( $count + 1 ))

			if [[ "${app_PID}" == "" ]] ; then
				echo "Application died before ${STARTUP_POSTCHECK_TIMEOUT}s. Postcheck failed."
				return 11
			fi
		done

		echo "Application is still running with PID ${app_PID} after ${STARTUP_POSTCHECK_TIMEOUT}s. Postcheck succeeded."

		return 0
	}

	# Starts the Springboot application
	function start {
		declare -i my_PPID
		my_PPID=$( ps --no-headers -o ppid $$ )

		if [[ "$my_PPID" != "1" ]]; then
			echo "FATAL: Springboot application can only be started using systemd. Start aborted."
			return 127
		else

			echo "INFO: Staring Java process for Springboot application ${APP_NAME}."
			echo "INFO:	Using JAVA_HOME: $JAVA_HOME"
			echo "INFO:	Using Java tmpdir: $JAVA_TMPDIR"
			echo "INFO:	Using Java Security file: $JAVA_SECURITY_FILE"

			if [[ -n "${SPRING_CONFIG_LOCATION}" ]] ; then
				echo "INFO:	Using Spring config file: $SPRING_CONFIG_LOCATION"
				SPRING_CONFIG_OPT="-Dspring.config.location=file:${SPRING_CONFIG_LOCATION}"
			else
				SPRING_CONFIG_OPT=""
			fi

			trap "" SIGHUP
			$JAVA_HOME/bin/java -DAPP_NAME="${APP_NAME}" \
				-Dloader.path="${LOADER_PATH}" \
				-DLOG_PATH="${LOG_PATH}" \
				-Djava.io.tmpdir=${JAVA_TMPDIR} \
				-Djava.security.properties=${JAVA_SECURITY_FILE} \
				${SPRING_CONFIG_OPT} \
				${JAVA_EXTRA_ARGS} \
				-jar "${APP_JAR_FILEPATH}" &

			jobpid=$!
			sleep 1
			ps ${jobpid} >/dev/null 2>&1
			if [[ $? == 0 ]] ; then
				return 0
			else
				echo "FATAL: Java process for Springboot application ${APP_NAME} died prematurely."
				return 10
			fi
		fi
	}


	#
	# Main
	#

	case "$2" in
		cleanup)
			cleanup
			RC=$?
		;;
		precheck)
			precheck
			RC=$?
		;;
		postcheck)
			postcheck
			RC=$?
		;;
		start)
			start
			RC=$?
		;;
		restart|reload)
			/usr/bin/systemctl restart springboot@${APP_NAME}.service
			RC=$?
		;;
		status)
			/usr/bin/systemctl status springboot@${APP_NAME}.service
			RC=$?
		;;
		*)
			usage
			echo "Unknown option [$2]"
			RC=1
	esac

else
	usage
	RC=1
fi

exit $RC

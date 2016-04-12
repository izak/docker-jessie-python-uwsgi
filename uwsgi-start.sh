#!/bin/bash

# Default values
UWSGI_UID=${UWSGI_UID:-uwsgi}
UWSGI_GID=${UWSGI_GID:-uwsgi}
UWSGI_NUM_PROCESSES=${UWSGI_NUM_PROCESSES:-4}
UWSGI_NUM_THREADS=${UWSGI_NUM_THREADS:-4}
UWSGI_MAX_REQUEST=${UWSGI_MAX_REQUEST:-400}
UWSGI_HARAKIRI=${UWSGI_HARAKIRI:-910}
UWSGI_HTTP_TIMEOUT=${UWSGI_HTTP_TIMEOUT:-900}
UWSGI_LOG_FILE=${UWSGI_LOG_FILE:-/var/log/uwsgi/uwsgi.log}

if test -z "$WSGI_MODULE"; then
    echo "WSGI_MODULE is unset. Here, have a shell."
    /bin/bash
    exit 1
fi

echo '--------------------------------------------------------------------------------------------'
echo "WSGI_MODULE=$WSGI_MODULE"
echo "UWSGI_LOG_FILE=$UWSGI_LOG_FILE"
echo "UWSGI_NUM_PROCESSES=$UWSGI_NUM_PROCESSES"
echo "UWSGI_NUM_THREADS=$UWSGI_NUM_THREADS"
echo "UWSGI_MAX_REQUEST=$UWSGI_MAX_REQUEST"
echo "UWSGI_HARAKIRI=$UWSGI_HARAKIRI"
echo "UWSGI_HTTP_TIMEOUT=$UWSGI_HTTP_TIMEOUT"
echo '--------------------------------------------------------------------------------------------'

# make sure the application log file exists
if [ -d $(dirname "$UWSGI_LOG_FILE") ] ; then
  echo 'WSGI Log Directory: ' $(dirname "$UWSGI_LOG_FILE")
  ls $(dirname "$UWSGI_LOG_FILE")
else
  echo 'Creating WSGI Log Directory: ' $(dirname "$UWSGI_LOG_FILE")
  mkdir -p $(dirname "$UWSGI_LOG_FILE") && chown -R "$UWSGI_UID":"$UWSGI_GID" $(dirname "$UWSGI_LOG_FILE")
fi

# make sure the application log file exists and fix permissions
if [ -n "$LOG_FILENAME" ] ; then
  LOG_FILE_DIR_NAME=$(dirname "$LOG_FILENAME")
  if ! test -d "$LOG_FILE_DIR_NAME"; then mkdir -p "$LOG_FILE_DIR_NAME" ; fi
  touch "$LOG_FILENAME"
  chown "$UWSGI_UID":"$UWSGI_GID" "$LOG_FILENAME"
fi

# make sure the application error log file exists and fix permissions
if [ -n "$ERROR_LOG_FILENAME" ] ; then
  LOG_FILE_DIR_NAME=$(dirname "$ERROR_LOG_FILENAME")
  if [ '!' -d "$LOG_FILE_DIR_NAME" ] ; then mkdir -p "$LOG_FILE_DIR_NAME" ; fi
  touch "$ERROR_LOG_FILENAME"
  chown "$UWSGI_UID":"$UWSGI_GID" "$ERROR_LOG_FILENAME"
fi

# Fix stormpath api key permission to only be viewable by the UWSGI user
if [ -n "$STORMPATH_API_KEY_FILE" ] ; then
  chown "$UWSGI_UID":"$UWSGI_GID" "$STORMPATH_API_KEY_FILE"
fi

echo '============================================================================================'

if ! pidof cron > /dev/null; then
    # Start cron in background
    echo "Starting cron in the background"
    cron
    RETCODE="$?"
    if [ "$RETCODE" -ne 0 ] ; then exit "$RETCODE" ; fi
fi

export USER="$UWSGI_UID"
/usr/bin/uwsgi --plugins http,python --master \
    --http-socket :8080 \
    --module "$WSGI_MODULE" \
    --max-requests "$UWSGI_MAX_REQUEST" \
    --processes "$UWSGI_NUM_PROCESSES" \
    --threads "$UWSGI_NUM_THREADS" \
    --http-timeout "$UWSGI_HTTP_TIMEOUT" \
    --harakiri "$UWSGI_HARAKIRI" \
    --uid "$UWSGI_UID" \
    --gid "$UWSGI_GID" \
    --logto2 "$UWSGI_LOG_FILE"

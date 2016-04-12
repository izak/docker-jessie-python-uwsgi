FROM        debian:jessie
RUN         apt-get -y update && \
            apt-get -y install wget python-pip  python-setuptools build-essential python-dev libatlas-dev libatlas3gf-base liblapack-dev gfortran \
               libfreetype6 libpng12-0 libfreetype6-dev libxft-dev libfreetype6-dev pkg-config

ENV         WHEEL_DIR=/var/local/cache/wheelhouse TMP_WHEEL_DIR=/tmp/wheelhouse/
RUN         mkdir -p "$WHEEL_DIR"
VOLUME      ["/var/local/cache/wheelhouse"]

RUN         apt-get -y install uwsgi uwsgi-plugin-python lsb-invalid-mta logrotate cron

# Add scripts and config files to docker container
COPY        uwsgi-start.sh /usr/local/bin/uwsgi-start.sh
RUN         chmod u+x /usr/local/bin/uwsgi-start.sh

## Setup UWSGI user and logs
ENV         UWSGI_UID=uwsgi UWSGI_GID=uwsgi UWSGI_LOG_FILE=/var/log/uwsgi/uwsgi.log
RUN         echo "Adding user '${UWSGI_UID}' with group '${UWSGI_GID}'for uwsgi and logging to '${UWSGI_LOG_FILE}' . " && \
            groupadd "${UWSGI_GID}" && useradd "${UWSGI_UID}" -g "${UWSGI_GID}" -s /bin/false && \
            export UWSGI_LOG_DIR=$(dirname "${UWSGI_LOG_FILE}") && \
            if [ '!' -d "$UWSGI_LOG_DIR" ] ; then mkdir -p "$UWSGI_LOG_DIR" && chown -R ${UWSGI_UID}:${UWSGI_GID} "$UWSGI_LOG_DIR" ; fi && \
            touch "${UWSGI_LOG_FILE}" && chown -R ${UWSGI_UID}:${UWSGI_GID} "$UWSGI_LOG_FILE"

EXPOSE     8080
CMD        []
ENTRYPOINT ["/usr/local/bin/uwsgi-start.sh"]

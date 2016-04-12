# What is this?

It's a base package with python and uwsgi.

# How do I use this?

Simple, just checkout this project if you haven't yet, then run the following
command:

    docker build .

Or just pull it directly from DockerHub using

    docker pull izakburger/python-jessie-omc-uwsgi

# Is that it?

In a word, yes. Keep in mind this image is meant to be used as a base image
and does nothing on it's own.

# That sounds useless... So what then?

In its base form, it will simply dump you in a shell. Extend this build and
add WSGI_MODULE to the environment. You can also override default settings
to customise things. For example:

    FROM        izakburger/jessie-python-uwsgi

    ENV         UWSGI_NUM_PROCESSES    1
    ENV         UWSGI_NUM_THREADS      15
    ENV         UWSGI_HTTP_TIMEOUT     60
    ENV         UWSGI_HARAKIRI         65
    ENV         UWSGI_LOG_FILE         /var/log/uwsgi/uwsgi.log
    ENV         WSGI_MODULE            wsgi_module:application
    ENV         APP_DIR                /var/app
    ENV         LOG_FILENAME           /var/log/yourapp.log

    COPY        your.wheel.tar.gz /var/local/cache/wheelhouse/
    RUN         pip install --find-links $WHEEL_DIR --upgrade your.app

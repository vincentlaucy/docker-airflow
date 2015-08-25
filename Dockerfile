# VERSION 1.0
# AUTHOR: Matthieu "Puckel_" Roisil + LCY Modified
# DESCRIPTION: Basic Airflow container
# BUILD: docker build --rm -t puckel/docker-airflow
# SOURCE: https://github.com/puckel/docker-airflow

FROM debian:wheezy
MAINTAINER Puckel_

# Never prompts the user for choices on installation/configuration of packages
ENV DEBIAN_FRONTEND noninteractive
ENV TERM linux
# Work around initramfs-tools running on kernel 'upgrade': <http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=594189>
ENV INITRD No

ENV AIRFLOW_VERSION 1.4.0
ENV AIRFLOW_COMMIT aa0dffdb7b735c0e95fba61583e933aa68abcc37
ENV AIRFLOW_HOME /usr/local/airflow
ENV C_FORCE_ROOT true
ENV PYTHONLIBPATH /usr/lib/python2.7/dist-packages

RUN apt-get update -y
RUN apt-get install -y --no-install-recommends \
    netcat \
    python-pip \
    python-dev \
    libmysqlclient-dev \
    libkrb5-dev \
    libsasl2-dev \
    libpq-dev \
    build-essential \
    && mkdir -p $AIRFLOW_HOME/logs \
    && mkdir $AIRFLOW_HOME/dags \
    && pip install --install-option="--install-purelib=$PYTHONLIBPATH" git+git://github.com/airbnb/airflow.git@$AIRFLOW_COMMI \
    && pip install --install-option="--install-purelib=$PYTHONLIBPATH" airflow[postgres]==$AIRFLOW_VERSION \
    && apt-get clean \
    && rm -rf \
    /var/lib/apt/lists/* \
    /tmp/* \
    /var/tmp/* \
    /usr/share/man \
    /usr/share/doc \
    /usr/share/doc-base

ONBUILD ADD config/airflow.cfg $AIRFLOW_HOME/airflow.cfg
ADD script/entrypoint.sh /root/entrypoint.sh
RUN chmod +x /root/entrypoint.sh

EXPOSE 8080
EXPOSE 5555
EXPOSE 8793

ENTRYPOINT ["/root/entrypoint.sh"]

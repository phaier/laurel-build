FROM pypy:3
MAINTAINER Tadashi KOJIMA

WORKDIR /home

RUN apt-get update

### Check versions
RUN pypy3 --version \
    && pip --version


### Install other libraries
RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get install -y build-essential && \
    apt-get install -y software-properties-common
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C0B21F32
RUN add-apt-repository "deb http://archive.ubuntu.com/ubuntu bionic main universe restricted multiverse"
RUN apt-get update
RUN apt-get remove -y binutils
RUN apt-get install -y libatlas-doc libopenblas-base sqlite3 pandoc python-sphinx gfortran libblas-dev liblapack-dev python-scipy python-numpy

### Override python command
RUN ln -sf /usr/local/bin/pypy3 /usr/bin/python

### Preprocessing for pip install
RUN rm /usr/bin/lsb_release

### pip install
RUN pip install -r requirements.txt

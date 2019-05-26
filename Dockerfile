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
RUN apt-get install -y libatlas-doc libopenblas-base sqlite3 pandoc gfortran libblas-dev liblapack-dev sudo

### Override python command
RUN ln -sf /usr/local/bin/pypy3 /usr/bin/python

### Preprocessing for pip install
RUN rm /usr/bin/lsb_release
RUN apt-get install -y python3-pip python-sphinx python-scipy python-numpy

### pip install
COPY requirements.txt /home
RUN pip3 install -r requirements.txt

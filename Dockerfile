FROM jimako1989/bazel-build:latest
MAINTAINER Tadashi KOJIMA

WORKDIR /home

# Install basic commands
RUN apt-get install -y make vim less
RUN apt-get install -y libatlas-doc libopenblas-base
# skip install libatlas-base-dev libopenblas-dev

# Install python modules
RUN apt-get install -y python3-pip python3-dev \
  && pip3 install --upgrade pip
COPY requirements.txt /home/requirements.txt
RUN pip3 install -r /home/requirements.txt

# Install other modules
RUN apt-get install -y pandoc sqlite3

# Entrypoint
COPY docker-entrypoint.sh /home/docker-entrypoint.sh
RUN chmod +x docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]

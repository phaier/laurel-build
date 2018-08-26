FROM python:3.7.0-stretch AS build-env
FROM jimako1989/bazel-build:latest
MAINTAINER Tadashi KOJIMA

COPY --from=build-env /usr/local/bin/ /usr/local/bin/
WORKDIR /home

# Check versions
RUN python3 --version \
    && pip3 --version \
    && bazel version

# Install basic commands
RUN apt-get update
RUN apt-get install -y build-essential
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
RUN chmod +x /home/docker-entrypoint.sh
ENTRYPOINT ["/home/docker-entrypoint.sh"]

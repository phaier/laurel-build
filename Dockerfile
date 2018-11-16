FROM pypy:3
MAINTAINER Tadashi KOJIMA

WORKDIR /home

### Install OpenJDK

RUN apt-get update && apt-get install -y --no-install-recommends \
		bzip2 \
		unzip \
		xz-utils \
	&& rm -rf /var/lib/apt/lists/*

# Default to UTF-8 file.encoding
ENV LANG C.UTF-8

# add a simple script that can auto-detect the appropriate JAVA_HOME value
# based on whether the JDK or only the JRE is installed
RUN { \
		echo '#!/bin/sh'; \
		echo 'set -e'; \
		echo; \
		echo 'dirname "$(dirname "$(readlink -f "$(which javac || which java)")")"'; \
	} > /usr/local/bin/docker-java-home \
	&& chmod +x /usr/local/bin/docker-java-home

# do some fancy footwork to create a JAVA_HOME that's cross-architecture-safe
RUN ln -svT "/usr/lib/jvm/java-7-openjdk-$(dpkg --print-architecture)" /docker-java-home
ENV JAVA_HOME /docker-java-home

ENV JAVA_VERSION 7u181
ENV JAVA_DEBIAN_VERSION 7u181-2.6.14-1~deb8u1

RUN set -ex; \
	\
# deal with slim variants not having man page directories (which causes "update-alternatives" to fail)
	if [ ! -d /usr/share/man/man1 ]; then \
		mkdir -p /usr/share/man/man1; \
	fi; \
	\
	apt-get update; \
	apt-get install -y --no-install-recommends \
		openjdk-7-jdk="$JAVA_DEBIAN_VERSION" \
	; \
	rm -rf /var/lib/apt/lists/*; \
	\
# verify that "docker-java-home" returns what we expect
	[ "$(readlink -f "$JAVA_HOME")" = "$(docker-java-home)" ]; \
	\
# update-alternatives so that future installs of other OpenJDK versions don't change /usr/bin/java
	update-alternatives --get-selections | awk -v home="$(readlink -f "$JAVA_HOME")" 'index($3, home) == 1 { $2 = "manual"; print | "update-alternatives --set-selections" }'; \
# ... and verify that it actually worked for one of the alternatives we care about
	update-alternatives --query java | grep -q 'Status: manual'

# If you're reading this and have any feedback on how this image could be
# improved, please open an issue or a pull request so we can discuss it!
#
#   https://github.com/docker-library/openjdk/issues


### Install bazel

RUN wget https://github.com/bazelbuild/bazel/releases/download/0.18.1/bazel-0.18.1-installer-linux-x86_64.sh \
    && chmod +x ./bazel-0.18.1-installer-linux-x86_64.sh \
    && ./bazel-0.18.1-installer-linux-x86_64.sh


### Check versions
RUN pypy3 --version \
    && pip --version \
    && bazel version


### Install other libraries
RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get install -y build-essential && \
    apt-get install -y software-properties-common
RUN apt-key adv --keyserver keys.gnupg.net --recv-keys C0B21F32
RUN add-apt-repository "deb http://archive.ubuntu.com/ubuntu bionic main universe restricted multiverse"
RUN apt-get update
RUN apt-get remove -y binutils
RUN apt-get install -y libatlas-doc libopenblas-base sqlite3 pandoc python-sphinx gfortran libblas-dev liblapack-dev python-scipy python-numpy

### Override python command
RUN ln -sf /usr/local/bin/pypy3 /usr/bin/python

### Preprocessing for pip install
RUN rm /usr/bin/lsb_release

### Entrypoint
COPY docker-entrypoint.sh /home/docker-entrypoint.sh
RUN chmod +x /home/docker-entrypoint.sh
CMD ["/home/docker-entrypoint.sh"]

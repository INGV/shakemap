FROM debian:stretch 

MAINTAINER Valentino Lauciani <valentino.lauciani@ingv.it>

ENV DEBIAN_FRONTEND=noninteractive
ENV INITRD No
ENV FAKE_CHROOT 1

# install packages
RUN apt-get update \
    && apt-get dist-upgrade -y --no-install-recommends \
    && apt-get install -y \
        build-essential \
        vim \
        bc \
	git \
	curl

WORKDIR /opt
RUN mkdir gitwork \
    && cd gitwork \
    && git clone https://github.com/usgs/shakemap.git shakemap_src \
    && cd shakemap_src 

COPY install.sh.alberto /opt/

WORKDIR /opt/gitwork/shakemap_src
#RUN cp install.sh install.sh.original
#RUN cp /opt/install.sh.alberto install.sh

# Update 'install.sh' file
RUN cp -v install.sh install.sh.original
RUN sed -e 's|"sphinx"|"jupyter"|' install.sh > install.sh.new
RUN mv install.sh.new install.sh
RUN bash ./install.sh -d

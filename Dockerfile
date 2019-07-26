FROM continuumio/miniconda3 

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

WORKDIR /opt/gitwork/shakemap_src

# Update 'install.sh' file
RUN cp -v install.sh install.sh.original \
    && sed -e 's|"sphinx"|"jupyter"|' install.sh > install.sh.new \
    && mv install.sh.new install.sh
RUN bash ./install.sh -d

# Add 'conda' source in the '.bashrc' file
#RUN echo ". /root/miniconda/etc/profile.d/conda.sh" > /root/.bashrc
RUN echo ". /opt/conda/etc/profile.d/conda.sh" > /root/.bashrc

SHELL ["/bin/bash", "-c"]

# Source variable
#RUN . /root/miniconda/etc/profile.d/conda.sh \ 
RUN . /opt/conda/etc/profile.d/conda.sh \ 
    && conda info --envs \
    && conda activate shakemap \ 
    && sm_profile -c default -a 
#    && py.test .

#RUN py.test .

# Copy 'gmice.py' and 'fm10.py'
WORKDIR /opt/gitwork/shakemap_src/shakelib/gmice
ADD gmice.py ./
ADD fm10.py ./

# Copy 'bindi_2011.py' and 'tusa_langer_2016.py'
WORKDIR /opt/conda/envs/shakemap/lib/python3.6/site-packages/openquake/hazardlib/gsim
ADD bindi_2011.py ./
ADD tusa_langer_2016.py ./

# Default dir
WORKDIR /root

# verify the installation
#RUN verify the installation



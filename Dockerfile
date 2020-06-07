FROM continuumio/miniconda3:4.8.2
#FROM continuumio/anaconda3:2020.02

MAINTAINER Valentino Lauciani <valentino.lauciani@ingv.it>

#
ENV DEBIAN_FRONTEND=noninteractive
ENV INITRD No
ENV FAKE_CHROOT 1

# Set Python version
ENV PYTHON_VER=3.7

# Set Shakemap checkout: https://github.com/usgs/shakemap.git
ENV SHAKEMAP_COMMIT=3367757

# Make RUN commands use `bash --login`:
SHELL ["/bin/bash", "--login", "-c"]

# install packages
RUN apt-get update \
    && apt-get dist-upgrade -y --no-install-recommends \
    && apt-get install -y \
        build-essential \
        vim \
        bc \
	git \
	curl \
        clang

WORKDIR /opt
RUN mkdir gitwork \
    && cd gitwork \
    && git config --global user.email "valentino.lauciani@ingv.it" \
    && git config --global user.name "Valentino Lauciani" \
    && git clone https://github.com/usgs/shakemap.git shakemap_src \
    && cd shakemap_src \
    && git checkout ${SHAKEMAP_COMMIT}

# Copy modified plotregr.py (issue: https://gitlab.rm.ingv.it/shakemap/shakemap4/-/issues/5)
WORKDIR /opt/gitwork/shakemap_src
COPY plotregr.py /opt/gitwork/shakemap_src/shakemap/coremods/

# INGV FIX
RUN mv install.sh install.sh.original \
    && sed \
        -e 's|gdal|gdal=3.0.2|' \
        -e 's|cartopy|cartopy=0.17|' \
        -e "s|3.8|${PYTHON_VER}|" \
        install.sh.original > install.sh

#RUN mv setup.py setup.py.original \
#    && sed -e 's/os.environ.*//' setup.py.original > setup.py

# Install
RUN bash install.sh

# Add 'conda' source in the '.bashrc' file
RUN echo ". /opt/conda/etc/profile.d/conda.sh" >> /root/.bashrc

# Add bash alias
RUN echo "alias ll='ls -l'" >> /root/.bashrc

# Source variable
RUN . /opt/conda/etc/profile.d/conda.sh \ 
    && conda info --envs \
    && conda activate shakemap \ 
    && sm_profile -c default -a -n 

RUN . /opt/conda/etc/profile.d/conda.sh \
    && conda info --envs \
    && conda activate shakemap \
    && sm_profile -c italy -a -n

RUN . /opt/conda/etc/profile.d/conda.sh \
    && conda info --envs \
    && conda activate shakemap \
    && sm_profile -c world -a -n

# Copy 'gmice.py' and 'fm10.py'
WORKDIR /opt/gitwork/shakemap_src/shakelib/gmice
ADD gmice.py ./
ADD fm10.py ./

# Copy 'bindi_2011.py' and 'tusa_langer_2016.py'
WORKDIR /opt/conda/envs/shakemap/lib/python${PYTHON_VER}/site-packages/openquake/hazardlib/gsim
ADD tusa_langer_2016.py ./

# Default dir
WORKDIR /root

# Copy entrypoint file
WORKDIR /opt
COPY entrypoint.sh /opt/
RUN chmod 755 /opt/entrypoint.sh

RUN echo "source activate shakemap" >> ~/.bashrc
ENV PATH /opt/conda/envs/env/bin:$PATH

# Set entrypoint
ENTRYPOINT ["./entrypoint.sh"]

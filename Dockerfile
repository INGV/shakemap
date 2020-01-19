FROM continuumio/miniconda3:4.7.12

MAINTAINER Valentino Lauciani <valentino.lauciani@ingv.it>

ENV DEBIAN_FRONTEND=noninteractive
ENV INITRD No
ENV FAKE_CHROOT 1

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
	curl

WORKDIR /opt
RUN mkdir gitwork \
    && cd gitwork \
    && git config --global user.email "valentino.lauciani@ingv.it" \
    && git config --global user.name "Valentino Lauciani" \
    && git clone https://github.com/usgs/shakemap.git shakemap_src \
    && cd shakemap_src 

WORKDIR /opt/gitwork/shakemap_src

# Install
RUN bash install.sh -d

# Update 'install.sh' file
#RUN cp -v install.sh install.sh.original \
#    && sed -e 's|"sphinx"|"jupyter"|' install.sh > install.sh.new \
#    && mv install.sh.new install.sh \
#    && sed -e 's|"scikit-image"|""|' install.sh > install.sh.new \
#    && mv install.sh.new install.sh \
#    && chmod 755 install.sh  
#RUN conda init bash \
#    && bash -c "./install.sh -d" \
#    && conda info --envs \
#    && sleep 10000

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
WORKDIR /opt/conda/envs/shakemap/lib/python3.6/site-packages/openquake/hazardlib/gsim
ADD bindi_2011.py ./
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

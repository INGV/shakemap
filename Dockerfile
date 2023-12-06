FROM debian:buster-slim

MAINTAINER Valentino Lauciani <valentino.lauciani@ingv.it>


#
ENV DEBIAN_FRONTEND=noninteractive
ENV INITRD No
ENV FAKE_CHROOT 1

##### DEPRECATED - Set Shakemap checkout: https://github.com/usgs/shakemap.git
#a12d0dc5204e3dff1f7848fcea4c29836cf15d2e #v4.1.3
#8dafaa2589224d78d0f4343dcc675fa6644de2ea #v4.1.4
#f23f1aeb252670b5eee25fd3529a78b7ffacd666

##### Set Shakemap checkout: https://github.com/DOI-USGS/ghsc-esi-shakemap
# v4.1.5 (but doesn't work)
#ed31eee91a20b3417eef42f510d19905c9d6067d
# last commit after v4.1.5
ENV SHAKEMAP_COMMIT=f28a82fbd59892f6503796be09f3ad089765c731

# Make RUN commands use `bash --login`:
SHELL ["/bin/bash", "--login", "-c"]

# Set 'root' pwd
RUN echo root:toor | chpasswd

# install packages
RUN apt-get update \
    && apt-get dist-upgrade -y --no-install-recommends \
    && apt-get install -y \
        build-essential \
        vim \
        bc \
        git \
        curl \
        clang \
    && apt-get clean

# Set .bashrc for root user
RUN echo "" >> /root/.bashrc \
    && echo "##################################" >> /root/.bashrc \
    && echo "alias ll='ls -l --color'" >> /root/.bashrc \
    && echo "" >> /root/.bashrc \
    && echo "export LC_ALL=\"C\"" >> /root/.bashrc \
    && echo "" >> /root/.bashrc \
    && echo "caption always" >> /root/.screenrc \
    && echo "caption string '%{+b b}%H: %{= .W.} %{b}%D %d-%M %{r}%c %{k}%?%F%{.B.}%?%2n%? [%h]%? (%w)'" >> /root/.screenrc

##################################
# Set User and Group variabls
ENV GROUP_NAME=shake
ENV USER_NAME=shake
ENV HOMEDIR_USER=/home/${USER_NAME}

# Set default User and Group id from arguments
# If UID and/or GID are equal to zero then new user and/or group are created
ARG ENV_UID=0
ARG ENV_GID=0

RUN echo ENV_UID=${ENV_UID}
RUN echo ENV_GID=${ENV_GID}

RUN \
		if (( ${ENV_UID} == 0 )) || (( ${ENV_GID} == 0 )); \
		then \
			echo ""; \
			echo "WARNING: when passing UID or GID equal to zero, new user and/or group are created."; \
			echo "         On Linux, if you run docker image by different UID or GID you could not able to write in docker mount data directory."; \
			echo ""; \
		fi

# Check if GID already exists
RUN cat /etc/group
RUN \
		if (( ${ENV_GID} == 0 )); \
		then \
			addgroup --system ${GROUP_NAME}; \
		elif grep -q -e "[^:][^:]*:[^:][^:]*:${ENV_GID}:.*$" /etc/group; \
		then \
			GROUP_NAME_ALREADY_EXISTS=$(grep  -e "[^:][^:]*:[^:][^:]*:${ENV_GID}:.*$" /etc/group | cut -f 1 -d':'); \
			echo "GID ${ENV_GID} already exists with group name ${GROUP_NAME_ALREADY_EXISTS}"; \
			groupmod -n ${GROUP_NAME} ${GROUP_NAME_ALREADY_EXISTS}; \
		else \
			echo "GID ${ENV_GID} does not exist"; \
			addgroup --gid ${ENV_GID} --system ${GROUP_NAME}; \
		fi

# Check if UID already exists
RUN cat /etc/passwd
RUN \
		if (( ${ENV_UID} == 0 )); \
		then \
			useradd --system -d ${HOMEDIR_USER} -g ${GROUP_NAME} -s /bin/bash ${USER_NAME}; \
		elif grep -q -e "[^:][^:]*:[^:][^:]*:${ENV_UID}:.*$" /etc/passwd; \
		then \
			USER_NAME_ALREADY_EXISTS=$(grep  -e "[^:][^:]*:[^:][^:]*:${ENV_UID}:.*$" /etc/passwd | cut -f 1 -d':'); \
			echo "UID ${ENV_UID} already exists with user name ${USER_NAME_ALREADY_EXISTS}"; \
			usermod -d ${HOMEDIR_USER} -g ${ENV_GID} -l ${USER_NAME} ${USER_NAME_ALREADY_EXISTS}; \
		else \
			echo "UID ${ENV_UID} does not exist"; \
			useradd --system -u ${ENV_UID} -d ${HOMEDIR_USER} -g ${ENV_GID} -G ${GROUP_NAME} -s /bin/bash ${USER_NAME}; \
		fi
			# adduser -S -h ${HOMEDIR_USER} -G ${GROUP_NAME} -s /bin/bash ${USER_NAME}; \
			# adduser --uid ${ENV_UID} --home ${HOMEDIR_USER} --gid ${ENV_GID} --shell /bin/bash ${USER_NAME}; \

# Create home directory
RUN mkdir ${HOMEDIR_USER}
###########################################

# Copy some files
RUN cp /root/.bashrc ${HOMEDIR_USER}/
RUN cp /root/.screenrc ${HOMEDIR_USER}/

# Copy entrypoint file
COPY ./entrypoint.sh ${HOMEDIR_USER}/
RUN chmod 755 ${HOMEDIR_USER}/entrypoint.sh

# Set home directory own
RUN chown -R ${USER_NAME}:${GROUP_NAME} ${HOMEDIR_USER}

# Change default user
USER ${USER_NAME}:${GROUP_NAME}

# Get shakemap software
WORKDIR ${HOMEDIR_USER}
RUN mkdir gitwork \
    && cd gitwork \
    && git config --global user.email "valentino.lauciani@ingv.it" \
    && git config --global user.name "Valentino Lauciani" \
    && git clone https://github.com/DOI-USGS/ghsc-esi-shakemap shakemap_src \
    && cd shakemap_src \
    && git checkout ${SHAKEMAP_COMMIT}

# Copy modified plotregr.py (issue: https://gitlab.rm.ingv.it/shakemap/shakemap4/-/issues/5)
COPY ./ext/plotregr.py ${HOMEDIR_USER}/gitwork/shakemap_src/shakemap/coremods/

# Add 'conda' source in the '.bashrc' file - It must be run BEFORE to install shakemap software; because, if not exists, the intalleer will add '. /etc/profile.d/conda.sh' that doesn't exist.
RUN echo ". ${HOMEDIR_USER}/miniconda/etc/profile.d/conda.sh" >> ${HOMEDIR_USER}/.bashrc

# BUGFIX 1/3
#WORKDIR ${HOMEDIR_USER}/gitwork/shakemap_src
#RUN mv install.sh install.sh.original \
#    && sed -e 's/curl -L/curl --tls-max 1.2 -L/' install.sh.original > install.sh

# BUGFIX 2/3 - il paccketto 'numpy' se installato nei 'package_list', da errore; se installato singolarmente successivamente a 'bash install.sh', va bene... boh!
#WORKDIR ${HOMEDIR_USER}/gitwork/shakemap_src
#RUN mv install.sh install.sh.original \
#    && sed -e 's/"numpy==1.20"//' install.sh.original > install.sh

# Install shakemap software
WORKDIR ${HOMEDIR_USER}/gitwork/shakemap_src
RUN bash install.sh

# BUGFIX 3/3
#RUN . ${HOMEDIR_USER}/miniconda/etc/profile.d/conda.sh \
#    && conda install -n shakemap numpy==1.20 -y

# 1) Source variables
# 2) Add python modules 'basemap' and 'seaborn'. Issue: #20
# 3) Add python module 'alpha-shapes' as suggested from Bruce Worden (workaround email 29-Nov-2023. It should be romoved in version 4.2.0)
# 4) Install and configure 'strec_cfg'
RUN . ${HOMEDIR_USER}/miniconda/etc/profile.d/conda.sh \
    && conda info --envs \
    && conda activate shakemap \
    && sm_profile -c world -a -n \ 
    && pip install alpha-shapes \
    && pip install basemap \
    && pip install seaborn \
    && mkdir ${HOMEDIR_USER}/strec_data \
    && pip install --upgrade usgs-strec \
    && strec_cfg update --datafolder ${HOMEDIR_USER}/strec_data --slab --gcmt

# Copy own libs
#COPY ./ext/gmice.py ${HOMEDIR_USER}/gitwork/shakemap_src/shakelib/gmice/
COPY ./ext/fm10.py ${HOMEDIR_USER}/gitwork/shakemap_src/shakelib/gmice/
COPY ./ext/ofm22.py ${HOMEDIR_USER}/gitwork/shakemap_src/shakelib/gmice/
COPY ./ext/fm11_ch.py ${HOMEDIR_USER}/gitwork/shakemap_src/shakelib/gmice/

# Copy 'tusa_langer_2016.py'
COPY ./ext/tusa_langer_2016.py /tmp/
# COPY ./ext/pasolini_2008_ipe.py /tmp/
#RUN for TUSA in $(find ${HOMEDIR_USER}/miniconda/ -name tusa_langer_2016.py); do cp -v /tmp/tusa_langer_2016.py ${TUSA}; done
RUN PATHTUSA=$( find ${HOMEDIR_USER}/miniconda/ -name tusa_langer_2016.py ) \
    && DIRNAME_PATHTUSA=$( dirname ${PATHTUSA} ) \
    && cp -v /tmp/tusa_langer_2016.py ${DIRNAME_PATHTUSA}/
#    && cp -v /tmp/pasolini_2008_ipe.py ${DIRNAME_PATHTUSA}/

#
WORKDIR ${HOMEDIR_USER}

#
RUN echo "conda activate base" >> ${HOMEDIR_USER}/.bashrc
RUN echo "source activate shakemap" >> ${HOMEDIR_USER}/.bashrc
ENV PATH ${HOMEDIR_USER}/miniconda/envs/env/bin:$PATH

# Set entrypoint
ENTRYPOINT ["./entrypoint.sh"]

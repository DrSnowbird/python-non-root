ARG BASE=${BASE:-python:3.9}
FROM ${BASE}

MAINTAINER DrSnowbird "DrSnowbird@openkbs.org"

ENV DEBIAN_FRONTEND noninteractive

#### ------------------------------------------------------------------------
#### ---- User setup so we don't use root as user ----
#### ------------------------------------------------------------------------
ARG USER_ID=${USER_ID:-1000}
ENV USER_ID=${USER_ID}

ARG GROUP_ID=${GROUP_ID:-1000}
ENV GROUP_ID=${GROUP_ID}
    
ARG USER=${USER:-developer}
ENV USER=${USER}

ENV WORKSPACE=${HOME}/workspace

###################################
#### ---- user: developer ---- ####
###################################
ENV USER_ID=${USER_ID:-1000}
ENV GROUP_ID=${GROUP_ID:-1000}
ENV USER=${USER:-developer}
ENV HOME=/home/${USER}

RUN apt-get update && apt-get install -y --no-install-recommends sudo apt-utils && \
    useradd -ms /bin/bash ${USER} && \
    export uid=${USER_ID} gid=${GROUP_ID} && \
    mkdir -p /home/${USER} && \
    mkdir -p /home/${USER}/workspace && \
    mkdir -p /etc/sudoers.d && \
    echo "${USER}:x:${USER_ID}:${GROUP_ID}:${USER},,,:/home/${USER}:/bin/bash" >> /etc/passwd && \
    echo "${USER}:x:${USER_ID}:" >> /etc/group && \
    echo "${USER} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${USER} && \
    chmod 0440 /etc/sudoers.d/${USER} && \
    chown -R ${USER}:${USER} /home/${USER}

################################################### 
#### ---- python3: pyenv                    ----  #
###################################################
#### ref: https://github.com/pyenv/pyenv
#### ref: https://github.com/pyenv/pyenv-virtualenv
#### Notes:
#### 1. There is a venv module available for CPython 3.3 and newer. 
####    It provides an executable module venv which is 
####    the successor of virtualenv and distributed by default. 
####    and distributed by default.
#### 2. If conda is available, 
####       pyenv virtualenv will use it to create environment by conda create
#### ----------------------------------------------
#### ---- python3: pyenv      ----
#### ---- plugin: virtualenv  ----
#### ----------------------------------------------
#### ---- Version:
####      >> pyenv version
#### ---- Create: virtualenv from current version
####      >> pyenv virutalenv myvenv
#### ---- Create: virtualenv new version
####      >> pyenv virutalenv 3.9.0 myvenv-3.9.0
#### ---- Activate: virtualenv:
####      >> pyenv activate myvenv
####      >> pyenv activate myvenv-3.9.0
#### ---- DeActivate: virtualenv:
####      >> pyenv deactivate
#### ---- Uninstall: virutalenv:
####      >> pyenv uninstall myvenv-3.9.0
####      >> pyenv virtualenv-delete my-virtual-env
#### ---- List: virtualenvs:
####      >> pyenv virtualenvs
#### ---- List All Python Versions:
####      >> pyenv install --list
#### ----------------------------------------------
USER ${USER}
WORKDIR ${HOME}

RUN sudo apt-get install -y curl vim git ack && \
    curl https://pyenv.run | bash && \
    echo "export PYENV_ROOT=\$HOME/.pyenv" >> ~/.bashrc && \
    echo "export PATH=\$PYENV_ROOT/bin:\$HOME/.local/bin:\$PATH" >> $HOME/.bashrc && \
    echo "eval \"\$(pyenv init --path)\" " >> $HOME/.bashrc && \
    echo "eval \"\$(pyenv init -)\" " >> $HOME/.bashrc && \
    echo "eval \"\$(pyenv virtualenv-init -)\" " >> $HOME/.bashrc && \
    echo "pyenv virtualenv myvenv" >> $HOME/.bashrc && \
    echo "pyenv activate myvenv" >> $HOME/.bashrc
    
RUN echo "alias venv='pyenv virtualenv'" >> $HOME/.bashrc && \
    echo "alias activate='pyenv activate'" >> $HOME/.bashrc && \
    echo "alias deactivate='pyenv deactivate'" >> $HOME/.bashrc && \
    echo "alias venv-delete='pyenv virtualenv-delete'" >> $HOME/.bashrc
    
ENV PYENV_ROOT=${HOME}/.pyenv

RUN mkdir ${HOME}/bin 
#COPY --chown=${USER} ./bin ${HOME}/bin
#COPY --chown=${USER} ./bin/pre-load-virtualenv.sh ${HOME}/bin/
#RUN ${HOME}/bin/pre-load-virtualenv.sh myvenv

################################ 
#### ---- Entrypoint setup ----#
################################
#### --- Copy Entrypoint script in the container ---- ####
COPY --chown=$USER ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]

############################### 
#### ---- Workspace setup ----#
###############################
VOLUME "${HOME}/data"
VOLUME "${HOME}/workspace"

#### ------------------------------------------------------------------------
#### ---- Change to user mode ----
#### ------------------------------------------------------------------------
#CMD ["/bin/bash"]
CMD ["python", "-V"]

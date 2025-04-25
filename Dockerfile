FROM px4io/px4-dev-ros-noetic AS base

ENV DEBIAN_FRONTEND=noninteractive
SHELL [ "/bin/bash", "-o", "pipefail", "-c" ]

ARG UNAME=sim
ARG USE_NVIDIA=1

# Dependencies
RUN sudo apt-get update \
    && apt-get install -y -qq --no-install-recommends \
    python-is-python3 \
    apt-utils \
    byobu \
    fuse \
    git \
    libxext6 \
    libx11-6 \
    libglvnd0 \
    libgl1 \
    libglx0 \
    libegl1 \
    libfuse-dev \
    libpulse-mainloop-glib0 \
    rapidjson-dev \
    gstreamer1.0-plugins-bad \
    gstreamer1.0-libav \ 
    gstreamer1.0-gl \
    iputils-ping \
    nano \
    wget \
    && rm -rf /var/lib/apt/lists/*

# User
RUN adduser --disabled-password --gecos '' $UNAME
RUN adduser $UNAME sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
ENV HOME=/home/$UNAME
USER $UNAME


ENV DISPLAY=:0
RUN echo $DISPLAY
WORKDIR $HOME

# Nvidia GPU vars
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=graphics,utility,compute
RUN if [[ -z "${USE_NVIDIA}" ]] ;\
    then printf "export QT_GRAPHICSSYSTEsudo docker imagesM=native" >> /home/${UNAME}/.bashrc ;\
    else echo "Native rendering support disabled" ;\
    fi

# Add sourcing of your catkin workspace and FLIGHTMARE_PATH environment variable to your .bashrc file:
RUN echo "source ~/workspace/catkin_ws/devel/setup.bash --extend" >> ~/.bashrc >> ~/.bashrc && \
    echo "source /opt/ros/noetic/setup.bash --extend" >> ~/.bashrc && \
    echo "export FLIGHTMARE_PATH=~/home/sim/flightmare" >> ~/.bashrc


    
    
    
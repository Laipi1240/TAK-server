# Base image updated to Ubuntu 22.04
FROM ubuntu:22.04 AS main-setup

ARG DEBIAN_FRONTEND=noninteractive
ENV ROS_DISTRO=humble \
    SHELL=/bin/bash \
    NB_USER=wilbur \
    NB_UID=1000 \
    GZ_VERSION=harmonic

RUN echo 'Etc/UTC' > /etc/timezone && \
    ln -s /usr/share/zoneinfo/Etc/UTC /etc/localtime

###################################### User Setup #####################################
RUN adduser --disabled-password \
--gecos "Default user" \
--uid ${NB_UID} \
${NB_USER} 

RUN echo "root:root" | chpasswd \
&& echo "${NB_USER}:111111" | chpasswd

ENV HOME=/home/${NB_USER}

###################################### Basic Tools #####################################
RUN apt-get update && \
    apt-get install -q -y --no-install-recommends \
    ccache \
    g++ \
    gcc \
    gdb \
    gawk \
    make \
    ninja-build \
    python3-numpy \
    python3.11 \
    python3.11-dev \
    python3.11-distutils \
    libpython3.11-stdlib \
    python-is-python3 \
    libtool-bin \
    zip \
    default-jre \
    socat \
    tzdata \
    pip \
    dirmngr \
    gnupg2 \
    git \
    gitk git-gui \
    vim \
    less \
    curl \
    wget \
    sudo \
    cmake \
    swig \
    net-tools \
    lsb-release \
    gnupg \
    build-essential \
    libcgal-dev \
    libfftw3-dev \
    rapidjson-dev \
    pkg-config \
    libboost-system-dev \
    libopencv-dev \
    gstreamer1.0-plugins-bad \
    gstreamer1.0-libav \
    gstreamer1.0-gl \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

###################################### Python Packages ##################################
RUN apt-get update && apt-get install -y python3-pip && \
    python3.11 -m pip install --upgrade pip && \
    python3.11 -m pip install \
    numpy \
    scipy \
    matplotlib \
    scikit-learn \
    scikit-image \
    pandas \
    opencv-python \
    opencv-python-headless \
    pyyaml \
    pyquaternion \
    pymavlink \
    MAVProxy \
    pyserial \
    pexpect \
    Pillow \
    tensorboard \
    tensorflow \
    future

################################## Torch, Gymnasium, and SB3 ##################################
RUN python3.11 -m pip install --no-cache-dir --ignore-installed PyYAML && \
    python3.11 -m pip install \
    torch \
    torchaudio \
    torchvision \
    gymnasium \
    gymnasium[box2d] \
    stable-baselines3 \
    openai \
    trajectopy-core \
    huggingface-sb3 \
    huggingface_hub \
    transformers \
    datasets \
    hf_transfer \
    opencv-python-headless \
    timm

###################################### ROS 2 ####################################
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null && \
    apt-get update && apt-get install -y --no-install-recommends \
    ros-${ROS_DISTRO}-desktop \
    ros-${ROS_DISTRO}-ros2-control \
    ros-${ROS_DISTRO}-ros2-controllers \
    ros-${ROS_DISTRO}-joy* \
    ros-${ROS_DISTRO}-joint-state-publisher \
    ros-${ROS_DISTRO}-mavros \
    ros-${ROS_DISTRO}-mavros-extras \
    ros-${ROS_DISTRO}-mavros-msgs \
    ros-${ROS_DISTRO}-rosbridge-server \
    ros-${ROS_DISTRO}-gps-msgs \
    ros-${ROS_DISTRO}-vision-msgs \
    ros-${ROS_DISTRO}-ament-cmake \
    ros-${ROS_DISTRO}-geometry-msgs \
    ros-${ROS_DISTRO}-std-msgs \
    ros-${ROS_DISTRO}-sensor-msgs \
    ros-${ROS_DISTRO}-tf2-msgs \
    ros-${ROS_DISTRO}-xacro \
    ros-${ROS_DISTRO}-rviz-rendering \
    ros-${ROS_DISTRO}-rcl-interfaces \
    ros-${ROS_DISTRO}-urdf \
    ros-${ROS_DISTRO}-geographic-msgs \
    ros-${ROS_DISTRO}-topic-tools \
    ros-dev-tools \
    ros-${ROS_DISTRO}-launch-pytest \
    python3-colcon-common-extensions \
    python3-rosdep \
    ros-dev-tools && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN cd /opt && git clone -b ros2 https://github.com/mavlink/mavros.git && \
    cd mavros/mavros/scripts && \
    ./install_geographiclib_datasets.sh

###################################### Gazebo ##################################
RUN curl https://packages.osrfoundation.org/gazebo.gpg --output /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] http://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/gazebo-stable.list > /dev/null && \
    apt-get update && \
    apt-get install -y \
    libgz-sim8-dev \
    libgz-transport13-dev \
    libignition-utils1-dev \
    libsdformat14-dev \
    gz-${GZ_VERSION} \
    ros-${ROS_DISTRO}-ros-gz${GZ_VERSION} \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rosdep init && \
    rosdep update

###################################### Micro XRCE-DDS Gen ####################################
FROM eclipse-temurin:19-jdk-jammy AS dds-gen-builder
RUN apt-get update && apt-get install --no-install-recommends -y \
    git \
    && apt-get clean \
    && apt-get -y autoremove \
    && apt-get autoclean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN git clone -b master --recurse-submodules https://github.com/ArduPilot/Micro-XRCE-DDS-Gen.git --depth 1 --no-single-branch --branch master dds-gen \
    && cd dds-gen \
    && ./gradlew assemble

FROM main-setup

# Copy DDS Gen to final container
COPY --from=dds-gen-builder /dds-gen/scripts /usr/local/dds-gen/scripts/
COPY --from=dds-gen-builder /dds-gen/share /usr/local/dds-gen/share/

# Ensure microxrceddsgen is in PATH
ENV PATH="/usr/local/dds-gen/scripts:$PATH"

# Set the buildlogs directory into /tmp as other directories aren't accessible
ENV BUILDLOGS=/tmp/buildlogs
ENV TZ=UTC

###################################### FreeTAKServer ####################################
RUN python3.11 -m pip install FreeTAKServer[ui]

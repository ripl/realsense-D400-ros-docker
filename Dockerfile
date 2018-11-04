FROM afdaniele/libbot2-ros:latest

# set the version of the realsense library
ENV LIBREALSENSE_VERSION 2.16.1
ENV LIBREALSENSE_ROS_VERSION 2.1.0

# set working directory
RUN mkdir -p /code
WORKDIR /code

# install dependencies
RUN apt update && \
  DEBIAN_FRONTEND=noninteractive apt install -y \
  wget \
  python-rosinstall \
  python-catkin-tools \
  ros-${ROS_DISTRO}-jsk-tools \
  ros-${ROS_DISTRO}-rgbd-launch \
  ros-${ROS_DISTRO}-image-transport-plugins \
  ros-${ROS_DISTRO}-image-transport \
  libusb-1.0-0 \
  libusb-1.0-0-dev \
  freeglut3-dev \
  libgtk-3-dev \
  libglfw3-dev && \
  # clear cache
  rm -rf /var/lib/apt/lists/*

# install librealsense
RUN cd /tmp && \
  wget https://github.com/IntelRealSense/librealsense/archive/v${LIBREALSENSE_VERSION}.tar.gz && \
  tar -xvzf v${LIBREALSENSE_VERSION}.tar.gz && \
  rm v${LIBREALSENSE_VERSION}.tar.gz && \
  mkdir -p librealsense-${LIBREALSENSE_VERSION}/build && \
  cd librealsense-${LIBREALSENSE_VERSION}/build && \
  cmake .. && \
  make -j && \
  make install && \
  rm -rf librealsense-${LIBREALSENSE_VERSION}

# install ROS package
RUN mkdir -p /code/src && \
  cd /code/src/ && \
  wget https://github.com/intel-ros/realsense/archive/${LIBREALSENSE_ROS_VERSION}.tar.gz && \
  tar -xvzf ${LIBREALSENSE_ROS_VERSION}.tar.gz && \
  rm ${LIBREALSENSE_ROS_VERSION}.tar.gz && \
  mv realsense-${LIBREALSENSE_ROS_VERSION}/realsense2_camera ./ && \
  rm -rf realsense-${LIBREALSENSE_ROS_VERSION}

# build ROS package
RUN . /opt/ros/${ROS_DISTRO}/setup.sh && \
  catkin build

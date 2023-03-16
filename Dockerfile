# parameters
ARG ARCH
ARG NAME
ARG ORGANIZATION
ARG DESCRIPTION
ARG MAINTAINER

# ==================================================>
# ==> Do not change the code below this line
ARG BASE_REGISTRY=docker.io
ARG BASE_ORGANIZATION=ripl
ARG BASE_REPOSITORY=libbot2-ros
ARG BASE_TAG=cpk

# define base image
FROM ${BASE_REGISTRY}/${BASE_ORGANIZATION}/${BASE_REPOSITORY}:${BASE_TAG}-${ARCH} as BASE

# recall all arguments
# - current project
ARG NAME
ARG ORGANIZATION
ARG DESCRIPTION
ARG MAINTAINER
# - base project
ARG BASE_REGISTRY
ARG BASE_ORGANIZATION
ARG BASE_REPOSITORY
ARG BASE_TAG
# - defaults
ARG LAUNCHER=default

# define/create project paths
ARG PROJECT_PATH="${CPK_SOURCE_DIR}/${NAME}"
ARG PROJECT_LAUNCHERS_PATH="${CPK_LAUNCHERS_DIR}/${NAME}"
RUN mkdir -p "${PROJECT_PATH}"
RUN mkdir -p "${PROJECT_LAUNCHERS_PATH}"
WORKDIR "${PROJECT_PATH}"

# keep some arguments as environment variables
ENV \
    CPK_PROJECT_NAME="${NAME}" \
    CPK_PROJECT_DESCRIPTION="${DESCRIPTION}" \
    CPK_PROJECT_MAINTAINER="${MAINTAINER}" \
    CPK_PROJECT_PATH="${PROJECT_PATH}" \
    CPK_PROJECT_LAUNCHERS_PATH="${PROJECT_LAUNCHERS_PATH}" \
    CPK_LAUNCHER="${LAUNCHER}"

# install apt dependencies
COPY ./dependencies-apt.txt "${PROJECT_PATH}/"
RUN cpk-apt-install ${PROJECT_PATH}/dependencies-apt.txt

# install python3 dependencies
COPY ./dependencies-py3.txt "${PROJECT_PATH}/"
RUN cpk-pip3-install ${PROJECT_PATH}/dependencies-py3.txt

# install launcher scripts
COPY ./launchers/. "${PROJECT_LAUNCHERS_PATH}/"
COPY ./launchers/default.sh "${PROJECT_LAUNCHERS_PATH}/"
RUN cpk-install-launchers "${PROJECT_LAUNCHERS_PATH}"

# copy project root
COPY ./*.cpk ./*.sh ${PROJECT_PATH}/

# copy the source code
COPY ./packages "${CPK_PROJECT_PATH}/packages"

# build catkin workspace
RUN catkin build \
    --workspace ${CPK_CODE_DIR}

# install packages dependencies
RUN cpk-install-packages-dependencies

# define default command
CMD ["bash", "-c", "launcher-${CPK_LAUNCHER}"]

# store module metadata
LABEL \
    cpk.label.current="${ORGANIZATION}.${NAME}" \
    cpk.label.project.${ORGANIZATION}.${NAME}.description="${DESCRIPTION}" \
    cpk.label.project.${ORGANIZATION}.${NAME}.code.location="${PROJECT_PATH}" \
    cpk.label.project.${ORGANIZATION}.${NAME}.base.registry="${BASE_REGISTRY}" \
    cpk.label.project.${ORGANIZATION}.${NAME}.base.organization="${BASE_ORGANIZATION}" \
    cpk.label.project.${ORGANIZATION}.${NAME}.base.project="${BASE_REPOSITORY}" \
    cpk.label.project.${ORGANIZATION}.${NAME}.base.tag="${BASE_TAG}" \
    cpk.label.project.${ORGANIZATION}.${NAME}.maintainer="${MAINTAINER}"
# <== Do not change the code above this line
# <==================================================


# install librealsense
# per Step 2 of https://github.com/IntelRealSense/realsense-ros/tree/ros1-legacy
# which points to https://github.com/IntelRealSense/librealsense/blob/master/doc/distribution_linux.md#installing-the-packages 
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-key F6E65AC044F831AC80A06380C8B3A55A6F3EFCDE || sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-key F6E65AC044F831AC80A06380C8B3A55A6F3EFCDE
RUN add-apt-repository "deb https://librealsense.intel.com/Debian/apt-repo $(lsb_release -cs) main" -u
RUN apt-get install librealsense2-dkms
RUN apt-get install librealsense2-utils
RUN apt-get install librealsense2-dev
RUN apt-get install librealsense2-dbg


RUN cd /tmp && \
  wget https://github.com/IntelRealSense/librealsense/archive/v${LIBREALSENSE_VERSION}.tar.gz && \
  tar -xvzf v${LIBREALSENSE_VERSION}.tar.gz && \
  rm v${LIBREALSENSE_VERSION}.tar.gz && \
  mkdir -p librealsense-${LIBREALSENSE_VERSION}/build && \
  cd librealsense-${LIBREALSENSE_VERSION}/build && \
  cmake .. && \
  make && \
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

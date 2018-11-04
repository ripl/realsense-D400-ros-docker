#!/bin/bash

# source user-specific ROS packages
source /code/devel/setup.bash

# run sensor node
/entrypoint.sh \
  roslaunch \
    realsense2_camera \
    rs_rgbd.launch \
      "$@"

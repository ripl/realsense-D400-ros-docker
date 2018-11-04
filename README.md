# realsense-D400-ros-docker

Docker image containing the ROS bindings for the
[Intel® RealSense™ Depth Camera D400-Series](https://software.intel.com/en-us/realsense/d400)
devices.

## How to run the camera drivers

### 1. Build the image

Run the following command from the root directory of this repository
to build the Docker image
```
docker build -t ripl/realsense-d400-ros ./
```

### 2. Run the drivers using the ROS launch file

Run the following command to run the drivers using the ROS
launch file.
```
docker run -it --net=host --privileged ripl/realsense-d400-ros roslaunch realsense2_camera rs_rgbd.launch
```

**NOTE:** The command `roslaunch realsense2_camera rs_rgbd.launch` is the
same used in the instructions of the original
[ROS wrapper from Intel](https://github.com/intel-ros/realsense) for these
cameras. Feel free to use another launch-file or change the parameters as
explained at the URL above.

### 3. (Advanced) Run the drivers using a `libbot2` deputy

Run the following command to launch a `liboot2` deputy that is responsible
for running/stopping/monitoring the drivers on behalf of a `liboot2` sheriff
process.
```
docker run -it --net=host --privileged ripl/realsense-d400-ros bot-procman-deputy --name <deputy_name>
```
where `<deputy_name>` can be any string that identifies the camera
(e.g., `camera_left_side`).

The deputy will have access to ROS and all the necessary packages. This means
that you can simply use the command `roslaunch realsense2_camera rs_rgbd.launch`
in your procman configuration. Check out the file `samples/procman.cfg` for
an example of procman configuration file that activates a realsense camera.

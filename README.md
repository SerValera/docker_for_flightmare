
# Docker Manual for **FLIGHTMARE** Installation Using ROS in Docker

## 1. Clone the Repository

```bash
git clone https://github.com/SerValera/docker_for_flightmare
```

## 2. Allow Docker GUI Access via xhost

```bash
xhost +local:docker
```

## 3. Go to Folder with Dockerfile and Build Image

Build the updated Docker image (if the Dockerfile has been changed):

```bash
cd docker_for_flightmare
sudo docker-compose build
```

## 4. Run a Container Instance from the Image  

**(Make sure you are in the `docker_for_flightmare` folder!)**

```bash
sudo docker run -it --privileged --ipc=host --net=host \
-v /tmp/.X11-unix:/tmp/.X11-unix:rw \
-v ~/.Xauthority:/home/sim/.Xauthority \
-v ./:/home/sim/workspace:rw \
-e DISPLAY=$DISPLAY -p 14570:14570/udp \
--name=docker_fm ros1_fm-drone_sim:latest bash
```

## 4. (Alternative) Run the Container with GPU Access  

**(Also from the `docker_for_flightmare` folder)**

```bash
sudo docker run -it --privileged --ipc=host --net=host \
--gpus=all \
-v /tmp/.X11-unix:/tmp/.X11-unix:rw \
--env="QT_X11_NO_MITSHM=1" \
-v ~/.Xauthority:/home/sim/.Xauthority \
-v ./:/home/sim/docker_for_flightmare:rw \
--runtime=nvidia \
-e NVIDIA_DRIVER_CAPABILITIES=all \
-e DISPLAY=$DISPLAY -p 14570:14570/udp \
--name=docker_fm ros1_fm-drone_sim:latest bash
```

## 5. To Enter the Docker Container

```bash
sudo docker exec -it docker_fm bash
```

Some useful commands
```bash
docker stop docker_fm
docker start docker_fm
docker exec -it docker_fm bash
```

---

# Installation via PIP (Tested)

Reference:  
📄 https://github.com/uzh-rpg/flightmare/wiki/Install-with-pip

# Next steps in Docker container!!! 

## 6. Become Root

```bash
sudo -i
```

## 7. Install Required Packages

```bash
apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    libzmqpp-dev \
    libopencv-dev
```

## 8. Exit Root

```bash
exit
```

## 9. Install ROS Noetic Desktop Full

Follow the instructions:  
http://wiki.ros.org/noetic/Installation/Ubuntu  

## 10. Install Gazebo

Follow the steps in:  
https://classic.gazebosim.org/tutorials?tut=install_ubuntu&cat=install

## 11. Install MiniConda

```bash
cd
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-*.sh
source ~/miniconda3/bin/activate
```

## 12. Create and Activate a Python 3.7 Environment

```bash
conda create --name ENVNAME37 python=3.7
conda activate ENVNAME37
```

## 13. Clone Flightmare

```bash
cd
git clone https://github.com/uzh-rpg/flightmare.git
```

# Troubleshooting and Fixes

## 14. Fix CMake File Issues

In `flightlib/cmake/pybind11_download.cmake`, change branch from `master` to `v2.12`  
In `flightlib/cmake/gtest_download.cmake`, change from `master` to `main`

## 15. Fix `ModuleNotFoundError`

Edit `flightmare/flightrl/setup.py`:  
Replace:

```python
packages=['rpg_baselines']
```

with:

```python
packages=['rpg_baselines', 'rpg_baselines.ppo', 'rpg_baselines.common', 'rpg_baselines.envs']
```

## 16. Install Required Python Packages

```bash
conda activate ENVNAME37
pip install protobuf==3.20.*
pip uninstall ruamel.yaml
pip install ruamel.yaml==0.16.1

# For GPU users
cd flightmare
pip install tensorflow-gpu==1.14

# For CPU-only users (alternative)
# pip install tensorflow==1.14

pip install scikit-build
```

## 17. Build and Install `flightlib`

```bash
cd ~/flightmare/flightlib
pip install .
```

All installations should complete without errors.  
If you encounter issues, check the [Flightmare GitHub Issues](https://github.com/uzh-rpg/flightmare/issues).

## 18. ROS Dependencies

On Ubuntu 20.04, replace `python-vcstool` with `python3-vcstool`:

```bash
sudo apt-get install libgoogle-glog-dev protobuf-compiler ros-noetic-octomap-msgs ros-noetic-octomap-ros ros-noetic-joy python3-vcstool
sudo apt-get install python3-pip
sudo pip install catkin-tools
```

```bash
cd workspace
mkdir -p catkin_ws/src
cd ..
catkin config --init --mkdirs --extend /opt/ros/noetic --merge-devel --cmake-args -DCMAKE_BUILD_TYPE=Release
```

## 19. Update YAML File at `flightmare/flightros/dependencies.yaml`

```yaml
repositories:
  catkin_simple:
    type: git
    url: https://github.com/catkin/catkin_simple.git
    version: master
  eigen_catkin:
    type: git
    url: https://github.com/ethz-asl/eigen_catkin.git
    version: master
  mav_comm:
    type: git
    url: https://github.com/ethz-asl/mav_comm.git
    version: master
  rotors_simulator:
    type: git
    url: https://github.com/ethz-asl/rotors_simulator.git
    version: master
  rpg_quadrotor_common:
    type: git
    url: https://github.com/uzh-rpg/rpg_quadrotor_common.git
    version: master
  rpg_single_board_io:
    type: git
    url: https://github.com/uzh-rpg/rpg_single_board_io.git
    version: master
  rpg_quadrotor_control:
    type: git
    url: https://github.com/uzh-rpg/rpg_quadrotor_control.git
    version: master
```

```bash
cd
vcs-import < ~/workspace/catkin_ws/src/flightmare/flightros/dependencies.yaml
```

## 20. Install Additional Packages

```bash
conda activate ENVNAME37
pip install empy
pip install catkin-pkg
pip install PyYAML
pip uninstall empy
pip install empy==3.3.2
```

## 21. Fix Issues Using the Following Instruction

(Source: https://github.com/ethz-asl/rotors_simulator/issues/737)

```bash
cd ~/workspace/catkin_ws/src/flightmare/flightros/rotors_simulator/rotors_hil_interface/include/rotors_hil_interface
sudo nano hil_interface.h
```

Add the following lines:

```cpp
#ifndef MAVLINK_H
  typedef mavlink::mavlink_message_t mavlink_message_t;
  typedef mavlink::mavlink_status_t mavlink_status_t;
  #include <mavlink/v2.0/common/mavlink.h>
#endif
```

## 22. Final Build

```bash
cd ~/workspace/catkin_ws
catkin_make -DPython_EXECUTABLE=/usr/bin/python3
```

## Done! You can use Flightmare following instruction:  

https://flightmare.readthedocs.io/en/latest/getting_started/readme.html
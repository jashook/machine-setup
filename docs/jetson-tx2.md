# Jetson TX2

## Install JetPack 3.3

In order to use docker, the OS needs to be updated to what is provided in JetPack 3.3 or greater.

1. In order to do this setup an Nvidia developer account at: https://developer.nvidia.com/. 
2. You can then download JetPack 3.3 at: https://developer.nvidia.com/embedded/dlc/jetpack-l4t-3_3.
3. Follow the install instructions at: https://docs.nvidia.com/jetson/archives/jetpack-archived/jetpack-33/#jetpack/3.3/install.htm%3FTocPath%3D_____3

## Setup

1. Remotely login as ubuntu@ip

Note that the following will except the SSD to be attached at /dev/sda, if there are multiple drives, or the SSD is disconnected it will not work as expected.

```sh
curl https://github.com/jashook/machine-setup/blob/master/src/jetson-tx2/setup.sh -o setup.sh

sudo bash -x setup.sh
```
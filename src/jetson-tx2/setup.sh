################################################################################
################################################################################
# 
# Module: setup.sh
#
# Notes:
#
# This is intended to be run on a jetson tx2. However there may be bits that can
# be run on any platform.
#
################################################################################
################################################################################

if [ $# -eq 0 ]; then
    echo "Please pass in a username an password."
    echo "setup.sh <username> <password>"

    exit 1
fi

username=$1
password=$2

# Create the user account
useradd -m -p $(openssl passwd -1 ${password}) ${username} -s /bin/bash

# Setup the SSD
parted /dev/sda mklabel msdos
parted /dev/sda mkpart primary 0% 100%

mkfs.ext4 /dev/sda1

# Create mountpoint

mkdir -p /ssd

# Modify fstab
blkid=$(sudo blkid | grep /dev/sda1 | awk '{print $2}' | sed 's/\"//g')

fstab_contents=$(cat /etc/fstab)

if grep -q ${blkid} ${fstab_contents}; then
    echo "Skipping modifying fstab, UUID is already present."
else
    echo -e "${blkid}\t/ssd\text4\tdefaults\t0\t0" >> /etc/fstab
fi

# Test the mount
mount -a

if [ $? -eq 0 ]; then
    # No problems continue
    echo "Mounted correctly."
else
    echo "Error mounting, the disk is setup incorrectly."
    exit 1
fi

# Install all dependencies.

# Install docker
apt-get update
apt-get upgrade -f -y

apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

if ! [ -x "$(command -v docker)" ]; then
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

    add-apt-repository \
    "deb [arch=arm64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable"

    apt-get update
    apt-get install -y docker.ce

    groupadd docker

    usermod -aG docker $username
fi

usermod -aG docker $username

# Install the rest of the dependencies

apt-get update && apt-get install -y \
    vim \
    htop \
    cmake \
    llvm-3.9 \
    clang-3.9 \
    lldb-3.9 \
    liblldb-3.9-dev \
    libunwind8 \
    libunwind8-dev \
    gettext \
    libicu-dev \
    liblttng-ust-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    libnuma-dev \
    libkrb5-dev \
    python3 \
    git

# Setup ownership of the /ssd drive
chown -R ${username}:${username} /ssd

# Add $username to the sudo list
usermod -aG sudo $username

# Set all default nvidia usernames to the same password passed.
echo nvidia:${password} | sudo chpasswd
echo ubuntu:${password} | sudo chpasswd

# Disable auto-login for the nvidia account
sed -i '2d' /etc/lightdm/lightdm.conf.d/50-nvidia.conf 

# Delete the nvidia user
userdel -r -f nvidia

# Reboot
reboot
#!/bin/bash
set -ex
#sed -i 's/^# //g'  /etc/apt/sources.list
dis_codename="$(cat /etc/lsb-release  | grep DISTRIB_CODENAME | cut -d'=' -f2)"
cat <<EOF | sudo tee /etc/apt/sources.list.d/ubuntu-"$dis_codename"-proposed.list
# Enable Ubuntu proposed archive
deb http://archive.ubuntu.com/ubuntu/ $dis_codename-proposed restricted main multiverse universe
deb-src http://archive.ubuntu.com/ubuntu/ $dis_codename-proposed restricted main multiverse universe
deb-src http://archive.ubuntu.com/ubuntu/ $dis_codename-updates restricted main multiverse universe
EOF
sudo apt-get update
NVIDIA_DEB=$(apt-cache search  "^nvidia-driver-[0-9][0-9][0-9]" | cut -d' ' -f1 | sort -r | head -n1)
apt-get --download-only source "$NVIDIA_DEB"
tar xvf nvidia-graphics-drivers-*amd64.tar.gz
$(find . -name "*.run") -x
cat $(find . -name "supported-gpus.json")

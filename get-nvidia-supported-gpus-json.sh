#!/bin/bash
set -ex
#sed -i 's/^# //g'  /etc/apt/sources.list
dis_codename="$(grep DISTRIB_CODENAME /etc/lsb-release| cut -d'=' -f2)"
cat <<EOF | sudo tee /etc/apt/sources.list.d/ubuntu-"$dis_codename"-proposed.list
# Enable Ubuntu proposed archive
deb http://archive.ubuntu.com/ubuntu/ $dis_codename-proposed restricted main multiverse universe
deb-src http://archive.ubuntu.com/ubuntu/ $dis_codename-proposed restricted main multiverse universe
deb-src http://archive.ubuntu.com/ubuntu/ $dis_codename-updates restricted main multiverse universe
EOF
sudo apt-get update
WORK_DIR=$PWD
while read -r NVIDIA_DEB; do
    echo "deal with $NVIDIA_DEB"
    json_file="$dis_codename"-"$NVIDIA_DEB"-supported-gpus.json
    modaliases_file="$dis_codename"-"$NVIDIA_DEB"-modaliases
    apt-cache show "$NVIDIA_DEB" | grep -q Modaliases || continue
    apt-cache show "$NVIDIA_DEB" | grep  Modaliases | sed  's/[, \)\(]/\n/g' |grep pci > "$WORK_DIR"/"$modaliases_file"
    tmpfolder="$(mktemp -d)"
    pushd "$tmpfolder" || exit 0
    apt-get --download-only source "$NVIDIA_DEB"
    tar xvf nvidia-graphics-drivers-*amd64.tar.gz
    $(find . -name "*.run") -x
    cp "$(find . -name "supported-gpus.json")" "$WORK_DIR"/"$json_file"
    rm -rf "$tmpfolder"
    popd
done < <(apt-cache search  "^nvidia-driver-[0-9][0-9][0-9]" | cut -d' ' -f1 | grep -v server | sort -r | head -n4)

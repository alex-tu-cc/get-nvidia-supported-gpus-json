#!/bin/bash
set -ex
url="https://alex-tu-cc.github.io/get-nvidia-supported-gpus-json/"
#sed -i 's/^# //g'  /etc/apt/sources.list
dis_codename="$(grep DISTRIB_CODENAME /etc/lsb-release| cut -d'=' -f2)"
cat <<EOF | sudo tee /etc/apt/sources.list.d/ubuntu-"$dis_codename"-proposed.list
# Enable Ubuntu proposed archive
deb http://archive.ubuntu.com/ubuntu/ $dis_codename-proposed restricted main multiverse universe
deb-src http://archive.ubuntu.com/ubuntu/ $dis_codename-proposed restricted main multiverse universe
deb-src http://archive.ubuntu.com/ubuntu/ $dis_codename-updates restricted main multiverse universe
EOF
sudo apt-get update
sudo apt-get install -y jq
WORK_DIR=$PWD
while read -r NVIDIA_DEB; do
    echo "deal with $NVIDIA_DEB"
    tmpfolder="$(mktemp -d)"
    pushd "$tmpfolder" || exit 0
    apt-get --download-only source "$NVIDIA_DEB"
    tar xvf nvidia-graphics-drivers-*amd64.tar.gz
    $(find . -name "*.run") -x
    json_file="$dis_codename"-"$NVIDIA_DEB"-supported-gpus.json
    jq < "$(find . -name "supported-gpus.json")" > "$WORK_DIR"/"$json_file"
    echo "[$json_file]($url/$json_file)  " >> "$WORK_DIR"/index.md
    rm -rf "$tmpfolder"
    popd
    #jq ". += {\"version\":\"$NVIDIA_DEB\"}" $(find . -name "supported-gpus.json") > $NVIDIA_DEB-supported-gpus.json
done < <(apt-cache search  "^nvidia-driver-[0-9][0-9][0-9]" | cut -d' ' -f1 | grep -v server | sort -r | head -n4)


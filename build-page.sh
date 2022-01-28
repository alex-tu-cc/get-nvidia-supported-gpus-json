#!/bin/bash

set -ex
url="https://alex-tu-cc.github.io/get-nvidia-supported-gpus-json"
#$1 : input folder
#$2 : output folder
while read -r json_file_path; do
    json_file="$(basename "$json_file_path")"
    jq < "$json_file_path" > "$2/$json_file"
    echo "[$json_file]($url/$json_file)  " >> "$2"/index.md
    #modaliases_file_path="$(echo "$json_file_path" | sed 's/supported-gpus.json/modaliases/g')"
    modaliases_file_path="${json_file_path//supported-gpus.json/modaliases}"
    modaliases_file="$(basename "$modaliases_file_path")"
    cp "$modaliases_file_path" "$2"/
    echo "[$modaliases_file]($url/$modaliases_file)  " >> "$2"/index.md
done< <(find "$1" -name "*.json")

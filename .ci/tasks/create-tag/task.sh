#!/bin/sh
build_version=$(cat source/.git/ref)
build_date=$(date +'%s')

cat <<EOF > tag/image
${build_date}-${build_version:0:7}
EOF
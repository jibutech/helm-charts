#!/bin/bash -e

ys1000Repo=registry.cn-shanghai.aliyuncs.com/jibudata

ys1000Images=(
    ${ys1000Repo}/qiming-operator
    ${ys1000Repo}/mig-ui
    ${ys1000Repo}/mig-discovery
    ${ys1000Repo}/mig-controller
    ${ys1000Repo}/velero-installer
    ${ys1000Repo}/cron
    ${ys1000Repo}/helm-tool
    ${ys1000Repo}/self-restore
    ${ys1000Repo}/data-mover
)

if [ $# -lt 2 ];then
  echo "invalid parameters"
  echo "$0 <src-tag> <dst-tag> [--push]"
  exit 1
fi

src_tag=$1
dst_tag=$2

for image in "${ys1000Images[@]}"
do

  src_img=${image}:${src_tag}
  dst_img=${image}:${dst_tag}

  docker pull $src_img > /dev/null
  if [ $? -ne 0 ];then
    echo "failed to docker pull $src_img, abort..."
    exit 2
  fi

  docker tag $src_img $dst_img
  if [ $? -ne 0 ];then
    echo "failed to docker tag $src_img to $dst_img"
    exit 1
  else
    echo "docker tag $src_img to $dst_img done!"
    echo
  fi

done

if [ $# -eq 2 ];then
  exit 0
fi

# do push new image
for image in "${ys1000Images[@]}"
do

  dst_img=${image}:${dst_tag}

  docker push $dst_img
  if [ $? -ne 0 ];then
    echo "failed to docker push $dst_img"
    exit 1
  else
    echo "docker push $dst_img done!"
    echo
  fi

done




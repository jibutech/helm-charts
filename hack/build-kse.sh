#!/bin/bash -e

export YS1000_VERSION=$(cat charts/ys1000/Chart.yaml | yq '.version')

# customize values.yaml
if [[ "$1" == "none-logo" ]];then
    yq eval --inplace ".components.portal.image.tag=\"${YS1000_VERSION}-none-logo\"" charts/ys1000/values.yaml
fi
yq eval --inplace '.migconfig.deploymentMode="kse-extension"' charts/ys1000/values.yaml
yq eval --inplace '.migconfig.deletionPolicy.removeResources=false' charts/ys1000/values.yaml
yq eval --inplace '.migconfig.deletionPolicy.cancelRunningJobs=true' charts/ys1000/values.yaml
yq eval --inplace '.mysql.primary.persistence.enabled=true' charts/ys1000/values.yaml
yq eval --inplace '.mysql.primary.persistence.storageClass=null' charts/ys1000/values.yaml
yq eval --inplace '.featureGates.Tenant=true' charts/ys1000/values.yaml

# customize values.yaml
if [[ "$1" == "none-logo" ]];then
    yq eval --inplace ".images |= map(select(.repo == \"mig-ui\").tag=\"${YS1000_VERSION}-none-logo\")" charts/ys1000/images.yaml
fi

# package ys1000-${YS1000_VERSION}.tgz and move to kse charts dir
helm package charts/ys1000
mv ys1000-${YS1000_VERSION}.tgz charts/ys1000-kse/charts/
# update version
yq -i -e '.version |= env(YS1000_VERSION)' charts/ys1000-kse/extension.yaml
yq -i -e '.version |= env(YS1000_VERSION)' charts/ys1000-kse/charts/frontend/Chart.yaml
yq -i -e '.appVersion |= env(YS1000_VERSION)' charts/ys1000-kse/charts/frontend/Chart.yaml
yq -i -e '.dependencies |= map(.version |= env(YS1000_VERSION))' charts/ys1000-kse/extension.yaml
# update images list
cat charts/ys1000/images.yaml| env TAG_DEFAULT=$(cat charts/ys1000/values.yaml|  yq eval '.imageBase.tag' -r - ) RESITRY_PATH=$(cat charts/ys1000/images.yaml|  yq eval '.ys1000Repo' -r - ) yq eval '.images[] | [env(RESITRY_PATH) + "/" + .repo + ":" + (.tag // env(TAG_DEFAULT))]' | yq -i -e '.images |= (load("/dev/stdin"))' charts/ys1000-kse/extension.yaml
# build extension
KSE_PKG_NAME=ys1000-kse-${YS1000_VERSION}.tgz
if [[ "$1" == "none-logo" ]];then
    KSE_PKG_NAME=ys1000-kse-${YS1000_VERSION}-none-logo.tgz
fi

(cd charts && rm -f ys1000-${YS1000_VERSION}.tgz && ksbuilder package ys1000-kse && mv ys1000-${YS1000_VERSION}.tgz ../${KSE_PKG_NAME})

# we are safe to restore what we customized
rm charts/ys1000-kse/charts/ys1000-${YS1000_VERSION}.tgz
git restore ys1000-${YS1000_VERSION}.tgz || :
git restore charts/ys1000/images.yaml
git restore charts/ys1000/values.yaml
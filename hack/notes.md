# steps to build release chart

1. locate to root dir of helm-charts repo

2. git branch to specific branch, such as v2.7.0

3. do git merge from main first (note: git pull to keep main to latest)

4. run following commands to generate helm chart package and update index.yaml

    ```bash
    cd helm-charts

    helm package charts/ys1000
    helm repo index . --url  https://jibutech.github.io/helm-charts/

    # update helm index
    mkdir -p new_charts
    helm package  -d  new_charts charts/ys1000 
    helm repo index --url  https://jibutech.github.io/helm-charts/ --merge ./index.yaml new_charts
    cp new_charts/* .
    rm -rf new_charts
    ```

5. push to specific release branch and merge to main

6. wait for 5 or 10 minutes and then resync this repo and check the new release is available

```bash
# initial step only
helm repo add qiming https://jibutech.github.io/helm-charts/

# update
helm repo update
helm search repo qiming
```

## tips

```bash
# update helm dependency
➜  $ pwd
helm-charts/charts
➜  $ export HTTPS_PROXY=<your proxy>
➜  $ helm dependency update ys1000/
```

## steps to build KSE extension package

1. locate to root dir of helm-charts repo

2. run following commands to generate package

    ```bash
    yq eval --inplace '.migconfig.deploymentMode="kse-extension"' charts/ys1000/values.yaml
    yq eval --inplace '.migconfig.deletionPolicy.removeResources=true' charts/ys1000/values.yaml
    yq eval --inplace '.migconfig.deletionPolicy.cancelRunningJobs=true' charts/ys1000/values.yaml
    yq eval --inplace '.mysql.primary.persistence.enabled=true' charts/ys1000/values.yaml
    yq eval --inplace '.mysql.primary.persistence.storageClass=null' charts/ys1000/values.yaml
    helm package charts/ys1000
    git restore charts/ys1000/values.yaml
    # replace below 3.8.0 with correct release
    mv ys1000-3.8.0.tgz charts/ys1000-kse/charts/
    (cd charts && rm -f ys1000-3.8.0.tgz && ksbuilder package ys1000-kse && mv ys1000-3.8.0.tgz ../ys1000-kse-3.8.0.tgz)
    ```

3. (optional) publish to development kubesphere environment and test

```bash
ksbuilder publish ys1000-kse-3.8.0.tgz
```

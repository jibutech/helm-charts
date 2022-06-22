# steps to build release chart

1. locate to root dir of helm-charts repo

2. git branch to specific branch, such as v2.7.0

3. do git merge from main first (note: git pull to keep main to latest)

4. run following commands to generate helm chart package and update index.yaml 

```
cd helm-charts

helm package charts/qiming-operator
helm repo index . --url  https://jibutech.github.io/helm-charts/
```
5. correct index.yaml for only new helm chart package

6. push to specific release branch and merge to main

7. wait for 5 or 10 minutes and then resync this repo and check the new release is available

```
# initial step only
helm repo add qiming https://jibutech.github.io/helm-charts/

# update
helm repo update
helm search repo qiming
```


# Yinhe Helm Chart

## Introduction

This chart creates yinhe data protection components on a Kubernetes cluster using the Helm package manager.

## Prerequisites

- Kubernetes 1.18 or above
- Helm >= 3.5

## Installation 

1. Add helm repo as follows:

   ```bash
   helm repo add jibutech https://jibutech.github.io/helm-charts/
   ```

   You can then run `helm search repo jibutech` to see the charts, for example:

   ```bash
   [root@~]# helm search repo jibutech
   NAME             CHART VERSION   APP VERSION     DESCRIPTION
   jibutech/ys1000  3.4.0           3.4.0           ys1000 provides data protection for cloud nativ...
   ```

2. Install helm chart **ys1000** 

   **NOTE**: if any previous ys1000 was installed , please do crd update before installation or upgrade by:
   ```
   kubectl apply -k 'github.com/jibutech/helm-charts/charts/ys1000?ref=release-3.4.0'
   ```

   Option 1: CLI commands

      Specify the necessary values using the `--set key=value[,key=value] `argument to helm install.

      For example:

      ```bash
      helm install jibutech/ys1000 --namespace ys1000 \ 
          --create-namespace --generate-name --set service.type=NodePort \
          --set s3Config.provider=aws --set s3Config.name=minio \
          --set s3Config.accessKey=minio --set s3Config.secretKey=passw0rd \
          --set s3Config.bucket=test --set s3Config.s3Url=http://172.16.0.10:30170

      NAME: ys1000-1635128765
      LAST DEPLOYED: Mon Oct 20 10:26:10 2021
      NAMESPACE: ys1000
      STATUS: deployed
      REVISION: 1

      NOTES:
      Check the application status Ready by running these commands:
        NOTE: It may take a few minutes to pull docker images.
              You can watch the status of by running `kubectl --namespace ys1000 get migconfigs.migration.yinhestor.com -w`
        kubectl --namespace ys1000 get migconfigs.migration.yinhestor.com
      ```

   Option 2: YAML file

      Add/update the necessary values by changing the values.yaml from this repository.

      **NOTES**: s3Config.[provider, name, accessKey, secretKey, bucket, s3Url] are required to set before `helm install`, then run,

      ```bash
      # generate default values.yaml
      helm inspect values jibutech/ys1000 --version v3.4.0 > values.yaml
      
      # fill required arguments in values.yaml
      # install by specifying the values.yaml
      helm install jibutech/ys1000 --namespace ys1000 -f values.yaml --generate-name
      ```

3. Check the installed helm chart

   a. Use command `helm list -n <NAMESPACE> ` to list the installed helm chart.

      For example:

      ```bash
      [root@~]# helm list -n ys1000
      NAME                    NAMESPACE      REVISION         UPDATED                                   STATUS      CHART                APP VERSION
      ys1000-1683716371       ys1000         11               2023-05-26 17:53:15.116051313 +0800 CST   deployed    ys1000-3.4.0         3.4.0
      ```

   b. wait for the installation status to be ready. For example:

      ```bash
      [root@~]# kubectl --namespace ys1000 get migconfigs.migration.yinhestor.com
      NAME        AGE     PHASE   CREATED AT             VERSION
      jibutech-config   2d2h   Ready   2021-10-20T06:21:20Z  v3.4.0
      ```

4. Access web UI

   a. get the application URL by running these commands:

    ```bash
    [root@~]# export NODE_PORT=$(kubectl get --namespace ys1000 -o jsonpath="{.spec.ports[0].nodePort}" services ui-service-default )
    [root@~]# export NODE_IP=$(kubectl get nodes --namespace ys1000 -o jsonpath="{.items[0].status.addresses[0].address}")
    [root@~]# echo http://$NODE_IP:$NODE_PORT
    http://192.168.0.2:31151
    ```

    b. Login web UI

      There are two ways to login the web UI.

    1. With the kubeconfig by running these commands

    ```bash
    kubectl config view --flatten
    ```
    or
    ```bash
    cat ~/.kube/config
    ```

    2. With username/password

        The default username is `admin` and default password is `passw0rd`.
        The password can be set during installation by flag,

    ```bash
    --set migconfig.UIadminPassword=<your new password>
    ```

## Upgrade

1. Upgrade to a chart version by specifying `--version=<CHART VERSION>` through `helm upgrade`
   
   **NOTE**: please do crd update before upgrade by:
   ```
   kubectl apply -k 'github.com/jibutech/helm-charts/charts/ys1000?ref=release-3.4.0'
   ```
   
   If a value needs to be added or changed, you may do so with the `--set key=value[,key=value] ` argument. 

   An example:

   ```bash
   [root@~]helm upgrade ys1000-1618982398 jibutech/ys1000 --namespace ys1000 --reuse-values --version=3.3.2
   ```

## Uninstallation

1. Uninstall **ys1000** helm chart

   Specify the current release name and namespace to uninstall.

   ```bash
   [root@~]# helm list -n ys1000
   NAME                    NAMESPACE       REVISION        UPDATED                                  STATUS      CHART                APP VERSION
   ys1000-1683716371       ys1000          11              2023-05-26 17:53:15.116051313 +0800 CST  deployed    ys1000-3.4.0         3.4.0
   
   [root@~]# helm uninstall ys1000-1618982398 -n ys1000
   release "ys1000-1618982398" uninstalled
   ```

   **NOTES**: velero components and resources would be still kept to avoid data loss.

   In case you still want to remove velero and history backup records, run the commands:

   ```bash
   [root@~]# kubectl delete ns ys1000
   namespace "ys1000" deleted
   
   [root@~]# k delete clusterrolebindings.rbac.authorization.k8s.io velero-ys1000
   clusterrolebinding.rbac.authorization.k8s.io "velero-ys1000" deleted
   
   [root@~]# kubectl delete crds -l component=velero
   customresourcedefinition.apiextensions.k8s.io "backups.velero.io" deleted
   customresourcedefinition.apiextensions.k8s.io "backupstoragelocations.velero.io" deleted
   customresourcedefinition.apiextensions.k8s.io "deletebackuprequests.velero.io" deleted
   customresourcedefinition.apiextensions.k8s.io "downloadrequests.velero.io" deleted
   customresourcedefinition.apiextensions.k8s.io "podvolumebackups.velero.io" deleted
   customresourcedefinition.apiextensions.k8s.io "podvolumerestores.velero.io" deleted
   customresourcedefinition.apiextensions.k8s.io "resticrepositories.velero.io" deleted
   customresourcedefinition.apiextensions.k8s.io "restores.velero.io" deleted
   customresourcedefinition.apiextensions.k8s.io "schedules.velero.io" deleted
   customresourcedefinition.apiextensions.k8s.io "serverstatusrequests.velero.io" deleted
   customresourcedefinition.apiextensions.k8s.io "volumesnapshotlocations.velero.io" deleted
   ```

## Configuration

The following table lists the required parameters during installation.

| Parameter               | Description                           | Example                                                    |
| ----------------------- | ----------------------------------    | ---------------------------------------------------------- |
| namespace          |  Namespace of yinhe software     |  --namespace ys1000                           |
| create-namespace   |  Create new namespace               |  --create-namespace
| generate-name      |  Whether create new name otherwise user need to specify the name |   --generate-name
| service.type       |  Service type                        |   --set service.type=NodePort
| s3Config.provider  |   S3 provider               |   --set s3Config.provider=aws
| s3Config.name      |  Backup storage name |   --set s3Config.name=minio
| s3Config.accessKey |    Access key of S3              |   --set s3Config.accessKey=minio
| s3Config.secretKey |    Secret key of S3        |    --set s3Config.secretKey=passw0rd
| s3Config.bucket    |   S3 bucket name              |   --set s3Config.bucket=test
| s3Config.s3Url     |    S3 URL                          |   --set s3Config.s3Url=http://172.16.0.10:30170
| migconfig.UIadminPassword |  set password                          | --set migconfig.UIadminPassword=`<your password>`         |

## Acknowledgement

YS1000 functionalities are based on [Velero](https://github.com/vmware-tanzu/velero) and [other open source projects](https://github.com/jibutech/helm-charts/blob/main/credits.md).


# Yinhe Helm Chart

## Introduction

This chart creates yinhe data protection components on a Kubernetes cluster using the Helm package manager.

## Prerequisites

- Kubernetes 1.18 or above
- Helm >= 3.5

## Installation 

1. Add helm repo as follows:

   ```bash
   $ helm repo add qiming https://jibutech.github.io/helm-charts/
   ```

   You can then run `helm search repo qiming` to see the charts, for example:

   ```bash
   [root@test-master ~]# helm search repo qiming
   NAME                  	CHART VERSION	APP VERSION	DESCRIPTION
   qiming/qiming-operator  2.6.1           2.6.1           ys1000 provides data protection for cloud nativ...
   ```

2. Install helm chart **qiming-operator** 

   **NOTE**: if any previous ys1000 was installed , please do crd update before installation or upgrade by:
   ```
   kubectl apply -k 'github.com/jibutech/helm-charts/charts/qiming-operator/crds'
   ```

   Option 1: CLI commands

      Specify the necessary values using the `--set key=value[,key=value] `argument to helm install.

      For example:

      ```bash
      helm install qiming/qiming-operator --namespace qiming-migration \ 
          --create-namespace --generate-name --set service.type=NodePort \
          --set s3Config.provider=aws --set s3Config.name=minio \
          --set s3Config.accessKey=minio --set s3Config.secretKey=passw0rd \
          --set s3Config.bucket=test --set s3Config.s3Url=http://172.16.0.10:30170

      NAME: qiming-operator-1635128765
      LAST DEPLOYED: Mon Oct 20 10:26:10 2021
      NAMESPACE: qiming-migration
      STATUS: deployed
      REVISION: 1

      NOTES:
      Check the application status Ready by running these commands:
        NOTE: It may take a few minutes to pull docker images.
              You can watch the status of by running `kubectl --namespace qiming-migration get migconfigs.migration.yinhestor.com -w`
        kubectl --namespace qiming-migration get migconfigs.migration.yinhestor.com
      ```

   Option 2: YAML file

      Add/update the necessary values by changing the values.yaml from this repository.

      **NOTES**: s3Config.[provider, name, accessKey, secretKey, bucket, s3Url] are required to set before `helm install`, then run,

      ```bash
      # generate default values.yaml
      helm inspect values  qiming/qiming-operator > values.yaml
      
      # fill required arguments in values.yaml
      # install by specifying the values.yaml
      helm install qiming/qiming-operator --namespace qiming-migration -f values.yaml --generate-name
      ```

3. Check the installed helm chart

   a. Use command `helm list -n <NAMESPACE> ` to list the installed helm chart.

      For example:

      ```bash
      [root@remote-dev ~]# helm list -n qiming-migration
      NAME           	NAMESPACE       	REVISION	UPDATED                                	STATUS  	CHART                	APP VERSION
      qiming-operator	qiming-migration	1       	2021-10-20 14:21:19.974930606 +0800 CST	deployed	qiming-operator-2.0.3	2.0.3
      ```

   b. wait for the installation status to be ready. For example:

      ```bash
      [root@remote-dev ~]# kubectl --namespace qiming-migration get migconfigs.migration.yinhestor.com
      NAME        AGE     PHASE   CREATED AT             VERSION
      qiming-config   2d2h   Ready   2021-10-20T06:21:20Z  v2.0.3
      ```

4. Access web UI

   a. get the application URL by running these commands:

    ```bash
    [root@remote-dev ~]# export NODE_PORT=$(kubectl get --namespace qiming-migration -o jsonpath="{.spec.ports[0].nodePort}" services ui-service-default )
    [root@remote-dev ~]# export NODE_IP=$(kubectl get nodes --namespace qiming-migration -o jsonpath="{.items[0].status.addresses[0].address}")
    [root@remote-dev ~]# echo http://$NODE_IP:$NODE_PORT
    http://192.168.0.2:31151
    ```

    b. Login web UI

      There are two ways to login the web UI.

    1. with the token by running these commands

    ```bash
    export SECRET=$(kubectl -n qiming-migration get secret | (grep qiming-operator |grep -v helm || echo "$_") | awk '{print $1}')
    export TOKEN=$(kubectl -n qiming-migration describe secrets $SECRET |grep token: | awk '{print $2}')
            echo $TOKEN
    ```

    2. with username/password

        The default username is `admin` and default password is `passw0rd`.
        The password can be set during installation by flag,

    ```bash
    --set migconfig.UIadminPassword=<your new password>
    ```

## Upgrade

1. Upgrade to a chart version by specifying `--version=<CHART VERSION>`  through `helm upgrade`
   
   **NOTE**: please do crd update before upgrade by:
   ```
   kubectl apply -k 'github.com/jibutech/helm-charts/charts/qiming-operator/crds'
   ```
   
   If a value needs to be added or changed, you may do so with the `--set key=value[,key=value] ` argument. 

   An example:

   ```bash
   [root@remote-dev ~]helm upgrade qiming-operator-1618982398 qiming/qiming-operator --namespace qiming-migration --reuse-values --version=2.0.3
   ```

## Uninstallation

1. Uninstall **qiming-operator** helm chart

   Specify the current release name and namespace to uninstall.

   ```bash
   [root@remote-dev ~]# helm list -n qiming-migration
   NAME                      	NAMESPACE       	REVISION	UPDATED                                	STATUS  	CHART                	APP VERSION
   qiming-operator-1618982398	qiming-migration	4       	2021-04-21 13:41:27.365865385 +0800 CST	deployed	qiming-operator-0.2.1	0.2.1
   
   [root@remote-dev ~]# helm uninstall qiming-operator-1618982398 -n qiming-migration
   release "qiming-operator-1618982398" uninstalled
   ```

   **NOTES**: velero components and resources would be still kept to avoid data loss.

   In case you still want to remove velero and history backup records, run the commands:

   ```bash
   [root@remote-dev ~]# kubectl delete ns qiming-migration
   namespace "qiming-migration" deleted
   
   [root@remote-dev ~]# k delete clusterrolebindings.rbac.authorization.k8s.io velero-qiming-migration
   clusterrolebinding.rbac.authorization.k8s.io "velero-qiming-migration" deleted
   
   [root@remote-dev ~]# kubectl delete crds -l component=velero
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
| namespace          |  Namespace of yinhe software     |  --namespace qiming-migration                           |
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
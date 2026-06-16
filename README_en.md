# YS1000 Helm Chart

## Introduction

This chart creates yinhe data protection components on a Kubernetes cluster using the Helm package manager.

## Prerequisites

- Kubernetes 1.16 or above
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

   ```bash
   kubectl apply -k 'github.com/jibutech/helm-charts/charts/ys1000'
   ```

   In production environment, it is recommended to specify mysql.primary.persistence.enabled=true and storageClass (unless defaultStorageClass is specified in the cluster).

   Option 1: CLI commands

   Specify the necessary values using the `--set key=value[,key=value] `argument to helm install.

   For example:

   ```bash
   helm install ys1000 jibutech/ys1000 --create-namespace --namespace ys1000 --set mysql.primary.persistence.enabled=true --set mysql.primary.persistence.storageClass=<storage-class-name>
   NAME: ys1000
   LAST DEPLOYED: Thu Sep 21 03:08:42 2023
   NAMESPACE: ys1000
   STATUS: deployed
   REVISION: 1
   TEST SUITE: None
   NOTES:
   1. Check the application status Ready by running these commands:
   NOTE: It may take a few minutes to pull pod images.
         You can watch the status of by running
   kubectl --namespace ys1000 get pod -w

   2. After status is ready, get the application URL by running these commands:
   export NODE_PORT=$(kubectl get --namespace ys1000 -o jsonpath="{.spec.ports[0].nodePort}" services ui-service-default )
   export NODE_IP=$(kubectl get nodes --namespace ys1000 -o jsonpath="{.items[0].status.addresses[0].address}")
   echo http://$NODE_IP:$NODE_PORT

   3. Login web UI with credentials: admin/passw0rd
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

   b. Login web UI with username/password

   The default username is `admin` and default password is `passw0rd`.
   The password can be set during installation by flag,

   ```bash
   --set migconfig.UIadminPassword=<your new password>
   ```

## Upgrade

1. Upgrade to a chart version by specifying `--version=<CHART VERSION>` through `helm upgrade`

   **NOTE**: please do crd update before upgrade by:

   ```
   kubectl apply -k 'github.com/jibutech/helm-charts/charts/ys1000'
   ```

   If a value needs to be added or changed, you may do so with the `--set key=value[,key=value] ` argument.

   An example:

   ```bash
   [root@~]helm upgrade ys1000-1618982398 jibutech/ys1000 --namespace ys1000 --reuse-values --version=3.3.2
   ```

## Uninstall

### Keep data uninstall

If you need to keep the current backup configuration and backup data, please use the native helm delete to delete the ys1000 resources.

```bash
# Assume that ys1000 is installed in ys1000 ns
helm delete ys1000 -n ys1000
```

### Clean data uninstall

From v3.4.0, ys1000 provides self-cleanup function, please use the following methods to clean data and uninstall ys1000.

1. Copy yscli command from ys1000 deployment namespace, please refer to the following example:

   ```bash
   # get ys1000 operator pod
   ❯ kubectl -n ys1000-v3 get pods -l app=qiming-operator
   NAME                      READY   STATUS    RESTARTS   AGE
   ys1000-5b55f866d4-k445g   1/1     Running   0          39s

   # copy yscli command and set execute permission
   ❯ kubectl -n ys1000-v3 cp ys1000-5b55f866d4-k445g:/bin/yscli ./yscli
   tar: Removing leading '/' from member names

   ❯ chmod +x yscli

   ❯ ./yscli version
   version.info{Version:"v3.5.2", GitVersion:"v3.5.2-7+70d2d7e7d0ec2b", GitCommit:"70d2d7e7d0ec2b1a9687e9a5607f19e196ea3165", GitTreeState:"clean", BuildDate:"2023-10-17T06:52:28Z", GoVersion:"go1.20.4", Compiler:"gc", Platform:"linux/amd64"}
   ```

2. Specify the ys1000 operator pod kubeconfig and namespace to run yscli cleanup command:

   ```bash
   # Attention: when data is large or the environment is slow, the above command may encounter timeout error, please run the command again to try and verify the deletion completion.
   ❯ ./yscli cleanup --kubeconfig /root/.kube/ys1000-kubeconfig.yaml -n ys1000-v3
   2023-09-21T06:36:29Z    INFO    Start to delete resources
   2023-09-21T06:36:29Z    INFO    Force deleting all resources
   2023-09-21T06:36:30Z    INFO    Deleting migConfig resources
   ...
   2023-09-21T06:36:31Z    INFO    Deleting cluster resources
   2023-09-21T06:36:31Z    INFO    Deleting CRDs
   2023-09-21T06:36:31Z    INFO    Finish to cleanup resources

   ```

3. Use `helm uninstall` to uninstall ys1000, please refer to the following example:

   ```bash
   ❯ helm uninstall ys1000 -n ys1000-v3
   These resources were kept due to the resource policy:
   [Migconfig] qiming-config

   release "ys1000" uninstalled

   ❯ kubectl delete ns ys1000-v3
   namespace "ys1000-v3" deleted
   ```

4. Delete the backup engine namespace

   ```bash
   kubectl delete ns qiming-backend
   ```

   Attention: if the backup engine namespace is in the `Terminating` state，run `kubectl get ns <ns-name> -oyaml` to check the resources that are not deleted.
   解决方法请参考如下示例，或联系相关技术支持人员:

   ```bash
   ❯ kubectl get ns
   NAME                STATUS        AGE
   ...
   qiming-backend      Terminating   97d
   ...

   ❯ kubectl get ns qiming-backend -oyaml
   apiVersion: v1
   kind: Namespace
   metadata:
   annotations:
      kubectl.kubernetes.io/last-applied-configuration: |
         {"metadata":{"name":"qiming-backend","creationTimestamp":null},"spec":{},"status":{}}
   creationTimestamp: "2023-07-11T15:41:51Z"
   deletionTimestamp: "2023-10-17T13:16:59Z"
   labels:
      kubernetes.io/metadata.name: qiming-backend
   name: qiming-backend
   resourceVersion: "98318905"
   uid: 168e830b-4bb8-44f9-8b49-07f12cca5f51
   spec:
   finalizers:
   - kubernetes
   status:
   conditions:
   - lastTransitionTime: "2023-10-17T13:17:05Z"
      message: All resources successfully discovered
      reason: ResourcesDiscovered
      status: "False"
      type: NamespaceDeletionDiscoveryFailure
   - lastTransitionTime: "2023-10-17T13:17:05Z"
      message: All legacy kube types successfully parsed
      reason: ParsedGroupVersions
      status: "False"
      type: NamespaceDeletionGroupVersionParsingFailure
   - lastTransitionTime: "2023-10-17T13:17:05Z"
      message: All content successfully deleted, may be waiting on finalization
      reason: ContentDeleted
      status: "False"
      type: NamespaceDeletionContentFailure
   - lastTransitionTime: "2023-10-17T13:17:05Z"
      message: 'Some resources are remaining: exporthandlers.agent.jibudata.com has
         2 resource instances'
      reason: SomeResourcesRemain
      status: "True"
      type: NamespaceContentRemaining
   - lastTransitionTime: "2023-10-17T13:17:05Z"
      message: 'Some content in the namespace has finalizers remaining: ys.jibudata.com/exporthandler-protection
         in 2 resource instances'
      reason: SomeFinalizersRemain
      status: "True"
      type: NamespaceFinalizersRemaining
   phase: Terminating

   # Attention: the backup engine namespace is in the `Terminating` state, please check the resources that are not deleted.
   ❯ kubectl -n qiming-backend get exporthandlers.agent.jibudata.com
   NAME                     AGE
   de-pvc-only-1690858815   77d
   de-pvc-only-1691396796   71d

   # Use kubectl to patch to remove the finalizer configuration
   ❯ kubectl -n qiming-backend patch exporthandlers.agent.jibudata.com  de-pvc-only-1690858815  -p '{"metadata":{"finalizers":null}}' --type=merge
   exporthandler.agent.jibudata.com/de-pvc-only-1690858815 patched
   ❯ kubectl -n qiming-backend patch exporthandlers.agent.jibudata.com  de-pvc-only-1691396796  -p '{"metadata":{"finalizers":null}}' --type=merge
   exporthandler.agent.jibudata.com/de-pvc-only-1691396796 patched

   # Attention: the backup engine namespace is in the `Terminating` state, please check the resources that are not deleted.
   ❯ kubectl get ns qiming-backend
   Error from server (NotFound): namespaces "qiming-backend" not found
   ```

## Configuration

This table lists the configuration parameters required for the backup engine:

| Parameter Name                         | Description                                                         | Example                                                      |
| -------------------------------------- | ------------------------------------------------------------------- | ------------------------------------------------------------ |
| components.portal.serviceType          | Service type (optional, default: NodePort)                          | --set components.portal.serviceType=NodePort                 |
| featureGates.EtcdStub                  | Enable etcd stub backup feature (optional, default: false)          | --set featureGates.EtcdStub=true                             |
| featureGates.HostPathBackup            | Enable hostPath backup feature (optional, default: false)           | --set featureGates.HostPathBackup=true                       |
| featureGates.Tenant                    | Enable host cluster tenant feature (optional, default: false)       | --set featureGates.Tenant=true                               |
| velero.resticPodVolumeOperationTimeout | restic pod volume operation timeout (optional, default: "240m")     | --set velero.resticPodVolumeOperationTimeout=120m            |
| mysql.primary.persistence.enabled      | Enable mysql primary persistence feature (optional, default: false) | --set mysql.primary.persistence.enabled=true                 |
| mysql.primary.persistence.storageClass | Storage class for mysql primary persistence (optional, default: "") | --set mysql.primary.persistence.storageClass=rook-ceph-block |
| mysql.auth.rootPassword                | Database root user password (optional, default: "passw0rd")         | --set mysql.auth.rootPassword=123456                         |
| mysql.auth.database                    | Database name for webserver (optional, default: webserver)          | --set mysql.auth.database=web                                |
| auth.username                          | Database user for webserver (optional, default: "webserver")        | --set auth.username=webuser                                  |
| auth.password                          | Database password for webserver (optional, default: "passw0rd")     | --set auth.password=123456                                   |

## Acknowledgement

YS1000 functionalities are based on [Velero](https://github.com/vmware-tanzu/velero) and [other open source projects](https://github.com/jibutech/helm-charts/blob/main/credits.md).

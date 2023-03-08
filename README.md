# YS1000 Helm Chart

## 简介

此软件(Helm chart) 使用 **Helm** 包管理工具在 **Kubernetes** (K8S) 集群中安装和部署银数多云数据管理软件。

## 先决条件

- Kuberentes 版本支持 >= Kubernetes 1.18
- Helm 版本支持 >= 3.5
- 在线安装请确保 K8S 集群节点可以访问和拉取容器镜像 (container images)

## 在线安装

1. 使用以下命令添加 **Helm** 软件仓库:

   ```bash
   $ helm repo add qiming https://jibutech.github.io/helm-charts/
   ```

   添加完成之后，您可以通过执行命令 `helm search repo qiming` 来查看可选安装的软件版本，例如:

   ```bash
   [root@test-master ~]# helm search repo qiming
   NAME                    CHART VERSION   APP VERSION     DESCRIPTION                                       
   qiming/qiming-operator  2.6.1           2.6.1           ys1000 provides data protection for cloud nativ...
   ```

2. 您可以使用以下两种方法进行安装:

   **注意-1**: 为确保安装成功，请设置必需的的配置参数， 具体信息请参考安装手册配置章节 <br>
   **注意-2**: YS1000 v3.0以上的版本与之前版本不兼容，如果需要升级请联系技术支持 <br>
   **注意-3**: 如果安装环境中，之前安装过YS1000 历史版本，需要手动更新crd之后再进行安装或者升级
   ```
   kubectl apply -k 'github.com/jibutech/helm-charts/release-3.1.2/charts/ys1000'
   ```
   **从release 2.7.0开始，增加了mysql组件，安装时需额外注意**：
   生产环境或一些严肃场景必须指定 mysql.primary.persistence.enabled=true，需要同时指定storageClass（除非集群有指定defaultStorageClass）

   a. 通过命令行方式安装:

    使用**Helm**命令行参数`--set key=value[,key=value] `来指定必要的配置参数，例如:

      ```bash
      helm install qiming/ys1000 --namespace qiming-migration \
          --create-namespace --generate-name --set components.portal.serviceType=NodePort

      NAME: ys1000
      LAST DEPLOYED: Wed Mar  8 16:48:28 2023
      NAMESPACE: qiming-migration
      STATUS: deployed
      REVISION: 1
      NOTES:
      1. Check the application status Ready by running these commands:
        NOTE: It may take a few minutes to pull docker images.
              You can watch the status of by running `kubectl --namespace qiming-migration get migconfigs.migration.yinhestor.com -w`
        kubectl --namespace qiming-migration get migconfigs.migration.yinhestor.com 

      2. After status is ready, get the application URL by running these commands:
        export NODE_PORT=$(kubectl get --namespace qiming-migration -o jsonpath="{.spec.ports[0].nodePort}" services ui-service-default )
        export NODE_IP=$(kubectl get nodes --namespace qiming-migration -o jsonpath="{.items[0].status.addresses[0].address}")
        echo http://$NODE_IP:$NODE_PORT

      3. Login web UI with the token by running these commands:
        export SECRET=$(kubectl -n qiming-migration get secret | (grep qiming-operator |grep -v helm || echo "$_") | awk '{print $1}')
        export TOKEN=$(kubectl -n qiming-migration describe secrets $SECRET |grep token: | awk '{print $2}')
        echo $TOKEN

      ```

    说明:
    使用如下命令来检查安装状态正否正常

     ```bash
     kubectl -n qiming-migration get pod -w
     ```

   b. 通过 **YAML** 文件指定参数进行安装

    在 **values.yaml** 配置文件中设置或者修改必要的配置参数。

    1. 下载 values.yaml 模板配置文件

    2. 修改配置文件中的配置参数 
    
    3. 通过 `-f values.yaml` 来指定配置文件进行安装， 如下示例：

      ```bash
      # step 1: generate default values.yaml
      helm inspect values  qiming/ys1000 > values.yaml

      # step 2: fill required arguments in values.yaml
      vim values.yaml

      # step 3: install by specifying the values.yaml
      helm install qiming/ys1000 --namespace qiming-migration --generate-name -f values.yaml 
      ```

3. 获取已安装的软件的运行状态

    使用上述安装结束后 `NOTES` 中的第一条命令来查询软件的运行状态，使用可选 `-w` 参数观察软件初始化过程更新。

      **注意**：软件在初次安装时，需要一段时间下载容器镜像到 K8S 节点上，具体时间取决于镜像拉取速度。

      当`PHASE` 状态变成 `Ready`，表明软件初始化完成。

      如果变成 `Error` ，则说明初始化过程失败，需要查找错误原因。

      ```bash
      [root@remote-dev ~]# kubectl --namespace qiming-migration get migconfigs.migration.yinhestor.com
      NAME        AGE     PHASE   CREATED AT             VERSION
      qiming-config   2d2h   Ready   2021-10-20T06:21:20Z  v2.0.3
      ```

    使用命令 `helm list -n <NAMESPACE> ` 来显示当前安装的软件信息，例如：

      ```bash
      [root@remote-dev ~]# helm list -n qiming-migration
      NAME           	NAMESPACE       	REVISION	UPDATED                                	STATUS  	CHART                	APP VERSION
      ys1000  qiming-migration        1               2023-03-08 16:48:28.57116923 +0800 CST  deployed        ys1000-3.1.1    3.1.1
      ```

4. 访问图形管理界面（UI）

    a. 使用上述安装结束后 `NOTES` 中的第二条和第三条命令获取程序访问地址(Web URL) 以及登录所需的认证令(token)

      **注意**：软件通过 K8S Service 来暴露对外访问接口；Web URL 基于 K8S 配置以及安装中指定的参数不同， 暴露出的访问地址不同，支持类型包括: `kubectl proxy`， `ingress` 和   `nodeport`，下文以 `nodeport` 安装方式为例:

      ```bash
      [root@remote-dev ~]# export NODE_PORT=$(kubectl get --namespace qiming-migration -o jsonpath="{.spec.ports[0].nodePort}" services ui-service-default )
      [root@remote-dev ~]# export NODE_IP=$(kubectl get nodes --namespace qiming-migration -o jsonpath="{.items[0].status.addresses[0].address}")

      [root@remote-dev ~]# echo http://$NODE_IP:$NODE_PORT
      http://192.168.0.2:31151
      ```

    b. 登录管理界面

    目前支持两种登录方式，集群令牌访问和用户名密码访问。

    1. 集群令牌获取:

    ```bash
    export SECRET=$(kubectl -n qiming-migration get secret | (grep qiming-operator |grep -v helm || echo "$_") | awk '{print $1}')
    export TOKEN=$(kubectl -n qiming-migration describe secrets $SECRET |grep token: | awk '{print $2}')
    echo $TOKEN
    ```

    2. 使用用户名和密码：

    默认用户名 `admin` 默认密码 `passw0rd`.
    密码可以在安装时指定：

    ```bash
    --set migconfig.UIadminPassword=<your new password>
    ```

## 升级

1. 使用命令 `helm repo update` 更新可用的软件版本, 并可以通过 `helm search repo qiming` 来查看更新后的软件版本列表，例如：

   ```bash
   [root@ ~]# helm search repo qiming
   NAME                    CHART VERSION   APP VERSION     DESCRIPTION                                       
   qiming/qiming-operator  2.10.3          2.10.3          ys1000 provides data protection for cloud nativ...
   qiming/mysql            1.0.0           8.0.32          MySQL is a fast, reliable, scalable, and easy t...
   qiming/ys1000           3.0.0           3.0.0           ys1000 provides data protection for cloud nativ...

   [root@ ~]# helm search repo qiming --versions
   NAME                  	CHART VERSION	APP VERSION	DESCRIPTION
   qiming/qiming-operator  2.10.3          2.10.3          ys1000 provides data protection for cloud nativ...
   qiming/qiming-operator  2.10.2          2.10.2          ys1000 provides data protection for cloud nativ...
   qiming/qiming-operator  2.10.1          2.10.1          ys1000 provides data protection for cloud nativ...
   qiming/qiming-operator  2.9.0           2.9.0           ys1000 provides data protection for cloud nativ...
   ...
   ```

2. 使用命令 `helm upgrade` 进行软件升级，通过参数 `--version=<CHART VERSION>` 指定升级版本。

   **注意-1**：如果需要在升级过程中修改或者增加部分参数，可以附加参数 `--set key=value[,key=value] ` 来完成，具体参数参照文末 **配置** <br>
   **注意-2**: 如果安装环境中，之前安装过ys1000 历史版本，需要手动更新crd之后再进行安装或者升级
   ```
   kubectl apply -k 'github.com/jibutech/helm-charts/release-3.1.2/charts/ys1000'
   ```
   
   例如：
   
   ```bash
   [root@remote-dev ~]helm upgrade ys1000 qiming/ys1000 --namespace qiming-migration --version=3.1.2 --set migconfig.UIadminPassword=`<your password>`
   ```

   或者将需要修改或者新增的参数放在 values.yaml 中，并在升级时应用该 values.yaml
   ```
   # example of values.yaml
   migconfig:
     UIadminPassword: "password"
     selfBackupIntervalSeconds: 3000
   featureGates:
     ClusterCache: true
     DataMover: false
     AmberApp: true
     Stub: true
     Archive: true
     DisasterRecovery: true
     DMAgent: true
     ImageBackup: true
     EtcdStub: true
   velero:
     resticPodVolumeOperationTimeout: 120m
   components:
     portal:
       serviceType: NodePort
     webServer:
       serviceType: NodePort
   ```
   例如：

   ```bash
   [root@remote-dev ~]helm upgrade ys1000 qiming/ys1000 --namespace qiming-migration --version=3.1.2 -f values.yaml
   ```
   

## 卸载

1. 登录ys1000，确保所有任务已经被清除，移除受管集群和备份仓库
2. 卸载已安装的 Helm chart

   指定当前已安装的软件名`release name` 和 软件所在的命名空间`namespace`

   ```bash
   [root@remote-dev ~]# helm list -n qiming-migration
   NAME                      	NAMESPACE       	REVISION	UPDATED                                	STATUS  	CHART                	APP VERSION
   ys1000  qiming-migration        1               2023-03-08 16:48:28.57116923 +0800 CST  deployed        ys1000-3.1.1    3.1.1  

   [root@remote-dev ~]# helm uninstall ys1000 -n qiming-migration
   release "ys1000" uninstalled
   ```

   **注意**: `velero` 组件和资源对象默认仍然保留在命名空间中, 以防止数据丢失。

   如果您确定需要删除 `velero` 和相关应用备份数据记录，可以通过以下命令在每个 Kubernetes 集群上分别运行，进行清除操作：

   ```bash
   kubectl delete ns qiming-migration

   kubectl delete clusterrolebindings.rbac.authorization.k8s.io velero-qiming-migration

   kubectl delete crds -l component=velero
   ```

## 配置

此表列出安装阶段所需的必要和可选参数，且指定过的参数在升级时需要同样指定，否则使用默认值：

| 参数命名                               | 描述                                         | 示例                                          |
| ------------------------------------- | ------------------------------------------- | --------------------------------------------- |
| components.portal.serviceType         | 服务类型（可选，默认为 ClusterIP）              | --set components.portal.serviceType=NodePort   |
| components.webServer.serviceType      | 服务类型（可选，默认为 ClusterIP）              | --set components.portal.serviceType=NodePort   |
| migconfig.UIadminPassword             | 指定admin密码（可选，默认为“passw0rd”）         | --set migconfig.UIadminPassword=123456      ｜
| migconfig.selfBackupIntervalSeconds   | 指定YS1000自备份间隔时长（可选，默认为“300”秒）   | --set migconfig.selfBackupIntervalSeconds=600  ｜
| featureGates.Archive                  | 是否开启归档功能（可选，默认为false）             | --set featureGates.Archive=true           |
| featureGates.DisasterRecovery         | 是否开启容灾功能（可选，默认为false）             | --set featureGates.DisasterRecovery=true  |
| featureGates.EtcdStub                 | 是否开启etcd备份功能（可选，默认为false）         | --set featureGates.EtcdStub=true          |
| velero.resticPodVolumeOperationTimeout| restic拷贝podvolume的超时时长（可选，默认为“240m”| --set velero.resticPodVolumeOperationTimeout=120m |
| mysql.primary.persistence.enabled     | 是否对mysql数据做持久化（可选，默认为false）      | --set mysql.primary.persistence.enabled=true  |
| mysql.primary.persistence.storageClass| 是否指定mysql存储类型（可选，默认为空）           | --set mysql.primary.persistence.storageClass=rook-ceph-block|
| mysql.auth.rootPassword               | 指定数据库root用户的密码（可选，默认为"passw0rd"）| --set mysql.auth.rootPassword=123456           |
| mysql.auth.database                   | 指定webserver使用的数据库（可选，默认为"webserver"）| --set mysql.auth.database=web                
| auth.username                         | 指定数据库的用户（可选，默认为"webserver"）      | --set auth.username=webuser                    |
| auth.password                         | 指定数据库的密码（可选，默认为"passw0rd"）       | --set auth.password=123456                      |

## 致谢

YS1000 产品中使用了[Velero](https://github.com/vmware-tanzu/velero) 开源项目以及[其他开源软件](https://github.com/jibutech/helm-charts/blob/main/credits.md)。

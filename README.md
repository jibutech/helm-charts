# YS1000 Helm Chart

## 简介

此软件(Helm chart) 使用 **Helm** 包管理工具在 **Kubernetes** (K8S) 集群中安装和部署YS1000。

## 先决条件

- Kuberentes 版本支持范围: [v1.16, v1.17, ....,  v1.31]
- Helm 版本支持 >= 3.5
- 在线安装请确保 K8S 集群节点可以访问阿里云容器镜像服务
- K8S集群节点可以访问一个或多个对象存储(AWS S3兼容)实例

## 在线安装

1. 使用以下命令添加 **Helm** 软件仓库:

   ```bash
   helm repo add jibutech https://jibutech.github.io/helm-charts/
   ```

   添加完成之后，您可以通过执行命令 `helm search repo jibutech` 来查看可选安装的软件版本，例如:

   ```bash
   [root@~]# helm search repo jibutech
   NAME                    CHART VERSION   APP VERSION     DESCRIPTION
   jibutech/ys1000         3.4.0           3.4.0           ys1000 provides data protection for cloud nativ...
   ```

2. 您可以使用以下两种方法进行安装:
   **注意-1**: 为确保安装成功，请设置必需的的配置参数， 具体信息请参考安装手册配置章节
   **注意-2**: 需要在安装本软件之前准备好 S3 (AWS S3 兼容) 对象存储环境，下文基于本地安装的 [minio](https://min.io/) 为例进行说明
   **注意-3**: 如果安装环境中，之前安装过ys1000 历史版本，需要手动更新crd之后再进行安装或者升级
   **从YS1000 3.6 版本开始在helm 安装和升级时内置拉取crd的钩子，只要钩子程序的pod成功运行即可；如果报错请检查pod log或联系技术支持**

   ```bash
      kubectl apply -k 'github.com/jibutech/helm-charts/charts/ys1000'
   ```

   生产环境中建议必须指定 mysql.primary.persistence.enabled=true，需要同时指定storageClass（除非集群有指定defaultStorageClass）

   a. 通过命令行方式安装:
   使用**Helm**命令行参数 `--set key=value[,key=value]`来指定必要的配置参数，例如:

   ```bash
   helm install ys1000 jibutech/ys1000 --create-namespace --namespace ys1000
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

   说明:
   使用如下命令来检查安装状态正否正常

   ```bash
   kubectl --namespace ys1000 get pod -w
   kubectl --namespace ys1000 get migconfigs.migration.yinhestor.com
   ```

   b. 通过 **YAML** 文件指定参数进行安装
   在 **values.yaml** 配置文件中设置或者修改必要的配置参数。

   - 下载 values.yaml 模板配置文件
   - 修改配置文件中的配置参数
   - 通过 `-f values.yaml` 来指定配置文件进行安装， 如下示例：

   ```bash
   # step 1: generate default values.yaml
   helm inspect values  jibutech/ys1000 > values.yaml

   # step 2: fill required arguments in values.yaml
   vim values.yaml

   # step 3: install by specifying the values.yaml
   helm install jibutech/ys1000 --namespace ys1000 -f values.yaml --generate-name
   ```

4. 获取已安装的软件的运行状态
   使用上述安装结束后 `NOTES` 中的第一条命令来查询软件的运行状态，使用可选 `-w` 参数观察软件初始化过程更新。

   **注意**：软件在初次安装时，需要一段时间下载容器镜像到 K8S 节点上，具体时间取决于镜像拉取速度。

   当 `PHASE` 状态变成 `Ready`，表明软件初始化完成。
   如果变成 `Error` ，则说明初始化过程失败，需要查找错误原因。

   ```bash
   kubectl --namespace ys1000 get migconfigs.migration.yinhestor.com -w
   NAME            AGE   PHASE   CREATED AT             VERSION
   qiming-config   52s   Ready   2023-03-15T06:41:11Z   3.4.0
   ```

   使用命令 `helm list -n <NAMESPACE>` 来显示当前安装的软件信息，例如：

   ```bash
   [root@~]# helm list -n ys1000
   NAME                    NAMESPACE      REVISION        UPDATED                                   STATUS      CHART                APP VERSION
   ys1000-1683716371       ys1000         11              2023-05-26 17:53:15.116051313 +0800 CST   deployed    ys1000-3.4.0         3.4.0
   ```

5. 访问图形管理界面（UI）

   a. 使用上述安装结束后 `NOTES` 中的第二条和第三条命令获取程序访问地址以及登录密码
   **注意**：软件通过 K8S Service 来暴露对外访问接口；Web URL基于K8S配置以及安装中指定的参数不同，暴露出的访问地址不同，支持类型包括: `kubectl proxy`， `ingress` 和 `nodeport`，下文以 `nodeport` 安装方式为例:

   ```bash
   [root@~]# export NODE_PORT=$(kubectl get --namespace ys1000 -o jsonpath="{.spec.ports[0].nodePort}" services ui-service-default )
   [root@~]# export NODE_IP=$(kubectl get nodes --namespace ys1000 -o jsonpath="{.items[0].status.addresses[0].address}")
   [root@~]# echo http://$NODE_IP:$NODE_PORT
   http://192.168.0.2:31151
   ```

   b. 登录管理界面
   目前支持用户名密码访问。默认用户名 `admin` 默认密码 `passw0rd`.

## 升级

1. 使用命令 `helm repo update` 更新可用的软件版本, 并可以通过 `helm search repo jibutech` 来查看更新后的软件版本列表，例如：

   ```bash
   [root@ ~]# helm search repo jibutech
   NAME             CHART VERSION   APP VERSION     DESCRIPTION
   jibutech/ys1000  3.4.0           3.4.0           ys1000 provides data protection for cloud nativ...

   [root@ ~]# helm search repo jibutech --versions
   NAME             CHART VERSION   APP VERSION     DESCRIPTION
   jibutech/ys1000  3.4.0           3.4.0           ys1000 provides data protection for cloud nativ...
   jibutech/ys1000  3.3.1           3.3.1           ys1000 provides data protection for cloud nativ...
   jibutech/ys1000  3.3.0           3.3.1           ys1000 provides data protection for cloud nativ...
   jibutech/ys1000  3.2.3           3.2.3           ys1000 provides data protection for cloud nativ...
   ...

   ```

2. 使用命令 `helm upgrade` 进行软件升级，通过参数 `--version=<CHART VERSION>` 指定升级版本。

   **注意-1**：如果需要在升级过程中修改或者增加部分参数，可以附加参数 `--set key=value[,key=value]` 来完成，具体参数参照文末 **配置**
   **注意-2**: 如果安装环境中，之前安装过ys1000 历史版本，需要手动更新crd之后再进行安装或者升级

   ```bash
      kubectl apply -k 'github.com/jibutech/helm-charts/charts/ys1000'
   ```

   例如:

   ```bash
   helm upgrade ys1000 jibutech/ys1000 --namespace ys1000 --version=3.4.0 --set migconfig.UIadminPassword=`<your password>`
   ```

   或者将需要修改或者新增的参数放在 values.yaml 中，并在升级时应用该 values.yaml

   ```bash
   # example of external database setting
   # only support mysql, and you need to create a database for webserver in advance

   tags:
     mysql: false
   components:
     webServer:
       database:
         username:
           value: root
         password:
           valueFrom:
             secretKeyRef:
               key: mysql-root-password
               name: mysql
               optional: true
         host: mysql.mysql-ys1000  # change to your own mysql host
         name: sit_webserver  # change to your own database name

    clusterpedia:
      externalStorage:
        type: "mysql"
        host: "mysql.mysql-ys1000"  # change to your own mysql host
        port: 3306
        user: "root"
        password: "password"  # change to your own database password
        database: "sit_clusterpedia"  # change to your own database name
        createDatabase: true

   # example of alarm setting
   # you need to setup a prometheus for ys1000 host cluster in advance, and add the host ip to your wechat list

   alarm:
     enabled: true
   wechat:
     enabled: true
     corpID: "ww9435adfc497dffff"   # change to your company ID
     agentID: "'1000000'"    # change to your own ID
     toUser: "username"     # change to your own name
     apiSecret: "z2CJdkRuq14fCejAkEBaPt0w641QCD_teCatrfePE00"    # change to your wechatsecret

   # Enable OSS support
   components:
     velero:
       plugins:
       - ys1000/velero-plugin-alibabacloud:v1.2.1-jibu-dev-2373ba8-20240229150839
   
   ```

   例如：

   ```bash
   [root@remote-dev ~]helm upgrade ys1000 jibutech/ys1000 --namespace ys1000 --version=3.2.0 -f values.yaml
   ```
   
   **注意-3**: 在YS1000 v3.6 版本之前若使用内置mysql数据库，并设置持久化mysql数据卷，升级到v3.7 版本时，由于mysql版本升级，需要执行特殊操作以保证数据一致，参考：
   https://github.com/jibutech/docs/blob/main/YS1000%20upgrade%20v3.6-v3.7%20mysql%20persistence%20setting.md
   **注意-4**: 从YS1000 v3.10 版本升级到 v4.0 版本时，由于 restic 版本升级，需要执行以下步骤：
   1. 下载对应版本yscli
   2. 设置所有受管集群为维护模式
   3. 在每个受管集群上运行yscli 升级命令： yscli misc upgrade
   4. 解除受管集群维护模式

## 卸载

### 保留数据卸载

   如果需要保留当前备份配置和备份数据，使用原生helm delete 删除ys1000资源

   ```bash
   # 假设当前ys1000 安装在 ys1000 ns 下
   helm delete ys1000 -n ys1000
   ```

### 清除数据卸载

   从v3.4.0 版本开始，ys1000 提供自清理功能，可使用如下方法进行数据清理和软件卸载：

   1. 从ys1000部署所在的命令空间中拷贝`yscli`命令，请参考如下示例:

      ```bash
      # 获取当前运行的ys1000 operator pod 
      ❯ kubectl -n ys1000-v3 get pods -l app=qiming-operator
      NAME                      READY   STATUS    RESTARTS   AGE
      ys1000-5b55f866d4-k445g   1/1     Running   0          39s

      # 拷贝 ysci 命令并设置执行权限
      ❯ kubectl -n ys1000-v3 cp ys1000-5b55f866d4-k445g:/bin/yscli ./yscli
      tar: Removing leading '/' from member names

      ❯ chmod +x yscli

      ❯ ./yscli version
      version.info{Version:"v3.5.2", GitVersion:"v3.5.2-7+70d2d7e7d0ec2b", GitCommit:"70d2d7e7d0ec2b1a9687e9a5607f19e196ea3165", GitTreeState:"clean", BuildDate:"2023-10-17T06:52:28Z", GoVersion:"go1.20.4", Compiler:"gc", Platform:"linux/amd64"}
      ```

   2. 指定ys1000运行所属集群的kubeconfig 和 ys1000部署的命名空间，运行yscli cleanup清除命令:

      ```bash
      # 注意：当数据较多或者容器环境较慢时，上述命令在删除某个资源时可能会遇到timeout报错，需要再次运行该命令进行尝试并验证删除完成

      ❯ ./yscli cleanup --kubeconfig /root/.kube/ys1000-kubeconfig.yaml -n ys1000-v3
      2023-09-21T06:36:29Z    INFO    Start to delete resources
      2023-09-21T06:36:29Z    INFO    Force deleting all resources
      2023-09-21T06:36:30Z    INFO    Deleting migConfig resources
      ...
      2023-09-21T06:36:31Z    INFO    Deleting cluster resources
      2023-09-21T06:36:31Z    INFO    Deleting CRDs
      2023-09-21T06:36:31Z    INFO    Finish to cleanup resources

      ```

   3. 使用`helm uninstall` 卸载ys1000，成功后删除对应的命名空间，请参考如下示例

      ```bash
      ❯ helm uninstall ys1000 -n ys1000-v3
      These resources were kept due to the resource policy:
      [Migconfig] qiming-config

      release "ys1000" uninstalled

      ❯ kubectl delete ns ys1000-v3
      namespace "ys1000-v3" deleted
      ```

   4. 删除受管集群中灾备引擎命名空间

      ```bash
      kubectl delete ns qiming-backend
      ```

      *注意:* 可能部分资源因版本等问题仍然存在命名空间中，导致命名空间删除处于 `Terminating` 状态，可通过 `kubectl get ns <ns-name> -oyaml` 来查找未被成功删除的资源。
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

      # 根据上述提示，存在如下资源，仍包含finalizers 导致命名空间无法清理
      ❯ kubectl -n qiming-backend get exporthandlers.agent.jibudata.com
      NAME                     AGE
      de-pvc-only-1690858815   77d
      de-pvc-only-1691396796   71d

      # 通过kubectl patch 移除相关finalizer 配置
      ❯ kubectl -n qiming-backend patch exporthandlers.agent.jibudata.com  de-pvc-only-1690858815  -p '{"metadata":{"finalizers":null}}' --type=merge
      exporthandler.agent.jibudata.com/de-pvc-only-1690858815 patched
      ❯ kubectl -n qiming-backend patch exporthandlers.agent.jibudata.com  de-pvc-only-1691396796  -p '{"metadata":{"finalizers":null}}' --type=merge
      exporthandler.agent.jibudata.com/de-pvc-only-1691396796 patched

      # 上述手动清理执行完成后，对应命名空间将自动被清理
      ❯ kubectl get ns qiming-backend
      Error from server (NotFound): namespaces "qiming-backend" not found
      ```

## 配置

此表列出安装阶段所需的必要和可选参数，且指定过的参数在升级时需要同样指定，否则使用默认值:

| 参数命名                               | 描述                                                 | 示例                                                         |
| -------------------------------------- | ---------------------------------------------------- | ------------------------------------------------------------ |
| components.portal.serviceType          | 服务类型（可选，默认为 NodePort）                    | --set components.portal.serviceType=NodePort                 |
| featureGates.EtcdStub                  | 是否开启etcd备份功能（可选，默认为false）            | --set featureGates.EtcdStub=true                             |
| featureGates.HostPathBackup            | 是否开启hostPath备份功能（可选，默认为false）        | --set featureGates.HostPathBackup=true                       |
| featureGates.Tenant                    | 是否开启host集群Tenant功能（可选，默认为false）      | --set featureGates.Tenant=true                              |
| velero.resticPodVolumeOperationTimeout | restic拷贝podvolume的超时时长（可选，默认为“240m”  | --set velero.resticPodVolumeOperationTimeout=120m            |
| mysql.primary.persistence.enabled      | 是否对mysql数据做持久化（可选，默认为false）         | --set mysql.primary.persistence.enabled=true                 |
| mysql.primary.persistence.storageClass | 是否指定mysql存储类型（可选，默认为空）              | --set mysql.primary.persistence.storageClass=rook-ceph-block |
| mysql.auth.rootPassword                | 指定数据库root用户的密码（可选，默认为"passw0rd"）   | --set mysql.auth.rootPassword=123456                         |
| mysql.auth.database                    | 指定webserver使用的数据库（可选，默认为"webserver"） | --set mysql.auth.database=web                                |
| auth.username                          | 指定数据库的用户（可选，默认为"webserver"）          | --set auth.username=webuser                                  |
| auth.password                          | 指定数据库的密码（可选，默认为"passw0rd"）           | --set auth.password=123456                                   |

## 致谢

YS1000 产品中使用了[Velero](https://github.com/vmware-tanzu/velero) 开源项目以及[其他开源软件](https://github.com/jibutech/helm-charts/blob/main/credits.md)。

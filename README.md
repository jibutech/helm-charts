# YS1000 Helm Chart

## 简介

此软件(Helm chart) 使用 **Helm** 包管理工具在 **Kubernetes** (K8S) 集群中安装和部署银数多云数据管理软件。

## 先决条件

- Kuberentes 版本支持 >= Kubernetes 1.18
- Helm 版本支持 >= 3.5
- 在线安装请确保 K8S 集群节点可以访问和拉取容器镜像 (container images)
- S3 (AWS S3 兼容) 对象存储

## 在线安装

1. 使用以下命令添加 **Helm** 软件仓库:

   ```bash
   $ helm repo add qiming https://jibutech.github.io/helm-charts/
   ```

   添加完成之后，您可以通过执行命令 `helm search repo qiming` 来查看可选安装的软件版本，例如:

   ```bash
   [root@test-master ~]# helm search repo qiming
   NAME                  	CHART VERSION	APP VERSION	DESCRIPTION
   qiming/qiming-operator	2.0.3        	2.0.3      	A Helm chart for YS1000 data management platform
   ```

2. 您可以使用以下两种方法进行安装:

   **注意-1**: 为确保安装成功，请设置必需的的配置参数， 具体信息请参考安装手册配置章节 <br>
   **注意-2**: 需要在安装本软件之前准备好 S3 (AWS S3 兼容) 对象存储环境，下文基于本地安装的 [minio](https://min.io/) 为例进行说明

   a. 通过命令行方式安装:

    使用**Helm**命令行参数`--set key=value[,key=value] `来指定必要的配置参数，例如:

      ```bash
      helm install qiming/qiming-operator --namespace qiming-migration \
          --create-namespace --generate-name --set service.type=NodePort \
          --set s3Config.accessKey=minio --set s3Config.secretKey=passw0rd \
          --set s3Config.bucket=test --set s3Config.s3Url=http://172.16.0.10:30170

      NAME: qiming-operator-1635128765
      LAST DEPLOYED: Mon Oct 20 10:26:10 2021
      NAMESPACE: qiming-migration
      STATUS: deployed
      REVISION: 1
      ```

    说明:
    使用如下命令来检查安装状态正否正常

     ```bash
     kubectl --namespace qiming-migration get migconfigs.migration.yinhestor.com -w
     ```

   b. 通过 **YAML** 文件指定参数进行安装

    在 **values.yaml** 配置文件中设置或者修改必要的配置参数。

    1. 下载 values.yaml 模板配置文件

    2. 修改配置文件中的配置参数 3. 通过 `-f values.yaml` 来指定配置文件进行安装， 如下示例：

      ```bash
      # step 1: generate default values.yaml
      helm inspect values  qiming/qiming-operator > values.yaml

      # step 2: fill required arguments in values.yaml
      vim values.yaml

      # step 3: install by specifying the values.yaml
      helm install qiming/qiming-operator --namespace qiming-migration -f values.yaml --generate-name
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
      qiming-operator	qiming-migration	1       	2021-10-20 14:21:19.974930606 +0800 CST	deployed	qiming-operator-2.0.3	2.0.3
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
   NAME                  	CHART VERSION	APP VERSION	DESCRIPTION
   qiming/qiming-operator	2.0.3        	2.0.3      	A Helm chart for YS1000 data management platform
   [root@ ~]# helm search repo qiming --versions
   NAME                  	CHART VERSION	APP VERSION	DESCRIPTION
   qiming/qiming-operator	2.0.3        	2.0.3      	A Helm chart for YS1000 data management platform
   qiming/qiming-operator	1.0.2        	1.0.2      	A Helm chart for yinhestor data management plat...
   qiming/qiming-operator	1.0.1        	1.0.1      	A Helm chart for yinhestor data management plat...
   helm search repo qiming --versions
   ```

2. 使用命令 `helm upgrade` 进行软件升级，通过参数 `--version=<CHART VERSION>` 指定升级版本。

   **注意**：如果需要在升级过程中修改或者增加部分参数，可以附加参数 `--set key=value[,key=value] ` 来完成，具体参数参照文末 **配置**
   
   例如：
   
   ```bash
   [root@remote-dev ~]helm upgrade qiming-operator qiming/qiming-operator --namespace qiming-migration --version=2.5.0 --set migconfig.UIadminPassword=`<your password>`
   ```

   或者将需要修改或者新增的参数放在 values.yaml 中，并在升级时应用该 values.yaml
   ```
   # example of values.yaml
   s3Config:
     provider: "aws"
     accessKey: "abc"
     secretKey: "xyz"
     bucket: "default"
     s3Url: ""
     region: "default"
   migconfig:
     UIadminPassword: "password"
   selfBackup:
     enabled: true
     frequency: 0 */3 * * *
     retention: 168
   ```
   例如：

   ```bash
   [root@remote-dev ~]helm upgrade qiming-operator qiming/qiming-operator --namespace qiming-migration --version=2.5.0 -f values.yaml
   ```
   

## 卸载

1. 卸载已安装的 Helm chart

   指定当前已安装的软件名`release name` 和 软件所在的命名空间`namespace`

   ```bash
   [root@remote-dev ~]# helm list -n qiming-migration
   NAME                      	NAMESPACE       	REVISION	UPDATED                                	STATUS  	CHART                	APP VERSION
   qiming-operator-1618982398	qiming-migration	4       	2021-04-21 13:41:27.365865385 +0800 CST	deployed	qiming-operator-0.2.1	0.2.1

   [root@remote-dev ~]# helm uninstall qiming-operator-1618982398 -n qiming-migration
   release "qiming-operator-1618982398" uninstalled
   ```

   **注意**: `velero` 组件和资源对象默认仍然保留在命名空间中, 已防止数据丢失。

   如果您确定需要删除 `velero` 和相关应用备份数据记录，可以通过下列命令在每个 Kubernetes 集群上分别运行，进行清除操作：

   ```bash
   kubectl delete ns qiming-migration

   kubectl delete clusterrolebindings.rbac.authorization.k8s.io velero-qiming-migration

   kubectl delete crds -l component=velero
   ```

helm install qiming/qiming-operator --namespace qiming-migration \
--create-namespace --generate-name --set service.type=NodePort \
 --set s3Config.name=minio --set s3Config.accessKey=minio \
 --set s3Config.secretKey=passw0rd --set s3Config.bucket=test \
 --set s3Config.s3Url=http://172.16.0.10:30170

## 配置

此表列出安装阶段所需的必要和可选参数：

| 参数命名                  | 描述                                         | 示例                                          |
| ------------------------- | -------------------------------------------- | --------------------------------------------- |
| service.type              | 服务类型                                     | --set service.type=NodePort                   |
| s3Config.provider         | S3 提供商                                    | --set s3Config.provider=aws                   |
| s3Config.name             | 所配置的 S3 服务名字， 也即数据备份仓库名字       | --set s3Config.name=minio                     |
| s3Config.accessKey        | 访问 S3 所需要的 access key                  | --set s3Config.accessKey=minio                |
| s3Config.secretKey        | 访问 S3 所需要的 secret key                  | --set s3Config.secretKey=passw0rd             |
| s3Config.bucket           | 访问 S3 的 bucket name                       | --set s3Config.bucket=test                    |
| s3Config.s3Url            | S3 URL                                      | --set s3Config.s3Url=http://172.16.0.10:30170 |
| migconfig.UIadminPassword | 指定admin密码（可选，默认为“passw0rd”）         | --set migconfig.UIadminPassword=`<your password>` ｜
| selfBackup.enabled        | 是否打开自备份（可选，默认为false）               | --set selfBackup.enabled=true                |

## 致谢

YS1000 产品中使用了[Velero](https://github.com/vmware-tanzu/velero) 开源项目以及[其他开源软件](https://github.com/jibutech/helm-charts/blob/main/credits.md)。

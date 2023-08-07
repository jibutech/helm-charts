# YS1000 Helm Chart

## 简介

此软件(Helm chart) 使用 **Helm** 包管理工具在 **Kubernetes** (K8S) 集群中安装和部署银数多云数据管理软件。

## 先决条件

- Kuberentes 版本支持 >= Kubernetes 1.16
- Helm 版本支持 >= 3.5
- 在线安装请确保 K8S 集群节点可以访问阿里云容器镜像服务
- K8S集群节点可以访问一个或多个对象存储(AWS S3兼容)实例

## 在线安装

1. 使用以下命令添加 **Helm** 软件仓库:

   ```bash

   ```

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

```

   kubectl apply -k 'github.com/jibutech/helm-charts/charts/ys1000'

```

**从release 2.7.0开始，增加了mysql组件，安装时需额外注意**：

   生产环境或一些严肃场景必须指定 mysql.primary.persistence.enabled=true，需要同时指定storageClass（除非集群有指定defaultStorageClass）

   a. 通过命令行方式安装:

   使用**Helm**命令行参数 `--set key=value[,key=value] `来指定必要的配置参数，例如:

```bash

helm install ys1000 jibutech/ys1000 --create-namespace --namespace ys1000

NAME: ys1000

LAST DEPLOYED: Wed Mar 15 14:41:10 2023

NAMESPACE: ys1000

STATUS: deployed

REVISION: 1

NOTES:

1. Check the application status Ready by running these commands:

 NOTE: It may take a few minutes to pull docker images.

       You can watch the status of by running `kubectl--namespace ys1000 get migconfigs.migration.yinhestor.com -w`

 kubectl --namespace ys1000 get migconfigs.migration.yinhestor.com 


2. After status is ready, get the application URL by running these commands:

 export NODE_PORT=$(kubectl get --namespace ys1000 -o jsonpath="{.spec.ports[0].nodePort}" services ui-service-default )

 export NODE_IP=$(kubectl get nodes --namespace ys1000 -o jsonpath="{.items[0].status.addresses[0].address}")

 echo http://$NODE_IP:$NODE_PORT


3. Login web UI with the token by running these commands:

 export SECRET=$(kubectl-n ys1000 get secret | (grep qiming-operator |grep-v helm ||echo "$_") |awk '{print $1}')

 export TOKEN=$(kubectl-n ys1000 describe secrets $SECRET|grep token: |awk '{print $2}')

 echo $TOKEN

```

   说明:

   使用如下命令来检查安装状态正否正常

```bash

kubectl --namespace ys1000 get pod -w

kubectl --namespace ys1000 get migconfigs.migration.yinhestor.com

```

   b. 通过 **YAML** 文件指定参数进行安装

   在 **values.yaml** 配置文件中设置或者修改必要的配置参数。

1. 下载 values.yaml 模板配置文件
2. 修改配置文件中的配置参数
3. 通过 `-f values.yaml` 来指定配置文件进行安装， 如下示例：

   ```bash

   ```

# step 1: generate default values.yaml

helm inspect values  jibutech/ys1000 > values.yaml

# step 2: fill required arguments in values.yaml

vim values.yaml

# step 3: install by specifying the values.yaml

helm install jibutech/ys1000 --namespace ys1000 -f values.yaml --generate-name

```

3. 获取已安装的软件的运行状态


   使用上述安装结束后 `NOTES` 中的第一条命令来查询软件的运行状态，使用可选 `-w` 参数观察软件初始化过程更新。


**注意**：软件在初次安装时，需要一段时间下载容器镜像到 K8S 节点上，具体时间取决于镜像拉取速度。


   当 `PHASE` 状态变成 `Ready`，表明软件初始化完成。


   如果变成 `Error` ，则说明初始化过程失败，需要查找错误原因。


   ```bash

kubectl --namespace ys1000 get migconfigs.migration.yinhestor.com -w

NAME            AGE   PHASE   CREATED AT             VERSION

qiming-config   52s   Ready   2023-03-15T06:41:11Z   3.1.1

```

   使用命令 `helm list -n <NAMESPACE> ` 来显示当前安装的软件信息，例如：

```bash

[root@~]# helm list -n ys1000

NAME                    NAMESPACE      REVISION        UPDATED                                   STATUS      CHART                APP VERSION

ys1000-1683716371       ys1000         11              2023-05-26 17:53:15.116051313 +0800 CST   deployed    ys1000-3.4.0         3.4.0

```

4. 访问图形管理界面（UI）

   a. 使用上述安装结束后 `NOTES` 中的第二条和第三条命令获取程序访问地址(Web URL) 以及登录所需的认证令(token)

**注意**：软件通过 K8S Service 来暴露对外访问接口；Web URL基于K8S配置以及安装中指定的参数不同，暴露出的访问地址不同，支持类型包括: `kubectl proxy`， `ingress` 和 `nodeport`，下文以 `nodeport` 安装方式为例:

```bash

[root@~]# export NODE_PORT=$(kubectl get --namespace ys1000 -o jsonpath="{.spec.ports[0].nodePort}" services ui-service-default )

[root@~]# export NODE_IP=$(kubectl get nodes --namespace ys1000 -o jsonpath="{.items[0].status.addresses[0].address}")


[root@~]# echo http://$NODE_IP:$NODE_PORT

http://192.168.0.2:31151

```

   b. 登录管理界面

   目前支持用户名密码访问。默认用户名 `admin` 默认密码 `passw0rd`.

   密码可以在安装时指定：

```bash

--set migconfig.UIadminPassword=<your new password>

```

## 升级

1. 使用命令 `helm repo update` 更新可用的软件版本, 并可以通过 `helm search repo jibutech` 来查看更新后的软件版本列表，例如：

   ```bash

   ```

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


**注意-1**：如果需要在升级过程中修改或者增加部分参数，可以附加参数 `--set key=value[,key=value] ` 来完成，具体参数参照文末 **配置**

**注意-2**: 如果安装环境中，之前安装过ys1000 历史版本，需要手动更新crd之后再进行安装或者升级


```

   kubectl apply -k 'github.com/jibutech/helm-charts/charts/ys1000'

```


   例如：


   ```bash

helm upgrade ys1000 jibutech/ys1000 --namespace ys1000 --version=3.4.0 --set migconfig.UIadminPassword=`<your password>`

```

   或者将需要修改或者新增的参数放在 values.yaml 中，并在升级时应用该 values.yaml

```

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

```

```

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

```

   例如：

```bash

[root@remote-dev ~]helm upgrade ys1000 jibutech/ys1000 --namespace ys1000 --version=3.2.0 -f values.yaml

```

## 卸载

1. 登录ys1000，确保所有任务已经被清除，移除受管集群和备份仓库
2. 卸载已安装的 Helm chart

   指定当前已安装的软件名 `release name` 和 软件所在的命名空间 `namespace`

   ```bash

   ```

[root@~]# helm list -n ys1000

NAME                    NAMESPACE       REVISION        UPDATED                                  STATUS      CHART                APP VERSION

ys1000-1683716371       ys1000          11              2023-05-26 17:53:15.116051313 +0800 CST  deployed    ys1000-3.4.0         3.4.0

[root@~]# helm uninstall ys1000-1618982398 -n ys1000

release "ys1000-1618982398" uninstalled

```


**注意**: `velero` 组件和资源对象默认仍然保留在命名空间中, 已防止数据丢失。


   如果您确定需要删除 `velero` 和相关应用备份数据记录，可以通过下列命令在每个 Kubernetes 集群上分别运行，进行清除操作：


   ```bash

kubectl delete ns ys1000


kubectl delete clusterrolebindings.rbac.authorization.k8s.io velero-ys1000


kubectl delete crds -l component=velero

```

## 配置

此表列出安装阶段所需的必要和可选参数，且指定过的参数在升级时需要同样指定，否则使用默认值:

| 参数命名                               | 描述                                                 | 示例                                                         |

| -------------------------------------- | ---------------------------------------------------- | ------------------------------------------------------------ |

| components.portal.serviceType          | 服务类型（可选，默认为 NodePort）                    | --set components.portal.serviceType=NodePort                 |

| components.webServer.serviceType       | 服务类型（可选，默认为 ClusterIP）                   | --set components.portal.serviceType=NodePort                 |

| migconfig.UIadminPassword              | 指定admin密码（可选，默认为“passw0rd”）            | --set migconfig.UIadminPassword=123456                       |

| migconfig.selfBackupIntervalSeconds    | 指定YS1000自备份间隔时长（可选，默认为“300”秒）    | --set migconfig.selfBackupIntervalSeconds=600                |

| featureGates.Archive                   | 是否开启归档功能（可选，默认为false）                | --set featureGates.Archive=true                              |

| featureGates.DisasterRecovery          | 是否开启容灾功能（可选，默认为false）                | --set featureGates.DisasterRecovery=true                     |

| featureGates.EtcdStub                  | 是否开启etcd备份功能（可选，默认为false）            | --set featureGates.EtcdStub=true                             |

| velero.resticPodVolumeOperationTimeout | restic拷贝podvolume的超时时长（可选，默认为“240m”  | --set velero.resticPodVolumeOperationTimeout=120m            |

| mysql.primary.persistence.enabled      | 是否对mysql数据做持久化（可选，默认为false）         | --set mysql.primary.persistence.enabled=true                 |

| mysql.primary.persistence.storageClass | 是否指定mysql存储类型（可选，默认为空）              | --set mysql.primary.persistence.storageClass=rook-ceph-block |

| mysql.auth.rootPassword                | 指定数据库root用户的密码（可选，默认为"passw0rd"）   | --set mysql.auth.rootPassword=123456                         |

| mysql.auth.database                    | 指定webserver使用的数据库（可选，默认为"webserver"） | --set mysql.auth.database=web                                |

| auth.username                          | 指定数据库的用户（可选，默认为"webserver"）          | --set auth.username=webuser                                  |

| auth.password                          | 指定数据库的密码（可选，默认为"passw0rd"）           | --set auth.password=123456                                   |

## 致谢

YS1000 产品中使用了[Velero](https://github.com/vmware-tanzu/velero) 开源项目以及[其他开源软件](https://github.com/jibutech/helm-charts/blob/main/credits.md)。

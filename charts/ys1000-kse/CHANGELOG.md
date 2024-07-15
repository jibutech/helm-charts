# Changelogs

This document records all significant changes to the project.

## v3.10.0

### Kubernetes cluster protection

Refactor kubernetes cluster backup function. User can add cluster instance for protection on etcd and configurations from master nodes

### DR UI Optimization

Refactor DR UI through DR dashboard and failover interaction

### DR app resource modification support

Support modification on application configuration from different clusters, such as Configmap, Service, any resource with JSON path update

### DR data sync enhancement

Integrate DR support with Percona MongoDB Cluster and add common external data volume sync configuration

## v3.9.2

### Resource Modifiers for Restore

Provide resource modification function during restore by using JSON merge path and Strategic Merge Patch.
In addition, it provides a simplified GUI interface to modifying common fields in Configmap, Secrets, Service, Ingress.

### Openshift migration support

Add support on Openshift platform and provide capability to migrate application from Openshift to Community Kubernetes platform.

### Legacy data volume migration support

Add function to migrate legacy data volumes (hostPath, nfs in-tree volume) to standard CSI PVC volume

### KubeVirt virtual Machine Protection（Tech Preview）

Provide Kubevirt virtual machine backup function with required version >= v1.0

## v3.8.2

* velero advanced resource collector for labeled backup
* fix dr hook when cluster not ready

## v3.8.1

### Resource Modifiers for Migration

In many use cases, customers often need to substitute specific values in Kubernetes resources during the restoration process like changing the namespace, changing the storage class, etc.

With the implementation of a new RestoreItemAction plugin, Resource Modifiers offer a generic solution in the restore workflow. It allows the user to define filters for specific resources and then specify a JSON Merge Patch and Strategic Merge Patch to apply to the resource.

### Bug Fixes

* Support select cluster and storage class for data verify during migration
* Fix backupjob failure due to no snapshot enabled on cluster
* Fix DR workflow hook running on both clusters
* Fix DR operation function table memory conflict
* Delete DR configurations and instances for cleanup
* Exclude snapshot resources for snapshot resource only restore
* Fix no incremental backups after full backups
* Fix could not click "Next" button in Advanced Settings when creating migration plan

## Initial Release

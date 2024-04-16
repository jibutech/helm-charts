# Changelogs
This document documents all significant changes to the project.

## [3.8.2]
* velero advanced resource collector for labeled backup
* fix dr hook when cluster not ready

## [3.8.1]
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

## [Initial Release]
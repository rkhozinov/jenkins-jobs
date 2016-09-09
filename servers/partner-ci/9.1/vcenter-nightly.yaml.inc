- runner-condition
- multijob:
    name: 'Smoke/BVT tests for vcenter5 {fuel-release}'
    condition: SUCCESSFUL
    projects:
     - name: '{fuel-release}.{plugin-name}.vcenter_dvs_bvt'
       property-file: build_number
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_dvs_bvt
         TEST_GROUP_PREFIX=system_test.vcenter.deploy_vcenter_dvs_run_ostf
         TEST_GROUP_CONFIG=vcenter_dvs_bvt
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_dvs_smoke'
       property-file: build_number
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_dvs_smoke
         TEST_GROUP_PREFIX=system_test.vcenter.deploy_vcenter_dvs_run_ostf
         TEST_GROUP_CONFIG=vcenter_dvs_smoke
       kill-phase-on: NEVER

- multijob:
    name: 'Nightly tests for vcenter5 {fuel-release}'
    condition: COMPLETED
    projects:
     - name: '{fuel-release}.{plugin-name}.vcenter_delete_cindervmware'
       property-file: build_number
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_delete_cindervmware
         TEST_GROUP_PREFIX=system_test.vcenter.scale_vcenter_dvs
         TEST_GROUP_CONFIG=vcenter_delete_cindervmware
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_delete_controller'
       property-file: build_number
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_delete_controller
         TEST_GROUP_PREFIX=system_test.vcenter.scale_vcenter_dvs
         TEST_GROUP_CONFIG=vcenter_delete_controller
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_delete_computevmware'
       property-file: build_number
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_delete_computevmware
         TEST_GROUP_PREFIX=system_test.vcenter.scale_vcenter_dvs
         TEST_GROUP_CONFIG=vcenter_delete_computevmware
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_add_computevmware'
       property-file: build_number
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_add_computevmware
         TEST_GROUP_PREFIX=system_test.vcenter.scale_vcenter_dvs
         TEST_GROUP_CONFIG=vcenter_add_computevmware
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_multiroles_computevmware_cindervmvare'
       property-file: build_number
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_multiroles_computevmware_cindervmvare
         TEST_GROUP_PREFIX=system_test.vcenter.deploy_vcenter_dvs_run_ostf
         TEST_GROUP_CONFIG=vcenter_multiroles_computevmware_cindervmvare
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_custom_hostname'
       property-file: build_number
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_custom_hostname
         TEST_GROUP_PREFIX=system_test.vcenter.deploy_with_custom_hostname
         TEST_GROUP_CONFIG=vcenter_vmware_roles
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_check_nova_conf'
       property-file: build_number
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_check_nova_conf
         TEST_GROUP_PREFIX=system_test.vcenter.check_nova_config
         TEST_GROUP_CONFIG=vcenter_dvs_bvt
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_check_nova_services'
       property-file: build_number
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_check_nova_services
         TEST_GROUP_PREFIX=system_test.vcenter.check_nova_srv
         TEST_GROUP_CONFIG=vcenter_vmware_roles
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_check_cindervmware_srv'
       property-file: build_number
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_check_cindervmware_srv
         TEST_GROUP_PREFIX=system_test.vcenter.check_cinder_srv
         TEST_GROUP_CONFIG=vcenter_vmware_roles
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_check_gw'
       property-file: build_number
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_check_gw
         TEST_GROUP_PREFIX=system_test.vcenter.neutron_public_net
         TEST_GROUP_CONFIG=vmware_roles_pub_ip
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_ceilometer_and_computevmware'
       property-file: build_number
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_ceilometer_and_computevmware
         TEST_GROUP_PREFIX=system_test.vcenter.deploy_vcenter_dvs_run_ostf
         TEST_GROUP_CONFIG=vcenter_ceilometer_and_computevmware
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_ceph_and_computevmware'
       property-file: build_number
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_ceph_and_computevmware
         TEST_GROUP_PREFIX=system_test.vcenter.deploy_vcenter_dvs_run_ostf
         TEST_GROUP_CONFIG=vcenter_ceph_and_computevmware
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_cindervmdk_and_computevmware'
       property-file: build_number
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_cindervmdk_and_computevmware
         TEST_GROUP_PREFIX=system_test.vcenter.deploy_vcenter_dvs_run_ostf
         TEST_GROUP_CONFIG=vcenter_cindervmdk_and_computevmware
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_computevmware'
       property-file: build_number
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_computevmware
         TEST_GROUP_PREFIX=system_test.vcenter.deploy_vcenter_dvs_run_ostf
         TEST_GROUP_CONFIG=vcenter_computevmware
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_glance_backend_and_computevmware'
       property-file: build_number
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_glance_backend_and_computevmware
         TEST_GROUP_PREFIX=system_test.vcenter.deploy_vcenter_dvs_run_ostf
         TEST_GROUP_CONFIG=vcenter_glance_backend_and_computevmware
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_ha_ceilometer'
       property-file: build_number
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_ha_ceilometer
         TEST_GROUP_PREFIX=system_test.vcenter.deploy_vcenter_dvs_run_ostf
         TEST_GROUP_CONFIG=vcenter_ha_ceilometer
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_ha_ceph'
       property-file: build_number
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_ha_ceph
         TEST_GROUP_PREFIX=system_test.vcenter.deploy_vcenter_dvs_run_ostf
         TEST_GROUP_CONFIG=vcenter_ha_ceph
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_ha_cinder_and_ceph'
       property-file: build_number
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_ha_cinder_and_ceph
         TEST_GROUP_PREFIX=system_test.vcenter.deploy_vcenter_dvs_run_ostf
         TEST_GROUP_CONFIG=vcenter_ha_cinder_and_ceph
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_ha_multiple_clusters'
       property-file: build_number
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_ha_multiple_clusters
         TEST_GROUP_PREFIX=system_test.vcenter.deploy_vcenter_dvs_run_ostf
         TEST_GROUP_CONFIG=vcenter_ha_multiple_clusters
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_multiroles_ceilometer'
       property-file: build_number
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_multiroles_ceilometer
         TEST_GROUP_PREFIX=system_test.vcenter.deploy_vcenter_dvs_run_ostf
         TEST_GROUP_CONFIG=vcenter_multiroles_ceilometer
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_multiroles_cindervmdk_and_ceph'
       property-file: build_number
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_multiroles_cindervmdk_and_ceph
         TEST_GROUP_PREFIX=system_test.vcenter.deploy_vcenter_dvs_run_ostf
         TEST_GROUP_CONFIG=vcenter_multiroles_cindervmdk_and_ceph
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_multiroles_cindervmdk_and_cinder'
       property-file: build_number
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_multiroles_cindervmdk_and_cinder
         TEST_GROUP_PREFIX=system_test.vcenter.deploy_vcenter_dvs_run_ostf
         TEST_GROUP_CONFIG=vcenter_multiroles_cindervmdk_and_cinder
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_cindervmdk'
       property-file: build_number
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_cindervmdk
         TEST_GROUP_PREFIX=system_test.vcenter.deploy_vcenter_dvs_run_ostf
         TEST_GROUP_CONFIG=vcenter_cindervmdk
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_attach_empty_vol'
       property-file: build_number
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_attach_empty_vol
         TEST_GROUP_PREFIX=system_test.vcenter.attach_empty_volume
         TEST_GROUP_CONFIG=vcenter_vmware_roles
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_bootable_vol'
       property-file: build_number
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_bootable_vol
         TEST_GROUP_PREFIX=system_test.vcenter.bootable_vol
         TEST_GROUP_CONFIG=vcenter_vmware_roles
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_vmware_datastore_upload_img'
       property-file: build_number
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_vmware_datastore_upload_img
         TEST_GROUP_PREFIX=system_test.vcenter.upload_image
         TEST_GROUP_CONFIG=vcenter_glance_backend_and_computevmware
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_cinder_upload_img'
       property-file: build_number
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_cinder_upload_img
         TEST_GROUP_PREFIX=system_test.vcenter.upload_image
         TEST_GROUP_CONFIG=vcenter_vmware_roles
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_ceph_upload_img'
       property-file: build_number
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_ceph_upload_img
         TEST_GROUP_PREFIX=system_test.vcenter.upload_image
         TEST_GROUP_CONFIG=vcenter_ceph_and_computevmware
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_vmxnet3'
       property-file: build_number
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_vmxnet3
         TEST_GROUP_PREFIX=system_test.vcenter.vmxnet3
         TEST_GROUP_CONFIG=vcenter_vmware_roles
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_batch_instance_creation'
       property-file: build_number
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_batch_instance_creation
         TEST_GROUP_PREFIX=system_test.vcenter.create_batch_of_instances
         TEST_GROUP_CONFIG=vcenter_vmware_roles
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_disktypes'
       property-file: build_number
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_disktypes
         TEST_GROUP_PREFIX=system_test.vcenter.diff_disk_types
         TEST_GROUP_CONFIG=vmware_roles_local_ds
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_add_controller'
       property-file: build_number
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_add_controller
         TEST_GROUP_PREFIX=system_test.vcenter.scale_vcenter_dvs
         TEST_GROUP_CONFIG=vcenter_add_controller
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_add_cindervmware'
       property-file: build_number
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_add_cindervmware
         TEST_GROUP_PREFIX=system_test.vcenter.scale_vcenter_dvs
         TEST_GROUP_CONFIG=vcenter_add_cindervmware
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_ha_kvm'
       property-file: build_number
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_ha_kvm
         TEST_GROUP_PREFIX=system_test.vcenter.deploy_vcenter_dvs_run_ostf
         TEST_GROUP_CONFIG=vcenter_dvs_bvt
         KVM_USE=True
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_disable_hosts'
       property-file: build_number
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_disable_hosts
         TEST_GROUP_PREFIX=system_test.vcenter.disable_enable_compute_service
         TEST_GROUP_CONFIG=vcenter_vmware_roles
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_shutdown_ctrl'
       property-file: build_number
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_shutdown_ctrl
         TEST_GROUP_PREFIX=system_test.vcenter.vcenter_shutdown_ctrl
         TEST_GROUP_CONFIG=vcenter_add_controller
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_reboot_ctrl'
       property-file: build_number
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_reboot_ctrl
         TEST_GROUP_PREFIX=system_test.vcenter.vcenter_reboot_ctrl
         TEST_GROUP_CONFIG=vcenter_dvs_failover
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_reset_ctrl'
       property-file: build_number
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_reset_ctrl
         TEST_GROUP_PREFIX=system_test.vcenter.vcenter_reset_ctrl
         TEST_GROUP_CONFIG=vcenter_dvs_failover
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_shutdown_cindervmware'
       property-file: build_number
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_shutdown_cindervmware
         TEST_GROUP_PREFIX=system_test.vcenter.vcenter_shutdown_cindervmware
         TEST_GROUP_CONFIG=vcenter_shutdown_cvm
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_reboot_cindervmware'
       property-file: build_number
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_reboot_cindervmware
         TEST_GROUP_PREFIX=system_test.vcenter.vcenter_reboot_cindervmware
         TEST_GROUP_CONFIG=vcenter_reboot_cvm
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_idatastore'
       property-file: build_number
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_idatastore
         TEST_GROUP_PREFIX=system_test.vcenter.vcenter_idatastore
         TEST_GROUP_CONFIG=vcenter_dvs_smoke
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_iname_glance_dc'
       property-file: build_number
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_iname_glance_dc
         TEST_GROUP_PREFIX=system_test.vcenter.vcenter_iname_glance_dc
         TEST_GROUP_CONFIG=vcenter_glance_backend
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_iname_glance_ds'
       property-file: build_number
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_iname_glance_ds
         TEST_GROUP_PREFIX=system_test.vcenter.vcenter_iname_glance_ds
         TEST_GROUP_CONFIG=vcenter_glance_backend
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_add_cluster_to_ctrl'
       property-file: build_number
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_add_cluster_to_ctrl
         TEST_GROUP_CONFIG=vcenter_add_cluster_to_ctrl
         TEST_GROUP_PREFIX=system_test.vcenter.scale_vcenter_dvs
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_mv_cluster_compute_to_compute'
       property-file: build_number
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_mv_cluster_compute_to_compute
         TEST_GROUP_CONFIG=vcenter_mv_cluster_compute_to_compute
         TEST_GROUP_PREFIX=system_test.vcenter.scale_vcenter_dvs
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_mv_cluster_compute_to_ctrl'
       property-file: build_number
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_mv_cluster_compute_to_ctrl
         TEST_GROUP_CONFIG=vcenter_mv_cluster_compute_to_ctrl
         TEST_GROUP_PREFIX=system_test.vcenter.scale_vcenter_dvs
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_mv_cluster_ctrl_to_compute'
       property-file: build_number
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_mv_cluster_ctrl_to_compute
         TEST_GROUP_CONFIG=vcenter_mv_cluster_ctrl_to_compute
         TEST_GROUP_PREFIX=system_test.vcenter.scale_vcenter_dvs
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_redeploy_successful_cluster'
       property-file: build_number
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_redeploy_successful_cluster
         TEST_GROUP_CONFIG=vcenter_glance_vmware_roles
         TEST_GROUP_PREFIX=system_test.vcenter.vcenter_redeploy_successful_cluster
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_redeploy_stopped_cluster'
       property-file: build_number
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_redeploy_stopped_cluster
         TEST_GROUP_CONFIG=vcenter_glance_vmware_roles
         TEST_GROUP_PREFIX=system_test.vcenter.vcenter_redeploy_stopped_cluster
         PROGRESS_TO_STOP=50
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_redeploy_failed_cluster'
       property-file: build_number
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_redeploy_failed_cluster
         TEST_GROUP_CONFIG=vcenter_glance_vmware_roles
         TEST_GROUP_PREFIX=system_test.vcenter.vcenter_redeploy_failed_cluster
       kill-phase-on: NEVER

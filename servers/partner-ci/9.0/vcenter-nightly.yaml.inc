- runner-condition
- multijob:
    name: 'Smoke/BVT tests for vcenter5 {fuel-release}'
    condition: SUCCESSFUL
    projects:
     - name: '{fuel-release}.{plugin-name}.vcenter_dvs_bvt'
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_dvs_bvt
         TEST_GROUP_PREFIX=system_test.vcenter.deploy_vcenter_dvs_run_ostf
         TEST_GROUP_CONFIG=vcenter_dvs_bvt
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_dvs_smoke'
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
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_delete_cindervmware
         TEST_GROUP_PREFIX=system_test.vcenter.deploy_vcenter_dvs_run_ostf
         TEST_GROUP_CONFIG=vcenter_delete_cindervmware
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_delete_controller'
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_delete_controller
         TEST_GROUP_PREFIX=system_test.vcenter.scale_vcenter_dvs_skipsrvcheck
         TEST_GROUP_CONFIG=vcenter_delete_controller
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_delete_computevmware'
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_delete_computevmware
         TEST_GROUP_PREFIX=system_test.vcenter.scale_vcenter_dvs_skipsrvcheck
         TEST_GROUP_CONFIG=vcenter_delete_computevmware
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_add_computevmware'
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_add_computevmware
         TEST_GROUP_PREFIX=system_test.vcenter.scale_vcenter_dvs
         TEST_GROUP_CONFIG=vcenter_add_computevmware
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_multiroles_computevmware_cindervmvare'
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_multiroles_computevmware_cindervmvare
         TEST_GROUP_PREFIX=system_test.vcenter.deploy_vcenter_dvs_run_ostf
         TEST_GROUP_CONFIG=vcenter_multiroles_computevmware_cindervmvare
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_custom_hostname'
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_custom_hostname
         TEST_GROUP_PREFIX=system_test.vcenter.deploy_with_custom_hostname
         TEST_GROUP_CONFIG=vcenter_vmware_roles
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_check_nova_conf'
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_check_nova_conf
         TEST_GROUP_PREFIX=system_test.vcenter.check_nova_config
         TEST_GROUP_CONFIG=vcenter_dvs_bvt
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_check_nova_services'
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_check_nova_services
         TEST_GROUP_PREFIX=system_test.vcenter.check_nova_srv
         TEST_GROUP_CONFIG=vcenter_vmware_roles
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_check_cindervmware_srv'
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_check_cindervmware_srv
         TEST_GROUP_PREFIX=system_test.vcenter.check_cinder_srv
         TEST_GROUP_CONFIG=vcenter_vmware_roles
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_check_gw'
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_check_gw
         TEST_GROUP_PREFIX=system_test.vcenter.neutron_public_net
         TEST_GROUP_CONFIG=vmware_roles_pub_ip
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_ceilometer_and_computevmware'
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_ceilometer_and_computevmware
         TEST_GROUP_PREFIX=system_test.vcenter.deploy_vcenter_dvs_run_ostf
         TEST_GROUP_CONFIG=vcenter_ceilometer_and_computevmware
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_ceph_and_computevmware'
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_ceph_and_computevmware
         TEST_GROUP_PREFIX=system_test.vcenter.deploy_vcenter_dvs_run_ostf
         TEST_GROUP_CONFIG=vcenter_ceph_and_computevmware
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_cindervmdk_and_computevmware'
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_cindervmdk_and_computevmware
         TEST_GROUP_PREFIX=system_test.vcenter.deploy_vcenter_dvs_run_ostf
         TEST_GROUP_CONFIG=vcenter_cindervmdk_and_computevmware
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_computevmware'
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_computevmware
         TEST_GROUP_PREFIX=system_test.vcenter.deploy_vcenter_dvs_run_ostf
         TEST_GROUP_CONFIG=vcenter_computevmware
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_glance_backend_and_computevmware'
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_glance_backend_and_computevmware
         TEST_GROUP_PREFIX=system_test.vcenter.deploy_vcenter_dvs_run_ostf
         TEST_GROUP_CONFIG=vcenter_glance_backend_and_computevmware
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_ha_ceilometer'
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_ha_ceilometer
         TEST_GROUP_PREFIX=system_test.vcenter.deploy_vcenter_dvs_run_ostf
         TEST_GROUP_CONFIG=vcenter_ha_ceilometer
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_ha_ceph'
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_ha_ceph
         TEST_GROUP_PREFIX=system_test.vcenter.deploy_vcenter_dvs_run_ostf
         TEST_GROUP_CONFIG=vcenter_ha_ceph
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_ha_cinder_and_ceph'
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_ha_cinder_and_ceph
         TEST_GROUP_PREFIX=system_test.vcenter.deploy_vcenter_dvs_run_ostf
         TEST_GROUP_CONFIG=vcenter_ha_cinder_and_ceph
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_ha_multiple_clusters'
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_ha_multiple_clusters
         TEST_GROUP_PREFIX=system_test.vcenter.deploy_vcenter_dvs_run_ostf
         TEST_GROUP_CONFIG=vcenter_ha_multiple_clusters
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_multiroles_ceilometer'
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_multiroles_ceilometer
         TEST_GROUP_PREFIX=system_test.vcenter.deploy_vcenter_dvs_run_ostf
         TEST_GROUP_CONFIG=vcenter_multiroles_ceilometer
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_multiroles_cindervmdk_and_ceph'
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_multiroles_cindervmdk_and_ceph
         TEST_GROUP_PREFIX=system_test.vcenter.deploy_vcenter_dvs_run_ostf
         TEST_GROUP_CONFIG=vcenter_multiroles_cindervmdk_and_ceph
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_multiroles_cindervmdk_and_cinder'
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_multiroles_cindervmdk_and_cinder
         TEST_GROUP_PREFIX=system_test.vcenter.deploy_vcenter_dvs_run_ostf
         TEST_GROUP_CONFIG=vcenter_multiroles_cindervmdk_and_cinder
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_cindervmdk'
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_cindervmdk
         TEST_GROUP_PREFIX=system_test.vcenter.deploy_vcenter_dvs_run_ostf
         TEST_GROUP_CONFIG=vcenter_cindervmdk
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_attach_empty_vol'
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_attach_empty_vol
         TEST_GROUP_PREFIX=system_test.vcenter.attach_empty_volume
         TEST_GROUP_CONFIG=vcenter_vmware_roles
       kill-phase-on: NEVER
         
     - name: '{fuel-release}.{plugin-name}.vcenter_bootable_vol'
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_bootable_vol
         TEST_GROUP_PREFIX=system_test.vcenter.bootable_vol
         TEST_GROUP_CONFIG=vcenter_vmware_roles
       kill-phase-on: NEVER
          
     - name: '{fuel-release}.{plugin-name}.vcenter_vmware_datastore_upload_img'
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_vmware_datastore_upload_img
         TEST_GROUP_PREFIX=system_test.vcenter.upload_image
         TEST_GROUP_CONFIG=vcenter_glance_backend_and_computevmware
       kill-phase-on: NEVER
          
     - name: '{fuel-release}.{plugin-name}.vcenter_cinder_upload_img'
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_cinder_upload_img
         TEST_GROUP_PREFIX=system_test.vcenter.upload_image
         TEST_GROUP_CONFIG=vcenter_vmware_roles
       kill-phase-on: NEVER
          
     - name: '{fuel-release}.{plugin-name}.vcenter_ceph_upload_img'
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_ceph_upload_img
         TEST_GROUP_PREFIX=system_test.vcenter.upload_image
         TEST_GROUP_CONFIG=vcenter_ceph_and_computevmware
       kill-phase-on: NEVER
          
     - name: '{fuel-release}.{plugin-name}.vcenter_vmxnet3'
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_vmxnet3
         TEST_GROUP_PREFIX=system_test.vcenter.vmxnet3
         TEST_GROUP_CONFIG=vcenter_vmware_roles
       kill-phase-on: NEVER
          
     - name: '{fuel-release}.{plugin-name}.vcenter_batch_instance_creation'
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_batch_instance_creation
         TEST_GROUP_PREFIX=system_test.vcenter.create_batch_of_instances
         TEST_GROUP_CONFIG=vcenter_vmware_roles
       kill-phase-on: NEVER
          
     - name: '{fuel-release}.{plugin-name}.vcenter_disktypes'
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_disktypes
         TEST_GROUP_PREFIX=system_test.vcenter.diff_disk_types
         TEST_GROUP_CONFIG=vmware_roles_local_ds
       kill-phase-on: NEVER
          
     - name: '{fuel-release}.{plugin-name}.vcenter_ha_kvm'
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP=vcenter_ha_kvm
         TEST_GROUP_PREFIX=system_test.vcenter.deploy_vcenter_dvs_run_ostf
         TEST_GROUP_CONFIG=vcenter_bvt
         KVM_USE=True
       kill-phase-on: NEVER

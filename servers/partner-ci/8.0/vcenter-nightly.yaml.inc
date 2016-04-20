- runner-condition
- multijob:
    name: 'Smoke/BVT tests for vcenter5 {fuel-release}'
    condition: SUCCESSFUL
    projects:
     - name: '{fuel-release}.{plugin-name}.vcenter_dvs_bvt'
       current-parameters: true
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_dvs_smoke'
       current-parameters: true
       kill-phase-on: NEVER

- multijob:
    name: 'System tests for {fuel-release}.{plugin-version} vcenter5'
    condition: COMPLETED
    projects:
     - name: '{fuel-release}.{plugin-name}.vcenter_add_cindervmware'
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP_PREFIX=system_test.vcenter.scale_vcenter_dvs
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_add_controller'
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP_PREFIX=system_test.vcenter.scale_vcenter_dvs
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_delete_cindervmware'
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP_PREFIX=system_test.vcenter.scale_vcenter_dvs
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_delete_controller'
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP_PREFIX=system_test.vcenter.scale_vcenter_dvs
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_ceilometer_and_computevmware'
       current-parameters: true
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_ceph_and_computevmware'
       current-parameters: true
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_cindervmdk_and_computevmware'
       current-parameters: true
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_computevmware'
       current-parameters: true
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_glance_backend_and_computevmware'
       current-parameters: true
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_ha_ceilometer'
       current-parameters: true
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_ha_ceph'
       current-parameters: true
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_ha_cinder_and_ceph'
       current-parameters: true
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_ha_multiple_clusters'
       current-parameters: true
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_multiroles_ceilometer'
       current-parameters: true
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_multiroles_cindervmdk_and_ceph'
       current-parameters: true
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_multiroles_cindervmdk_and_cinder'
       current-parameters: true
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_cindervmdk'
       current-parameters: true
       kill-phase-on: NEVER

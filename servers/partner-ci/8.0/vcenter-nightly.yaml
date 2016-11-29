- runner-condition
- multijob:
    name: 'Smoke/BVT tests for vcenter5 {fuel-release}'
    condition: SUCCESSFUL
    projects:
     - name: '{fuel-release}.{plugin-name}.vcenter_dvs_bvt'
       property-file: build_number
       current-parameters: true
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_dvs_smoke'
       property-file: build_number
       current-parameters: true
       kill-phase-on: NEVER

- multijob:
    name: 'System tests for {fuel-release}.{plugin-version} vcenter5'
    condition: COMPLETED
    projects:
     - name: '{fuel-release}.{plugin-name}.vcenter_add_cindervmware'
       property-file: build_number
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP_PREFIX=system_test.vcenter.scale_vcenter_dvs
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_add_controller'
       property-file: build_number
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP_PREFIX=system_test.vcenter.scale_vcenter_dvs
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_delete_cindervmware'
       property-file: build_number
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP_PREFIX=system_test.vcenter.scale_vcenter_dvs
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_delete_controller'
       property-file: build_number
       current-parameters: true
       predefined-parameters: |
         TEST_GROUP_PREFIX=system_test.vcenter.scale_vcenter_dvs
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_ceilometer_and_computevmware'
       property-file: build_number
       current-parameters: true
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_ceph_and_computevmware'
       property-file: build_number
       current-parameters: true
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_cindervmdk_and_computevmware'
       property-file: build_number
       current-parameters: true
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_computevmware'
       property-file: build_number
       current-parameters: true
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_glance_backend_and_computevmware'
       property-file: build_number
       current-parameters: true
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_ha_ceilometer'
       property-file: build_number
       current-parameters: true
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_ha_ceph'
       property-file: build_number
       current-parameters: true
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_ha_cinder_and_ceph'
       property-file: build_number
       current-parameters: true
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_ha_multiple_clusters'
       property-file: build_number
       current-parameters: true
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_multiroles_ceilometer'
       property-file: build_number
       current-parameters: true
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_multiroles_cindervmdk_and_ceph'
       property-file: build_number
       current-parameters: true
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_multiroles_cindervmdk_and_cinder'
       property-file: build_number
       current-parameters: true
       kill-phase-on: NEVER

     - name: '{fuel-release}.{plugin-name}.vcenter_cindervmdk'
       property-file: build_number
       current-parameters: true
       kill-phase-on: NEVER

- runner-condition
- multijob:
    name: 'System tests for {plugin-name} {fuel-release}.{plugin-version} vcenter5'
    condition: SUCCESSFUL
    projects:
     - name: '{fuel-release}.{plugin-name}.nsxt_smoke'
       current-parameters: true
       kill-phase-on: NEVER
       predefined-parameters: |
         TEST_GROUP=nsxt_smoke_scenarios
         VCENTER_USE=False
       property-file: build_number
     - name: '{fuel-release}.{plugin-name}.nsxt_bvt'
       current-parameters: true
       kill-phase-on: NEVER
       predefined-parameters: |
         VCENTER_USE=True
       property-file: build_number

- multijob:
    name: 'System tests for {plugin-name} {fuel-release}.{plugin-version} vcenter5'
    condition: COMPLETED
    projects:
     - name: '{fuel-release}.{plugin-name}.nsxt_ceilometer'
       current-parameters: true
       kill-phase-on: NEVER
       predefined-parameters: |
         VCENTER_USE=True
       property-file: build_number
     - name: '{fuel-release}.{plugin-name}.nsxt_ceph'
       current-parameters: true
       kill-phase-on: NEVER
       predefined-parameters: |
         VCENTER_USE=False
       property-file: build_number
     - name: '{fuel-release}.{plugin-name}.nsxt_add_delete_controller'
       current-parameters: true
       kill-phase-on: NEVER
       predefined-parameters: |
         VCENTER_USE=True
       property-file: build_number
     - name: '{fuel-release}.{plugin-name}.nsxt_add_delete_compute_node'
       current-parameters: true
       kill-phase-on: NEVER
       predefined-parameters: |
         VCENTER_USE=False
       property-file: build_number
     - name: '{fuel-release}.{plugin-name}.nsxt_add_delete_compute_vmware_node'
       current-parameters: true
       kill-phase-on: NEVER
       predefined-parameters: |
         VCENTER_USE=True
       property-file: build_number
     - name: '{fuel-release}.{plugin-name}.nsxt_uninstall_negative'
       current-parameters: true
       kill-phase-on: NEVER
       predefined-parameters: |
         VCENTER_USE=False
       property-file: build_number
     - name: '{fuel-release}.{plugin-name}.nsxt_shutdown_controller'
       current-parameters: true
       kill-phase-on: NEVER
       predefined-parameters: |
         VCENTER_USE=True
       property-file: build_number
     - name: '{fuel-release}.{plugin-name}.nsxt_setup_system'
       current-parameters: true
       kill-phase-on: NEVER
       predefined-parameters: |
         VCENTER_USE=True
       property-file: build_number
     - name: '{fuel-release}.{plugin-name}.nsxt_manage_ports'
       current-parameters: true
       kill-phase-on: NEVER
       predefined-parameters: |
         VCENTER_USE=True
       property-file: build_number
     - name: '{fuel-release}.{plugin-name}.nsxt_hot'
       current-parameters: true
       kill-phase-on: NEVER
       predefined-parameters: |
         VCENTER_USE=True
       property-file: build_number

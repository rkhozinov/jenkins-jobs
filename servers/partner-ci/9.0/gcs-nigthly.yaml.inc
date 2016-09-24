- runner-condition
- multijob:
    name: 'Pre-check for {plugin-name} {fuel-release}.{plugin-version}'
    condition: SUCCESSFUL
    projects:
     - name: '{fuel-release}.{plugin-name}.{plugin-version}.gcs_smoke'
       current-parameters: true
       kill-phase-on: NEVER
       property-file: build_number
     - name: '{fuel-release}.{plugin-name}.{plugin-version}.gcs_bvt'
       current-parameters: true
       kill-phase-on: NEVER
       property-file: build_number

- multijob:
    name: 'Nightly suite {plugin-name} {fuel-release}.{plugin-version}'
    condition: COMPLETED
    projects:
     - name: '{fuel-release}.{plugin-name}.{plugin-version}.gcs_ceph'
       current-parameters: true
       kill-phase-on: NEVER
       property-file: build_number
       
     - name: '{fuel-release}.{plugin-name}.{plugin-version}.gcs_cinder_multirole'
       current-parameters: true
       kill-phase-on: NEVER
       property-file: build_number
       
     - name: '{fuel-release}.{plugin-name}.{plugin-version}.gcs_cinder_ceph_multirole'
       current-parameters: true
       kill-phase-on: NEVER
       property-file: build_number
       
     - name: '{fuel-release}.{plugin-name}.{plugin-version}.gcs_ceilometer'
       current-parameters: true
       kill-phase-on: NEVER
       property-file: build_number
       
     - name: '{fuel-release}.{plugin-name}.{plugin-version}.gcs_delete_add_controller'
       current-parameters: true
       kill-phase-on: NEVER
       property-file: build_number
       
     - name: '{fuel-release}.{plugin-name}.{plugin-version}.gcs_delete_add_compute'
       current-parameters: true
       kill-phase-on: NEVER
       property-file: build_number
       
     - name: '{fuel-release}.{plugin-name}.{plugin-version}.gcs_delete_add_cinder'
       current-parameters: true
       kill-phase-on: NEVER
       property-file: build_number
       
     - name: '{fuel-release}.{plugin-name}.{plugin-version}.gcs_delete_add_single_cinder'
       current-parameters: true
       kill-phase-on: NEVER
       property-file: build_number
       
     - name: '{fuel-release}.{plugin-name}.{plugin-version}.gcs_add_ceph'
       current-parameters: true
       kill-phase-on: NEVER
       property-file: build_number

     - name: '{fuel-release}.{plugin-name}.{plugin-version}.gcs_gui_defaults'
       current-parameters: true
       kill-phase-on: NEVER
       property-file: build_number

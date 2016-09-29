- runner-condition
- multijob:
    name: 'Pre-check for {plugin-name} {fuel-release}.{plugin-version}'
    condition: SUCCESSFUL
    projects:
     - name: '{fuel-release}.{plugin-name}.manila_smoke'
       current-parameters: true
       kill-phase-on: NEVER
       property-file: build_number
     - name: '{fuel-release}.{plugin-name}.manila_bvt'
       current-parameters: true
       kill-phase-on: NEVER
       property-file: build_number

- multijob:
    name: 'System tests for {plugin-name} {fuel-release}.{plugin-version}'
    condition: SUCCESSFUL
    projects:
     - name: '{fuel-release}.{plugin-name}.manila_install'
       current-parameters: true
       kill-phase-on: NEVER
       property-file: build_number

     - name: '{fuel-release}.{plugin-name}.manila_data_ha'
       current-parameters: true
       kill-phase-on: NEVER
       property-file: build_number

     - name: '{fuel-release}.{plugin-name}.manila_share_ha'
       current-parameters: true
       kill-phase-on: NEVER
       property-file: build_number

     - name: '{fuel-release}.{plugin-name}.manila_with_ceilometer'
       current-parameters: true
       kill-phase-on: NEVER
       property-file: build_number

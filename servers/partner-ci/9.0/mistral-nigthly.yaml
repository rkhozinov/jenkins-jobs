- runner-condition
- multijob:
    name: 'Pre-check for {plugin-name} {fuel-release}.{plugin-version}'
    condition: SUCCESSFUL
    projects:
     - name: '{fuel-release}.{plugin-name}.{plugin-version}.mistral_smoke'
       current-parameters: true
       kill-phase-on: NEVER
       property-file: build_number
     - name: '{fuel-release}.{plugin-name}.{plugin-version}.mistral_bvt'
       current-parameters: true
       kill-phase-on: NEVER
       property-file: build_number

       #- multijob:
       #    name: 'Nightly suite {plugin-name} {fuel-release}.{plugin-version}'
       #    condition: COMPLETED
       #    projects:
       #     - name: '{fuel-release}.{plugin-name}.{plugin-version}.mistral_ceph'
       #       current-parameters: true
       #       kill-phase-on: NEVER
       #       property-file: build_number

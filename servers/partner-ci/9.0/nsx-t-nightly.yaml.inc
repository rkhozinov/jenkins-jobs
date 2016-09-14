- runner-condition
- multijob:
    name: 'System tests for {plugin-name} {fuel-release}.{plugin-version} vcenter5'
    condition: SUCCESSFUL
    projects:
     - name: '{fuel-release}.{plugin-name}.nsx-t_smoke'
       current-parameters: true
       kill-phase-on: NEVER
       property-file: build_number
     - name: '{fuel-release}.{plugin-name}.nsx-t_bvt'
       current-parameters: true
       kill-phase-on: NEVER
       property-file: build_number

#- multijob:
#    name: 'System tests for {plugin-name} {fuel-release}.{plugin-version} vcenter5'
#    condition: COMPLETED
#    projects:
#     - name: '{fuel-release}.{plugin-name}.nsx-t_add_delete_nodes'
#       current-parameters: true
#       kill-phase-on: NEVER
#       property-file: build_number
#     - name: '{fuel-release}.{plugin-name}.nsx-t_add_delete_controller'
#       current-parameters: true
#       kill-phase-on: NEVER
#       property-file: build_number

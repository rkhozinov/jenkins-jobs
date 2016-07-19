- runner-condition
- multijob:
    name: >
      'Baremetal tests for {fuel-release}.{plugin-name}.{plugin-version}'
    condition: COMPLETED
    projects:
      - name: '{fuel-release}.{plugin-name}.{plugin-version}.contrail_ha_dpdk.juniper'
        property-file: build_number
        node-label-name: 'label'
        node-label: 'contrail-baremetal'
        predefined-parameters: |
           CONTRAIL_DISTRIBUTION=juniper
           node=contrail-baremetal
        current-parameters: true
        kill-phase-on: NEVER
      - name: '{fuel-release}.{plugin-name}.{plugin-version}.contrail_dpdk_add_compute.juniper'
        property-file: build_number
        node-label-name: 'label'
        node-label: 'contrail-baremetal'
        predefined-parameters: |
           CONTRAIL_DISTRIBUTION=juniper
           node=contrail-baremetal
        current-parameters: true
        kill-phase-on: NEVER
      - name: '{fuel-release}.{plugin-name}.{plugin-version}.contrail_dpdk_delete_compute.juniper'
        property-file: build_number
        node-label-name: 'label'
        node-label: 'contrail-baremetal'
        predefined-parameters: |
           CONTRAIL_DISTRIBUTION=juniper
           node=contrail-baremetal
        current-parameters: true
        kill-phase-on: NEVER
      - name: '{fuel-release}.{plugin-name}.{plugin-version}.contrail_dpdk_add_dpdk.juniper'
        property-file: build_number
        node-label-name: 'label'
        node-label: 'contrail-baremetal'
        predefined-parameters: |
           CONTRAIL_DISTRIBUTION=juniper
           node=contrail-baremetal
        current-parameters: true
        kill-phase-on: NEVER
      - name: '{fuel-release}.{plugin-name}.{plugin-version}.contrail_dpdk_delete_dpdk.juniper'
        property-file: build_number
        node-label-name: 'label'
        node-label: 'contrail-baremetal'
        predefined-parameters: |
           CONTRAIL_DISTRIBUTION=juniper
           node=contrail-baremetal
        current-parameters: true
        kill-phase-on: NEVER

- runner-condition
- inject:
    properties-content: |
      BM_IPMI_USER=engineer
      BM_IPMI_PASSWORD=Ba2Ie23#GHgho
      BM_IPMI_ADDR=cz7660-kvm.host-telecom.com
      BM_TARGET_MACS=00:1b:21:87:21:99;00:1b:21:87:21:98
      BM_HOST_BRIDGE_INTERFACES=eth2:10.109.0.0/24;eth3:10.109.4.0/24
      KVM_USE=True
- multijob:
    name: >
      'Baremetal DPDK for {fuel-release}.{plugin-name}.{plugin-version}'
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

      - name: '{fuel-release}.{plugin-name}.{plugin-version}.contrail_dpdk_add_controller.juniper'
        property-file: build_number
        node-label-name: 'label'
        node-label: 'contrail-baremetal'
        predefined-parameters: |
           CONTRAIL_DISTRIBUTION=juniper
           node=contrail-baremetal
        current-parameters: true
        kill-phase-on: NEVER

      - name: '{fuel-release}.{plugin-name}.{plugin-version}.contrail_dpdk_delete_controller.juniper'
        property-file: build_number
        node-label-name: 'label'
        node-label: 'contrail-baremetal'
        predefined-parameters: |
           CONTRAIL_DISTRIBUTION=juniper
           node=contrail-baremetal
        current-parameters: true
        kill-phase-on: NEVER

      - name: '{fuel-release}.{plugin-name}.{plugin-version}.contrail_add_to_dpdk_sriov.juniper'
        property-file: build_number
        node-label-name: 'label'
        node-label: 'contrail-baremetal'
        predefined-parameters: |
           CONTRAIL_DISTRIBUTION=juniper
           node=contrail-baremetal
        current-parameters: true
        kill-phase-on: NEVER

- multijob:
    name: >
      'Baremetal SRIOV for {fuel-release}.{plugin-name}.{plugin-version}'
    condition: COMPLETED
    projects:

      - name: '{fuel-release}.{plugin-name}.{plugin-version}.contrail_ha_sriov.juniper'
        property-file: build_number
        node-label-name: 'label'
        node-label: 'contrail-baremetal'
        predefined-parameters: |
           CONTRAIL_DISTRIBUTION=juniper
           node=contrail-baremetal
        current-parameters: true
        kill-phase-on: NEVER

      - name: '{fuel-release}.{plugin-name}.{plugin-version}.contrail_sriov_add_compute.juniper'
        property-file: build_number
        node-label-name: 'label'
        node-label: 'contrail-baremetal'
        predefined-parameters: |
           CONTRAIL_DISTRIBUTION=juniper
           node=contrail-baremetal
        current-parameters: true
        kill-phase-on: NEVER

      - name: '{fuel-release}.{plugin-name}.{plugin-version}.contrail_sriov_delete_compute.juniper'
        property-file: build_number
        node-label-name: 'label'
        node-label: 'contrail-baremetal'
        predefined-parameters: |
           CONTRAIL_DISTRIBUTION=juniper
           node=contrail-baremetal
        current-parameters: true
        kill-phase-on: NEVER

      - name: '{fuel-release}.{plugin-name}.{plugin-version}.contrail_sriov_add_sriov.juniper'
        property-file: build_number
        node-label-name: 'label'
        node-label: 'contrail-baremetal'
        predefined-parameters: |
           CONTRAIL_DISTRIBUTION=juniper
           node=contrail-baremetal
        current-parameters: true
        kill-phase-on: NEVER

      - name: '{fuel-release}.{plugin-name}.{plugin-version}.contrail_sriov_delete_sriov.juniper'
        property-file: build_number
        node-label-name: 'label'
        node-label: 'contrail-baremetal'
        predefined-parameters: |
           CONTRAIL_DISTRIBUTION=juniper
           node=contrail-baremetal
        current-parameters: true
        kill-phase-on: NEVER

      - name: '{fuel-release}.{plugin-name}.{plugin-version}.contrail_sriov_add_controller.juniper'
        property-file: build_number
        node-label-name: 'label'
        node-label: 'contrail-baremetal'
        predefined-parameters: |
           CONTRAIL_DISTRIBUTION=juniper
           node=contrail-baremetal
        current-parameters: true
        kill-phase-on: NEVER

      - name: '{fuel-release}.{plugin-name}.{plugin-version}.contrail_sriov_delete_controller.juniper'
        property-file: build_number
        node-label-name: 'label'
        node-label: 'contrail-baremetal'
        predefined-parameters: |
           CONTRAIL_DISTRIBUTION=juniper
           node=contrail-baremetal
        current-parameters: true
        kill-phase-on: NEVER

      - name: '{fuel-release}.{plugin-name}.{plugin-version}.contrail_dpdk_update_core_repos.juniper'
        property-file: build_number
        node-label-name: 'label'
        node-label: 'contrail-baremetal'
        predefined-parameters: |
           CONTRAIL_DISTRIBUTION=juniper
           node=contrail-baremetal
        current-parameters: true
        kill-phase-on: NEVER

      - name: '{fuel-release}.{plugin-name}.{plugin-version}.contrail_sriov_update_core_repos.juniper'
        property-file: build_number
        node-label-name: 'label'
        node-label: 'contrail-baremetal'
        predefined-parameters: |
           CONTRAIL_DISTRIBUTION=juniper
           node=contrail-baremetal
        current-parameters: true
        kill-phase-on: NEVER

- multijob:
    name: >
      'Baremetal DPDK on VF for {fuel-release}.{plugin-name}.{plugin-version}'
    condition: COMPLETED
    projects:
      - name: '{fuel-release}.{plugin-name}.{plugin-version}.contrail_ha_dpdk_on_vf.juniper'
        property-file: build_number
        node-label-name: 'label'
        node-label: 'contrail-baremetal'
        predefined-parameters: |
           contrail_distribution=juniper
           node=contrail-baremetal
        current-parameters: true
        kill-phase-on: never

      - name: '{fuel-release}.{plugin-name}.{plugin-version}.contrail_dpdk_on_vf_add_compute.juniper'
        property-file: build_number
        node-label-name: 'label'
        node-label: 'contrail-baremetal'
        predefined-parameters: |
           contrail_distribution=juniper
           node=contrail-baremetal
        current-parameters: true
        kill-phase-on: never

      - name: '{fuel-release}.{plugin-name}.{plugin-version}.contrail_dpdk_on_vf_delete_compute.juniper'
        property-file: build_number
        node-label-name: 'label'
        node-label: 'contrail-baremetal'
        predefined-parameters: |
           contrail_distribution=juniper
           node=contrail-baremetal
        current-parameters: true
        kill-phase-on: never

      - name: '{fuel-release}.{plugin-name}.{plugin-version}.contrail_dpdk_on_vf_add_dpdk.juniper'
        property-file: build_number
        node-label-name: 'label'
        node-label: 'contrail-baremetal'
        predefined-parameters: |
           contrail_distribution=juniper
           node=contrail-baremetal
        current-parameters: true
        kill-phase-on: never

      - name: '{fuel-release}.{plugin-name}.{plugin-version}.contrail_dpdk_on_vf_delete_dpdk.juniper'
        property-file: build_number
        node-label-name: 'label'
        node-label: 'contrail-baremetal'
        predefined-parameters: |
           contrail_distribution=juniper
           node=contrail-baremetal
        current-parameters: true
        kill-phase-on: never

      - name: '{fuel-release}.{plugin-name}.{plugin-version}.contrail_dpdk_on_vf_add_controller.juniper'
        property-file: build_number
        node-label-name: 'label'
        node-label: 'contrail-baremetal'
        predefined-parameters: |
           contrail_distribution=juniper
           node=contrail-baremetal
        current-parameters: true
        kill-phase-on: never


      - name: '{fuel-release}.{plugin-name}.{plugin-version}.contrail_dpdk_on_vf_delete_controller.juniper'
        property-file: build_number
        node-label-name: 'label'
        node-label: 'contrail-baremetal'
        predefined-parameters: |
           contrail_distribution=juniper
           node=contrail-baremetal
        current-parameters: true
        kill-phase-on: never

      - name: '{fuel-release}.{plugin-name}.{plugin-version}.contrail_dpdk_on_vf_disable.juniper'
        property-file: build_number
        node-label-name: 'label'
        node-label: 'contrail-baremetal'
        predefined-parameters: |
           contrail_distribution=juniper
           node=contrail-baremetal
        current-parameters: true
        kill-phase-on: never

      - name: '{fuel-release}.{plugin-name}.{plugin-version}.contrail_dpdk_on_vf_enable.juniper'
        property-file: build_number
        node-label-name: 'label'
        node-label: 'contrail-baremetal'
        predefined-parameters: |
           contrail_distribution=juniper
           node=contrail-baremetal
        current-parameters: true
        kill-phase-on: never

- runner-condition
- multijob:
    name: 'Smoke/BVT test for dvs{fuel-release}.{plugin-version} vcenter5'
    condition: SUCCESSFUL
    projects:
      - name: '{fuel-release}.{plugin-name}.dvs_vcenter_smoke'
        predefined-parameters: |
          TEST_GROUP=dvs_vcenter_smoke
          TEST_GROUP_CONFIG=dvs_vcenter_smoke
        property-file: build_number
        current-parameters: true
        kill-phase-on: NEVER
      - name: '{fuel-release}.{plugin-name}.dvs_vcenter_bvt'
        predefined-parameters: |
          TEST_GROUP=dvs_vcenter_bvt
          TEST_GROUP_CONFIG=dvs_vcenter_bvt
        property-file: build_number
        current-parameters: true
        kill-phase-on: NEVER

- multijob:
    name: 'System tests for dvs{fuel-release}.{plugin-version} vcenter5'
    condition: COMPLETED
    projects:
      - name: '{fuel-release}.{plugin-name}.dvs_vcenter_networks'
        property-file: build_number
        predefined-parameters: |
          TEST_GROUP=dvs_vcenter_networks
          TEST_GROUP_CONFIG=dvs_vcenter_networks
        current-parameters: true
        kill-phase-on: NEVER

      - name: '{fuel-release}.{plugin-name}.dvs_vcenter_ping_public'
        property-file: build_number
        predefined-parameters: |
          TEST_GROUP=dvs_vcenter_ping_public
          TEST_GROUP_CONFIG=dvs_vcenter_ping_public
        current-parameters: true
        kill-phase-on: NEVER

      - name: '{fuel-release}.{plugin-name}.dvs_instances_one_group'
        property-file: build_number
        predefined-parameters: |
          TEST_GROUP=dvs_instances_one_group
          TEST_GROUP_CONFIG=dvs_instances_one_group
        current-parameters: true
        kill-phase-on: NEVER

      - name: '{fuel-release}.{plugin-name}.dvs_vcenter_security'
        predefined-parameters: |
          TEST_GROUP=dvs_vcenter_security
          TEST_GROUP_CONFIG=dvs_vcenter_security
        property-file: build_number
        current-parameters: true
        kill-phase-on: NEVER

      - name: '{fuel-release}.{plugin-name}.dvs_vcenter_tenants_isolation'
        property-file: build_number
        predefined-parameters: |
          TEST_GROUP=dvs_vcenter_tenants_isolation
          TEST_GROUP_CONFIG=dvs_vcenter_tenants_isolation
        current-parameters: true
        kill-phase-on: NEVER

      - name: '{fuel-release}.{plugin-name}.dvs_vcenter_same_ip'
        predefined-parameters: |
          TEST_GROUP=dvs_vcenter_same_ip
          TEST_GROUP_CONFIG=dvs_vcenter_same_ip
        property-file: build_number
        current-parameters: true
        kill-phase-on: NEVER

      - name: '{fuel-release}.{plugin-name}.dvs_vcenter_bind_port'
        property-file: build_number
        predefined-parameters: |
          TEST_GROUP=dvs_vcenter_bind_port
          TEST_GROUP_CONFIG=dvs_vcenter_bind_port
        current-parameters: true
        kill-phase-on: NEVER

      - name: '{fuel-release}.{plugin-name}.dvs_vcenter_reset_controller'
        property-file: build_number
        predefined-parameters: |
          TEST_GROUP=dvs_vcenter_reset_controller
          TEST_GROUP_CONFIG=dvs_vcenter_reset_controller
        current-parameters: true
        kill-phase-on: NEVER

      - name: '{fuel-release}.{plugin-name}.dvs_vcenter_net_template'
        property-file: build_number
        predefined-parameters: |
          TEST_GROUP=dvs_vcenter_net_template
          TEST_GROUP_CONFIG=dvs_vcenter_net_template
        current-parameters: true
        kill-phase-on: NEVER

      - name: '{fuel-release}.{plugin-name}.dvs_vcenter_shutdown_controller'
        property-file: build_number
        predefined-parameters: |
          TEST_GROUP=dvs_vcenter_shutdown_controller
          TEST_GROUP_CONFIG=dvs_vcenter_shutdown_controller
        current-parameters: true
        kill-phase-on: NEVER

      - name: '{fuel-release}.{plugin-name}.dvs_different_networks'
        property-file: build_number
        predefined-parameters: |
          TEST_GROUP=dvs_different_networks
          TEST_GROUP_CONFIG=dvs_different_networks
        current-parameters: true
        kill-phase-on: NEVER

      - name: '{fuel-release}.{plugin-name}.dvs_remote_sg_simple'
        property-file: build_number
        predefined-parameters: |
          TEST_GROUP=dvs_remote_sg_simple
          TEST_GROUP_CONFIG=dvs_remote_sg_simple
        current-parameters: true
        kill-phase-on: NEVER

      - name: '{fuel-release}.{plugin-name}.dvs_remote_ip_prefix'
        property-file: build_number
        predefined-parameters: |
          TEST_GROUP=dvs_remote_ip_prefix
          TEST_GROUP_CONFIG=dvs_remote_ip_prefix
        current-parameters: true
        kill-phase-on: NEVER

      - name: '{fuel-release}.{plugin-name}.dvs_connect_default_net'
        property-file: build_number
        predefined-parameters: |
          TEST_GROUP=dvs_connect_default_net
          TEST_GROUP_CONFIG=dvs_connect_default_net
        current-parameters: true
        kill-phase-on: NEVER

      - name: '{fuel-release}.{plugin-name}.dvs_connect_nodefault_net'
        property-file: build_number
        predefined-parameters: |
          TEST_GROUP=dvs_connect_nodefault_net
          TEST_GROUP_CONFIG=dvs_connect_nodefault_net
        current-parameters: true
        kill-phase-on: NEVER

      - name: '{fuel-release}.{plugin-name}.dvs_ping_without_fip'
        property-file: build_number
        predefined-parameters: |
          TEST_GROUP=dvs_ping_without_fip
          TEST_GROUP_CONFIG=dvs_ping_without_fip
        current-parameters: true
        kill-phase-on: NEVER

      - name: '{fuel-release}.{plugin-name}.dvs_reboot_vcenter_1'
        property-file: build_number
        predefined-parameters: |
          TEST_GROUP=dvs_reboot_vcenter_1
          TEST_GROUP_CONFIG=dvs_reboot_vcenter_1
        current-parameters: true
        kill-phase-on: NEVER

      - name: '{fuel-release}.{plugin-name}.dvs_reboot_vcenter_2'
        property-file: build_number
        predefined-parameters: |
          TEST_GROUP=dvs_reboot_vcenter_2
          TEST_GROUP_CONFIG=dvs_reboot_vcenter_2
        current-parameters: true
        kill-phase-on: NEVER

      - name: '{fuel-release}.{plugin-name}.dvs_volume'
        property-file: build_number
        predefined-parameters: |
          TEST_GROUP=dvs_volume
          TEST_GROUP_CONFIG=dvs_volume
        current-parameters: true
        kill-phase-on: NEVER

      - name: '{fuel-release}.{plugin-name}.dvs_update_network'
        property-file: build_number
        predefined-parameters: |
          TEST_GROUP=dvs_update_network
          TEST_GROUP_CONFIG=dvs_update_network
        current-parameters: true
        kill-phase-on: NEVER

      - name: '{fuel-release}.{plugin-name}.dvs_port_security_group'
        property-file: build_number
        predefined-parameters: |
          TEST_GROUP=dvs_port_security_group
          TEST_GROUP_CONFIG=dvs_port_security_group
        current-parameters: true
        kill-phase-on: NEVER

      - name: '{fuel-release}.{plugin-name}.dvs_attached_ports'
        property-file: build_number
        predefined-parameters: |
          TEST_GROUP=dvs_attached_ports
          TEST_GROUP_CONFIG=dvs_attached_ports
        current-parameters: true
        kill-phase-on: NEVER

      - name: '{fuel-release}.{plugin-name}.dvs_instances_batch_mix_sg'
        property-file: build_number
        predefined-parameters: |
          TEST_GROUP=dvs_instances_batch_mix_sg
          TEST_GROUP_CONFIG=dvs_instances_batch_mix_sg
        current-parameters: true
        kill-phase-on: NEVER

      - name: '{fuel-release}.{plugin-name}.dvs_vcenter_multiple_nics'
        property-file: build_number
        predefined-parameters: |
          TEST_GROUP=dvs_vcenter_multiple_nics
          TEST_GROUP_CONFIG=dvs_vcenter_multiple_nics
        current-parameters: true
        kill-phase-on: NEVER

      - name: '{fuel-release}.{plugin-name}.dvs_vcenter_uninstall'
        property-file: build_number
        predefined-parameters: |
          TEST_GROUP=dvs_vcenter_uninstall
          TEST_GROUP_CONFIG=dvs_vcenter_uninstall
        current-parameters: true
        kill-phase-on: NEVER

      - name: '{fuel-release}.{plugin-name}.dvs_heat'
        property-file: build_number
        predefined-parameters: |
          TEST_GROUP=dvs_heat
          TEST_GROUP_CONFIG=dvs_heat
        current-parameters: true
        kill-phase-on: NEVER

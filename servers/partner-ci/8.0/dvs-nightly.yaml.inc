- runner-conditions
- multijob:
    name: 'System tests for dvs{fuel-release}.{plugin-version} vcenter5'
    condition: COMPLETED
    projects:
      - name: '{fuel-release}.{plugin-name}.dvs_vcenter_systest_setup'
        property-file: build_number
        current-parameters: true
        kill-phase-on: NEVER
      - name: '{fuel-release}.{plugin-name}.dvs_vcenter_networks'
        property-file: build_number
        current-parameters: true
        kill-phase-on: NEVER
      - name: '{fuel-release}.{plugin-name}.dvs_vcenter_ping_public'
        property-file: build_number
        current-parameters: true
        kill-phase-on: NEVER
      - name: '{fuel-release}.{plugin-name}.dvs_instances_one_group'
        property-file: build_number
        current-parameters: true
        kill-phase-on: NEVER
      - name: '{fuel-release}.{plugin-name}.dvs_vcenter_security'
        property-file: build_number
        current-parameters: true
        kill-phase-on: NEVER
      - name: '{fuel-release}.{plugin-name}.dvs_vcenter_tenants_isolation'
        property-file: build_number
        current-parameters: true
        kill-phase-on: NEVER
      - name: '{fuel-release}.{plugin-name}.dvs_vcenter_same_ip'
        property-file: build_number
        current-parameters: true
        kill-phase-on: NEVER
      - name: '{fuel-release}.{plugin-name}.dvs_vcenter_uninstall'
        property-file: build_number
        current-parameters: true
        kill-phase-on: NEVER
      - name: '{fuel-release}.{plugin-name}.dvs_vcenter_bind_port'
        property-file: build_number
        current-parameters: true
        kill-phase-on: NEVER
      - name: '{fuel-release}.{plugin-name}.dvs_vcenter_reset_controller'
        property-file: build_number
        current-parameters: true
        kill-phase-on: NEVER
      - name: '{fuel-release}.{plugin-name}.dvs_vcenter_net_template'
        property-file: build_number
        current-parameters: true
        kill-phase-on: NEVER
      - name: '{fuel-release}.{plugin-name}.dvs_vcenter_shutdown_controller'
        property-file: build_number
        current-parameters: true
        kill-phase-on: NEVER
      - name: '{fuel-release}.{plugin-name}.dvs_different_networks'
        property-file: build_number
        current-parameters: true
        kill-phase-on: NEVER
      - name: '{fuel-release}.{plugin-name}.dvs_install'
        property-file: build_number
        current-parameters: true
        kill-phase-on: NEVER
      - name: '{fuel-release}.{plugin-name}.dvs_uninstall'
        property-file: build_number
        current-parameters: true
        kill-phase-on: NEVER

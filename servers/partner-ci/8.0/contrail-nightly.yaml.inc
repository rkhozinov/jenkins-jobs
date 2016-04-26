- runner-condition
- multijob:
    name: >
      'Smoke/bvt tests to check before running of nighlty tests.
       The nightly tests scope will be runned only if smoke/bvt will have successful state'
    condition: SUCCESSFUL
    projects:
      - name: '{fuel-release}.{plugin-name}.{plugin-version}.contrail_smoke.juniper'
        property-file: build_number
        predefined-parameters: |
           CONTRAIL_DISTRIBUTION=juniper
        current-parameters: true
        kill-phase-on: FAILURE
      - name: '{fuel-release}.{plugin-name}.{plugin-version}.contrail_bvt.juniper'
        property-file: build_number
        predefined-parameters: |
           CONTRAIL_DISTRIBUTION=juniper
        current-parameters: true
        kill-phase-on: FAILURE
- multijob:
    name: >
      'Nightly tests for {fuel-release}.{plugin-name}.{plugin-version}'
    condition: COMPLETED
    projects:
      - name: '{fuel-release}.{plugin-name}.{plugin-version}.contrail_ha.juniper'
        property-file: build_number
        predefined-parameters: |
           CONTRAIL_DISTRIBUTION=juniper
        current-parameters: true
        kill-phase-on: NEVER
      - name: '{fuel-release}.{plugin-name}.{plugin-version}.contrail_ha_baseos.juniper'
        property-file: build_number
        predefined-parameters: |
           CONTRAIL_DISTRIBUTION=juniper
        current-parameters: true
        kill-phase-on: NEVER
      - name: '{fuel-release}.{plugin-name}.{plugin-version}.contrail_ceilometer.juniper'
        property-file: build_number
        predefined-parameters: |
           CONTRAIL_DISTRIBUTION=juniper
        current-parameters: true
        kill-phase-on: NEVER
      - name: '{fuel-release}.{plugin-name}.{plugin-version}.contrail_vlan.juniper'
        property-file: build_number
        predefined-parameters: |
           CONTRAIL_DISTRIBUTION=juniper
        current-parameters: true
        kill-phase-on: NEVER
      - name: '{fuel-release}.{plugin-name}.{plugin-version}.contrail_jumbo.juniper'
        property-file: build_number
        predefined-parameters: |
           CONTRAIL_DISTRIBUTION=juniper
        current-parameters: true
        kill-phase-on: NEVER

        property-file: build_number
      - name: '{fuel-release}.{plugin-name}.{plugin-version}.contrail_bonding.juniper'
        predefined-parameters: |
           CONTRAIL_DISTRIBUTION=juniper
        current-parameters: true
        kill-phase-on: NEVER
        property-file: build_number

      - name: '{fuel-release}.{plugin-name}.{plugin-version}.contrail_ceph_multirole.juniper'
        predefined-parameters: |
           CONTRAIL_DISTRIBUTION=juniper
        current-parameters: true
        property-file: build_number
        kill-phase-on: NEVER

      - name: '{fuel-release}.{plugin-name}.{plugin-version}.contrail_cinder_multirole.juniper'
        predefined-parameters: |
           CONTRAIL_DISTRIBUTION=juniper
        property-file: build_number
        current-parameters: true
        kill-phase-on: NEVER

      - name: '{fuel-release}.{plugin-name}.{plugin-version}.contrail_cinder_ceph_multirole.juniper'
        predefined-parameters: |
        property-file: build_number
           CONTRAIL_DISTRIBUTION=juniper
        current-parameters: true
        kill-phase-on: NEVER

      - name: '{fuel-release}.{plugin-name}.{plugin-version}.contrail_plugin_add_delete_controller_node.juniper'
        property-file: build_number
        predefined-parameters: |
           CONTRAIL_DISTRIBUTION=juniper
        current-parameters: true
        kill-phase-on: NEVER

      - name: '{fuel-release}.{plugin-name}.{plugin-version}.contrail_plugin_add_delete_compute_node.juniper'
        property-file: build_number
        predefined-parameters: |
           CONTRAIL_DISTRIBUTION=juniper
        current-parameters: true
        kill-phase-on: NEVER

      - name: '{fuel-release}.{plugin-name}.{plugin-version}.contrail_add_control.juniper'
        property-file: build_number
        predefined-parameters: |
           CONTRAIL_DISTRIBUTION=juniper
        current-parameters: true
        kill-phase-on: NEVER

      - name: '{fuel-release}.{plugin-name}.{plugin-version}.contrail_ha_with_shutdown_contrail_node.juniper'
        property-file: build_number
        predefined-parameters: |
           CONTRAIL_DISTRIBUTION=juniper
        current-parameters: true
        kill-phase-on: NEVER
      - name: '{fuel-release}.{plugin-name}.{plugin-version}.cannot_deploy_only_contrail_db.juniper'
        property-file: build_number
        predefined-parameters: |
           CONTRAIL_DISTRIBUTION=juniper
        current-parameters: true
        kill-phase-on: NEVER
      - name: '{fuel-release}.{plugin-name}.{plugin-version}.cannot_deploy_only_contrail_config.juniper'
        property-file: build_number
        predefined-parameters: |
           CONTRAIL_DISTRIBUTION=juniper
        current-parameters: true
        kill-phase-on: NEVER
      - name: '{fuel-release}.{plugin-name}.{plugin-version}.cannot_deploy_only_contrail_control.juniper'
        property-file: build_number
        predefined-parameters: |
           CONTRAIL_DISTRIBUTION=juniper
        current-parameters: true
        kill-phase-on: NEVER
      - name: '{fuel-release}.{plugin-name}.{plugin-version}.contrail_add_config.juniper'
        property-file: build_number
        predefined-parameters: |
           CONTRAIL_DISTRIBUTION=juniper
        current-parameters: true
        kill-phase-on: NEVER
      - name: '{fuel-release}.{plugin-name}.{plugin-version}.contrail_delete_control.juniper'
        property-file: build_number
        predefined-parameters: |
           CONTRAIL_DISTRIBUTION=juniper
        current-parameters: true
        kill-phase-on: NEVER
      - name: '{fuel-release}.{plugin-name}.{plugin-version}.contrail_delete_config.juniper'
        property-file: build_number
        predefined-parameters: |
           CONTRAIL_DISTRIBUTION=juniper
        current-parameters: true
        kill-phase-on: NEVER
      - name: '{fuel-release}.{plugin-name}.{plugin-version}.contrail_add_db.juniper'
        property-file: build_number
        predefined-parameters: |
           CONTRAIL_DISTRIBUTION=juniper
        current-parameters: true
        kill-phase-on: NEVER
      - name: '{fuel-release}.{plugin-name}.{plugin-version}.contrail_net_template.juniper'
        property-file: build_number
        predefined-parameters: |
           CONTRAIL_DISTRIBUTION=juniper
        current-parameters: true
        kill-phase-on: NEVER

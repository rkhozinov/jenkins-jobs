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

      - name: '{fuel-release}.{plugin-name}.{plugin-version}.contrail_add_delete_compute_ceph.juniper'
        property-file: build_number
        predefined-parameters: |
           CONTRAIL_DISTRIBUTION=juniper
        current-parameters: true
        kill-phase-on: NEVER

      - name: '{fuel-release}.{plugin-name}.{plugin-version}.contrail_delete_analytics.juniper'
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

      - name: '{fuel-release}.{plugin-name}.{plugin-version}.contrail_bonding.juniper'
        property-file: build_number
        predefined-parameters: |
           CONTRAIL_DISTRIBUTION=juniper
        current-parameters: true
        kill-phase-on: NEVER

      - name: '{fuel-release}.{plugin-name}.{plugin-version}.contrail_cinder_ceph_multirole.juniper'
        property-file: build_number
        predefined-parameters: |
           CONTRAIL_DISTRIBUTION=juniper
        current-parameters: true
        kill-phase-on: NEVER

      - name: '{fuel-release}.{plugin-name}.{plugin-version}.contrail_plugin_add_delete_controller_node.juniper'
        property-file: build_number
        predefined-parameters: |
           CONTRAIL_DISTRIBUTION=juniper
        current-parameters: true
        kill-phase-on: NEVER

      - name: '{fuel-release}.{plugin-name}.{plugin-version}.contrail_add_controller.juniper'
        property-file: build_number
        predefined-parameters: |
           CONTRAIL_DISTRIBUTION=juniper
        current-parameters: true
        kill-phase-on: NEVER

      - name: '{fuel-release}.{plugin-name}.{plugin-version}.contrail_no_default.juniper'
        property-file: build_number
        predefined-parameters: |
           CONTRAIL_DISTRIBUTION=juniper
        current-parameters: true
        kill-phase-on: NEVER

      - name: '{fuel-release}.{plugin-name}.{plugin-version}.contrail_add_ha_analytics_db.juniper'
        property-file: build_number
        predefined-parameters: |
           CONTRAIL_DISTRIBUTION=juniper
        current-parameters: true
        kill-phase-on: NEVER

      - name: '{fuel-release}.{plugin-name}.{plugin-version}.contrail_add_ha_analytics_db.juniper'
        property-file: build_number
        predefined-parameters: |
           CONTRAIL_DISTRIBUTION=juniper
        current-parameters: true
        kill-phase-on: NEVER

      - name: '{fuel-release}.{plugin-name}.{plugin-version}.contrail_add_analytics_db.juniper'
        property-file: build_number
        predefined-parameters: |
           CONTRAIL_DISTRIBUTION=juniper
        current-parameters: true
        kill-phase-on: NEVER

      - name: '{fuel-release}.{plugin-name}.{plugin-version}.contrail_ha_multiple_networks.juniper'
        property-file: build_number
        predefined-parameters: |
           CONTRAIL_DISTRIBUTION=juniper
           MULTIPLE_NETWORKS=True
           MULTIPLE_NETWORKS_TEMPLATE=./plugin_test/fuel-qa/system_test/tests_templates/tests_configs/multirack.yaml
           VSRX_CONFIG_PATH=/storage/contrail/config.txt.lo.2nodegroups
        current-parameters: true
        kill-phase-on: NEVER

      - name: '{fuel-release}.{plugin-name}.{plugin-version}.contrail_different_ha_in_multinet.juniper'
        property-file: build_number
        predefined-parameters: |
           CONTRAIL_DISTRIBUTION=juniper
           MULTIPLE_NETWORKS=True
           MULTIPLE_NETWORKS_TEMPLATE=./plugin_test/fuel-qa/system_test/tests_templates/tests_configs/multirack.yaml
           VSRX_CONFIG_PATH=/storage/contrail/config.txt.lo.2nodegroups
        current-parameters: true
        kill-phase-on: NEVER

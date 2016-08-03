- inject:
    properties-content: $ADDITIONAL_PARAMETERS
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

      - name: '{fuel-release}.{plugin-name}.{plugin-version}.contrail_add_analytics.juniper'
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

      - name: '{fuel-release}.{plugin-name}.{plugin-version}.contrail_add_delete_compute_ceph.juniper'
        property-file: build_number
        predefined-parameters: |
           CONTRAIL_DISTRIBUTION=juniper
        current-parameters: true
        kill-phase-on: NEVER

      - name: '{fuel-release}.{plugin-name}.{plugin-version}.contrail_add_all_contrail.juniper'
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

      - name: '{fuel-release}.{plugin-name}.{plugin-version}.contrail_ceph_multirole.juniper'
        property-file: build_number
        predefined-parameters: |
           CONTRAIL_DISTRIBUTION=juniper
        current-parameters: true
        kill-phase-on: NEVER

      - name: '{fuel-release}.{plugin-name}.{plugin-version}.contrail_cinder_multirole.juniper'
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

      - name: '{fuel-release}.{plugin-name}.{plugin-version}.create_new_network_via_contrail.juniper'
        property-file: build_number
        predefined-parameters: |
           CONTRAIL_DISTRIBUTION=juniper
        current-parameters: true
        kill-phase-on: NEVER

      - name: '{fuel-release}.{plugin-name}.{plugin-version}.create_networks.juniper'
        property-file: build_number
        predefined-parameters: |
           CONTRAIL_DISTRIBUTION=juniper
        current-parameters: true
        kill-phase-on: NEVER

      - name: '{fuel-release}.{plugin-name}.{plugin-version}.contrail_login_password.juniper'
        property-file: build_number
        predefined-parameters: |
           CONTRAIL_DISTRIBUTION=juniper
        current-parameters: true
        kill-phase-on: NEVER

      - name: '{fuel-release}.{plugin-name}.{plugin-version}.contrail_vm_connection_in_different_tenants.juniper'
        property-file: build_number
        predefined-parameters: |
           CONTRAIL_DISTRIBUTION=juniper
        current-parameters: true
        kill-phase-on: NEVER

      - name: '{fuel-release}.{plugin-name}.{plugin-version}.install_contrail.juniper'
        property-file: build_number
        predefined-parameters: |
           CONTRAIL_DISTRIBUTION=juniper
        current-parameters: true
        kill-phase-on: NEVER
      - name: '{fuel-release}.{plugin-name}.{plugin-version}.contrail_uninstall.juniper'
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

      - name: '{fuel-release}.{plugin-name}.{plugin-version}.contrail_ceilometer_metrics.juniper'
        property-file: build_number
        predefined-parameters: |
           CONTRAIL_DISTRIBUTION=juniper
        current-parameters: true
        kill-phase-on: NEVER

      - name: '{fuel-release}.{plugin-name}.{plugin-version}.https_tls_selected.juniper'
        property-file: build_number
        predefined-parameters: |
           CONTRAIL_DISTRIBUTION=juniper
        current-parameters: true
        kill-phase-on: NEVER

      - name: '{fuel-release}.{plugin-name}.{plugin-version}.contrail_ostf_net_provisioning_disable.juniper'
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
           MULTIPLE_NETWORKS_TEMPLATE="${{WORKSPACE}}/plugin_test/fuel-qa/system_test/tests_templates/tests_configs/multirack.yaml"
           VSRX_CONFIG_PATH="/storage/contrail/config.txt.lo.2nodegroups"
        current-parameters: true
        kill-phase-on: NEVER

      - name: '{fuel-release}.{plugin-name}.{plugin-version}.contrail_multiple_networks_add_controller.juniper'
        property-file: build_number
        predefined-parameters: |
           CONTRAIL_DISTRIBUTION=juniper
           MULTIPLE_NETWORKS=True
           MULTIPLE_NETWORKS_TEMPLATE="${{WORKSPACE}}/plugin_test/fuel-qa/system_test/tests_templates/tests_configs/multirack.yaml"
           VSRX_CONFIG_PATH="/storage/contrail/config.txt.lo.2nodegroups"
        current-parameters: true
        kill-phase-on: NEVER

      - name: '{fuel-release}.{plugin-name}.{plugin-version}.contrail_multiple_networks_delete_controller.juniper'
        property-file: build_number
        predefined-parameters: |
           CONTRAIL_DISTRIBUTION=juniper
           MULTIPLE_NETWORKS=True
           MULTIPLE_NETWORKS_TEMPLATE="${{WORKSPACE}}/plugin_test/fuel-qa/system_test/tests_templates/tests_configs/multirack.yaml"
           VSRX_CONFIG_PATH="/storage/contrail/config.txt.lo.2nodegroups"
        current-parameters: true
        kill-phase-on: NEVER

      - name: '{fuel-release}.{plugin-name}.{plugin-version}.contrail_multiple_networks_delete_compute.juniper'
        property-file: build_number
        predefined-parameters: |
           CONTRAIL_DISTRIBUTION=juniper
           MULTIPLE_NETWORKS=True
           MULTIPLE_NETWORKS_TEMPLATE="${{WORKSPACE}}/plugin_test/fuel-qa/system_test/tests_templates/tests_configs/multirack.yaml"
           VSRX_CONFIG_PATH="/storage/contrail/config.txt.lo.2nodegroups"
        current-parameters: true
        kill-phase-on: NEVER

      - name: '{fuel-release}.{plugin-name}.{plugin-version}.contrail_multiple_networks_add_compute.juniper'
        property-file: build_number
        predefined-parameters: |
           CONTRAIL_DISTRIBUTION=juniper
           MULTIPLE_NETWORKS=True
           MULTIPLE_NETWORKS_TEMPLATE="${{WORKSPACE}}/plugin_test/fuel-qa/system_test/tests_templates/tests_configs/multirack.yaml"
           VSRX_CONFIG_PATH="/storage/contrail/config.txt.lo.2nodegroups"
        current-parameters: true
        kill-phase-on: NEVER

      - name: '{fuel-release}.{plugin-name}.{plugin-version}.contrail_different_ha_in_multinet.juniper'
        property-file: build_number
        predefined-parameters: |
           CONTRAIL_DISTRIBUTION=juniper
           MULTIPLE_NETWORKS=True
           MULTIPLE_NETWORKS_TEMPLATE="${{WORKSPACE}}/plugin_test/fuel-qa/system_test/tests_templates/tests_configs/multirack.yaml"
           VSRX_CONFIG_PATH="/storage/contrail/config.txt.lo.2nodegroups"
        current-parameters: true
        kill-phase-on: NEVER

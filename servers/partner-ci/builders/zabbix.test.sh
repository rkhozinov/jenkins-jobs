#!/bin/bash -e
# activate bash xtrace for script
[[ "${DEBUG}" == "true" ]] && set -x || set +x

# Export paths for plugins
zabbix_plugin_path=$(ls -t ${WORKSPACE}/zabbix_monitoring-*.rpm | head -n 1)
export ZABBIX_MONITORING_PLUGIN_PATH=${ZABBIX_MONITORING_PLUGIN_PATH:-$zabbix_plugin_path}

zabbix_emc_plugin_path=$(ls -t ${WORKSPACE}/zabbix_monitoring_emc-*.rpm | head -n 1)
export ZABBIX_MONITORING_EMC_PLUGIN_PATH=${ZABBIX_MONITORING_EMC_PLUGIN_PATH:-$zabbix_emc_plugin_path}

zabbix_extr_net_plugin_path=$(ls -t ${WORKSPACE}/zabbix_monitoring_extreme_networks-*.rpm | head -n 1)
export ZABBIX_MONITORING_EXTREME_NETWORKS_PLUGIN_PATH=${ZABBIX_MONITORING_EXTREME_NETWORKS_PLUGIN_PATH:-$zabbix_extr_net_plugin_path}

zabbix_snmp_plugin_path=$(ls -t ${WORKSPACE}/zabbix_snmptrapd-*.rpm | head -n 1)
export ZABBIX_MONITORING_SNMPTRAPD_PLUGIN_PATH=${ZABBIX_MONITORING_SNMPTRAPD_PLUGIN_PATH:-$zabbix_snmp_plugin_path}

echo -e "test-group: ${TEST_GROUP}\n" \
        "env-name: ${ENV_NAME}\n" \
        "use-snapshots: ${USE_SNAPSHOTS}\n" \
        "fuel-release: ${FUEL_RELEASE}\n" \
        "venv-path: ${VENV_PATH}\n" \
        "env-name: ${ENV_NAME}\n" \
        "iso-path: ${ISO_PATH}\n" \
        "zabbix-external-plugin-path: ${ZABBIX_MONITORING_PLUGIN_PATH:?}\n" \
        "zabbix-emc-plugin-path: ${ZABBIX_MONITORING_EMC_PLUGIN_PATH:?}\n" \
        "zabbix-extr-net-plugin-path: ${ZABBIX_MONITORING_EXTREME_NETWORKS_PLUGIN_PATH:?}\n" \
        "zabbix-snmp-plugin-path: ${ZABBIX_MONITORING_SNMPTRAPD_PLUGIN_PATH:?}\n"

. "${VENV_PATH}/bin/activate"


set -x
export ISO_PATH=${ISO_STORAGE:?}/${ISO_FILE:?}
export PYTHONPATH="${WORKSPACE}:${WORKSPACE}/tests"
python tests/stacklight_tests/run_tests.py run -q --nologcapture --with-xunit --group="${TEST_GROUP:?}"
echo "ENVIRONMENT NAME is $ENV_NAME"

env_data=$(dos.py list --ips | grep ${ENV_NAME})
echo $env_data
admin_node_ip=$(echo $env_data | cut -d' ' -f2)
export NAILGUN_HOST=${NAIGLUN_HOST:-$admin_node_ip}

cd ${WORKSPACE}
cat << REPORTER_PROPERTIES > reporter.properties
ISO_VERSION=${SNAPSHOTS_ID:?}
SNAPSHOTS_ID=${SNAPSHOTS_ID:?}
ISO_FILE=${ISO_FILE:?}
TEST_GROUP=${TEST_GROUP:?}
TEST_JOB_BUILD_NUMBER=${BUILD_NUMBER:?}
TEST_JOB_NAME=${JOB_NAME:?}
DATE=$(date +'%B-%d')
REPORTER_PROPERTIES

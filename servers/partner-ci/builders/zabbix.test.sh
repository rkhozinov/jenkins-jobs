#!/bin/bash -e
# activate bash xtrace for script
[[ "${DEBUG}" == "true" ]] && set -x || set +x

# Export build numbers
zabbix_external_build_version=$(grep "BUILD_NUMBER" < fuel-plugin-external-zabbix.properties | cut -d= -f2 )
export ZABBIX_EXTERNAL_PKG_JOB_BUILD_NUMBER=${PKG_JOB_BUILD_NUMBER:-$zabbix_external_build_version}

zabbix_emc_build_version=$(grep "BUILD_NUMBER" < fuel-plugin-zabbix-monitoring-emc.properties | cut -d= -f2 )
export ZABBIX_EMC_PKG_JOB_BUILD_NUMBER=${PKG_JOB_BUILD_NUMBER:-$zabbix_emc_build_version}

zabbix_extr_net_build_version=$(grep "BUILD_NUMBER" < fuel-plugin-zabbix-monitoring-extreme-networks.properties | cut -d= -f2 )
export ZABBIX_EXTR_NET_PKG_JOB_BUILD_NUMBER=${PKG_JOB_BUILD_NUMBER:-$zabbix_extr_net_build_version}

zabbix_snmp_build_version=$(grep "BUILD_NUMBER" < fuel-plugin-zabbix-snmptrapd.properties | cut -d= -f2 )
export ZABBIX_SNMP_PKG_JOB_BUILD_NUMBER=${PKG_JOB_BUILD_NUMBER:-$zabbix_snmp_build_version}

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
        "zabbix-external-plugin-path: ${ZABBIX_EXTERNAL_PLUGIN_PATH:?}\n" \
        "zabbix-emc-plugin-path: ${ZABBIX_EMC_PLUGIN_PATH:?}\n" \
        "zabbix-extr-net-plugin-path: ${ZABBIX_EXTR_NET_PLUGIN_PATH:?}\n" \
        "zabbix-snmp-plugin-path: ${ZABBIX_SNMP_PLUGIN_PATH:?}\n"

. "${VENV_PATH}/bin/activate"

cd ${WORKSPACE}/fuel-qa
sh -ex "tests/utils/jenkins/system_tests.sh"  \
   -k                                   \
   -K                                   \
   -w "$(pwd)"                          \
   -t test                              \
   -o --group="${TEST_GROUP:?}" \
   -i ${ISO_STORAGE:?}/${ISO_FILE:?}

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

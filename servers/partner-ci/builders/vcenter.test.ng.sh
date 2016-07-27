#!/bin/bash -e

# activate bash xtrace for script
[[ "${DEBUG}" == "true" ]] && set -x || set +x
[ -z $ISO_FILE  ] && (echo "ISO_FILE variable is empty"; exit 1)

#Set statistics job-group properties for tests
export FUEL_STATS_HOST=${FUEL_STATS_HOST:-"fuel-collect-systest.infra.mirantis.net"}
export ANALYTICS_IP="${ANALYTICS_IP:-"fuel-stats-systest.infra.mirantis.net"}"

export MIRROR_HOST=${MIRROR_HOST:-"mirror.seed-cz1.fuel-infra.org"}

export SNAPSHOTS_ID=${CUSTOM_VERSION:10}   

[ -z "${SNAPSHOTS_ID}" ] && { echo SNAPSHOTS_ID is empty; exit 1; }

wget --no-check-certificate -O snapshots.params ${SNAPSHOTS_URL/SNAPSHOTS_ID/$SNAPSHOTS_ID}

[ -f snapshots.params ] &&  . snapshots.params || \
  { echo snapshots.params file is not found; exit 1; }

if [[ "${UPDATE_MASTER}" == "true" ]]; then

  if [[ ! "${MIRROR_UBUNTU}" ]]; then
  
      case "${UBUNTU_MIRROR_ID}" in
          latest)
              UBUNTU_MIRROR_URL="$(curl "http://${MIRROR_HOST}/pkgs/ubuntu-latest.htm")"
              ;;
          *)
              UBUNTU_MIRROR_URL="http://${MIRROR_HOST}/pkgs/${UBUNTU_MIRROR_ID}/"
      esac
  
      UBUNTU_REPOS="deb ${UBUNTU_MIRROR_URL} trusty main universe multiverse|deb ${UBUNTU_MIRROR_URL} trusty-updates main universe multiverse|deb ${UBUNTU_MIRROR_URL} trusty-security main universe multiverse"
  
      ENABLE_PROPOSED="${ENABLE_PROPOSED:-true}"
  
      if [ "$ENABLE_PROPOSED" = true ]; then
          UBUNTU_PROPOSED="deb ${UBUNTU_MIRROR_URL} trusty-proposed main universe multiverse"
          UBUNTU_REPOS="$UBUNTU_REPOS|$UBUNTU_PROPOSED"
      fi
  
      export MIRROR_UBUNTU="$UBUNTU_REPOS"
  
  fi
  
  function join() {
      local __sep="${1}"
      local __head="${2}"
      local __tail="${3}"
      [[ -n "${__head}" ]] && echo "${__head}${__sep}${__tail}" || echo "${__tail}"
  }
  
  function to_uppercase() {
      echo "$1" | awk '{print toupper($0)}'
  }
  
  __space=' '
  __pipe='|'
  
  # Adding MOS rpm repos to
  # - UPDATE_FUEL_MIRROR - will be used for master node
  # - EXTRA_RPM_REPOS - will be used for nodes in cluster
  for _dn in  "os"        \
              "proposed"  \
              "updates"   \
              "holdback"  \
              "hotfix"    \
              "security"  ; do
      # a pointer to variable name which holds value of enable flag for this dist name
      __enable_ptr="ENABLE_MOS_CENTOS_$(to_uppercase "${_dn}")"
      if [[ "${!__enable_ptr}" = true ]] ; then
          # a pointer to variable name which holds repo id
          __repo_id_ptr="MOS_CENTOS_$(to_uppercase "${_dn}")_MIRROR_ID"
          __repo_url="http://${MIRROR_HOST}/mos-repos/centos/mos9.0-centos7/snapshots/${!__repo_id_ptr}/x86_64"
          __repo_name="mos-${_dn},${__repo_url}"
          UPDATE_FUEL_MIRROR="$(join "${__space}" "${UPDATE_FUEL_MIRROR}" "${__repo_url}" )"
          EXTRA_RPM_REPOS="$(join "${__pipe}" "${EXTRA_RPM_REPOS}" "${__repo_name}" )"
      fi
  done
  
  # Adding MOS deb repos to
  # - EXTRA_DEB_REPOS - will be used for nodes in cluster
  for _dn in  "proposed"  \
              "updates"   \
              "holdback"  \
              "hotfix"    \
              "security"  ; do
      # a pointer to variable name which holds value of enable flag for this dist name
      __enable_ptr="ENABLE_MOS_UBUNTU_$(to_uppercase "${_dn}")"
      # a pointer to variable name which holds repo id
      __repo_id_ptr="MOS_UBUNTU_MIRROR_ID"
      __repo_url="http://${MIRROR_HOST}/mos-repos/ubuntu/snapshots/${!__repo_id_ptr}"
      if [[ "${!__enable_ptr}" = true ]] ; then
          __repo_name="mos-${_dn},deb ${__repo_url} mos9.0-${_dn} main restricted"
          EXTRA_DEB_REPOS="$(join "${__pipe}" "${EXTRA_DEB_REPOS}" "${__repo_name}")"
      fi
  done
  
  export UPDATE_FUEL_MIRROR   # for fuel-qa
  export UPDATE_MASTER        # for fuel-qa
  export EXTRA_RPM_REPOS      # for fuel-qa
  export EXTRA_DEB_REPOS      # for fuel-qa
fi 

PLUGIN_VERSION_ARTIFACT='build.plugin_version'

if [ -z $PLUGIN_VERSION  ]; then
   # but if use doesn't want custom iso, we should get iso from artifacts
   [ -f $PLUGIN_VERSION_ARTIFACT ] && source $PLUGIN_VERSION_ARTIFACT || (echo "The PLUGIN_VERSION is empty"; exit 1)
fi

[ -z $PLUGIN_VERSION  ] && { echo "PLUGIN_VERSION variable is empty"; exit 1; } || export DVS_PLUGIN_VERSION=$PLUGIN_VERSION

if [ -z "${PKG_JOB_BUILD_NUMBER}" ]; then
    if [ -f build.properties ]; then
        export PKG_JOB_BUILD_NUMBER=$(grep "BUILD_NUMBER" < build.properties | cut -d= -f2 )
    else
        echo "build.properties file is not available so the results couldn't be publihsed"
        echo "$PKG_JOB_BUILD_NUMBER is empty, but it's needed for reporter. Exit."
        exit 1
    fi
fi

#remove old logs and test data
[ -f nosetest.xml ] && rm -f nosetests.xml
rm -rf logs/*

export ISO_PATH="${ISO_STORAGE}/${ISO_FILE}"

if [[ $ISO_FILE == *"Mirantis"* ]]; then
  export FUEL_RELEASE=$(echo $ISO_FILE | cut -d- -f2 | tr -d '.iso')
fi

[ ${SNAPSHOTS_ID} ] && export env_id=${SNAPSHOTS_ID} || export env_id=${CUSTOM_VERSION:10}
[ -z  ${env_id}   ] && { echo "Environment ID is not defined"; exit 1; }

export ENV_NAME="${ENV_PREFIX}.${env_id}"
export VENV_PATH="${HOME}/${FUEL_RELEASE}-venv"

[ -z "${DVS_PLUGIN_PATH}" ] && export DVS_PLUGIN_PATH=$(ls -t ${WORKSPACE}/fuel-plugin-vmware-dvs*.rpm | head -n 1)
[ -z "${DVS_PLUGIN_PATH}" ] && { echo "DVS_PLUGIN_PATH is empty"; exit 1; }
[ -z "${PLUGIN_PATH}"     ] && export PLUGIN_PATH=$DVS_PLUGIN_PATH

systest_parameters=''
[[ $USE_SNAPSHOTS  == 'true' ]] && systest_parameters+=' --existing' || echo snapshots for env is not be used
[[ $SHUTDOWN_AFTER == 'true' ]] && systest_parameters+=' --destroy' || echo the env will not be removed after test
#[[ $ERASE_AFTER    == 'true' ]] && systest_parameters+=' --erase' || echo the env will not be erased after test

[ -z $TEST_GROUP_PREFIX ] && { echo "testgroup prefix is empty"; exit 1; } || echo test-group-prefix: $TEST_GROUP_PREFIX

echo "test-group: ${TEST_GROUP}"
echo "env-name: ${ENV_NAME}"
echo "use-snapshots: ${USE_SNAPSHOTS}"
echo "fuel-release: ${FUEL_RELEASE}"
echo "venv-path: ${VENV_PATH}"
echo "env-name: ${ENV_NAME}"
echo "iso-path: ${ISO_PATH}"
echo "plugin-path: ${DVS_PLUGIN_PATH}"
echo "plugin-checksum: $(md5sum -b ${DVS_PLUGIN_PATH})"

cat << UPDATE_PROPERTIES > update.properties
UPDATE_FUEL_MIRROR=$UPDATE_FUEL_MIRROR
UPDATE_MASTER=$UPDATE_MASTER
EXTRA_RPM_REPOS=$EXTRA_RPM_REPOS
EXTRA_DEB_REPOS=$EXTRA_DEB_REPOS
UPDATE_PROPERTIES

cat snapshots.params >> update.properties

cat << REPORTER_PROPERTIES > reporter.properties
ISO_VERSION=${CUSTOM_VERSION:10}
ISO_FILE=$ISO_FILE
TEST_GROUP=$TEST_GROUP
TEST_GROUP_CONFIG=$TEST_GROUP_CONFIG
TEST_JOB_NAME=$JOB_NAME
TEST_JOB_BUILD_NUMBER=$BUILD_NUMBER
PKG_JOB_BUILD_NUMBER=$PKG_JOB_BUILD_NUMBER
PLUGIN_VERSION=$PLUGIN_VERSION
TREP_TESTRAIL_SUITE=$TREP_TESTRAIL_SUITE
TREP_TESTRAIL_SUITE_DESCRIPTION=$TREP_TESTRAIL_SUITE_DESCRIPTION
TREP_TESTRAIL_PLAN=$TREP_TESTRAIL_PLAN
TREP_TESTRAIL_PLAN_DESCRIPTION=$TREP_TESTRAIL_PLAN_DESCRIPTION
DATE=$(date +'%B-%d')
REPORTER_PROPERTIES

source "${VENV_PATH}/bin/activate"

#/btsync/tpi_systest_mod.sh -d ${OPENSTACK_RELEASE} \
#                           -n "${NODES_COUNT}" \
#                           -i ${ISO_PATH} \
#                           -t "${TEST_GROUP_PREFIX}(${TEST_GROUP_CONFIG})" \
#                           $systest_parameters

/btsync/tpi_systest_mod2.sh -d ${OPENSTACK_RELEASE} \
                            -i ${ISO_PATH} \
                            -t "${TEST_GROUP_PREFIX}(${TEST_GROUP_CONFIG})" \
                            $systest_parameters

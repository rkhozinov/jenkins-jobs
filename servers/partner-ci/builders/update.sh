#Set statistics job-group properties for tests
export FUEL_STATS_HOST=${FUEL_STATS_HOST:-"fuel-collect-systest.infra.mirantis.net"}
export ANALYTICS_IP="${ANALYTICS_IP:-"fuel-stats-systest.infra.mirantis.net"}"
export MIRROR_HOST=${MIRROR_HOST:-"mirror.seed-cz1.fuel-infra.org"}

[ ${SNAPSHOTS_ID} ] && export SNAPSHOTS_ID=${SNAPSHOTS_ID} || export SNAPSHOTS_ID=${CUSTOM_VERSION:10}
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

cat << UPDATE_PROPERTIES > update.properties
SNAPSHOTS_ID=$SNAPSHOTS_ID
MIRROR_UBUNTU=$MIRROR_UBUNTU
UPDATE_FUEL_MIRROR=$UPDATE_FUEL_MIRROR
UPDATE_MASTER=$UPDATE_MASTER
EXTRA_RPM_REPOS=$EXTRA_RPM_REPOS
EXTRA_DEB_REPOS=$EXTRA_DEB_REPOS
UPDATE_PROPERTIES

[[ "${UPDATE_MASTER}" == "true" ]] && cat snapshots.params >> update.properties;




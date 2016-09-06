# Sync fuel bugs" :
export LAUNCHPAD_PROJECT='fuel'
export LAUNCHPAD_MILESTONE='{"9.1": "Core VMware"}'
python sync_jira_with_launchpad.py

# Sync dvs bugs:
export LAUNCHPAD_PROJECT='fuel-plugin-vmware-dvs'
export LAUNCHPAD_MILESTONE='{"3.1.0": "DVS plugin 3.1.0"}'
python sync_jira_with_launchpad.py

# Sync nsx-t bugs:
export LAUNCHPAD_PROJECT='fuel-plugin-nsx-t'
export LAUNCHPAD_MILESTONE='{"1.0.0": "NSX-t plugin 1.0.0"}'
python sync_jira_with_launchpad.py

# Sync contrail bugs:
export LAUNCHPAD_PROJECT='fuel-plugin-contrail'
export LAUNCHPAD_MILESTONE='{"5.0.0": "Contrail plugin 5.0"}'
#export LAUNCHPAD_TAGS='contrail'
python sync_jira_with_launchpad.py

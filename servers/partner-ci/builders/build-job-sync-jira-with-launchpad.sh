# Sync fuel bugs" :
export LAUNCHPAD_PROJECT='fuel'
export LAUNCHPAD_MILESTONE='{"9.0": "Core VMware"}'
python sync_jira_with_launchpad.py

# Sync dvs bugs:
export LAUNCHPAD_PROJECT='fuel-plugin-vmware-dvs'
export LAUNCHPAD_MILESTONE='{"3.1.0": "DVS plugin 3.1.0"}'
python sync_jira_with_launchpad.py

# Sync nsxv bugs:
export LAUNCHPAD_PROJECT='fuel-plugin-nsxv'
export LAUNCHPAD_MILESTONE='{"3.0.0": "NSXv plugin 3.0.0"}'
python sync_jira_with_launchpad.py

# Sync contrail bugs:
export LAUNCHPAD_PROJECT='fuel-plugin-contrail'
export LAUNCHPAD_MILESTONE='{"3.0.1": "Contrail plugin 3.0.1", "4.0.1": "Contrail plugin 4.0.1"}'
#export LAUNCHPAD_TAGS='contrail'
python sync_jira_with_launchpad.py

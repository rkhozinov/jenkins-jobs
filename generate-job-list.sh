#!/bin/bash

testgroup="
vcenter_smoke                                 
vcenter_bvt                                   
vcenter_cindervmdk                            
vcenter_computevmware                         
vcenter_cindervmdk_and_computevmware          
vcenter_glance_backend                        
vcenter_multiple_cluster_with_computevmware   
vcenter_ceph                                  
vcenter_computevmware_and_ceph                
vcenter_multiroles_cindervmdk_and_ceph        
vcenter_multiroles_cindervmdk_and_cinder      
vcenter_ceilometer                            
vcenter_ceilometer_and_computevmware          
vcenter_multiroles_ceilometer                 
vcenter_add_delete_nodes                      
vcenter_delete_controler                      
vcenter_ha_ceph                               
vcenter_ha_cinder_and_ceph                    
vcenter_ha_glance_backend_multiple_cluster    
vcenter_ha_multiroles_cindervmdk_and_ceph     
vcenter_ha_multiroles_cindervmdk_and_cinder   
vcenter_ha_nova_flat_multiple_clusters        
vcenter_ha_nova_vlan_multiple_clusters"

echo "projects:"                                         

for test in $testgroup; do
    echo "
  - name: '8.0.systest.$test'       
    current-parameters: true                      
    kill-phase-on: NEVER"
done   

from azure.identity import ClientSecretCredential
from azure.mgmt.compute import ComputeManagementClient
import time
from datetime import datetime
import pytz
import os
# Azure credentials
tenant_id = os.getenv('TENANT_ID')
client_id = os.getenv('CLIENT_ID')
client_secret = os.getenv('CLIENT_SECRET')

# List of subscription IDs
subscription_ids = [
    '',
    #'subscription_id_3'
]
# Initialize credentials
credential = ClientSecretCredential(
    tenant_id=tenant_id,
    client_id=client_id,
    client_secret=client_secret
)

def stop_vm(compute_client, resource_group, vm_name):
    try:
        compute_client.virtual_machines.begin_deallocate(resource_group, vm_name).wait()
    except Exception:
        pass

def stop_all_vms():
    for subscription_id in subscription_ids:
        try:
            compute_client = ComputeManagementClient(credential, subscription_id)
            
            # Get all VMs 
            for vm in compute_client.virtual_machines.list_all():
                resource_group = vm.id.split("/")[4]
                vm_name = vm.name
                stop_vm(compute_client, resource_group, vm_name)
        
        except Exception:
            pass

def is_execution_time():
    est = pytz.timezone('US/Eastern')
    current_time = datetime.now(est)
    return current_time.hour == 19 and current_time.minute == 0

if __name__ == "__main__":
    last_execution_date = None
    
    while True:
        try:
            current_date = datetime.now(pytz.timezone('US/Eastern')).date()
            
            if is_execution_time() and current_date != last_execution_date:
                stop_all_vms()
                last_execution_date = current_date
            
            time.sleep(30)  # Check every 30 seconds this to avaid continuous exec
        except Exception:
            pass

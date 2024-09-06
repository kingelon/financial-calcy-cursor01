#!/bin/bash

# Load the configuration file
source ./config/config.cfg

# Function to attempt creating a VM in a given zone
create_vm() {
    local VM_NAME=$1
    local ZONE=$2

    echo "Attempting to create VM: $VM_NAME in $ZONE"
    gcloud compute instances create "$VM_NAME" \
        --project="$PROJECT_ID" \
        --zone="$ZONE" \
        --machine-type="$MACHINE_TYPE" \
        --image-family="$IMAGE_FAMILY" \
        --image-project="$IMAGE_PROJECT" \
        --boot-disk-size="$DISK_SIZE" \
        --boot-disk-type="$DISK_TYPE" \
        --tags=http-server,https-server
    
    # Capture the result of the instance creation
    if [ $? -eq 0 ]; then
        echo "VM $VM_NAME created in $ZONE."
        return 0  # Success
    else
        echo "Failed to create VM $VM_NAME in $ZONE."
        return 1  # Failure
    fi
}

# Loop through each VM and attempt to create in each zone until successful
vm_created=false

for VM_NAME in "${VM_NAMES[@]}"; do
    for ZONE in "${ZONES[@]}"; do
        create_vm "$VM_NAME" "$ZONE"
        if [ $? -eq 0 ]; then
            vm_created=true
            break  # Exit the zone loop once VM is created
        fi
    done

    if [ "$vm_created" = false ]; then
        echo "Failed to create VM $VM_NAME in all specified zones."
        exit 1  # Exit if no VM was created
    fi
done

# If a VM was successfully created, proceed to firewall rule creation
if [ "$vm_created" = true ]; then
    # Check for existing firewall rules and only create if missing
    for RULE in "${FIREWALL_RULES[@]}"; do
        echo "Checking for existing firewall rule: $RULE"
        
        if gcloud compute firewall-rules describe "$RULE" > /dev/null 2>&1; then
            echo "Firewall rule $RULE already exists, skipping..."
        else
            echo "Creating firewall rule: $RULE"
            gcloud compute firewall-rules create "$RULE" --allow tcp:80,tcp:443 --quiet
        fi
    done
else
    echo "No VMs were created, skipping firewall rule creation."
fi

echo "Script execution completed."

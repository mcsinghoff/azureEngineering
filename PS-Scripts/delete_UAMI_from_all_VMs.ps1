<#
.SYNOPSIS
    This script iterates through all VMs in all Azure subscriptions to find and remove a specified User Assigned Managed Identity (UAMI) from each VM.

.DESCRIPTION
    The script performs the following steps:
    1. Logs into Azure.
    2. Retrieves all subscriptions associated with the logged-in account.
    3. Iterates through each subscription to get all resource groups.
    4. Iterates through each resource group to get all VMs.
    5. Checks if each VM has the specified User Assigned Managed Identity.
    6. Removes the specified User Assigned Managed Identity from the VM if it exists.
    7. Updates the VM to persist the changes.

.PARAMETER UAMI_Name
    The name of the User Assigned Managed Identity to be removed from VMs.

.EXAMPLE
    .\Remove-UAMIFromVMs.ps1 -UAMI_Name "myUserAssignedManagedIdentity"

.NOTES
    Ensure you have the Azure PowerShell module installed and are authenticated to your Azure account before running this script.
#>

param (
    [Parameter(Mandatory = $true)]
    [string]$UAMI_Name
)

# Login to Azure
Connect-AzAccount

# Get all subscriptions
$subscriptions = Get-AzSubscription

foreach ($subscription in $subscriptions) {
    Set-AzContext -SubscriptionId $subscription.Id
    
    # Get all resource groups in the current subscription
    $resourceGroups = Get-AzResourceGroup
    
    foreach ($resourceGroup in $resourceGroups) {
        # Get all VMs in the current resource group
        $vms = Get-AzVM -ResourceGroupName $resourceGroup.ResourceGroupName
        
        foreach ($vm in $vms) {
            # Get the identity of the current VM
            $vmIdentity = Get-AzVM -ResourceGroupName $resourceGroup.ResourceGroupName -Name $vm.Name -Status | Select-Object -ExpandProperty Identity
            
            # Check if the VM has the specified User Assigned Managed Identity
            if ($vmIdentity.UserAssignedIdentities -contains "/subscriptions/$($subscription.Id)/resourcegroups/$($resourceGroup.ResourceGroupName)/providers/Microsoft.ManagedIdentity/userAssignedIdentities/$UAMI_Name") {
                Write-Output "Removing User Assigned Managed Identity $UAMI_Name from VM $($vm.Name) in Resource Group $($resourceGroup.ResourceGroupName)"
                
                # Remove the User Assigned Managed Identity
                $vm.Identity.UserAssignedIdentities.Remove("/subscriptions/$($subscription.Id)/resourcegroups/$($resourceGroup.ResourceGroupName)/providers/Microsoft.ManagedIdentity/userAssignedIdentities/$UAMI_Name")
                
                # Update the VM with the new identity configuration
                # This step is necessary to apply the changes to the VM in Azure
                $vmUpdateParams = @{
                    ResourceGroupName = $resourceGroup.ResourceGroupName
                    Name = $vm.Name
                    Identity = $vm.Identity
                }
                Update-AzVM @vmUpdateParams
            }
        }
    }
}

Write-Output "Script execution completed."

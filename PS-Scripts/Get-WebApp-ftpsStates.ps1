######################################One SubscriptionSte-az####################################################

# Connect to your Azure account (if not already connected)
Connect-AzAccount

Set-AzContext

# Get all App Service resources (Web Apps and Function Apps)
$webApps = Get-AzWebApp


# Initialize an array to store the results
$results = @()

# Loop through each App Service resource to get its FtpsState
foreach ($app in $webApps) {
    # Retrieve the Site Config to access FtpsState
    $siteConfig = Get-AzWebApp -ResourceGroupName $app.ResourceGroup -Name $app.Name

    # Add the resource details to the results array
    $results += [PSCustomObject]@{
        Name      = $app.Name
        Kind      = $app.Kind
        FtpsState = $siteConfig.SiteConfig.FtpsState
    }
}

# Display the table of all resources with their FtpsState
Write-Host "`nDetailed Overview of App Service Resources:`n" -ForegroundColor Cyan
$results | Sort-Object Name | Format-Table -AutoSize

# Count the number of resources per FtpsState
$counts = $results | Group-Object -Property FtpsState | Select-Object Name, Count

# Ensure all possible FtpsState values are represented in the counts
$allStates = @('AllAllowed', 'Disabled', 'FtpsOnly', $null)
foreach ($state in $allStates) {
    if (-not ($counts | Where-Object { $_.Name -eq $state })) {
        $counts += [PSCustomObject]@{
            Name  = $state
            Count = 0
        }
    }
}

# Display the summary table of FtpsState counts
Write-Host "`nSummary of FtpsState Values:`n" -ForegroundColor Cyan
$counts | Sort-Object Name | Format-Table -AutoSize

<#
Example Output:


Detailed Overview of App Service Resources:

Name                                        Kind        FtpsState
----                                        ----        ---------
app-AdminUI-prod                        app         AllAllowed
app-B2CPages-prod                       app         AllAllowed
app-ContractManagement-prod             app         AllAllowed
app-CustomerRelationshipManagement-prod app         FtpsOnly
app-Dispatcher-MabaTrade-prod           app         AllAllowed
app-Dispatcher-Mail-prod                app         AllAllowed
app-Dispatcher-RightAngle-prod          app         AllAllowed
app-Importer-prod                       app         AllAllowed
app-OrderManagement-prod                app         AllAllowed
app-PriceCalculation-prod               app         AllAllowed
app-PriceCalculator-prod                app         AllAllowed
app-PriceHub-prod                       app         AllAllowed
app-PriceNotification-prod              app         AllAllowed
app-RegisterDE-prod                     app         AllAllowed
app-RegisterUK-prod                     app         AllAllowed
app-Reporting-prod                      app         AllAllowed
app-Trading-prod                        app         AllAllowed
app-UI-prod                             app         AllAllowed
app-UI-UK-prod                          app         AllAllowed
app-UserManagement-prod                 app         AllAllowed
func-serviceBusRevisionHistory-prod     functionapp Disabled
func-timer-prod                         functionapp Disabled

Summary of FtpsState Values:

Name       Count
----       -----
               0
AllAllowed    19
Disabled       2
FtpsOnly       1
#>

######################################All management Groups####################################################

# Connect to your Azure account (if not already connected)
Connect-AzAccount

# Get all management groups
$managementGroups = Get-AzManagementGroup

# Initialize an array to store the results
$results = @()

# Loop through each management group
foreach ($mg in $managementGroups) {
    Write-Host "Processing Management Group: $($mg.Name)" -ForegroundColor Green

    # Get all subscriptions under the current management group
    $mgSubscriptions = Get-AzSubscription

    # Loop through each subscription in the management group
    foreach ($subscription in $mgSubscriptions) {
        Write-Host "  Processing Subscription: $($subscription.Name)" -ForegroundColor Yellow

        # Set the context to the current subscription
        Set-AzContext -Subscription $subscription.Id

        # Get all App Service resources (Web Apps and Function Apps) in the subscription
        $webApps = Get-AzWebApp

        # Loop through each App Service resource to get its FtpsState
        foreach ($app in $webApps) {
            # Retrieve the Site Config to access FtpsState
            $siteConfig = Get-AzWebApp -ResourceGroupName $app.ResourceGroup -Name $app.Name

            # Add the resource details to the results array
            $results += [PSCustomObject]@{
                ManagementGroup   = $mg.Name
                SubscriptionName  = $subscription.Name

                SubscriptionId    = $subscription.Id
                ResourceGroup     = $app.ResourceGroup
                AppName           = $app.Name
                Kind              = $app.Kind
                FtpsState         = $siteConfig.SiteConfig.FtpsState
            }
        }
    }
}

# Display the table of all resources with their FtpsState
Write-Host "`nDetailed Overview of App Service Resources:`n" -ForegroundColor Cyan
$results | Sort-Object ManagementGroup, SubscriptionName, ResourceGroup, AppName | Format-Table -AutoSize

# Count the number of resources per FtpsState
$counts = $results | Group-Object -Property FtpsState | Select-Object Name, Count

# Ensure all possible FtpsState values are represented in the counts
$allStates = @('AllAllowed', 'Disabled', 'FtpsOnly', $null)
foreach ($state in $allStates) {
    if (-not ($counts | Where-Object { $_.Name -eq $state })) {
        $counts += [PSCustomObject]@{
            Name  = $state
            Count = 0
        }
    }
}

# Display the summary table of FtpsState counts
Write-Host "`nSummary of FtpsState Values:`n" -ForegroundColor Cyan
$counts | Sort-Object Name | Format-Table -AutoSize

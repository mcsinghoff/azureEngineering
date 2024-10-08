# Install AzureAD module if it's not installed
if (-not (Get-Module -ListAvailable -Name AzureAD)) {
    Install-Module -Name AzureAD -Force
}

# Connect to Azure AD
Connect-AzureAD

# Get all app registrations
$appRegistrations = Get-AzureADApplication

# Initialize an array to store the results
$results = @()

foreach ($app in $appRegistrations) {
    # Get the corresponding enterprise application (service principal) if it exists
    $servicePrincipal = Get-AzureADServicePrincipal -Filter "AppId eq '$($app.AppId)'"

    # Prepare the object to be exported
    $obj = [PSCustomObject]@{
        AppRegistrationName                                        = $app.DisplayName
        AppId                                                      = $app.AppId
        AppRegistrationObjectId                                    = $app.ObjectId
        EnterpriseApplicationOrServicePrincipalName                = if ($servicePrincipal) { $servicePrincipal.DisplayName } else { "N/A" }
        ServicePrincipalObjectId                                   = if ($servicePrincipal) { $servicePrincipal.ObjectId } else { "N/A" }
    }

    # Add the object to the results array
    $results += $obj
}

# Export the results to a CSV file
$results | Export-Csv -Path "AppRegistrationsWithEnterpriseApplications.csv" -NoTypeInformation

Write-Host "Export completed. File saved as AppRegistrationsWithEnterpriseApplications.csv"

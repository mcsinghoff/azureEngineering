# Install the Microsoft.Graph Module if not already installed
# Install-Module Microsoft.Graph -Scope CurrentUser

# Connect to Microsoft Graph
Connect-MgGraph -Scopes "Application.Read.All", "Directory.Read.All", "AuditLog.Read.All"

# Get all applications (App Registrations)
$applications = Get-MgApplication -All

# Get all service principals
$servicePrincipals = Get-MgServicePrincipal -All

# Define an array to store the results
$results = @()

# Get current date for comparison
$currentDate = Get-Date

foreach ($app in $applications) {
    $appInfo = @{
        Name                  = $app.DisplayName
        ObjectId              = $app.Id
        Type                  = "Application"
        LastSignInDate        = "N/A"
        LastSignInMoreThan2M  = "N/A"
        LastSignInMoreThan6M  = "N/A"
    }
    $results += $appInfo
}

foreach ($sp in $servicePrincipals) {
    $spSignInActivity = Get-MgAuditLogSignIn -Filter "appId eq '$($sp.AppId)'" | Select-Object -First 1

    $lastSignInDate = if ($spSignInActivity) { $spSignInActivity.CreatedDateTime } else { $null }

    # Calculate if the last sign-in was more than 2 or 6 months ago
    $lastSignInMoreThan2M = if ($lastSignInDate) { ($currentDate - $lastSignInDate).Days -ge 60 } else { $false }
    $lastSignInMoreThan6M = if ($lastSignInDate) { ($currentDate - $lastSignInDate).Days -ge 180 } else { $false }

    $spInfo = @{
        Name                  = $sp.DisplayName
        ObjectId              = $sp.Id
        Type                  = "Service Principal"
        LastSignInDate        = if ($lastSignInDate) { $lastSignInDate } else { "No Sign-In" }
        LastSignInMoreThan2M  = if ($lastSignInDate) { if ($lastSignInMoreThan2M) { "Yes" } else { "No" } } else { "N/A" }
        LastSignInMoreThan6M  = if ($lastSignInDate) { if ($lastSignInMoreThan6M) { "Yes" } else { "No" } } else { "N/A" }
    }
    $results += $spInfo
}

# Export results to a CSV file
$results | Export-Csv -Path "C:\Users\msinghof\Downloads\AppRegistrations_ServicePrincipals_LastSignIn.csv" -NoTypeInformation

# Display results
$results | Format-Table -AutoSize 

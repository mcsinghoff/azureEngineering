# Install the AzureAD Preview Module if not already installed
Install-Module AzureADPreview -Scope CurrentUser -Force -AllowClobber

# Connect to Azure AD
Connect-AzureAD

# Get all applications (App Registrations) that start with "app-"
$applications = Get-AzureADApplication | Where-Object { $_.DisplayName -like 'appreg-*' }

# Get all service principals that start with "appreg-"
$servicePrincipals = Get-AzureADServicePrincipal | Where-Object { $_.DisplayName -like 'app-*' }

# Define an array to store the results
$results = @()

# Get current date for comparison
$currentDate = Get-Date

foreach ($app in $applications) {
    # Retrieve the sign-in logs and filter for the application AppId
    $lastSignInLog = Get-AzureADAuditSignInLogs | Where-Object { $_.AppId -eq $app.AppId } | Select-Object -First 1
    
    $lastSignInDate = if ($lastSignInLog) { $lastSignInLog.CreatedDateTime } else { $null }

    # Calculate if the last sign-in was more than 2 or 6 months ago
    $lastSignInMoreThan2M = if ($lastSignInDate) { ($currentDate - $lastSignInDate).Days -ge 60 } else { $false }
    $lastSignInMoreThan6M = if ($lastSignInDate) { ($currentDate - $lastSignInDate).Days -ge 180 } else { $false }

    $appInfo = @{
        Name                  = $app.DisplayName
        ObjectId              = $app.ObjectId
        Type                  = "Application"
        LastSignInDate        = if ($lastSignInDate) { $lastSignInDate } else { "No Sign-In" }
        LastSignInMoreThan2M  = if ($lastSignInDate) { if ($lastSignInMoreThan2M) { "Yes" } else { "No" } } else { "N/A" }
        LastSignInMoreThan6M  = if ($lastSignInDate) { if ($lastSignInMoreThan6M) { "Yes" } else { "No" } } else { "N/A" }
    }
    $results += $appInfo
}

foreach ($sp in $servicePrincipals) {
    # Retrieve the sign-in logs and filter for the service principal AppId
    $lastSignInLog = Get-AzureADAuditSignInLogs | Where-Object { $_.AppId -eq $sp.AppId } | Select-Object -First 1
    
    $lastSignInDate = if ($lastSignInLog) { $lastSignInLog.CreatedDateTime } else { $null }

    # Calculate if the last sign-in was more than 2 or 6 months ago
    $lastSignInMoreThan2M = if ($lastSignInDate) { ($currentDate - $lastSignInDate).Days -ge 60 } else { $false }
    $lastSignInMoreThan6M = if ($lastSignInDate) { ($currentDate - $lastSignInDate).Days -ge 180 } else { $false }

    $spInfo = @{
        Name                  = $sp.DisplayName
        ObjectId              = $sp.ObjectId
        Type                  = "Service Principal"
        LastSignInDate        = if ($lastSignInDate) { $lastSignInDate } else { "No Sign-In" }
        LastSignInMoreThan2M  = if ($lastSignInDate) { if ($lastSignInMoreThan2M) { "Yes" } else { "No" } } else { "N/A" }
        LastSignInMoreThan6M  = if ($lastSignInDate) { if ($lastSignInMoreThan6M) { "Yes" } else { "No" } } else { "N/A" }
    }
    $results += $spInfo
}

# Export results to a CSV file
$results | Export-Csv -Path "C:\Users\msinghof\Downloads\AzureAD_AppRegistrations_ServicePrincipals_LastSignIn.csv" -NoTypeInformation

# Display results
$results | Format-Table -AutoSize

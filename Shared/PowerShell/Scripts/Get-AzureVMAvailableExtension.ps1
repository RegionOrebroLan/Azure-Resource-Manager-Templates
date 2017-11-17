Add-AzureAccount;

Write-Host "Microsoft.Powershell";
foreach($extension in (Get-AzureVMAvailableExtension -Publisher "Microsoft.Powershell"))
{
	Write-Host "ExtensionName = $($extension.ExtensionName)";
    Write-Host "Version = $($extension.Version)";
    Write-Host "Publisher = $($extension.Publisher)";
    Write-Host "Label = $($extension.Label)";
    Write-Host "Description = $($extension.Description)";
    Write-Host "PublicConfigurationSchema = $($extension.PublicConfigurationSchema)";
    Write-Host "PrivateConfigurationSchema = $($extension.PrivateConfigurationSchema)";
    Write-Host "SampleConfig = $($extension.SampleConfig)";
    Write-Host "Eula = $($extension.Eula)";
    Write-Host "PrivacyUri = $($extension.PrivacyUri)";
    Write-Host "HomepageUri = $($extension.HomepageUri)";
}

Write-Host "Microsoft.Compute";
foreach($extension in (Get-AzureVMAvailableExtension -Publisher "Microsoft.Compute"))
{
	Write-Host "ExtensionName = $($extension.ExtensionName)";
    Write-Host "Version = $($extension.Version)";
    Write-Host "Publisher = $($extension.Publisher)";
    Write-Host "Label = $($extension.Label)";
    Write-Host "Description = $($extension.Description)";
    Write-Host "PublicConfigurationSchema = $($extension.PublicConfigurationSchema)";
    Write-Host "PrivateConfigurationSchema = $($extension.PrivateConfigurationSchema)";
    Write-Host "SampleConfig = $($extension.SampleConfig)";
    Write-Host "Eula = $($extension.Eula)";
    Write-Host "PrivacyUri = $($extension.PrivacyUri)";
    Write-Host "HomepageUri = $($extension.HomepageUri)";
}

Write-Host "Ready";

Read-Host;
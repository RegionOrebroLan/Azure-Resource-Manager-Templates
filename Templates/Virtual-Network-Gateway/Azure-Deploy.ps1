Import-Module "$($PSScriptRoot)\..\..\Shared\PowerShell\Modules\Azure-Helper";
Import-Module "$($PSScriptRoot)\..\..\Shared\PowerShell\Modules\Certificate";
Import-Module "$($PSScriptRoot)\..\..\Shared\PowerShell\Modules\Helper";

$_ipAddressFirstPartLabel = "IP-address first part";
$_ipAddressSecondPartLabel = "IP-address second part";
$_resourceNamePrefixLabel = "Resource-name-prefix";
$_templateUri = (Get-TemplateUriFormat).Replace("{0}", "Virtual-Network-Gateway");
$ipAddressFirstPart = 10;
$ipAddressSecondPart = 0;

$azureContext = Initialize;

$indent = Get-Indent;
$accepted = $false;

while(!$accepted)
{
	Select-Required -AzureContext $azureContext;

	$subscriptionLabel = Get-SubscriptionLabel -Subscription (Get-SelectedSubscription -AzureContext $azureContext);

	$resourceGroupLabel = Get-ResourceGroupLabel -ResourceGroup (Get-NewOrSelectedResourceGroup -AzureContext $azureContext);

	$ipAddressFirstPart = Select-Number -MaximumValue 254 -MinimumValue 1 -Value $ipAddressFirstPart -ValueName $_ipAddressFirstPartLabel;

	$ipAddressSecondPart = Select-Number -MaximumValue 254 -MinimumValue 0 -Value $ipAddressSecondPart -ValueName $_ipAddressSecondPartLabel;

	Select-ResourceNamePrefix -AzureContext $azureContext;
	
	Write-Host;
	Write-Host "Your selections:";
	Write-Host "$($indent)Subscription: $($subscriptionLabel)";
	Write-Host "$($indent)Resource-group: $($resourceGroupLabel)";
	Write-Host "$($indent)$($_ipAddressFirstPartLabel): $($ipAddressFirstPart)";
	Write-Host "$($indent)$($_ipAddressSecondPartLabel): $($ipAddressSecondPart)";
	Write-Host "$($indent)$($_resourceNamePrefixLabel): $($azureContext.ResourceNamePrefix)";

	$accepted = (Accept);
}

try
{
	$virtualNetworkGatewayCertificateInformation = Get-VirtualNetworkGatewayCertificateInformation;

	if($virtualNetworkGatewayCertificateInformation.NewCertificates.Count -gt 0)
	{
		Write-Host;

		Write-Host "New local certificates have been created:";

		foreach($newCertificate in $virtualNetworkGatewayCertificateInformation.NewCertificates)
		{
			Write-Host "$($indent)$($newCertificate)";
		}
	}
}
catch
{
	Write-Host;

	Write-Host "Could not get the certificate value: $($_.Exception.Message)" -ForegroundColor (Get-ErrorColor);

	Close;
}

$parameters = New-Object System.Collections.Hashtable;

$parameters.Add("ipAddressFirstPart", $ipAddressFirstPart);
$parameters.Add("ipAddressSecondPart", $ipAddressSecondPart);
$parameters.Add("resourceNamePrefix", $azureContext.ResourceNamePrefix);
$parameters.Add("virtualNetworkGatewayCertificateValue", $virtualNetworkGatewayCertificateInformation.PublicKey);

try
{
	Deploy -AzureContext $azureContext -Parameters $parameters -Uri $_templateUri;
}
catch
{
	WriteError $_.Exception.Message;
}

Close;
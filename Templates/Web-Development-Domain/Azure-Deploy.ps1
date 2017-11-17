Import-Module "$($PSScriptRoot)\..\..\Shared\PowerShell\Modules\Azure-Helper";
Import-Module "$($PSScriptRoot)\..\..\Shared\PowerShell\Modules\Certificate";
Import-Module "$($PSScriptRoot)\..\..\Shared\PowerShell\Modules\Helper";

$_domainNameLabel = "Domain-name";
$_ipAddressFirstPartLabel = "IP-address first part";
$_ipAddressSecondPartLabel = "IP-address second part";
$_passwordLabel = "Password";
$_resourceNamePrefixLabel = "Resource-name-prefix";
$_templateUri = (Get-TemplateUriFormat).Replace("{0}", "Web-Development-Domain");
$_userNameLabel = "User-name";
$domainName = "local.net";
$ipAddressFirstPart = 10;
$ipAddressSecondPart = 0;

function Validate-DomainName
{
	param
	(
		[string]$domainName
	)

	return ValidateDomainName -DomainName $domainName -DomainNameLabel $_domainNameLabel;
}

function Validate-Password
{
	param
	(
		[string]$password
	)

	return ValidatePassword -Password $password -PasswordLabel $_passwordLabel;
}

function Validate-UserName
{
	param
	(
		[string]$userName
	)

	return ValidateUserName -UserName $userName -UserNameLabel $_userNameLabel;
}

$azureContext = Initialize;

$indent = Get-Indent;
$accepted = $false;

while(!$accepted)
{
	Select-Required -AzureContext $azureContext;

	$subscriptionLabel = Get-SubscriptionLabel -Subscription (Get-SelectedSubscription -AzureContext $azureContext);

	$resourceGroupLabel = Get-ResourceGroupLabel -ResourceGroup (Get-NewOrSelectedResourceGroup -AzureContext $azureContext);

	$domainName = Select-Value -ValidateFunction ${function:Validate-DomainName} -Value $domainName -ValueName $_domainNameLabel;

	$ipAddressFirstPart = Select-Number -MaximumValue 254 -MinimumValue 1 -Value $ipAddressFirstPart -ValueName $_ipAddressFirstPartLabel;

	$ipAddressSecondPart = Select-Number -MaximumValue 254 -MinimumValue 0 -Value $ipAddressSecondPart -ValueName $_ipAddressSecondPartLabel;

	$password = Select-Value -Secure $true -ValidateFunction ${function:Validate-Password} -Value $password -ValueName $_passwordLabel;

	Select-ResourceNamePrefix -AzureContext $azureContext;

	$userName = Select-Value -ValidateFunction ${function:Validate-UserName} -Value $userName -ValueName $_userNameLabel;
	
	Write-Host;
	Write-Host "Your selections:";
	Write-Host "$($indent)Subscription: $($subscriptionLabel)";
	Write-Host "$($indent)Resource-group: $($resourceGroupLabel)";
	Write-Host "$($indent)$($_domainNameLabel): $($domainName)";
	Write-Host "$($indent)$($_ipAddressFirstPartLabel): $($ipAddressFirstPart)";
	Write-Host "$($indent)$($_ipAddressSecondPartLabel): $($ipAddressSecondPart)";
	Write-Host "$($indent)$($_passwordLabel): $(ToSecureString $password)";
	Write-Host "$($indent)$($_resourceNamePrefixLabel): $($azureContext.ResourceNamePrefix)";
	Write-Host "$($indent)$($_userNameLabel): $($userName)";

	$accepted = (Accept);
}

try
{
	$webDevelopmentDomainCertificateInformation = Get-WebDevelopmentDomainCertificateInformation -DomainName $domainName -Password (ConvertTo-SecureString $password -AsPlainText -Force) -ResourceNamePrefix $azureContext.ResourceNamePrefix;

	if($webDevelopmentDomainCertificateInformation.NewCertificates.Count -gt 0)
	{
		Write-Host;

		Write-Host "New local certificates have been created:";

		foreach($newCertificate in $webDevelopmentDomainCertificateInformation.NewCertificates)
		{
			Write-Host "$($indent)$($newCertificate)";
		}
	}
}
catch
{
	Write-Host;

	Write-Host "Could not get the certificate values: $($_.Exception.Message)" -ForegroundColor (Get-ErrorColor);

	Close;
}

$parameters = New-Object System.Collections.Hashtable;

$parameters.Add("applicationGatewayAuthenticationCertificatePublicKeyValue", $webDevelopmentDomainCertificateInformation.ApplicationGatewayAuthenticationCertificatePublicKey);
$parameters.Add("applicationGatewayAuthenticationCertificateValue", $webDevelopmentDomainCertificateInformation.ApplicationGatewayAuthenticationCertificateValue);
$parameters.Add("applicationGatewaySslCertificateValue", $webDevelopmentDomainCertificateInformation.ApplicationGatewaySslCertificateValue);
$parameters.Add("domainName", $domainName);
$parameters.Add("ipAddressFirstPart", $ipAddressFirstPart);
$parameters.Add("ipAddressSecondPart", $ipAddressSecondPart);
$parameters.Add("password", $password);
$parameters.Add("resourceNamePrefix", $azureContext.ResourceNamePrefix);
$parameters.Add("userName", $userName);
$parameters.Add("virtualNetworkGatewayCertificateValue", $webDevelopmentDomainCertificateInformation.VirtualNetworkGatewayCertificatePublicKey);

try
{
	Deploy -AzureContext $azureContext -Parameters $parameters -Uri $_templateUri;
}
catch
{
	WriteError $_.Exception.Message;
}

Close;
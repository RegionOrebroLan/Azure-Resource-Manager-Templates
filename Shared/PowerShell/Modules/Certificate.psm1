#https://docs.microsoft.com/sv-se/azure/vpn-gateway/vpn-gateway-certificates-point-to-site#clientcert
#https://blogs.msdn.microsoft.com/asiatech/2014/11/02/quickly-generate-install-and-export-self-signed-certificate-in-powershell-on-windows-8-12012r2/

$_certificateNamePrefix = "Region Orebro lan / self-signed for Azure: ";

$_applicationGatewayAuthenticationCertificateFriendlyName = "$($_certificateNamePrefix)Application-Gateway Authentication-Certificate";
$_applicationGatewaySslCertificateFriendlyName = "$($_certificateNamePrefix)Application-Gateway SSL-Certificate";
$_certificateExpiration = (Get-Date).AddYears(1);
$_certificateRootStoreLocation = "Cert:\CurrentUser\Root\";
$_certificateStoreLocation = "Cert:\CurrentUser\My\";
$_exportedApplicationGatewayCertificateDirectoryPath = "$($env:TEMP)\";
$_exportedApplicationGatewayAuthenticationCertificatePath = "$($_exportedApplicationGatewayCertificateDirectoryPath)Azure-Application-Gateway-Authentication-Certificate.pfx";
$_exportedApplicationGatewaySslCertificatePath = "$($_exportedApplicationGatewayCertificateDirectoryPath)Azure-Application-Gateway-SSL-Certificate.pfx";
$_virtualNetworkGatewayClientCertificateName = "$($_certificateNamePrefix)VPN Point-To-Site Client-Certificate";
$_virtualNetworkGatewayRootCertificateName = "$($_certificateNamePrefix)VPN Point-To-Site Root-Certificate";

Import-Module "$($PSScriptRoot)\Helper";

function Get-ApplicationGatewayAuthenticationCertificateDnsNames
{
	param
	(
		[Parameter(Mandatory)]
		[string]$domainName,
		[string]$resourceNamePrefix
	)

	if(!$resourceNamePrefix)
	{
		$resourceNamePrefix = "";
	}

	$domainName = $domainName.ToLower();
	$resourceNamePrefix = $resourceNamePrefix.ToLower();

	$dnsNames = New-Object System.Collections.Generic.List[string];

	# This is not required but maybe we should include it, anyhow: $dnsNames.Add("$($resourceNamePrefix)web.$($domainName)");
	$dnsNames.Add("$($resourceNamePrefix)web-01.$($domainName)");
	$dnsNames.Add("$($resourceNamePrefix)web-02.$($domainName)");

	return $dnsNames;
}

function Get-ApplicationGatewaySslCertificateDnsNames
{
	param
	(
		[Parameter(Mandatory)]
		[string]$domainName,
		[string]$resourceNamePrefix
	)

	if(!$resourceNamePrefix)
	{
		$resourceNamePrefix = "";
	}

	$domainName = $domainName.ToLower();
	$resourceNamePrefix = $resourceNamePrefix.ToLower();

	$dnsNames = New-Object System.Collections.Generic.List[string];

	$dnsNames.Add("$($resourceNamePrefix)application-gateway.westeurope.cloudapp.azure.com");
	$dnsNames.Add("$($resourceNamePrefix)web.$($domainName)");

	return $dnsNames;
}

function Get-VirtualNetworkGatewayCertificateInformation
{
	$clientCertificate = Get-ChildItem -DnsName $_virtualNetworkGatewayClientCertificateName -Path $_certificateStoreLocation;
	$rootCertificate = Get-ChildItem -DnsName $_virtualNetworkGatewayRootCertificateName -Path $_certificateStoreLocation;
	
	if($clientCertificate -and !$rootCertificate)
	{
		Throw "The client-certificate ""$($_certificateStoreLocation)CN=$($_virtualNetworkGatewayClientCertificateName)"" exists already but the root-certificate ""$($_certificateStoreLocation)CN=$($_virtualNetworkGatewayRootCertificateName)"" do not. The client-certificate must be created with the root-certificate as ""Signer"". Delete the client-certificate and try again.";
	}

	$newCertificates = New-StringList;

	if(!$rootCertificate)
	{
		$rootCertificate = New-VirtualNetworkGatewayRootCertificate -CertificateStoreLocation $_certificateStoreLocation -Name $_virtualNetworkGatewayRootCertificateName;
		$newCertificates.Add("$($_certificateStoreLocation)$($rootCertificate.Subject)");
	}

	if(!$clientCertificate)
	{
		$clientCertificate = New-VirtualNetworkGatewayClientCertificate -CertificateStoreLocation $_certificateStoreLocation -Name $_virtualNetworkGatewayClientCertificateName -Signer $rootCertificate;
		$newCertificates.Add("$($_certificateStoreLocation)$($clientCertificate.Subject)");
	}

	$virtualNetworkGatewayCertificateInformation = New-VirtualNetworkGatewayCertificateInformation -NewCertificates $newCertificates -PublicKey ([System.Convert]::ToBase64String($rootCertificate.RawData));

	return $virtualNetworkGatewayCertificateInformation;
}

function Get-WebDevelopmentDomainCertificateInformation
{
	param
	(
		[Parameter(Mandatory)]
		[string]$domainName,
		[Parameter(Mandatory)]
		[SecureString]$password,
		[Parameter(Mandatory)]
		[AllowEmptyString()]
		[string]$resourceNamePrefix
	)

	$domainName = $domainName.ToLower();
	$resourceNamePrefix = $resourceNamePrefix.ToLower();

	$virtualNetworkGatewayCertificateInformation = Get-VirtualNetworkGatewayCertificateInformation;

	$applicationGatewayAuthenticationCertificateDnsNames = Get-ApplicationGatewayAuthenticationCertificateDnsNames -DomainName $domainName -ResourceNamePrefix $resourceNamePrefix;
	$applicationGatewayAuthenticationCertificateSubject = "$($_certificateNamePrefix)$($resourceNamePrefix)web.$($domainName)";

	$applicationGatewaySslCertificateDnsNames = Get-ApplicationGatewaySslCertificateDnsNames -DomainName $domainName -ResourceNamePrefix $resourceNamePrefix;
	$applicationGatewaySslCertificateSubject = "$($_certificateNamePrefix)$($applicationGatewaySslCertificateDnsNames[0])";
	
	$newCertificates = New-StringList;

	$applicationGatewayAuthenticationCertificate = Get-ChildItem -DnsName $applicationGatewayAuthenticationCertificateSubject -Path $_certificateStoreLocation;
	$applicationGatewaySslCertificate = Get-ChildItem -DnsName $applicationGatewaySslCertificateSubject -Path $_certificateStoreLocation;
	
	if(!$applicationGatewayAuthenticationCertificate)
	{
		$applicationGatewayAuthenticationCertificate = New-SelfSignedCertificate -CertStoreLocation $_certificateStoreLocation -DnsName $applicationGatewayAuthenticationCertificateDnsNames -FriendlyName $_applicationGatewayAuthenticationCertificateFriendlyName -Subject $applicationGatewayAuthenticationCertificateSubject;
		$newCertificates.Add("$($_certificateStoreLocation)$($applicationGatewayAuthenticationCertificate.Subject)");
	}

	if(!$applicationGatewaySslCertificate)
	{
		$applicationGatewaySslCertificate = New-SelfSignedCertificate -CertStoreLocation $_certificateStoreLocation -DnsName $applicationGatewaySslCertificateDnsNames -FriendlyName $_applicationGatewaySslCertificateFriendlyName -Subject $applicationGatewaySslCertificateSubject;
		$newCertificates.Add("$($_certificateStoreLocation)$($applicationGatewaySslCertificate.Subject)");
	}
	
	$applicationGatewayAuthenticationCertificatePublicKey = [System.Convert]::ToBase64String($applicationGatewayAuthenticationCertificate.RawData);
	$exportedApplicationGatewayAuthenticationCertificate = Export-PfxCertificate -Cert $applicationGatewayAuthenticationCertificate -FilePath $_exportedApplicationGatewayAuthenticationCertificatePath -Force -Password $password;
	$applicationGatewayAuthenticationCertificateValue = [System.Convert]::ToBase64String([System.IO.File]::ReadAllBytes($_exportedApplicationGatewayAuthenticationCertificatePath));
	Remove-Item -Path $_exportedApplicationGatewayAuthenticationCertificatePath;

	$exportedApplicationGatewaySslCertificate = Export-PfxCertificate -Cert $applicationGatewaySslCertificate -FilePath $_exportedApplicationGatewaySslCertificatePath -Force -Password $password;
	$applicationGatewaySslCertificateValue = [System.Convert]::ToBase64String([System.IO.File]::ReadAllBytes($_exportedApplicationGatewaySslCertificatePath));
	Remove-Item -Path $_exportedApplicationGatewaySslCertificatePath;

	# For the moment we check if it exists in the root-store first, if not we import it. Dont know if we have to check, seems to overwrite or skip if it already exists.
	$importedApplicationGatewaySslCertificate = Get-Item -ErrorAction SilentlyContinue -Path "$($_certificateRootStoreLocation)$($applicationGatewaySslCertificate.Thumbprint)";
	if(!$importedApplicationGatewaySslCertificate)
	{
		$exportedApplicationGatewaySslCertificatePath = $_exportedApplicationGatewaySslCertificatePath.Replace(".pfx", ".cer");
		Export-Certificate -Cert $applicationGatewaySslCertificate -FilePath $exportedApplicationGatewaySslCertificatePath;
		$importedApplicationGatewaySslCertificate = Import-Certificate -CertStoreLocation $_certificateRootStoreLocation -FilePath $exportedApplicationGatewaySslCertificatePath;
		Remove-Item -Path $exportedApplicationGatewaySslCertificatePath;
		$newCertificates.Add("$($_certificateRootStoreLocation)$($importedApplicationGatewaySslCertificate.Subject)");
	}

	foreach($newCertificate in $virtualNetworkGatewayCertificateInformation.NewCertificates)
	{
		$newCertificates.Add($newCertificate);
	}

	$webDevelopmentDomainCertificateInformation = New-WebDevelopmentDomainCertificateInformation `
		-ApplicationGatewayAuthenticationCertificatePublicKey $applicationGatewayAuthenticationCertificatePublicKey `
		-ApplicationGatewayAuthenticationCertificateValue $applicationGatewayAuthenticationCertificateValue `
		-ApplicationGatewaySslCertificateValue $applicationGatewaySslCertificateValue `
		-NewCertificates $newCertificates `
		-VirtualNetworkGatewayCertificatePublicKey $virtualNetworkGatewayCertificateInformation.PublicKey;

	return $webDevelopmentDomainCertificateInformation;
}

function New-VirtualNetworkGatewayCertificateInformation
{
	param
	(
		[Parameter(Mandatory)]
		[System.Collections.Generic.IEnumerable[string]]$newCertificates,
		[Parameter(Mandatory)]
		[string]$publicKey
	)

	$propertyNames = New-StringList;

	$propertyNames.Add("NewCertificates");
	$propertyNames.Add("PublicKey");

	$virtualNetworkGatewayCertificateInformation = New-BasicObject -PropertyNames $propertyNames;

	$virtualNetworkGatewayCertificateInformation.NewCertificates = $newCertificates;
	$virtualNetworkGatewayCertificateInformation.PublicKey = $publicKey;

	return $virtualNetworkGatewayCertificateInformation;
}

function New-VirtualNetworkGatewayClientCertificate
{
	param
	(
		[Parameter(Mandatory)]
		[string]$certificateStoreLocation,
		[Parameter(Mandatory)]
		[string]$name,
		[Parameter(Mandatory)]
		$signer
	)

	return New-SelfSignedCertificate `
		-CertStoreLocation $certificateStoreLocation `
		-HashAlgorithm sha256 `
		-KeyExportPolicy Exportable `
		-KeyLength 2048 `
		-KeySpec Signature `
		-NotAfter $_certificateExpiration `
		-Signer $signer `
		-Subject "CN=$($name)" `
		-TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.2") `
		-Type Custom;
}

function New-VirtualNetworkGatewayRootCertificate
{
	param
	(
		[Parameter(Mandatory)]
		[string]$certificateStoreLocation,
		[Parameter(Mandatory)]
		[string]$name
	)

	return New-SelfSignedCertificate `
		-CertStoreLocation $certificateStoreLocation `
		-HashAlgorithm sha256 `
		-KeyExportPolicy Exportable `
		-KeyLength 2048 `
		-KeySpec Signature `
		-KeyUsage CertSign `
		-KeyUsageProperty Sign `
		-NotAfter $_certificateExpiration `
		-Subject "CN=$($name)" `
		-Type Custom;
}

function New-WebDevelopmentDomainCertificateInformation
{
	param
	(
		[Parameter(Mandatory)]
		[string]$applicationGatewayAuthenticationCertificatePublicKey,
		[Parameter(Mandatory)]
		[string]$applicationGatewayAuthenticationCertificateValue,
		[Parameter(Mandatory)]
		[string]$applicationGatewaySslCertificateValue,
		[Parameter(Mandatory)]
		[System.Collections.Generic.IEnumerable[string]]$newCertificates,
		[Parameter(Mandatory)]
		[string]$virtualNetworkGatewayCertificatePublicKey
	)

	$propertyNames = New-StringList;

	$propertyNames.Add("ApplicationGatewayAuthenticationCertificatePublicKey");
	$propertyNames.Add("ApplicationGatewayAuthenticationCertificateValue");
	$propertyNames.Add("ApplicationGatewaySslCertificateValue");
	$propertyNames.Add("NewCertificates");
	$propertyNames.Add("VirtualNetworkGatewayCertificatePublicKey");

	$webDevelopmentDomainCertificateInformation = New-BasicObject -PropertyNames $propertyNames;

	$webDevelopmentDomainCertificateInformation.ApplicationGatewayAuthenticationCertificatePublicKey = $applicationGatewayAuthenticationCertificatePublicKey;
	$webDevelopmentDomainCertificateInformation.ApplicationGatewayAuthenticationCertificateValue = $applicationGatewayAuthenticationCertificateValue;
	$webDevelopmentDomainCertificateInformation.ApplicationGatewaySslCertificateValue = $applicationGatewaySslCertificateValue;
	$webDevelopmentDomainCertificateInformation.NewCertificates = $newCertificates;
	$webDevelopmentDomainCertificateInformation.VirtualNetworkGatewayCertificatePublicKey = $virtualNetworkGatewayCertificatePublicKey;

	return $webDevelopmentDomainCertificateInformation;
}

Export-ModuleMember -Function "Get-VirtualNetworkGatewayCertificateInformation", "Get-WebDevelopmentDomainCertificateInformation";
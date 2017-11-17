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

Import-Module "$($PSScriptRoot)\..\..\Shared\PowerShell\Modules\Certificate";
Import-Module "$($PSScriptRoot)\..\..\Shared\PowerShell\Modules\Helper";

$indent = Get-Indent;

Try
{
	Write-Host;

	$webDevelopmentDomainCertificateInformation = Get-WebDevelopmentDomainCertificateInformation -DomainName $domainName -Password $password -ResourceNamePrefix $resourceNamePrefix;

	if($webDevelopmentDomainCertificateInformation.NewCertificates.Count -gt 0)
	{
		Write-Host "New local certificates have been created:";

		foreach($newCertificate in $webDevelopmentDomainCertificateInformation.NewCertificates)
		{
			Write-Host "$($indent)$($newCertificate)";
		}

		Write-Host;
	}
		
	Write-Host $webDevelopmentDomainCertificateInformation.ApplicationGatewayAuthenticationCertificatePublicKey -ForegroundColor Yellow;
	Write-Host;
	Write-Host "The ""Application Gateway Authentication Certificate Public Key Value"" is copied to the clipboard" -ForegroundColor Green;
	Set-Clipboard -Value $webDevelopmentDomainCertificateInformation.ApplicationGatewayAuthenticationCertificatePublicKey;

	PressAnyKeyToContinue;
		
	Write-Host $webDevelopmentDomainCertificateInformation.ApplicationGatewayAuthenticationCertificateValue -ForegroundColor Yellow;
	Write-Host;
	Write-Host "The ""Application Gateway Authentication Certificate Value"" is copied to the clipboard" -ForegroundColor Green;
	Set-Clipboard -Value $webDevelopmentDomainCertificateInformation.ApplicationGatewayAuthenticationCertificateValue;

	PressAnyKeyToContinue;

	Write-Host $webDevelopmentDomainCertificateInformation.ApplicationGatewaySslCertificateValue -ForegroundColor Yellow;
	Write-Host;
	Write-Host "The ""Application Gateway Ssl Certificate Value"" is copied to the clipboard" -ForegroundColor Green;
	Set-Clipboard -Value $webDevelopmentDomainCertificateInformation.ApplicationGatewaySslCertificateValue;

	PressAnyKeyToContinue;

	Write-Host $webDevelopmentDomainCertificateInformation.VirtualNetworkGatewayCertificatePublicKey -ForegroundColor Yellow;
	Write-Host;
	Write-Host "The ""Virtual Network Gateway Certificate Value"" is copied to the clipboard" -ForegroundColor Green;
	Set-Clipboard -Value $webDevelopmentDomainCertificateInformation.VirtualNetworkGatewayCertificatePublicKey;
}
Catch
{
	Write-Host "Could not get the certificate values: $($_.Exception.Message)" -ForegroundColor Red;
}

Close;
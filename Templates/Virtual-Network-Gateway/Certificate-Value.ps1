Import-Module "$($PSScriptRoot)\..\..\Shared\PowerShell\Modules\Certificate";
Import-Module "$($PSScriptRoot)\..\..\Shared\PowerShell\Modules\Helper";

$indent = Get-Indent;

Try
{
	$virtualNetworkGatewayCertificateInformation = Get-VirtualNetworkGatewayCertificateInformation;

	if($virtualNetworkGatewayCertificateInformation.NewCertificates.Count -gt 0)
	{
		Write-Host "New local certificates have been created:";

		foreach($newCertificate in $virtualNetworkGatewayCertificateInformation.NewCertificates)
		{
			Write-Host "$($indent)$($newCertificate)";
		}

		Write-Host;
	}

	Write-Host $virtualNetworkGatewayCertificateInformation.PublicKey -ForegroundColor Yellow;

	Write-Host;

	Write-Host "The ""Virtual Network Gateway Certificate Value"" is copied to the clipboard" -ForegroundColor Green;

	Set-Clipboard -Value $virtualNetworkGatewayCertificateInformation.PublicKey;
}
Catch
{
	Write-Host "Could not get the ""Virtual Network Gateway Certificate Value"": $($_.Exception.Message)" -ForegroundColor Red;
}

Close;
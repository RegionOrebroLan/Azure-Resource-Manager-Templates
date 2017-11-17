$location = "westeurope";

Login-AzureRmAccount;

# Some publishers: Microsoft, MicrosoftVisualStudio, MicrosoftWindowsServer

# Get-AzureRmVMImagePublisher -Location $location;

# Get-AzureRmVMImageOffer -Location $location -PublisherName "MicrosoftWindowsServer";

# Get-AzureRmVMImageSku -Location $location -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer";

# Get-AzureRmVMImage -Location $location -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2012-R2-Datacenter";

Write-Host Skus;

Write-Host "MicrosoftVisualStudio - VisualStudio";
Get-AzureRmVMImageSku -Location $location -Offer "VisualStudio" -PublisherName "MicrosoftVisualStudio";

Write-Host "MicrosoftVisualStudio - Windows";
Get-AzureRmVMImageSku -Location $location -Offer "Windows" -PublisherName "MicrosoftVisualStudio";

Read-Host;
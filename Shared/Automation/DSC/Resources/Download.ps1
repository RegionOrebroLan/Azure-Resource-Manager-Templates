Save-Module -Name xActiveDirectory -Path $PSScriptRoot;
Save-Module -Name xAdcsDeployment -Path $PSScriptRoot;
Save-Module -Name xChrome -Path $PSScriptRoot;
Save-Module -Name xComputerManagement -Path $PSScriptRoot;
Save-Module -Name xDnsServer -Path $PSScriptRoot;
Save-Module -Name xNetworking -Path $PSScriptRoot;
# Save-Module -Name xPSDesiredStateConfiguration -Path $PSScriptRoot; # Referenced by xChrome. Maybe it is downloaded when saving xChrome.
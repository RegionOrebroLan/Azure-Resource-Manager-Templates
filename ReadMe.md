# Azure-Resource-Manager-Templates

Templates to help you create resources in Azure.

## Templates

### <img height="20" src="https://106c4.wpc.azureedge.net/80106C4/Gallery-Prod/cdn/2015-02-24/prod20161101-microsoft-windowsazure-gallery/Microsoft.VirtualNetworkGateway-ARM.1.0.4/Icons/Small.png" /> [Virtual-Network-Gateway](/Templates/Virtual-Network-Gateway/)

### <img height="20" src="https://docs.microsoft.com/en-us/azure/active-directory/media/index/active-directory.svg" /> [Web-Development-Domain](/Templates/Web-Development-Domain/)

### PowerShell-scripts

You can deploy the templates by using PowerShell-scripts. Each "Howto" points out the script to run.

**Only supported for Windows 10/Windows Server 2016 at the moment. New-SelfSignedCertificate is used with parameter HashAlgorithm for instance and that parameter is not supported in Windows 8.1. New-SelfSignedCertificate is not supported in Windows 7.**

Windows 10 (some versions), bug when trying to paste password: https://github.com/Microsoft/console/issues/27. So for the moment we have to type the password.

Azure-modules are required and will be installed for the CurrentUser if you accept it when running the scripts. If you want to install the Azure-modules for AllUsers on your machine open PowerShell **as an administrator** and run the following command:

    Install-Module -Force -MinimumVersion 5.0.0 -Name "AzureRM.Resources" -Scope AllUsers;

## Development

The templates are based on the idea from [Azure Quickstart Templates](https://github.com/Azure/azure-quickstart-templates/).

The templates are built with:
- [**ARM**-templates (json-files)](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-authoring-templates/)
- [**DSC** (Desired State Configuration)](https://docs.microsoft.com/en-us/powershell/dsc/overview/)
- **PowerShell** (to simplify deployment)

The DSC-files are packed in zip-files and linked to from the ARM-templates. They are used by the [virtual-machine-extension-declarations](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/extensions-dsc-template/) in the ARM-templates. Most of the work is done in the DSC-files to get the machines in the state that you want.

The **Web-Development-Domain**-template as an example:

- [**Templates**](/Templates/)
  - [**Web-Development-Domain**](/Templates/Web-Development-Domain/)
    - [**DSC-Modules**](/Templates/Web-Development-Domain/DSC-Modules/)
      - [**ADFS**](/Templates/Web-Development-Domain/DSC-Modules/ADFS/)
        - [Modules.zip](/Templates/Web-Development-Domain/DSC-Modules/ADFS/Modules.zip)
      - [**Database-Server**](/Templates/Web-Development-Domain/DSC-Modules/Database-Server/)
        - [Modules.zip](/Templates/Web-Development-Domain/DSC-Modules/Database-Server/Modules.zip)
      - [**Domain-Computer**](/Templates/Web-Development-Domain/DSC-Modules/Domain-Computer/)
        - [Modules.zip](/Templates/Web-Development-Domain/DSC-Modules/Domain-Computer/Modules.zip)
      - [**Domain-Controller**](/Templates/Web-Development-Domain/DSC-Modules/Domain-Controller/)
        - [Modules.zip](/Templates/Web-Development-Domain/DSC-Modules/Domain-Controller/Modules.zip)
      - [**Web-Server**](/Templates/Web-Development-Domain/DSC-Modules/Web-Server/)
        - [Modules.zip](/Templates/Web-Development-Domain/DSC-Modules/Web-Server/Modules.zip)
    - [Azure-Deploy.json](/Templates/Web-Development-Domain/Azure-Deploy.json)
    - [Azure-Deploy.ps1](/Templates/Web-Development-Domain/Azure-Deploy.ps1)
    - ...

### Modules.zip
If we need to change it:
1. unzip it
2. change it (add/edit/remove)
3. zip it back

**Note**

If the Modules.zip gets to big you can get the following error when deploying:

*The WinRM client sent a request to the remote WS-Management service and was notified that the request size exceeded the configured MaxEnvelopeSize quota.*

You probably can change some value for this to get it to work.

### Azure-Deploy.json
This is the ARM-template.

### Azure-Deploy.ps1
If you want to deploy with PowerShell from your machine and avoid complex input.

### Resources
Maybe we want to use more resources in our **Modules.zip**. To find resources:
- [**PowerShell Gallery - Tags:"DSCResource"**](https://www.powershellgallery.com/items?q=Tags%3A%22DSCResource%22)

To download more resources use:

    Save-Module -Name xYourDesiredResource -Path $PSScriptRoot;

If we want to add resources to **Modules.zip**:
1. Add your resource downoad to [**Download.ps1**](/Shared/Automation/DSC/Resources/Download.ps1)
2. Run the script
3. Unzip **Modules.zip**
4. Copy the downoaded resources to the unzipped **Modules** directory
5. Zip the **Modules** directory back to **Modules.zip**

### Composite resources
The **Modules.zip**/Parts/DSCResources directory contains all parts for our composite resource. If we want to add another one:
- Copy one of them, one of the directories
- Rename the **directy**, the ***.psd1** file and the ***.schema.psm1** file to the same desired name
- Change the **GUID** and **RootModule** in the ***.psd1** file
- Change the implementation in the ***.schema.psm1** file

About composite resources:
- [Composite resources: Using a DSC configuration as a resource](https://docs.microsoft.com/en-us/powershell/dsc/authoringresourcecomposite)
- [Managing Large DSC Configurations With Composite Resources](https://thebreaksblog.wordpress.com/2015/10/09/managing-large-dsc-configurations-with-composite-resources-and-modularization-with-powershell-4-0/)
- [Reusing Existing Configuration Scripts in PowerShell Desired State Configuration](https://blogs.msdn.microsoft.com/powershell/2014/02/25/reusing-existing-configuration-scripts-in-powershell-desired-state-configuration/)
- [Helper Function to Create a PowerShell DSC Composite Resource](https://blogs.technet.microsoft.com/ashleymcglone/2015/02/25/helper-function-to-create-a-powershell-dsc-composite-resource/)

**Notes**

If we want to recreate the module-manifests from scratch we can run the following scripts:

    # The [SOLUTIONDIRECTORY] is the directory where you cloned this git-repository.
    
    CD [SOLUTIONDIRECTORY]\Shared\Automation\DSC\Modules\Parts
    New-ModuleManifest -Author "-" -CompanyName "-" -Copyright "-" -ModuleVersion "1.0.0" -Path "Parts.psd1";

    # For each part under [SOLUTIONDIRECTORY]\Shared\Automation\DSC\Modules\Parts\DSCResources
    CD [SOLUTIONDIRECTORY]\Shared\Automation\DSC\Modules\Parts\DSCResources\MyPart
    New-ModuleManifest -Author "-" -CompanyName "-" -Copyright "-" -ModuleVersion "1.0.0" -Path "MyPart.psd1" -RootModule "MyPart.schema.psm1";

### PowerShell PKI Module
We need the PowerShell PKI Module, PSPKI, https://github.com/Crypt32/PSPKI/. The version, when writing this read-me, is **3.2.6**.

Download: https://pspki.codeplex.com/releases/view/625365/

1. Download the zip-file: https://pspki.codeplex.com/downloads/get/1600625/
2. Extract the zip-file and create the following directory structure
    - **PSPKI**
        - **3.2.6.0**
            - Client
            - Library
            - Server
            - Types
            - ...
            - PSPKI.psd1
            - PSPKI.psm1
3. Add the **PSPKI** directory to **Modules.zip**

It is **important** that the **version-directory** (in this case 3.2.6.0) is named the same as the **ModuleVersion** in the **PSPKI.psd1** file.

### Run DSC "manually"

An example:

    configuration DomainControllerConfiguration
    {
        param
        (
            [string]$adfsCertificateTemplateNames = "SslCertificateTemplate;SSL Certificate Template",
            [Parameter(Mandatory)]
            [string]$applicationGatewayAuthenticationCertificateValue,
            [Parameter(Mandatory)]
            [string]$applicationGatewaySslCertificateValue,
            [Parameter(Mandatory)]
            [PSCredential]$credential,
            [object[]]$dnsRecords,
            [Parameter(Mandatory)]
            [string]$dnsServerForwarderIpAddress,
            [Parameter(Mandatory)]
            [string]$dnsServerIpAddress,
            [Parameter(Mandatory)]
            [string]$domainName,
            [Parameter(Mandatory)]
            [string]$ipAddress,
            [object[]]$serviceAccounts
        )

        ...
    }

    # Above is your configuration (paste it from your configuration-file). Below is for compiling.

    # Configure to allow domain-credentials.
    $configuration = @{
	    AllNodes = @(
		    @{
			    NodeName = "localhost";
			    PSDscAllowDomainUser = $true;
			    PSDscAllowPlainTextPassword = $true;
		    }
	    )
    }

    $credential = Get-Credential -Message "Password please" -UserName "yourdomain.net\User-name";

    WebDevelopmentDomainController `
        -ApplicationGatewayAuthenticationCertificateValue "1234" `
        -ApplicationGatewaySslCertificateValue "1234" `
        -ConfigurationData $configuration `
        -Credential = $credential `
        -DnsServerForwarderIpAddress "168.63.129.16" `
        -DnsServerIpAddress "127.0.0.1" `
        -DomainName "local.net" `
        -IpAddress "10.0.0.10" `
        -OutputPath $PSScriptRoot `
        -Verbose;

    Start-DscConfiguration -Path $PSScriptRoot -Wait -Verbose;

### Different notes
When setting up an Active Directory domain controller we need to add a dns-server-forwarder for the "internet". So we add the dns-server-forwarder 168.63.129.16.
- [**What is the IP address 168.63.129.16?**](https://blogs.msdn.microsoft.com/mast/2015/05/18/what-is-the-ip-address-168-63-129-16/)

**Miscellaneous**
- [**Complex Azure Template Odyssey Part Two: Domain Controller**](http://blogs.blackmarble.co.uk/blogs/rhepworth/post/2015/08/30/Complex-Azure-Template-Odyssey-Part-Two-Domain-Controller/)
- [**Desired State Configuration Quick Start**](https://msdn.microsoft.com/en-us/powershell/dsc/quickstart)
- [**DSC Script Resource**](https://msdn.microsoft.com/en-us/powershell/dsc/scriptresource)
- [**xPowerShellExecutionPolicy**](https://github.com/PowerShell/xPowerShellExecutionPolicy)
- [**Build Custom Windows PowerShell Desired State Configuration Resources**](https://msdn.microsoft.com/en-us/powershell/dsc/authoringresource)
- [**Writing a custom DSC resource with PowerShell classes**](https://msdn.microsoft.com/en-us/powershell/dsc/authoringresourceclass)
- [**Creating a Class based DSC Resource using PowerShell**](http://jacobbenson.com/?p=699#sthash.7aO3WbLr.dpbs)
- [**Use PowerShell to Configure the NIC on Windows Server 2012**](https://blogs.technet.microsoft.com/heyscriptingguy/2012/11/21/use-powershell-to-configure-the-nic-on-windows-server-2012/)
- [**Sorting the Desired State Configuration (DSC) "Running scripts is disabled on this system" error**](http://lloydholman.co.uk/sorting-the-desired-state-configuration-dsc-running-scripts-is-disabled-on-this-system-error/)

### Problems

The following DSC-script seems to work on Windows Servers but not on Windows 10:

    configuration DomainComputer
    {
	    param
	    (
		    [Parameter(Mandatory)]
		    [PSCredential]$credential,
		    [Parameter(Mandatory)]
		    [string]$domainName
	    )

	    $executionPolicy = Get-ExecutionPolicy -Scope LocalMachine;

	    if($executionPolicy -ne "RemoteSigned")
	    {
		    Set-ExecutionPolicy RemoteSigned -Force -Scope LocalMachine;
	    }

	    Import-DscResource -Module xActiveDirectory, xComputerManagement;

	    node localhost
	    {
		    LocalConfigurationManager
		    {
			    RebootNodeIfNeeded = $true;
		    }

		    xWaitForADDomain WaitForDomain
		    {
			    DomainName = $domainName;
			    DomainUserCredential = $credential;
			    RetryCount = 20;
			    RetryIntervalSec = 30;
		    }

		    xComputer JoinDomain
		    {
			    Credential = $credential;
			    DomainName = $domainName;
			    Name = $env:ComputerName;
			    DependsOn = "[xWaitForADDomain]WaitForDomain";
		    }
	    }
    }

**The error**

{"code":"DeploymentFailed","message":"At least one resource deployment operation failed. Please list deployment operations for details. Please see https://aka.ms/arm-debug for usage details.","details":[{"code":"Conflict","message":"{\r\n \"status\": \"Failed\",\r\n \"error\": {\r\n \"code\": \"ResourceDeploymentFailure\",\r\n \"message\": \"The resource operation completed with terminal provisioning state 'Failed'.\",\r\n \"details\": [\r\n {\r\n \"code\": \"VMExtensionProvisioningError\",\r\n \"message\": \"VM has reported a failure when processing extension 'Domain-Computer-Extension'. Error message: \\\"DSC Configuration 'DomainComputer' completed with error(s). Following are the first few: The client cannot connect to the destination specified in the request. Verify that the service on the destination is running and is accepting requests. Consult the logs and documentation for the WS-Management service running on the destination, most commonly IIS or WinRM. If the destination is the WinRM service, run the following command on the destination to analyze and configure the WinRM service: \\\"winrm quickconfig\\\". \\n Please note that the configuration produced errors and rebooted the machine too many times, due to this we have set the reboot if needed to false and action after reboot to stop.\\\".\"\r\n }\r\n ]\r\n }\r\n}"}]}

### Finally

- [To get more ideas, look at **Azure-QuickStart-Templates**](https://github.com/Azure/Azure-QuickStart-Templates/)
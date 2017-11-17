# Web-Development-Domain

## 1 Howto

**The password you choose is used to everything in the domain where a password is needed. So choose a safe one!**

### 1.1 PowerShell (Windows 10/Windows Server 2016)

1. [**Read this**](/ReadMe.md#powershell-scripts)
2. [**Download this repository**](https://github.com/RegionOrebroLan/Azure-Resource-Manager-Templates/archive/master.zip) and unzip, to be able to run the PowerShell script-files (if you get errors when unzipping try move the zip-file to the C-root, D-root, etc to avoid too long file-names, or you can try to ignore/skip those files)
3. Run the downloaded script [**[YOUR-UNZIPPED-REPOSITORY-PATH]\Templates\Web-Development-Domain\Azure-Deploy.ps1**](Azure-Deploy.ps1)

### 1.2 Get the values to enter from PowerShell-script (Windows 10/Windows Server 2016)

1. [**Read this**](/ReadMe.md#powershell-scripts)
2. [**Download this repository**](https://github.com/RegionOrebroLan/Azure-Resource-Manager-Templates/archive/master.zip) and unzip, to be able to run the PowerShell script-files (if you get errors when unzipping try move the zip-file to the C-root, D-root, etc to avoid too long file-names, or you can try to ignore/skip those files)
3. Click the deploy-link
4. Enter the name of a new resource-group
5. Choose a domain-name, password and resource-group-prefix
6. Run the downloaded script [**[YOUR-UNZIPPED-REPOSITORY-PATH]\Templates\Web-Development-Domain\Certificate-Values.ps1**](Certificate-Values.ps1)
7. **Certificate-Values.ps1**: Enter your chosen domain-name, password, resource-group-prefix and press enter
8. Enter the copied value from **Certificate-Values.ps1** in the "Application Gateway Authentication Certificate Public Key Value"-field
9. **Certificate-Values.ps1**: Press any key
10. Enter the copied value from **Certificate-Values.ps1** in the "Application Gateway Authentication Certificate Value"-field
11. **Certificate-Values.ps1**: Press any key
12. Enter the copied value from **Certificate-Values.ps1** in the "Application Gateway Ssl Certificate Value"-field
13. Enter your chosen domain-name in the "Domain Name"-field
14. Enter your chosen password in the "Password"-field
15. Enter your chosen resource-name-prefix in the "Resource Name Prefix"-field
16. Enter a user-name in the "User Name"-field
17. **Certificate-Values.ps1**: Press any key
18. Enter the copied value from **Certificate-Values.ps1** in the "Virtual Network Gateway Certificate Value"-field

### 1.3 If you already have values to enter

1. Click the deploy-link
2. Enter the values

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3a%2f%2fraw.githubusercontent.com%2fRegionOrebroLan%2fAzure-Resource-Manager-Templates%2fmaster%2fTemplates%2fWeb-Development-Domain%2fAzure-Deploy.json">
    <img src="http://azuredeploy.net/deploybutton.png" />
</a>
<a href="https://portal.azure.us/#create/Microsoft.Template/uri/https%3a%2f%2fraw.githubusercontent.com%2fRegionOrebroLan%2fAzure-Resource-Manager-Templates%2fmaster%2fTemplates%2fWeb-Development-Domain%2fAzure-Deploy.json">
    <img src="http://azuredeploy.net/azuregov.png" />
</a>
<a href="http://armviz.io/#/?load=https%3a%2f%2fraw.githubusercontent.com%2fRegionOrebroLan%2fAzure-Resource-Manager-Templates%2fmaster%2fTemplates%2fWeb-Development-Domain%2fAzure-Deploy.json">
    <img src="http://armviz.io/visualizebutton.png" />
</a>

## 2 Result

The machine-names depends on what resource-name-prefix you choose and the ip-addresses depends on what ip-address-first-part/ip-address-second-part you choose. If you choose the following eg:

- resource-name-prefix: **"AB01-"**
- ip-address-first-part: **10**
- ip-address-second-part: **0**

the result will be:

### 2.1 Machines

- **AB01-ADFS-01 / 10.0.0.20**: Windows Server 2016 Datacenter, ADFS
- **AB01-Client-01 / 10.0.0.100**: Windows 10 Enterprise
- **AB01-DB-01 / 10.0.0.60**: Windows Server 2016, SQL Server 2017 Developer
- **AB01-DC-01 / 10.0.0.10**: Windows Server 2016 Datacenter, domain-controller (Active Directory), dns-server and certificate-server
- **AB01-Dev-01 / 10.0.0.80**: Windows 10 Enterprise, Visual Studio 2017 Enterprise
- **AB01-Web-01 / 10.0.0.31**: Windows Server 2016 Datacenter, web server with IIS
- **AB01-Web-02 / 10.0.0.32**: Windows Server 2016 Datacenter, web server with IIS

### 2.2 Two application-gateways

#### 2.2.1 Internal

- http -> https redirect
- Loadbalancing
  - The alias **AB01-Web / 10.0.0.140** points to **AB01-Web-01 / 10.0.0.31** and **AB01-Web-02 / 10.0.0.32**

#### 2.2.1 Public

- http -> https redirect
- Loadbalancing
  - The public ip for the application-gateway points to **AB01-Web-01 / 10.0.0.31** and **AB01-Web-02 / 10.0.0.32**

### 2.3 A Point-To-Site VPN connection

- Download it (https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-howto-point-to-site-classic-azure-portal#vpnclientconfig)
- Install it
- Connect
- You can now connect to your machines with remote desktop
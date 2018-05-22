# SQL-Server

This template is for creating a SQL Server machine to handle situations where you are behind a firewall with port-restrictions. If you are not behind a firewall with port-restrctions you can create an Azure SQL Database that listens on port 1433.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3a%2f%2fraw.githubusercontent.com%2fRegionOrebroLan%2fAzure-Resource-Manager-Templates%2fmaster%2fTemplates%2fSQL-Server%2fAzure-Deploy.json">
    <img src="http://azuredeploy.net/deploybutton.png" />
</a>
<a href="https://portal.azure.us/#create/Microsoft.Template/uri/https%3a%2f%2fraw.githubusercontent.com%2fRegionOrebroLan%2fAzure-Resource-Manager-Templates%2fmaster%2fTemplates%2fSQL-Server%2fAzure-Deploy.json">
    <img src="http://azuredeploy.net/azuregov.png" />
</a>
<a href="http://armviz.io/#/?load=https%3a%2f%2fraw.githubusercontent.com%2fRegionOrebroLan%2fAzure-Resource-Manager-Templates%2fmaster%2fTemplates%2fSQL-Server%2fAzure-Deploy.json">
    <img src="http://armviz.io/visualizebutton.png" />
</a>

## Issues

After deployment it is not possible to connect to the SQL Server instantly. In the Azure-portal you need to enter the "SQL Server configuration" tab for the virtual machine, change the port and then change it back to be able to connect to the SQL Server. Dont know why.

The image used for this virtual machine is:
- Image-offer: "SQL2017-WS2016"
- Image-publisher: "MicrosoftSQLServer"
- Image-sku: "SQLDEV"

It seems like it is not correctly patched after creation. When you try to connect with RDP to it, you get an exception:

- [Unable to RDP to Virtual Machine: CredSSP Encryption Oracle Remediation](https://blogs.technet.microsoft.com/mckittrick/unable-to-rdp-to-virtual-machine-credssp-encryption-oracle-remediation/)

## Connect

These instructions are for the following entered values as an example:

- Machine Name: **OUR-SQL-01**
- Password: **My-P@ssword-98**
- Port: **8080**
- User Name: **My-User-Name**

### 1 Connect with Remote Desktop (RDP)

- If you are **NOT** behind a firewall with port-restrictions: **our-sql-01.westeurope.cloudapp.azure.com**
- If you are behind a firewall with port-restrictions: **our-sql-01-load-balancer.westeurope.cloudapp.azure.com:443**

### 2 Connect to SQL Server

#### 2.1 SQL Server Management Studio

- Server name: **our-sql-01.westeurope.cloudapp.azure.com,8080**
- Authentication: **SQL Server Authentication**
- Login: **My-User-Name**
- Password: **My-P@ssword-98**

#### 2.2 .NET - ConnectionString

    <add name="Connection-String-Name" connectionString="Server=our-sql-01.westeurope.cloudapp.azure.com,8080;User Id=My-User-Name;Password=My-P@ssword-98" providerName="System.Data.SqlClient" />

## Links

- https://github.com/Azure/azure-quickstart-templates/blob/master/101-vm-sql-existing-autopatching-update/prereqs/prereq.azuredeploy.json
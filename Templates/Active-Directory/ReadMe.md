# Active-Directory

This template is for creating an Active Directory machine to handle situations where you are behind a firewall with port-restrictions.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3a%2f%2fraw.githubusercontent.com%2fRegionOrebroLan%2fAzure-Resource-Manager-Templates%2fmaster%2fTemplates%2fActive-Directory%2fAzure-Deploy.json">
    <img src="http://azuredeploy.net/deploybutton.png" />
</a>
<a href="https://portal.azure.us/#create/Microsoft.Template/uri/https%3a%2f%2fraw.githubusercontent.com%2fRegionOrebroLan%2fAzure-Resource-Manager-Templates%2fmaster%2fTemplates%2fActive-Directory%2fAzure-Deploy.json">
    <img src="http://azuredeploy.net/azuregov.png" />
</a>
<a href="http://armviz.io/#/?load=https%3a%2f%2fraw.githubusercontent.com%2fRegionOrebroLan%2fAzure-Resource-Manager-Templates%2fmaster%2fTemplates%2fActive-Directory%2fAzure-Deploy.json">
    <img src="http://armviz.io/visualizebutton.png" />
</a>

## Connect

These instructions are for the following entered values as an example:

- Domain Name: **local.net**
- Machine Name: **OUR-AD-01**
- Password: **My-P@ssword-98**
- User Name: **My-User-Name**

### 1 Connect with Remote Desktop (RDP)

- If you are **NOT** behind a firewall with port-restrictions: **our-ad-01.westeurope.cloudapp.azure.com**
- If you are behind a firewall with port-restrictions: **our-ad-01-load-balancer.westeurope.cloudapp.azure.com:443**

### 2 Connect with C#

#### 2.1 If you are NOT behind a firewall with port-restrictions

    using (var principalContext = new System.DirectoryServices.AccountManagement.PrincipalContext(System.DirectoryServices.AccountManagement.ContextType.Domain, "our-ad-01.westeurope.cloudapp.azure.com", "DC=local,DC=net", System.DirectoryServices.AccountManagement.ContextOptions.Negotiate, "My-User-Name", "My-P@ssword-98"))
    {
	    var userPrincipal = System.DirectoryServices.AccountManagement.UserPrincipal.FindByIdentity(principalContext, System.DirectoryServices.AccountManagement.IdentityType.SamAccountName, "My-User-Name");
    }

    using(var directoryEntry = new System.DirectoryServices.DirectoryEntry("LDAP://our-ad-01.westeurope.cloudapp.azure.com/DC=local,DC=net", "My-User-Name", "My-P@ssword-98"))
    {
	    var guid = directoryEntry.Guid;
    }

#### 2.2 If you are behind a firewall with port-restrictions

    using (var principalContext = new System.DirectoryServices.AccountManagement.PrincipalContext(System.DirectoryServices.AccountManagement.ContextType.Domain, "our-ad-01-load-balancer.westeurope.cloudapp.azure.com:80", "DC=local,DC=net", System.DirectoryServices.AccountManagement.ContextOptions.Negotiate, "My-User-Name", "My-P@ssword-98"))
    {
	    var userPrincipal = System.DirectoryServices.AccountManagement.UserPrincipal.FindByIdentity(principalContext, System.DirectoryServices.AccountManagement.IdentityType.SamAccountName, "My-User-Name");
    }

    using(var directoryEntry = new System.DirectoryServices.DirectoryEntry("LDAP://our-ad-01-load-balancer.westeurope.cloudapp.azure.com:80/DC=local,DC=net", "My-User-Name", "My-P@ssword-98"))
    {
	    var guid = directoryEntry.Guid;
    }
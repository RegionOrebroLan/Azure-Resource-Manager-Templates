configuration SharingGroupPolicies
{
	Import-DscResource -Module Parts, PSDesiredStateConfiguration;

	$firewallRulesKey = "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\WindowsFirewall\FirewallRules";
	$firewallRulesType = "String";
	$lltdKey = "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\LLTD";
	$lltdType = "DWord";
	$name = "Default Domain Policy";

	GroupPolicy "EnableLLTDIO"
	{
		Key = $lltdKey;
		Name = $name;
		Type = $lltdType;
		Value = 1;
		ValueName = "EnableLLTDIO";
	}

	GroupPolicy "AllowLLTDIOOnDomain"
	{
		Key = $lltdKey;
		Name = $name;
		Type = $lltdType;
		Value = 1;
		ValueName = "AllowLLTDIOOnDomain";
	}

	GroupPolicy "AllowLLTDIOOnPublicNet"
	{
		Key = $lltdKey;
		Name = $name;
		Type = $lltdType;
		Value = 0;
		ValueName = "AllowLLTDIOOnPublicNet";
	}

	GroupPolicy "ProhibitLLTDIOOnPrivateNet"
	{
		Key = $lltdKey;
		Name = $name;
		Type = $lltdType;
		Value = 0;
		ValueName = "ProhibitLLTDIOOnPrivateNet";
	}

	GroupPolicy "EnableRspndr"
	{
		Name = $name;
		Key = $lltdKey;
		Type = $lltdType;
		Value = 1;
		ValueName = "EnableRspndr";
	}

	GroupPolicy "AllowRspndrOnDomain"
	{
		Name = $name;
		Key = $lltdKey;
		Type = $lltdType;
		Value = 1;
		ValueName = "AllowRspndrOnDomain";
	}

	GroupPolicy "AllowRspndrOnPublicNet"
	{
		Name = $name;
		Key = $lltdKey;
		Type = $lltdType;
		Value = 0;
		ValueName = "AllowRspndrOnPublicNet";
	}

	GroupPolicy "ProhibitRspndrOnPrivateNet"
	{
		Name = $name;
		Key = $lltdKey;
		Type = $lltdType;
		Value = 0;
		ValueName = "ProhibitRspndrOnPrivateNet";
	}

	GroupPolicy "NETDIS-FDRESPUB-WSD-In-UDP"
	{
		Key = $firewallRulesKey;
		Name = $name;
		Type = $firewallRulesType;
		Value = "v2.26|Action=Allow|Active=TRUE|Dir=In|Protocol=17|LPort=3702|RA4=LocalSubnet|RA6=LocalSubnet|App=%SystemRoot%\system32\svchost.exe|Svc=fdrespub|Name=@FirewallAPI.dll,-32809|Desc=@FirewallAPI.dll,-32810|EmbedCtxt=@FirewallAPI.dll,-32752|";
		ValueName = "NETDIS-FDRESPUB-WSD-In-UDP";
	}

	GroupPolicy "NETDIS-LLMNR-In-UDP"
	{
		Key = $firewallRulesKey;
		Name = $name;
		Type = $firewallRulesType;
		Value = "v2.26|Action=Allow|Active=TRUE|Dir=In|Protocol=17|LPort=5355|RA4=LocalSubnet|RA6=LocalSubnet|App=%SystemRoot%\system32\svchost.exe|Svc=dnscache|Name=@FirewallAPI.dll,-32801|Desc=@FirewallAPI.dll,-32804|EmbedCtxt=@FirewallAPI.dll,-32752|";
		ValueName = "NETDIS-LLMNR-In-UDP";
	}

	GroupPolicy "NETDIS-FDPHOST-In-UDP"
	{
		Key = $firewallRulesKey;
		Name = $name;
		Type = $firewallRulesType;
		Value = "v2.26|Action=Allow|Active=TRUE|Dir=In|Protocol=17|LPort=3702|RA4=LocalSubnet|RA6=LocalSubnet|App=%SystemRoot%\system32\svchost.exe|Svc=fdphost|Name=@FirewallAPI.dll,-32785|Desc=@FirewallAPI.dll,-32788|EmbedCtxt=@FirewallAPI.dll,-32752|";
		ValueName = "NETDIS-FDPHOST-In-UDP";
	}

	GroupPolicy "NETDIS-SSDPSrv-In-UDP"
	{
		Key = $firewallRulesKey;
		Name = $name;
		Type = $firewallRulesType;
		Value = "v2.26|Action=Allow|Active=TRUE|Dir=In|Protocol=17|LPort=1900|RA4=LocalSubnet|RA6=LocalSubnet|App=%SystemRoot%\system32\svchost.exe|Svc=Ssdpsrv|Name=@FirewallAPI.dll,-32753|Desc=@FirewallAPI.dll,-32756|EmbedCtxt=@FirewallAPI.dll,-32752|";
		ValueName = "NETDIS-SSDPSrv-In-UDP";
	}

	GroupPolicy "NETDIS-WSDEVNT-In-TCP"
	{
		Key = $firewallRulesKey;
		Name = $name;
		Type = $firewallRulesType;
		Value = "v2.26|Action=Allow|Active=TRUE|Dir=In|Protocol=6|LPort=5357|App=System|Name=@FirewallAPI.dll,-32817|Desc=@FirewallAPI.dll,-32818|EmbedCtxt=@FirewallAPI.dll,-32752|";
		ValueName = "NETDIS-WSDEVNT-In-TCP";
	}

	GroupPolicy "NETDIS-WSDEVNTS-In-TCP"
	{
		Key = $firewallRulesKey;
		Name = $name;
		Type = $firewallRulesType;
		Value = "v2.26|Action=Allow|Active=TRUE|Dir=In|Protocol=6|LPort=5358|App=System|Name=@FirewallAPI.dll,-32813|Desc=@FirewallAPI.dll,-32814|EmbedCtxt=@FirewallAPI.dll,-32752|";
		ValueName = "NETDIS-WSDEVNTS-In-TCP";
	}

	GroupPolicy "NETDIS-NB_Datagram-In-UDP"
	{
		Key = $firewallRulesKey;
		Name = $name;
		Type = $firewallRulesType;
		Value = "v2.26|Action=Allow|Active=TRUE|Dir=In|Protocol=17|LPort=138|App=System|Name=@FirewallAPI.dll,-32777|Desc=@FirewallAPI.dll,-32780|EmbedCtxt=@FirewallAPI.dll,-32752|";
		ValueName = "NETDIS-NB_Datagram-In-UDP";
	}

	GroupPolicy "NETDIS-NB_Name-In-UDP"
	{
		Key = $firewallRulesKey;
		Name = $name;
		Type = $firewallRulesType;
		Value = "v2.26|Action=Allow|Active=TRUE|Dir=In|Protocol=17|LPort=137|App=System|Name=@FirewallAPI.dll,-32769|Desc=@FirewallAPI.dll,-32772|EmbedCtxt=@FirewallAPI.dll,-32752|";
		ValueName = "NETDIS-NB_Name-In-UDP";
	}

	GroupPolicy "NETDIS-UPnPHost-In-TCP"
	{
		Key = $firewallRulesKey;
		Name = $name;
		Type = $firewallRulesType;
		Value = "v2.26|Action=Allow|Active=TRUE|Dir=In|Protocol=6|LPort=2869|App=System|Name=@FirewallAPI.dll,-32761|Desc=@FirewallAPI.dll,-32764|EmbedCtxt=@FirewallAPI.dll,-32752|";
		ValueName = "NETDIS-UPnPHost-In-TCP";
	}

	GroupPolicy "FPS-LLMNR-In-UDP"
	{
		Key = $firewallRulesKey;
		Name = $name;
		Type = $firewallRulesType;
		Value = "v2.26|Action=Allow|Active=TRUE|Dir=In|Protocol=17|LPort=5355|RA4=LocalSubnet|RA6=LocalSubnet|App=%SystemRoot%\system32\svchost.exe|Svc=dnscache|Name=@FirewallAPI.dll,-28548|Desc=@FirewallAPI.dll,-28549|EmbedCtxt=@FirewallAPI.dll,-28502|";
		ValueName = "FPS-LLMNR-In-UDP";
	}

	GroupPolicy "FPS-ICMP6-ERQ-In"
	{
		Key = $firewallRulesKey;
		Name = $name;
		Type = $firewallRulesType;
		Value = "v2.26|Action=Allow|Active=TRUE|Dir=In|Protocol=58|ICMP6=128:*|Name=@FirewallAPI.dll,-28545|Desc=@FirewallAPI.dll,-28547|EmbedCtxt=@FirewallAPI.dll,-28502|";
		ValueName = "FPS-ICMP6-ERQ-In";
	}

	GroupPolicy "FPS-ICMP4-ERQ-In"
	{
		Key = $firewallRulesKey;
		Name = $name;
		Type = $firewallRulesType;
		Value = "v2.26|Action=Allow|Active=TRUE|Dir=In|Protocol=1|ICMP4=8:*|Name=@FirewallAPI.dll,-28543|Desc=@FirewallAPI.dll,-28547|EmbedCtxt=@FirewallAPI.dll,-28502|";
		ValueName = "FPS-ICMP4-ERQ-In";
	}

	GroupPolicy "FPS-RPCSS-In-TCP"
	{
		Key = $firewallRulesKey;
		Name = $name;
		Type = $firewallRulesType;
		Value = "v2.26|Action=Allow|Active=TRUE|Dir=In|Protocol=6|LPort=RPC-EPMap|Svc=Rpcss|Name=@FirewallAPI.dll,-28539|Desc=@FirewallAPI.dll,-28542|EmbedCtxt=@FirewallAPI.dll,-28502|";
		ValueName = "FPS-RPCSS-In-TCP";
	}

	GroupPolicy "FPS-SpoolSvc-In-TCP"
	{
		Key = $firewallRulesKey;
		Name = $name;
		Type = $firewallRulesType;
		Value = "v2.26|Action=Allow|Active=TRUE|Dir=In|Protocol=6|LPort=RPC|App=%SystemRoot%\system32\spoolsv.exe|Svc=Spooler|Name=@FirewallAPI.dll,-28535|Desc=@FirewallAPI.dll,-28538|EmbedCtxt=@FirewallAPI.dll,-28502|";
		ValueName = "FPS-SpoolSvc-In-TCP";
	}

	GroupPolicy "FPS-NB_Datagram-In-UDP"
	{
		Key = $firewallRulesKey;
		Name = $name;
		Type = $firewallRulesType;
		Value = "v2.26|Action=Allow|Active=TRUE|Dir=In|Protocol=17|LPort=138|App=System|Name=@FirewallAPI.dll,-28527|Desc=@FirewallAPI.dll,-28530|EmbedCtxt=@FirewallAPI.dll,-28502|";
		ValueName = "FPS-NB_Datagram-In-UDP";
	}

	GroupPolicy "FPS-NB_Name-In-UDP"
	{
		Key = $firewallRulesKey;
		Name = $name;
		Type = $firewallRulesType;
		Value = "v2.26|Action=Allow|Active=TRUE|Dir=In|Protocol=17|LPort=137|App=System|Name=@FirewallAPI.dll,-28519|Desc=@FirewallAPI.dll,-28522|EmbedCtxt=@FirewallAPI.dll,-28502|";
		ValueName = "FPS-NB_Name-In-UDP";
	}

	GroupPolicy "FPS-SMB-In-TCP"
	{
		Key = $firewallRulesKey;
		Name = $name;
		Type = $firewallRulesType;
		Value = "v2.26|Action=Allow|Active=TRUE|Dir=In|Protocol=6|LPort=445|App=System|Name=@FirewallAPI.dll,-28511|Desc=@FirewallAPI.dll,-28514|EmbedCtxt=@FirewallAPI.dll,-28502|";
		ValueName = "FPS-SMB-In-TCP";
	}

	GroupPolicy "FPS-NB_Session-In-TCP"
	{
		Key = $firewallRulesKey;
		Name = $name;
		Type = $firewallRulesType;
		Value = "v2.26|Action=Allow|Active=TRUE|Dir=In|Protocol=6|LPort=139|App=System|Name=@FirewallAPI.dll,-28503|Desc=@FirewallAPI.dll,-28506|EmbedCtxt=@FirewallAPI.dll,-28502|";
		ValueName = "FPS-NB_Session-In-TCP";
	}

	GroupPolicy "PolicyVersion"
	{
		Key = "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\WindowsFirewall";
		Name = $name;
		Type = "DWord";
		Value = 538
		ValueName = "PolicyVersion";
	}

	Script Update
	{
		GetScript = {
			return @{ Result = "" };
		}
		SetScript = {
			GPUpdate /Force /Logoff /Boot;
		}
		TestScript = {
			return $false;
		}
	}

	<#
	Script Reboot
	{
		GetScript = {
			return @{ Result = "" };
		}
		SetScript = {
			$global:DSCMachineStatus = 1;
		}
		TestScript = {
			return $false;
		}
	}
	#>
}
configuration GroupPolicy
{
	param
	(
		[Parameter(Mandatory)]
		[string]$key,
		[Parameter(Mandatory)]
		[string]$name,
		[Parameter(Mandatory)]
		[ValidateSet("Binary", "DWord", "ExpandString", "MultiString", "QWord", "String", "Unknown")]
		[string]$type,
		[object]$value,
		[Parameter(Mandatory)]
		[string]$valueName
	)

	Import-DscResource -Module PSDesiredStateConfiguration;

	$_existsPrefix = "Exists=True;";
	$groupPolicyName = $name;
	$registryKey = $key;
	$registryValue = $value;

	Script "GroupPolicy"
	{
		GetScript = {
			$registryItem = Get-GPRegistryValue -ErrorAction SilentlyContinue -Key $using:registryKey -Name $using:groupPolicyName -ValueName $using:valueName;

			if($registryItem)
			{
				$valueToString = "";

				if($using:registryValue -ne $null)
				{
					$valueToString = ($using:registryValue).ToString();
				}

				$result = "Type=$(($using:type).ToString());Value=$($valueToString)";

				if($registryItem.Type -eq $using:type -and $registryItem.Value -eq $using:registryValue)
				{
					$result = "$($using:_existsPrefix)$($result)";
				}
				else
				{
					$result = "Exists=False;$($result)";
				}				
			}
			else
			{
				$result = "";
			}

			return @{ Result = $result };
		}
		SetScript = {
			try
			{
				Set-GPRegistryValue -Key $($using:registryKey) -Name $($using:groupPolicyName) -Type $($using:type) -Value $($using:registryValue) -ValueName $($using:valueName);
			}
			catch
			{
				throw "Could not set group-policy-registry-value, key = ""$($using:registryKey)"", name = ""$($using:groupPolicyName)"", type = ""$($using:type)"", value = ""$($using:registryValue)"", value-name = ""$($using:valueName)"". -> $($_.Exception.Message)";
			}
		}
		TestScript = {
			$result = (Invoke-Expression -Command $GetScript)["Result"];

			if($result -and $result.StartsWith($using:_existsPrefix))
			{
				return $true;
			}

			return $false;
		}
	}
}
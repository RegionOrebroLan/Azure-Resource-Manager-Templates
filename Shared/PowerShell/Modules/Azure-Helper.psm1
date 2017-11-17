$_defaultLocation = "westeurope";
$_templateUriFormat = "https://raw.githubusercontent.com/RegionOrebroLan/Azure-Resource-Manager-Templates/master/Templates/{0}/Azure-Deploy.json";

$_invalidPasswords = New-Object System.Collections.Generic.List[string];
$_invalidPasswords.Add("abc@123");
$_invalidPasswords.Add("iloveyou!");
$_invalidPasswords.Add("P@`$`$w0rd");
$_invalidPasswords.Add("P@ssw0rd");
$_invalidPasswords.Add("P@ssword123");
$_invalidPasswords.Add("Pa`$`$word");
$_invalidPasswords.Add("pass@word1");
$_invalidPasswords.Add("Password!");
$_invalidPasswords.Add("Password1");
$_invalidPasswords.Add("Password22");

$_invalidUserNames = New-Object System.Collections.Generic.List[string];
$_invalidUserNames.Add("_388945a0");
$_invalidUserNames.Add("1");
$_invalidUserNames.Add("123");
$_invalidUserNames.Add("a");
$_invalidUserNames.Add("actuser");
$_invalidUserNames.Add("adm");
$_invalidUserNames.Add("admin");
$_invalidUserNames.Add("admin1");
$_invalidUserNames.Add("admin2");
$_invalidUserNames.Add("administrator");
$_invalidUserNames.Add("aspnet");
$_invalidUserNames.Add("backup");
$_invalidUserNames.Add("console");
$_invalidUserNames.Add("david");
$_invalidUserNames.Add("guest");
$_invalidUserNames.Add("john");
$_invalidUserNames.Add("owner");
$_invalidUserNames.Add("root");
$_invalidUserNames.Add("server");
$_invalidUserNames.Add("sql");
$_invalidUserNames.Add("support");
$_invalidUserNames.Add("support");
$_invalidUserNames.Add("sys");
$_invalidUserNames.Add("test");
$_invalidUserNames.Add("test1");
$_invalidUserNames.Add("test2");
$_invalidUserNames.Add("test3");
$_invalidUserNames.Add("user");
$_invalidUserNames.Add("user1");
$_invalidUserNames.Add("user2");
$_invalidUserNames.Add("user3");
$_invalidUserNames.Add("user4");
$_invalidUserNames.Add("user5");

Import-Module "$($PSScriptRoot)\Helper";
Import-Module "$($PSScriptRoot)\Test-Helper";

$_azureResourcesModule = New-ModuleInformation -Name "AzureRM.Resources" -Version (New-Object System.Version(5, 0, 0)); # AzureRM.Profile 4.0.0 is also required but will be installed because AzureRM.Resources depends on it.
$_requiredModules = $_azureResourcesModule;

function Authenticate
{
	$activity = "Logging in...";

	Write-Progress -Activity $activity;

	if(IsNotTest)
	{
		$dummyToAvoidConsoleWriting = Login-AzureRmAccount;
	}
	else
	{
		Start-Sleep -s (Get-SleepTimeInSecondsForTests);
	}

	Write-Progress -Activity $activity -Completed;
}

function Deploy
{
	param
	(
		[Parameter(Mandatory)]
		$azureContext,
		[Parameter(Mandatory)]
		[System.Collections.Hashtable]$parameters,
		[Parameter(Mandatory)]
		[string]$uri
	)

	$started = Get-Date;

	Write-Host;

	Write-Host "Deploy started: $($started)";

	DeployResourceGroupIfNecessary -AzureContext $azureContext;

	DeployTemplate -AzureContext $azureContext -Parameters $parameters -Uri $uri;

	$finished = Get-Date;

	Write-Host "Deploy finished: $($finished)";

	Write-Host;

	[ConsoleColor]$color = Get-ConfirmationColor;
	Write-Host "Deployed successfully." -ForegroundColor $color;
	Write-Host "$($indent)Template: $($uri)" -ForegroundColor $color;
	Write-Host "$($indent)Duration: $(New-TimeSpan -End $finished -Start $started)" -ForegroundColor $color;
}

function DeployResourceGroupIfNecessary
{
	param
	(
		[Parameter(Mandatory)]
		$azureContext
	)

	if(!$azureContext.NewResourceGroup -or $azureContext.NewResourceGroup -eq $null)
	{
		return;
	}

	$activity = "Deploying resource-group...";

	Write-Progress -Activity $activity;

	if(IsNotTest)
	{
		New-AzureRmResourceGroup -Location $azureContext.NewResourceGroup.Location -Name $azureContext.NewResourceGroup.Name;
	}
	else
	{
		Start-Sleep -s (Get-SleepTimeInSecondsForTests);
	}

	Write-Progress -Activity $activity -Completed;
}

function DeployTemplate
{
	param
	(
		[Parameter(Mandatory)]
		$azureContext,
		[Parameter(Mandatory)]
		[System.Collections.Hashtable]$parameters,
		[Parameter(Mandatory)]
		[string]$uri
	)

	if($azureContext.NewResourceGroup -and $azureContext.NewResourceGroup -ne $null)
	{
		$resourceGroup = $azureContext.NewResourceGroup;
	}
	else
	{
		$resourceGroup = Get-SelectedResourceGroup -AzureContext $azureContext;
	}

	$activity = "Deploying template...";

	Write-Progress -Activity $activity;

	if(IsNotTest)
	{
		New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroup.Name -TemplateParameterObject $parameters -TemplateUri $uri;
	}
	else
	{
		Start-Sleep -s (Get-SleepTimeInSecondsForTests);
	}

	Write-Progress -Activity $activity -Completed;
}

function DomainNameIsValid
{
	param
	(
		[string]$domainName
	)

	if(StringIsNullOrEmpty $domainName)
	{
		return $false;
	}

	return $true;
}

function Get-DefaultResourceNamePrefix
{
	param
	(
		[Parameter(Mandatory)]
		$resourceGroup
	)

	if(!$resourceGroup.Name -or $resourceGroup.Name -eq "")
	{
		return $resourceGroup.Name;
	}

	$prefix = $this.Name;

	if($prefix.Length -gt 4)
	{
		$prefix = $prefix.Substring(0, 4);
	}

	return "$($prefix.ToUpper())-";
}

function Get-NewOrSelectedResourceGroup
{
	param
	(
		[Parameter(Mandatory)]
		$azureContext
	)

	if($azureContext.NewResourceGroup)
	{
		return $azureContext.NewResourceGroup;
	}

	return (Get-SelectedResourceGroup -AzureContext $azureContext);
}

function Get-ResourceGroupLabel
{
	param
	(
		[Parameter(Mandatory)]
		$resourceGroup
	)

	return "$($resourceGroup.Name) ($($resourceGroup.Location))";
}

function Get-ResourceGroups
{
	$activity = "Getting resource-groups...";

	Write-Progress -Activity $activity;

	if(IsNotTest)
	{
		$resourceGroups = New-ObjectList;

		foreach($azureRmResourceGroup in Get-AzureRmResourceGroup)
		{
			$resourceGroups.Add((New-ResourceGroup -Location $azureRmResourceGroup.Location -Name $azureRmResourceGroup.ResourceGroupName));
		}
	}
	else
	{
		Start-Sleep -s (Get-SleepTimeInSecondsForTests);
		$resourceGroups = New-TestResourceGroups;
	}

	Write-Progress -Activity $activity -Completed;

	return $resourceGroups;
}

function Get-SelectedResourceGroup
{
	param
	(
		[Parameter(Mandatory)]
		$azureContext
	)

	foreach($resourceGroup in $azureContext.ResourceGroups)
	{
		if($resourceGroup.Selected -eq $true)
		{
			return $resourceGroup;
		}
	}

	return $null;
}

function Get-SelectedSubscription
{
	param
	(
		[Parameter(Mandatory)]
		$azureContext
	)

	foreach($subscription in $azureContext.Subscriptions)
	{
		if($subscription.Selected -eq $true)
		{
			return $subscription;
		}
	}

	return $null;
}

function Get-SubscriptionLabel
{
	param
	(
		[Parameter(Mandatory)]
		$subscription
	)

	return "$($subscription.Name) ($($subscription.Id))";
}

function Get-Subscriptions
{
	$activity = "Getting your subscriptions...";

	Write-Progress -Activity $activity;

	if(IsNotTest)
	{
		$subscriptions = New-ObjectList;

		foreach($azureRmSubscription in Get-AzureRmSubscription)
		{
			$subscriptions.Add((New-Subscription -Id $azureRmSubscription.Id -Name $azureRmSubscription.Name));
		}
	}
	else
	{
		Start-Sleep -s (Get-SleepTimeInSecondsForTests);
		$subscriptions = New-TestSubscriptions;
	}

	Write-Progress -Activity $activity -Completed;

	return $subscriptions;
}

function Get-TemplateUriFormat
{
	return $_templateUriFormat;
}

function Initialize
{
	$installationNeeded = Prerequisites;

	if($installationNeeded -eq $true)
	{
		Write-Host;
	}

	Authenticate;

	$activity = "Getting Azure-context...";

	Write-Progress -Activity $activity;

	if(IsNotTest)
	{
		Try
		{
			$azureRmContext = Get-AzureRmContext;
		}
		Catch
		{
			Write-Progress -Activity $activity -Completed;

			WriteError $_.Exception.Message;
		}
	}
	else
	{
		Start-Sleep -s (Get-SleepTimeInSecondsForTests);
	}

	Write-Progress -Activity $activity -Completed;

	$azureContext = New-AzureContext;

	if(IsNotTest)
	{
		$azureContext.Account = $azureRmContext.Account;
	}
	else
	{
		$azureContext.Account = "firstname.lastname@company.com";
	}

	Write-Host "Logged in as: $($azureContext.Account)";

	Populate-Subscriptions -AzureContext $azureContext;
	
	if($azureContext.Subscriptions.Count -lt 1)
	{
		WriteMissingSubscriptionError;
	}

	Populate-ResourceGroups -AzureContext $azureContext;

	if(IsNotTest)
	{
		$selectedSubscription = $null;

		if($azureRmContext.Subscription)
		{
			$selectedSubscription = New-Subscription -Id $azureRmContext.Subscription.Id -Name $azureRmContext.Subscription.Name;
		}

		if($selectedSubscription)
		{
			foreach($subscription in $azureContext.Subscriptions)
			{
				if(Subscription-Equals $selectedSubscription $subscription)
				{
					$subscription.Selected = $true;
				}
			}
		}
	}

	return $azureContext;
}

function New-AzureContext
{
	$propertyNames = New-StringList;

	$propertyNames.Add("Account");
	$propertyNames.Add("NewResourceGroup");
	$propertyNames.Add("ResourceGroups");
	$propertyNames.Add("ResourceNamePrefix");
	$propertyNames.Add("Subscriptions");

	$azureContext = New-BasicObject -PropertyNames $propertyNames;

	$azureContext.ResourceGroups = New-ObjectList;
	$azureContext.Subscriptions = New-ObjectList;

	return $azureContext;
}

function New-ItemPropertyNames
{
	$propertyNames = New-StringList;

	$propertyNames.Add("Name");
	$propertyNames.Add("Selected");

	return $propertyNames;
}

function New-ResourceGroup
{
	param
	(
		[string]$location = $_defaultLocation,
		[Parameter(Mandatory)]
		[string]$name,
		[bool]$selected = $false
	)

	$basicPropertyNames = New-ItemPropertyNames;

	$propertyNames = New-StringList;

	$propertyNames.Add("Location");

	foreach($propertyName in $basicPropertyNames)
	{
		$propertyNames.Add($propertyName);
	}	

	$resourceGroup = New-BasicObject -PropertyNames $propertyNames;

	$resourceGroup.Location = $location;
	$resourceGroup.Name = $name;
	$resourceGroup.Selected = $selected;

	$resourceGroup | Add-Member -MemberType  ScriptProperty -Name "Prefix" -Value {
		return Get-DefaultResourceNamePrefix -ResourceGroup $this;
	};

	return $resourceGroup;
}

function New-Subscription
{
	param
	(
		[Parameter(Mandatory)]
		[string]$id,
		[Parameter(Mandatory)]
		[string]$name,
		[bool]$selected = $false
	)

	$basicPropertyNames = New-ItemPropertyNames;

	$propertyNames = New-StringList;

	$propertyNames.Add("Id");

	foreach($propertyName in $basicPropertyNames)
	{
		$propertyNames.Add($propertyName);
	}	

	$subscription = New-BasicObject -PropertyNames $propertyNames;

	$subscription.Id = $id;
	$subscription.Name = $name;
	$subscription.Selected = $selected;

	return $subscription;
}

function New-TestResourceGroups
{
	$testResourceGroups = New-ObjectList;

	$emptyTest = $false;

	if(!$emptyTest)
	{
		for($i = 1; $i -le 3; $i++)
		{
			$testResourceGroups.Add((New-ResourceGroup -Name "Test-Resource-Group-$($i)"));
		}
	}

	return $testResourceGroups;
}

function New-TestSubscriptions
{
	$testSubscriptions = New-ObjectList;

	$emptyTest = $false;

	if(!$emptyTest)
	{
		for($i = 1; $i -le 4; $i++)
		{
			$suffix = "Test-subscription-$($i)-";

			$testSubscriptions.Add((New-Subscription -Id "$($suffix)ID" -Name "$($suffix)name"));
		}
	}

	return $testSubscriptions;
}

function PasswordIsValid
{
	param
	(
		[string]$password
	)

	if(StringIsNullOrEmpty $password)
	{
		return $false;
	}

	if($password.Length -lt 12)
	{
		return $false;
	}

	if($password.Length -gt 123)
	{
		return $false;
	}

	$numberOfRequirementsFulfilled = 0;

	if($password -cne $password.ToUpper())
	{
		# Have lower characters
		$numberOfRequirementsFulfilled = $numberOfRequirementsFulfilled + 1;
	}

	if($password -cne $password.ToLower())
	{
		# Have upper characters
		$numberOfRequirementsFulfilled = $numberOfRequirementsFulfilled + 1;
	}

	if($password -match "[0-9]")
	{
		# Have a digit
		$numberOfRequirementsFulfilled = $numberOfRequirementsFulfilled + 1;
	}

	if($password -match "[\W_]")
	{
		# Have a special character
		$numberOfRequirementsFulfilled = $numberOfRequirementsFulfilled + 1;
	}

	if($numberOfRequirementsFulfilled -lt 3)
	{
		return $false;
	}

	if($_invalidPasswords -ccontains $password)
	{
		return $false;
	}

	return $true;
}

function Populate-ResourceGroups
{
	param
	(
		[Parameter(Mandatory)]
		$azureContext
	)

	$resourceGroups = Get-ResourceGroups;

	if($resourceGroups -and $resourceGroups.Count -gt 0)
	{
		foreach($resourceGroup in $resourceGroups)
		{
			$azureContext.ResourceGroups.Add($resourceGroup);
		}		
	}	
}

function Populate-Subscriptions
{
	param
	(
		[Parameter(Mandatory)]
		$azureContext
	)

	$subscriptions = Get-Subscriptions;

	if($subscriptions -and $subscriptions.Count -gt 0)
	{
		foreach($subscription in $subscriptions)
		{
			$azureContext.Subscriptions.Add($subscription);
		}
	}
}

function Prerequisites
{
	$firstLine = $true;
	$prerequisitesAreInvalid = $true;
	$installationNeeded = $false;

	while($prerequisitesAreInvalid)
	{
		$prerequisitesAreInvalid = $false;

		foreach($module in $_requiredModules)
		{

			if(ModuleIsNotInstalled -Module $module)
			{
				$installationNeeded = $true;

				if($firstLine -eq $false)
				{
					Write-Host;
				}

				$firstLine = $false;

				$prerequisitesAreInvalid = !(InstallModule $module);
			}
		}
	}

	return $installationNeeded;
}

function ResourceGroup-Equals($firstResourceGroup, $secondResourceGroup)
{
	if(!$firstResourceGroup)
	{
		if(!$secondResourceGroup)
		{
			return $true;
		}

		return $false;
	}

	if(!$secondResourceGroup)
	{
		return $false;
	}

	if(!$firstResourceGroup.Name)
	{
		if(!$secondResourceGroup.Name)
		{
			return $true;
		}

		return $false;
	}

	if(!$secondResourceGroup.Name)
	{
		return $false;
	}

	if($firstResourceGroup.Name.ToUpper() -eq $secondResourceGroup.Name.ToUpper())
	{
		return $true;
	}

	return $false;
}

function Select-Required
{
	param
	(
		[Parameter(Mandatory)]
		$azureContext
	)

	Select-Subscription -AzureContext $azureContext;

	Select-ResourceGroup -AzureContext $azureContext;
}

function Select-ResourceGroup
{
	param
	(
		[Parameter(Mandatory)]
		$azureContext
	)

	if($azureContext.NewResourceGroup)
	{
		$text = Get-ResourceGroupLabel -ResourceGroup $azureContext.NewResourceGroup;
		Write-Host;
		Write-Host "New resource-group: $($text)";

		$change = [bool](Ask -Question "Change?");

		if(!$change)
		{
			return;
		}
	}

	$selected = $false;

	while(!$selected)
	{
		if($azureContext.ResourceGroups.Count -lt 1)
		{
			$newResourceGroup = $true;
		}
		else
		{
			$newResourceGroup = [bool](Ask -Question "New resource-group?");
		}

		$before = Get-NewOrSelectedResourceGroup -AzureContext $azureContext;

		if($newResourceGroup)
		{
			foreach($resourceGroup in $azureContext.ResourceGroups)
			{
				$resourceGroup.Selected = $false;
			}

			$label = "Resource-group name";

			$name = Select-ValueInternal -DisplayLabel $label -InputLabel $label -ValidateFunction ${function:Validate-ResourceGroupName} -ValidateFunctionArguments $azureContext;

			$azureContext.NewResourceGroup = New-ResourceGroup -Name $name;
		}
		else
		{
			$azureContext.NewResourceGroup = $null;

			Select-IndexInternal -Heading "Existing resource-groups:" -ItemName "resource-group" -Items $azureContext.ResourceGroups -ItemLabelFunction ${function:Get-ResourceGroupLabel};
		}

		$after = Get-NewOrSelectedResourceGroup -AzureContext $azureContext;

		if(!$before -or $before.Prefix -ne $after.Prefix)
		{
			$azureContext.ResourceNamePrefix = $after.Prefix;
		}
		
		$selected = $true;
	}
}

function Select-ResourceNamePrefix
{
	param
	(
		[Parameter(Mandatory)]
		$azureContext
	)

	$azureContext.ResourceNamePrefix = Select-Value $false ${function:Validate-ResourceNamePrefix} $azureContext.ResourceNamePrefix "Resource-name-prefix";
}

function Select-Subscription
{
	param
	(
		[Parameter(Mandatory)]
		$azureContext
	)

	if($azureContext.Subscriptions.Count -lt 1)
	{
		WriteMissingSubscriptionError;
	}

	$before = Get-SelectedSubscription -AzureContext $azureContext;

	Select-IndexInternal -Heading "Your subscriptions:" -ItemName "subscription" -Items $azureContext.Subscriptions -ItemLabelFunction ${function:Get-SubscriptionLabel};

	$after = Get-SelectedSubscription -AzureContext $azureContext;

	if(Subscription-Equals $before $after)
	{
		return;
	}

	if(IsNotTest)
	{
		# To set the selected subscription for the context.
		$dummyToAvoidConsoleWriting = Get-AzureRmSubscription –SubscriptionId $after.Id | Select-AzureRmSubscription;
	}

	$azureContext.NewResourceGroup = $null;

	$azureContext.ResourceGroups.Clear();

	$azureContext.ResourceNamePrefix = $null;

	Populate-ResourceGroups -AzureContext $azureContext;
}

function Subscription-Equals($firstSubscription, $secondSubscription)
{
	if(!$firstSubscription)
	{
		if(!$secondSubscription)
		{
			return $true;
		}

		return $false;
	}

	if(!$secondSubscription)
	{
		return $false;
	}

	if(!$firstSubscription.Id)
	{
		if(!$secondSubscription.Id)
		{
			return $true;
		}

		return $false;
	}

	if(!$secondSubscription.Id)
	{
		return $false;
	}

	if($firstSubscription.Id.ToUpper() -eq $secondSubscription.Id.ToUpper())
	{
		return $true;
	}

	return $false;
}

function UserNameIsValid
{
	param
	(
		[string]$userName
	)

	if(StringIsNullOrEmpty $userName)
	{
		return $false;
	}

	if($userName.Length -gt 20)
	{
		return $false;
	}

	if($userName.EndsWith("."))
	{
		return $false;
	}

	if($_invalidUserNames -ccontains $userName)
	{
		return $false;
	}

	return $true;
}

function Validate-ResourceGroupName
{
	param
	(
		[Parameter(Mandatory)]
		$azureContext,
		[string]$name
	)

	if(StringIsNullOrEmpty $name)
	{
		return New-ValidationResult "The name can not be empty.";
	}

	$newResourceGroup = New-ResourceGroup -Name $name;

	foreach($resourceGroup in $azureContext.ResourceGroups)
	{
		if(ResourceGroup-Equals $newResourceGroup $resourceGroup)
		{
			return New-ValidationResult "The resource-group ""$($name)"" already exists.";
		}
	}

	return New-ValidationResult;
}

function Validate-ResourceNamePrefix
{
	param
	(
		[string]$resourceNamePrefix
	)

	if($resourceNamePrefix -and $resourceNamePrefix.Length -gt 5)
	{
		return New-ValidationResult "The resource-name-prefix can not be longer than 5 characters.";
	}

	return New-ValidationResult;
}

function ValidateDomainName
{
	param
	(
		[string]$domainName,
		[Parameter(Mandatory)]
		[string]$domainNameLabel
	)

	if(!(DomainNameIsValid $domainName))
	{
		return New-ValidationResult "The $($domainNameLabel.ToLower()) can not be empty.";
	}

	return New-ValidationResult;
}

function ValidatePassword
{
	param
	(
		[string]$password,
		[Parameter(Mandatory)]
		[string]$passwordLabel
	)

	if(!(PasswordIsValid $password))
	{
		$message = New-Object System.Collections.Generic.List[string];

		$message.Add("  The $($passwordLabel.ToLower()) must be 12 - 123 characters in length and meet 3 out of the following 4 complexity requirements:");
		$message.Add("   - Have lower characters");
		$message.Add("   - Have upper characters");
		$message.Add("   - Have a digit");
		$message.Add("   - Have a special character (Regex match [\W_])");
		$message.Add("  The following passwords are not allowed:")
		foreach($invalidPassword in $_invalidPasswords)
		{
			$message.Add("   - $($invalidPassword)");
		}
		$message.Add("");
		$message.Add("Read more: https://docs.microsoft.com/en-us/azure/virtual-machines/windows/faq#what-are-the-password-requirements-when-creating-a-vm");

		return New-ValidationResult $message;
	}

	return New-ValidationResult;
}

function ValidateUserName
{
	param
	(
		[string]$userName,
		[Parameter(Mandatory)]
		[string]$userNameLabel
	)

	if(!(UserNameIsValid $userName))
	{
		$message = New-Object System.Collections.Generic.List[string];

		$message.Add("  The $($userNameLabel.ToLower()) can not be empty.");
		$message.Add("  The $($userNameLabel.ToLower()) can be a maximum of 20 characters in length and cannot end in a period (""."").");
		$message.Add("  The following usernames are not allowed:");
		foreach($invalidUserName in $_invalidUserNames)
		{
			$message.Add("   - $($invalidUserName)");
		}
		$message.Add("");
		$message.Add("Read more: https://docs.microsoft.com/en-us/azure/virtual-machines/windows/faq#what-are-the-username-requirements-when-creating-a-vm");

		return New-ValidationResult $message;
	}

	return New-ValidationResult;
}

function WriteMissingSubscriptionError
{
	WriteErrorAndClose "You do not have any subscriptions.";
}

Export-ModuleMember -Function "Deploy", "Get-NewOrSelectedResourceGroup", "Get-ResourceGroupLabel", "Get-SelectedResourceGroup", "Get-SelectedSubscription", "Get-SubscriptionLabel", "Get-TemplateUriFormat", "Initialize", "Select-Required", "Select-ResourceNamePrefix", "ValidateDomainName", "ValidatePassword", "ValidateUserName";
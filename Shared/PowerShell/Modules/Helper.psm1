[ConsoleColor]$_confirmationColor = "Green";
[ConsoleColor]$_defaultColor = "White";
[ConsoleColor]$_errorColor = "Red"
$_indent = "  ";
[ConsoleColor]$_inputColor = "Yellow";
[ConsoleColor]$_warningColor = "Yellow";
$_pressAnyKeyToContinueMessage = "Press any key to continue...";
$_pressAnyKeyToContinueMessageForIse = "Continue...";
$_pressAnyKeyToExitMessage = "Press any key to exit...";
$_pressAnyKeyToExitMessageForIse = "Exit...";

Import-Module "$($PSScriptRoot)\Test-Helper";

function Accept
{
	$acceptIsInvalid = $true;

	while($acceptIsInvalid)
	{
		Write-Host;
		Write-Host "Accept? [Y] Yes [N] No [E] Exit: " -ForegroundColor $_inputColor -NoNewLine;

		$accept = Read-Host;
		$acceptToUpper = $accept.ToUpper();

		$acceptIsInvalid = $false;

		switch ($acceptToUpper)
		{
			"Y"
			{
				return $true;
			}
			"N"
			{
				return $false;
			}
			"E"
			{
				Close;
			}
			default
			{
				$acceptIsInvalid = $true;
				IsNotAnOption $accept;
				Write-Host;
			}
		}
	}
}

function Add-Argument
{
	param
	(
		[object[]]$arguments,
		$additionalArgument
	)

	$argumentList = New-Object System.Collections.Generic.List[object];

	if($arguments)
	{
		foreach($argument in $arguments)
		{
			$argumentList.Add($argument);
		}
	}

	$argumentList.Add($additionalArgument);

	return $argumentList;
}

function Ask
{
	param
	(
		[Parameter(Mandatory)]
		[string]$question
	)

	$questionIsInvalid = $true;

	while($questionIsInvalid)
	{
		Write-Host;
		Write-Host "$($question) [Y] Yes [N] No: " -ForegroundColor $_inputColor -NoNewLine;

		$answer = Read-Host;
		$answerToUpper = $answer.ToUpper();

		switch ($answerToUpper)
		{
			"Y"
			{
				return $true;
			}
			"N"
			{
				return $false;
			}
			default
			{
				$questionIsInvalid = $true;
				IsNotAnOption $answer;
				Write-Host;
			}
		}
	}
}

function Close()
{
	Write-Host;
	PressAnyKey -IseMessage $_pressAnyKeyToExitMessageForIse -Message $_pressAnyKeyToExitMessage;
	Exit;
}

function Get-ConfirmationColor
{
	return $_confirmationColor;
}

function Get-DefaultColor
{
	return $_defaultColor;
}

function Get-ErrorColor
{
	return $_errorColor;
}

function Get-Indent
{
	return $_indent;
}

function Get-InputColor
{
	return $_inputColor;
}

function Get-WarningColor
{
	return $_warningColor;
}

function InstallModule
{
	param
	(
		[Parameter(Mandatory)]
		[object]$module
	)

	Write-Host "You need to install the PowerShell module ""$($module.Name) ($($module.Version))"".";

	$accept = [bool](Accept);

	if($accept -eq $true)
	{
		$activity = "Installing $($module.Name) ($($module.Version))...";

		Write-Progress -Activity $activity;

		if(IsNotTest)
		{
			Install-Module -Force -MinimumVersion $module.Version -Name $module.Name -Scope CurrentUser;
		}
		else
		{
			Install-Module -Force -MinimumVersion $module.Version -Name $module.Name -Scope CurrentUser -WhatIf;
		}

		Write-Progress -Activity $activity -Completed;
	}

	return $accept;
}

function IsNotAnOption($option)
{
	WriteError """$($option)"" is not an option.";
}

function ModuleIsInstalled
{
	param
	(
		[Parameter(Mandatory)]
		[object]$module
	)

	foreach($availableModule in Get-Module -ListAvailable -Name $module.Name)
	{
		if($availableModule.Version -ge $module.Version)
		{
			return $true;
		}
	}

	return $false;
}

function ModuleIsNotInstalled
{
	param
	(
		[Parameter(Mandatory)]
		[object]$module
	)

	return !(ModuleIsInstalled -Module $module);
}

function New-BasicObject
{
	param
	(
		[Parameter(Mandatory)]
		[System.Collections.Generic.IEnumerable[string]]$propertyNames
	)

	$basicObject = New-Object System.Object;

	foreach($propertyName in $propertyNames)
	{
		$basicObject | Add-Member -MemberType NoteProperty -Name $propertyName -Value $null;
	}

	return $basicObject;
}

function New-ModuleInformation
{
	param
	(
		[Parameter(Mandatory)]
		[string]$name,
		[Parameter(Mandatory)]
		[System.Version]$version
	)

	$propertyNames = New-StringList;

	$propertyNames.Add("Name");
	$propertyNames.Add("Version");

	$moduleInformation = New-BasicObject -PropertyNames $propertyNames;

	$moduleInformation.Name = $name;
	$moduleInformation.Version = $version;

	return $moduleInformation;
}

function New-ObjectList
{
	return New-Object System.Collections.Generic.List[object];
}

function New-StringList
{
	return New-Object System.Collections.Generic.List[string];
}

function New-ValidationResult
{
	param
	(
		[string[]]$message
	)

	$propertyNames = New-StringList;

	$propertyNames.Add("IsValid");
	$propertyNames.Add("Message");

	$validationResult = New-BasicObject -PropertyNames $propertyNames;

	$validationResult.IsValid = $message -eq $null -or $message.Length -eq 0;
	$validationResult.Message = $message;

	return $validationResult;
}

function PressAnyKey
{
	param
	(
		[string]$color = $_defaultColor,
		[string]$iseMessage,
		[string]$message
	)

	if ($host.name -notmatch "ISE")
	{
		Write-Host $message -ForegroundColor $color -NoNewline;
		$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown");
	}
	else
	{
		Add-Type -AssemblyName System.Windows.Forms;
		$continue = [System.Windows.Forms.MessageBox]::Show($iseMessage);
	}
}

function PressAnyKeyToContinue
{
	Write-Host;
	PressAnyKey -IseMessage $_pressAnyKeyToContinueMessageForIse -Message $_pressAnyKeyToContinueMessage;
}

function Select-IndexInternal
{
	param
	(
		[Parameter(Mandatory)]
		[string]$heading,
		[Parameter(Mandatory)]
		[string]$itemName,
		[object[]]$items,
		[Parameter(Mandatory)]
		[ScriptBlock]$itemLabelFunction
	)
	
	$indent = Get-Indent;

	$selected = $false;
	
	while(!$selected)
	{
		Write-Host;
			
		Write-Host $heading;

		$anItemIsSelected = $false;

		for($i = 0; $i -lt $items.Count; $i++)
		{
			$item = $items[$i];

			$text = Invoke-Command -ArgumentList $item -ScriptBlock $itemLabelFunction;
			$text = "$($indent)$($i + 1): $($text)";

			if($item.Selected -eq $true)
			{
				$anItemIsSelected = $true;

				$text = "$($text) - Current";

				Write-Host $text -ForegroundColor (Get-ConfirmationColor);
			}
			else
			{
				Write-Host $text;
			}
		}

		Write-Host;

		$text = "Select the $($itemName) you want to use by entering its number (1 - $($items.Count))";

		if($anItemIsSelected -eq $true)
		{
			$text = "$($text) or press enter to keep the current one";
		}

		$text = "$($text): ";

		Write-Host $text -ForegroundColor (Get-InputColor) -NoNewLine;

		$indexValue = Read-Host;

		if($anItemIsSelected -eq $true -and $indexValue -eq "")
		{
			$selected = $true;
		}
		else
		{
			try
			{
				$index = [int]$indexValue - 1;

				if($index -ge 0 -and $index -lt $items.Count)
				{
					for($i = 0; $i -lt $items.Count; $i++)
					{
						$item = $items[$i];
						$item.Selected = [bool]($i -eq $index);
					}

					$selected = $true;
				}
				else
				{
					$selected = $false;
				}
			}
			catch
			{
				$selected = $false;
			}

			if(!$selected)
			{
				IsNotAnOption $indexValue;
				Write-Host;
			}
		}
	}
}

function Select-Number
{
	param
	(
		[Parameter(Mandatory)]
		[int]$maximumValue,
		[Parameter(Mandatory)]
		[int]$minimumValue,
		[int]$value,
		[Parameter(Mandatory)]
		$valueName
	)

	Select-ValueInternal -DisplayLabel $valueName -InputLabel $valueName -ValidateFunction ${function:ValidateNumber} -ValidateFunctionArguments $maximumValue, $minimumValue -Value $value;
}

function Select-Value
{
	param
	(
		[bool]$secure = $false,
		[Parameter(Mandatory)]
		[ScriptBlock]$validateFunction,
		$value,
		[Parameter(Mandatory)]
		$valueName
	)

	Select-ValueInternal -DisplayLabel $valueName -InputLabel $valueName -Secure $secure -ValidateFunction $validateFunction -Value $value;
}

function Select-ValueInternal
{
	param
	(
		[bool]$confirm = $false,
		[Parameter(Mandatory)]
		[string]$displayLabel,
		[Parameter(Mandatory)]
		[string]$inputLabel,
		[bool]$secure = $false,
		[Parameter(Mandatory)]
		[ScriptBlock]$validateFunction,
		[object[]]$validateFunctionArguments,
		$value
	)

	$arguments = Add-Argument -Arguments $validateFunctionArguments -AdditionalArgument $value;

	$validationResult = Invoke-Command -ArgumentList $arguments -ScriptBlock $validateFunction;

	if($validationResult.IsValid -eq $true)
	{
		$securedValue = $value;

		if($secure)
		{
			$securedValue = ToSecureString $value;
		}

		Write-Host;

		Write-Host "$($displayLabel): $($securedValue)";

		if($validationResult.IsValid)
		{
			$change = [bool](Ask -Question "Change?");

			if(!$change)
			{
				return $value;
			}
		}
	}

	$complete = $false;
	
	while(!$complete)
	{
		Write-Host;

		Write-Host "$($inputLabel): " -ForegroundColor (Get-InputColor) -NoNewLine;

		if($secure)
		{
			$inputValue = Read-Host -AsSecureString;
			$inputValue = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($inputValue));
		}
		else
		{
			$inputValue = Read-Host;
		}

		$arguments = Add-Argument -Arguments $validateFunctionArguments -AdditionalArgument $inputValue;

		$validationResult = Invoke-Command -ArgumentList $arguments -ScriptBlock $validateFunction;

		if($validationResult.IsValid -eq $false)
		{
			$securedInputValue = $inputValue;

			if($secure)
			{
				$securedInputValue = ToSecureString $inputValue;
			}

			Write-Host;
			$color = [ConsoleColor](Get-ErrorColor);
			Write-Host "The value ""$($securedInputValue)"" is not valid." -ForegroundColor $color;
			foreach($line in $validationResult.Message)
			{
				Write-Host $line -ForegroundColor $color;
			}
			WriteError;
			Write-Host;
		}
		else
		{
			if($confirm)
			{
				$confirmed = Ask "Satisfied?";
			}
			else
			{
				$confirmed = $true;
			}

			if($confirmed)
			{
				return $inputValue;
			}
		}
	}
}

function StringIsNullOrEmpty
{
	param
	(
		[string]$value
	)

	if(!$value -or $value -eq $null -or $value -eq "")
	{
		return $true;
	}

	return $false;
}

function ToSecureString($value)
{
	if(!$value)
	{
		return $null;
	}

	$secureValue = "";

	for($i = 0; $i -lt $value.Length; $i++)
	{
		$secureValue += "*";
	}

	return $secureValue;
}

function TryInvokeCommand
{
	param
	(
		[object[]]$argumentList,
		[Parameter(Mandatory)]
		[ScriptBlock]$scriptBlock
	)

	try
	{
		Invoke-Command -ArgumentList $argumentList -ScriptBlock $scriptBlock;
	}
	catch
	{
		if($_.Exception -is [System.Management.Automation.CommandNotFoundException])
		{
			WriteMessage "Could not invoke the command ""$($scriptBlock)"" because the method does not exist." $_warningColor;
			Write-Host;
		}
		else
		{
			throw $_.Exception;
		}		
	}
}

function ValidateNumber([int]$maximumValue, [int]$minimumValue, $value)
{
	try
	{
		[int]$number = $value;

		$isValid = [bool]($number -ge $minimumValue -and $number -le $maximumValue);

		if(!$isValid)
		{
			$message = "The value must be greater than or equal to $($minimumValue) and less than or equal to $($maximumValue)."
		}
	}
	catch
	{
		$message = "The value is not a number."
	}

	return New-ValidationResult $message;
}

function WriteError($message)
{
	WriteMessage $message $_errorColor;
}

function WriteErrorAndClose($message)
{
	$color = $_errorColor;

	Write-Host;
	Write-Host "$($message) " -ForegroundColor $color -NoNewLine;
	PressAnyKey -Color $color -IseMessage $_pressAnyKeyToExitMessageForIse -Message $_pressAnyKeyToExitMessage;
	Exit;
}

function WriteIndentedMessage($message, $indent)
{
	Write-Host "$($indent) - $($message)";
}

function WriteMessage($message, $color)
{
	Write-Host;
	if(!(StringIsNullOrEmpty $message))
	{
		Write-Host "$($message) " -ForegroundColor $color -NoNewLine;
	}	
	PressAnyKey -Color $color -IseMessage $_pressAnyKeyToContinueMessageForIse -Message $_pressAnyKeyToContinueMessage;
}

function WriteWarning($message)
{
	WriteMessage $message $_warningColor;
}

Export-ModuleMember -Function *;
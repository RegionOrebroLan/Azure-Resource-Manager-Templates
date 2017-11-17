[int]$_sleepTimeInSecondsForTests = 2;
[bool]$_test = $false;

function Get-SleepTimeInSecondsForTests
{
	return $_sleepTimeInSecondsForTests;
}

function IsNotTest
{
	return !$_test;
}

function IsTest
{
	return $_test;
}

Export-ModuleMember -Function "Get-SleepTimeInSecondsForTests", "IsNotTest", "IsTest";
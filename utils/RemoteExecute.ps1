<# 
.SYNOPSIS
	Runs a powershell script on a remote machine.
.DESCRIPTION
	Uses WinRM to execute the powershell script on a remote machine.  Note this needs
	to use CredSSP to allow double hop to other machines.
.PARAMETER script
	The full path to the script we are executing (i.e. C:\Temp\myscript.ps1)
.PARAMETER machine
	Machine to execute the script on.
.PARAMETER username
	Username to use for the winrm session.
.PARAMETER password
	Password to use for the winrm session.
.PARAMETER args
	Arguments to the script.
.EXAMPLE
	./RemoteExecute.ps1 -script 'C:\Temp\test.ps1'  -machine 'somemachine' -username 'bob' -password '5tr0ngP@55w0rd'
	Runs the script test.ps1 in C:\Temp\ on the somemachine using the credentials provided.
#>
[CmdletBinding()]
param(
	[Parameter(Mandatory=$true)][String]$script,
	[Parameter(Mandatory=$true)][String]$machine,
	[Parameter(Mandatory=$true)][String]$username,
	[Parameter(Mandatory=$true)][String]$password,
	[String]$args = ''
);

Set-StrictMode –Version latest;

Write-Output "script: $script";
Write-Output "machine: $machine";
Write-Output "username: $username";

$scriptFolder = Split-Path $script -Parent;
Write-Output "Run in: $scriptFolder";

Write-Output "Running script...";

$securePassword = $password | ConvertTo-SecureString -asPlainText -Force;
$credential = New-Object System.Management.Automation.PSCredential($username, $securePassword);
$session = New-PSSession $machine -Credential $credential -Authentication Credssp;

[String]$locationString = "Set-Location $scriptFolder";
[scriptblock]$locationBlock = [scriptblock]::Create($locationString);
[String]$execString = "& $script $args";
[scriptblock]$execBlock = [scriptblock]::Create($execString);

Invoke-Command -Session $session -ScriptBlock $locationBlock;
Invoke-Command -Session $session -ScriptBlock $execBlock;

Remove-PSSession $session;
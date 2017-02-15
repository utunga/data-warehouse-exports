
Param(
    [string]$scripts_path,
    [string]$export_path,
    [string]$db_user,
    [string]$db_pass,
    [switch]$debug_only
)


# Save current path for use later
$this_source_path = $PSScriptRoot
$utils_path = $this_source_path

# Setup variables
If(-Not($scripts_path))
{
    $scripts_path =  "$this_source_path\.."
}

# Change path to wehere the scripts are at
Set-Location -Path $scripts_path


# Activate conda environment
Invoke-Expression "$utils_path\env-activate.ps1 DataWarehouseExports"

Write-Host "Looking for export scripts in $scripts_path"
Write-Host "Exporting data to $export_path"
Write-Host

# pass through args, by definition the same for all scripts
$pass_through_args = "--db_user $db_user --db_pass $db_pass --export_path $export_path"

If ($debug_only) 
{
    $pass_through_args = $pass_through_args + " --debug_only True"
}
If ($db_pass) 
{
    $log_args = $pass_through_args.replace($db_pass, "****")
}
Else
{
    $log_args = $pass_through_args
}



Get-ChildItem $scripts_path -Filter *.py | 
Foreach-Object {

    $script = $_.FullName
    # Run enhancements
    Write-Host "Running $script $log_args"

    Invoke-Expression "python $script $pass_through_args"
    Write-Host 
}
# FIXME maybe it'd be good to bring this back 
# but for now the above gets the job done 
# Invoke-Expression "$deployedBinPath\CreditSights.Data.Baml.Enhancements.Runner\CreditSights.Data.Baml.Enhancements.Runner.exe -d $enhancementsPath"
Write-Host "Finished running scripts"


# not that we really need to do this.. but 

# Deactivate environment
Invoke-Expression "$utils_path\env-deactivate.ps1"

# Change path back to original not that it matters
Set-Location $this_source_path

Write-Host "Done. OK."


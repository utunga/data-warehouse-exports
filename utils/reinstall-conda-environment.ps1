
# Setup the Conda environment (and install python dependencies if need be)
# for the relevant Conda configuration as defined in scripts\environment.yml

# Notice the envrionment.yml is defined in the scripts folder
# which may of course be in a different location from this util

Param(
    [string]$scripts_path,
    [string]$environment_name
)

$this_source_path = $PSScriptRoot
$utils_path = $this_source_path

# Default values for variables 
If(-Not($scripts_path))
{
    # if not provided default to the directory one up from here
    $scripts_path =  "$this_source_path\.."
}

If(-Not($environment_name))
{
    # this needs to match the name at the
    # top of $scripts_path\environment.yml 
    $environment_name =  "DataWarehouseExports"
}

#NB Write-Host not supported by (MS Standard Task) PowerShellOnTargetMachines.ps1 so Write-Verbose instead

Try{
    Write-Verbose "Removing existing conda virtual environment if any"
    $output = conda remove -n DataWarehouseExports --yes --all 2>&1
    Write-Verbose $output
    
}
Catch{
    $time_stamp = Get-Date -format yyyyMMddHHmmss
    Write-Verbose "FAIL - $time_stamp - $Error[0]"
}
  

Try{
    Write-Verbose "Setting up python environment/dependencies per $scripts_path\environment.yml"
    $output = conda env create -f $scripts_path\environment.yml 2>&1
    Write-Verbose $output
}
Catch{
    $time_stamp = Get-Date -format yyyyMMddHHmmss
    Write-Verbose "FAIL - $time_stamp - $Error[0]"
}


Write-Verbose "Done."
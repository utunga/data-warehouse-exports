
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


Write-Host "Removing existing conda virtual environment if any"
Invoke-Expression "conda remove -n DataWarehouseExports --yes --all"

Write-Host "Setting up python environment/dependencies per $scripts_path\environment.yml"
Invoke-Expression "conda env create -f $scripts_path\environment.yml"


Write-Host "Done."
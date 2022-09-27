<#
.SYNOPSIS
    x
.DESCRIPTION
    x
.PARAMETER CurrentDirectory
    x
.EXAMPLE
    x
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]
    $AgentDirectory
)

begin
{
    $modulesLocation = "$AgentDirectory/.powershell/.modules"
    $modules = Get-ChildItem -Path $ModulesLocation -Directory
}
process
{
    try
    {
        $ErrorActionPreference = "Stop"
        
        foreach($module in $modules)
        {
            Write-Output "Importing Module $($module.FullName)"
            Import-Module $module.FullName
        }
    }
    catch
    {
        Write-Error $($_.Exception.Message)
        throw($($_.Exception.Message))
    }
}
end
{
    # ...
}
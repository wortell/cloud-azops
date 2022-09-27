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
    $AgentDirectory,
    
    [Parameter(Mandatory = $true)]
    [string]
    $organization,
    
    [Parameter(Mandatory = $true)]
    [string]
    $project,

    [Parameter(Mandatory = $true)]
    [string]
    $agentgroupname,

    [Parameter(Mandatory = $true)]
    [string]
    $reponame,

    [Parameter(Mandatory = $true)]
    [string]
    $repoDesiredStateName,

    [Parameter(Mandatory = $true)]
    [string]
    $repoid,

    [Parameter(Mandatory = $true)]
    [string]
    $pipelinepath,

    [Parameter(Mandatory = $true)]
    [string]
    $pullname,
    
    [Parameter(Mandatory = $true)]
    [string]
    $SYSTEM_ACCESSTOKEN
)

begin
{
    . "$AgentDirectory/.powershell/.modules/Load-AzOpsRequiredModules.ps1" -AgentDirectory $AgentDirectory
    
    $YAMLFilename = "push.yml"
}
process
{
    try
    {
        $ErrorActionPreference = "Stop"
        
        . "$AgentDirectory/.powershell/.azdevops/New-AzOpsPipelineYAML.ps1" `
        -AgentDirectory $AgentDirectory `
        -project $project `
        -reponame $reponame `
        -YAMLFilename $YAMLFilename
    
        . "$AgentDirectory/.powershell/.azdevops/New-AzOpsPipelineDefinition.ps1" `
        -organization $organization `
        -project $project `
        -agentgroupname $agentgroupname `
        -repoDesiredStateName $repoDesiredStateName `
        -repoid $repoid `
        -pipelinepath $pipelinepath `
        -pullname $pullname `
        -YAMLFilename $YAMLFilename `
        -SYSTEM_ACCESSTOKEN $SYSTEM_ACCESSTOKEN
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
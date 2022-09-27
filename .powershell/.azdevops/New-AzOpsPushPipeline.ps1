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
    $YAMLFilename = "push.yml"
}
process
{
    try
    {
        $ErrorActionPreference = "Stop"
        
        . "$AgentDirectory/.powershell/.azdevops/New-AzOpsPipelineDefinition.ps1" `
        -organization $organization `
        -project $project `
        -agentgroupname $agentgroupname `
        -reponame $reponame `
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
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
    $vargroupid,

    [Parameter(Mandatory = $true)]
    [string]
    $pipelinepath,

    [Parameter(Mandatory = $true)]
    [string]
    $pipelinename,
    
    [Parameter(Mandatory = $true)]
    [string]
    $SYSTEM_ACCESSTOKEN
)

begin
{
    $YAMLFilename = "validate.yml"
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
        -vargroupid $vargroupid `
        -pipelinepath $pipelinepath `
        -pipelinename $pipelinename `
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
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
    $project,

    [Parameter(Mandatory = $true)]
    [string]
    $reponame,

    [Parameter(Mandatory = $true)]
    [string]
    $vargroupname,

    [Parameter(Mandatory = $true)]
    [string]
    $YAMLFilename
)

begin
{
    $pipelineRepoFolder = "/.pipelines/.templates"

    $variables = New-Object -TypeName PSObject -Property @{}
    $variableGroup = New-Object -TypeName PSObject -Property @{}
    $repositoriesDetails = New-Object -TypeName PSObject -Property @{}
}
process
{
    try
    {
        $ErrorActionPreference = "Stop"
        
        $repositoriesDetails | Add-Member -MemberType NoteProperty -Name "repository" -Value ("azops")
        $repositoriesDetails | Add-Member -MemberType NoteProperty -Name "type" -Value ("git")
        $repositoriesDetails | Add-Member -MemberType NoteProperty -Name "name" -Value ("$project/$reponame")

        $variableGroup | Add-Member -MemberType NoteProperty -Name "group" -Value ($vargroupname)
        $variables | Add-Member -MemberType NoteProperty -Name "variables" -Value @($variableGroup)

        $extends = New-Object -TypeName PSObject -Property @{}
        $extendsDetails = New-Object -TypeName PSObject -Property @{}
        $extendsDetails | Add-Member -MemberType NoteProperty -Name "template" -Value ($templateLocation)
        $extends | Add-Member -MemberType NoteProperty -Name "extends" -Value ($extendsDetails)

        $yamlObject = New-Object -TypeName PSObject -Property @{}
        $yamlObject | Add-Member -MemberType NoteProperty -Name "variables" -Value ($variables.variables)

        $yamlObject = $yamlObject | ConvertTo-Yaml
        $yamlObject = $yamlObject.Replace("'\", "'")
        $yamlObject = $yamlObject.Replace("|-", ">")

        $variables = Get-Content -Path .\.pipelines\.templates\vars.yml | ConvertFrom-Yaml
        
    }
    catch
    {
        Write-Error $($_.Exception.Message)
        throw($($_.Exception.Message))
    }
}
end
{
    $yamlFile = New-Item -Path "$AgentDirectory/$pipelineRepoFolder" -Name "$YAMLFilename" -ItemType "file" -Value ($yamlObject)

    git push origin main
}
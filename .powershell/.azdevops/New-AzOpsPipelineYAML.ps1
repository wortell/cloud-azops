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
    $YAMLFilename
)

begin
{
    $pipelineRepoFolder = "/.pipelines"

    $resources = New-Object -TypeName PSObject -Property @{}
    $repositories = New-Object -TypeName PSObject -Property @{}
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

        $repositories | Add-Member -MemberType NoteProperty -Name "repositories" -Value @($repositoriesDetails)
        $resources | Add-Member -MemberType NoteProperty -Name "resources" -Value ($repositories)

        $templateLocation = "$pipelineRepoFolder/$YAMLFilename" + "@azops"
        $extends = New-Object -TypeName PSObject -Property @{}
        $extendsDetails = New-Object -TypeName PSObject -Property @{}
        $extendsDetails | Add-Member -MemberType NoteProperty -Name "template" -Value ($templateLocation)
        $extends | Add-Member -MemberType NoteProperty -Name "extends" -Value ($extendsDetails)

        $yamlObject = New-Object -TypeName PSObject -Property @{}
        $yamlObject | Add-Member -MemberType NoteProperty -Name "resources" -Value ($resources.resources)
        $yamlObject | Add-Member -MemberType NoteProperty -Name "extends" -Value ($extends.extends)

        $yamlObject = $yamlObject | ConvertTo-Yaml
        $yamlObject = $yamlObject.Replace("'\", "'")
        $yamlObject = $yamlObject.Replace("|-", ">")
        
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
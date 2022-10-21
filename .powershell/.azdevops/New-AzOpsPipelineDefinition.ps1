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
    $YAMLFilename,
    
    [Parameter(Mandatory = $true)]
    [string]
    $SYSTEM_ACCESSTOKEN
)

begin
{
    $pipelineRepoFolder = "/.pipelines"

    $headers = @{
        Authorization = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($SYSTEM_ACCESSTOKEN)"))
    }

    $URIOrga = "https://dev.azure.com/" + "$organization" + "/" + "$project" + "/"

    $definitionURI = $URIOrga + "_apis/build/definitions?api-version=6.0"

    $queueURI = $URIOrga + "_apis/distributedtask/queues?api-version=6.1-preview.1" 
    $queueObject = Invoke-RestMethod -Uri $queueURI -Method get -Headers $Headers
    $queueObject = $queueObject.value | Where-Object {$_.name -eq "$agentgroupname"}
    $queue = New-Object -TypeName PSObject -Property @{
        id = $queueObject.id
    }

    $body = New-Object -TypeName PSObject -Property @{}
    $processDetails = New-Object -TypeName PSObject -Property @{}
    $triggers = @()

    $repositoryDetails = New-Object -TypeName PSObject -Property @{}

}
process
{
    try
    {
        $ErrorActionPreference = "Stop"
        
        $body | Add-Member -MemberType NoteProperty -Name "name" -Value ("$pipelinename")
        $body | Add-Member -MemberType NoteProperty -Name "path" -Value ("`\$pipelinepath")
        $body | Add-Member -MemberType NoteProperty -Name "type" -Value ("build")
        $body | Add-Member -MemberType NoteProperty -Name "queueStatus" -Value ("enabled")

        $processDetails | Add-Member -MemberType NoteProperty -Name "yamlFilename" -Value ("$pipelineRepoFolder/$YAMLFilename")
        $processDetails | Add-Member -MemberType NoteProperty -Name "type" -Value (2)

        $repositoryDetails | Add-Member -MemberType NoteProperty -Name "id" -Value ($repoid)
        $repositoryDetails | Add-Member -MemberType NoteProperty -Name "type" -Value ("TfsGit")
        $repositoryDetails | Add-Member -MemberType NoteProperty -Name "name" -Value ($reponame)
        $repositoryDetails | Add-Member -MemberType NoteProperty -Name "defaultBranch" -Value ("main")
        $repositoryDetails | Add-Member -MemberType NoteProperty -Name "clean" -Value ($null)
        $repositoryDetails | Add-Member -MemberType NoteProperty -Name "checkoutSubmodules" -Value ($false)

        $triggerCI = New-Object -TypeName PSObject -Property @{
            branchFilters = ""
            pathFilters = ""
            settingsSourceType = 2
            batchChanges = $false
            maxConcurrentBuildsPerBranch = 1
            triggerType = "continuousIntegration"
        }
        $triggers += $triggerCI

        $body | Add-Member -MemberType NoteProperty -Name "process" -Value ($processDetails)
        $body | Add-Member -MemberType NoteProperty -Name "queue" -Value ($queue)
        $body | Add-Member -MemberType NoteProperty -Name "repository" -Value ($repositoryDetails)
        $body | Add-Member -MemberType NoteProperty -Name "triggers" -Value @($triggers)

        $Result = Invoke-RestMethod -Uri $definitionURI -Method post -Headers $Headers -Body ($body | ConvertTo-Json -Depth 100) -ContentType "application/json"

        $varGroupPermissionsURI = "https://dev.azure.com/$($organization)/$()/_apis/pipelines/pipelinePermissions/variablegroup/$($vargroupid)?api-version=7.1-preview.1"
        $varGroupPermissionsObject = Invoke-RestMethod -Uri $varGroupPermissionsURI -Method get -Headers $Headers

        $varGroupPermission = New-Object -TypeName PSObject -Property @{}
        $varGroupPermission | Add-Member -MemberType NoteProperty -Name "id" -Value $Result.id
        $varGroupPermission | Add-Member -MemberType NoteProperty -Name "authorized" -Value $true

        $varGroupPermissionsObject.pipelines += $varGroupPermission
        
        $Result = Invoke-RestMethod -Uri $varGroupPermissionsURI -Method Patch -Headers $Headers -Body ($varGroupPermissionsObject | ConvertTo-Json -Depth 100) -ContentType "application/json"
    }
    catch
    {
        Write-Error $($_.Exception.Message)
        throw($($_.Exception.Message))
    }
}
end
{
    
}
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
    $pipelinepath,

    [Parameter(Mandatory = $true)]
    [string]
    $validatename,
    
    [Parameter(Mandatory = $true)]
    [string]
    $SYSTEM_ACCESSTOKEN
)

begin
{
    $headers = @{
        Authorization = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($SYSTEM_ACCESSTOKEN)"))
    }

    $URIOrga = "https://dev.azure.com/" + "$organization" + "/" + "$project" + "/"

    $queueURI = $URIOrga + "_apis/distributedtask/queues?api-version=6.1-preview.1" 
    $queueObject = Invoke-RestMethod -Uri $queueURI -Method get -Headers $Headers
    $queueObject = $queueObject.value | Where-Object {$_.name -eq "$agentgroupname"}
    $queue = New-Object -TypeName PSObject -Property @{
        id = $queueObject.id
    }

    $definitionURI = $URIOrga + "_apis/build/definitions?api-version=6.0"

    $body = New-Object -TypeName PSObject -Property @{}
    $bodyDetails = New-Object -TypeName PSObject -Property @{}
    $processDetails = New-Object -TypeName PSObject -Property @{}
    $process = New-Object -TypeName PSObject -Property @{}

    $repositoryURI = $URIOrga + "_apis/git/repositories?api-version=5.1"
    $repositoryObject = Invoke-RestMethod -Uri $repositoryURI -Method get -Headers $Headers
    $repositoryObject = $repositoryObject.value | Where-Object {$_.name -eq "$reponame"}

    $repositoryDetails = New-Object -TypeName PSObject -Property @{}
    $repository = New-Object -TypeName PSObject -Property @{}
}
process
{
    try
    {
        $ErrorActionPreference = "Stop"
        
        $body | Add-Member -MemberType NoteProperty -Name "name" -Value ("$validatename")
        $body | Add-Member -MemberType NoteProperty -Name "path" -Value ("`\$pipelinepath")
        $body | Add-Member -MemberType NoteProperty -Name "type" -Value ("build")
        $body | Add-Member -MemberType NoteProperty -Name "queueStatus" -Value ("enabled")

        $processDetails | Add-Member -MemberType NoteProperty -Name "yamlFilename" -Value (".pipelines\validate.yml")
        $processDetails | Add-Member -MemberType NoteProperty -Name "type" -Value (2)

        $repositoryDetails | Add-Member -MemberType NoteProperty -Name "id" -Value ($repositoryObject.id)
        $repositoryDetails | Add-Member -MemberType NoteProperty -Name "type" -Value ("TfsGit")
        $repositoryDetails | Add-Member -MemberType NoteProperty -Name "name" -Value ($repositoryObject.name)
        $repositoryDetails | Add-Member -MemberType NoteProperty -Name "defaultBranch" -Value ("main")
        $repositoryDetails | Add-Member -MemberType NoteProperty -Name "clean" -Value ($null)
        $repositoryDetails | Add-Member -MemberType NoteProperty -Name "checkoutSubmodules" -Value ($false)

        $body | Add-Member -MemberType NoteProperty -Name "process" -Value ($processDetails)
        $body | Add-Member -MemberType NoteProperty -Name "queue" -Value ($queue)
        $body | Add-Member -MemberType NoteProperty -Name "repository" -Value ($repositoryDetails)
        
        $Result = Invoke-RestMethod -Uri $definitionURI -Method post -Headers $Headers -Body ($body | ConvertTo-Json -Depth 100) -ContentType "application/json"

    }
    catch
    {
        Write-Error $($_.Exception.Message)
        throw($($_.Exception.Message))
    }
}
end
{
    if($Result | Get-Member | Where-Object {$_.Name -like "*id*"})
    {
        Write-Host "We succesfully created the Definition with id $($Result.id)."
    }
}
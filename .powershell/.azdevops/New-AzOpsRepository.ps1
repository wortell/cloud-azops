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
    $projectid,

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
    $pullname,
    
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

    $repoURI = $URIOrga + "_apis/git/repositories?api-version=6.0" 
    
    $body = New-Object -TypeName PSObject -Property @{}

    $desiredStateRepo = "$reponame-desiredstate"
}
process
{
    try
    {
        $ErrorActionPreference = "Stop"
        
        $projectObject = New-Object -TypeName PSObject -Property @{}
        $projectObject | Add-Member -MemberType NoteProperty -Name "id" -Value ("$projectid")

        $body | Add-Member -MemberType NoteProperty -Name "name" -Value ("$desiredStateRepo")
        $body | Add-Member -MemberType NoteProperty -Name "project" -Value $projectObject
        
        $Result = Invoke-RestMethod -Uri $repoURI -Method post -Headers $Headers -Body ($body | ConvertTo-Json -Depth 100) -ContentType "application/json"
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
        Write-Host "We succesfully created the Repository with id $($Result.id)."
    }

    Write-Host "##vso[task.setvariable variable=repoId;isOutput=true;]$(($Result.id))"
    Write-Host "##vso[task.setvariable variable=repoDesiredStateName;isOutput=true;]$(($Result.name))"
}
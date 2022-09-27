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
    $approvaluri,
    
    [Parameter(Mandatory = $true)]
    [string]
    $approver,

    [Parameter(Mandatory = $true)]
    [string]
    $organization,
    
    [Parameter(Mandatory = $true)]
    [string]
    $project,

    [Parameter(Mandatory = $true)]
    [string]
    $definitionid,
    
    [Parameter(Mandatory = $true)]
    [string]
    $buildid,
    
    [Parameter(Mandatory = $true)]
    [string]
    $SYSTEM_ACCESSTOKEN
)

begin
{
    $headers = @{
        Authorization = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($SYSTEM_ACCESSTOKEN)"))
    }
}
process
{
    try
    {
        $ErrorActionPreference = "Stop"

        $body = New-Object -TypeName PSObject -Property @{}
        $body | Add-Member -MemberType NoteProperty -Name "approver" -Value $approver
        $body | Add-Member -MemberType NoteProperty -Name "organization" -Value $organization
        $body | Add-Member -MemberType NoteProperty -Name "project" -Value $project
        
        $status = Invoke-WebRequest -Uri $approvaluri -Method post -Body ($body | ConvertTo-Json -Depth 50) -ContentType "application/json"

        if($status.Content -eq "The server is going to brew coffee with a coffeemachine.")
        {
            $URI = "https://dev.azure.com/$($organization)/$($project)/_apis/build/definitions/$($definitionid)?api-version=6.0"
        
            $response = Invoke-WebRequest -Uri $uri -Method delete -Headers $headers
        }

        if($status.Content -eq "The server refuses the attempt to brew coffee with a teapot.")
        {
            $URI = "https://dev.azure.com/$($organization)/$($project)/_apis/build/builds/$($buildid)?api-version=6.0"
            
            $response = Invoke-WebRequest -Uri $uri -Method delete -Headers $headers
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
    if($status.StatusCode -ne 200){
        Write-Error "We did not received a 200 OK HTTP Status code but: $($status.StatusCode), with description: $($status.StatusDescription)."
    }
}
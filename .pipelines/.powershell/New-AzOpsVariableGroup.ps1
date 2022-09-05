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
    $armtenantid,
    
    [Parameter(Mandatory = $true)]
    [string]
    $armclientid,
    
    [Parameter(Mandatory = $true)]
    [string]
    $armclientsecret,
    
    [Parameter(Mandatory = $true)]
    [string]
    $armsubscriptionid,
    
    [Parameter(Mandatory = $true)]
    [string]
    $vargroupname,
    
    [Parameter(Mandatory = $true)]
    [string]
    $SYSTEM_ACCESSTOKEN
)

begin
{
    $URI = "https://dev.azure.com/" + $organization + "/" + $project + "/_apis/distributedtask/variablegroups?api-version=5.1-preview.1"
    $headers = @{
        Authorization = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($SYSTEM_ACCESSTOKEN)"))
    }

    $variableGroupObject = New-Object -TypeName PSObject
    $variablesObject = New-Object -TypeName PSObject
}
process
{
    try
    {
        $ErrorActionPreference = "Stop"
        
        #
        # ARM_CLIENT_ID added to the group Object
        #

        $variableObject = New-Object -TypeName PSObject
        $variableObject | Add-Member -type NoteProperty -Name 'value' -Value $armclientid
        $variableObject | Add-Member -type NoteProperty -Name 'isSecret' -Value $true
        $variableObject | Add-Member -type NoteProperty -Name 'isReadOnly' -Value $true

        $variablesObject | Add-Member -type NoteProperty -Name 'ARM_CLIENT_ID' -Value $variableObject

        #
        # ARM_CLIENT_SECRET added to the group Object
        #

        $variableObject = New-Object -TypeName PSObject
        $variableObject | Add-Member -type NoteProperty -Name 'value' -Value $armclientsecret
        $variableObject | Add-Member -type NoteProperty -Name 'isSecret' -Value $true
        $variableObject | Add-Member -type NoteProperty -Name 'isReadOnly' -Value $true

        $variablesObject | Add-Member -type NoteProperty -Name 'ARM_CLIENT_SECRET' -Value $variableObject
        
        #
        # ARM_SUBSCRIPTION_ID added to the group Object
        #

        $variableObject = New-Object -TypeName PSObject
        $variableObject | Add-Member -type NoteProperty -Name 'value' -Value $armsubscriptionid
        $variableObject | Add-Member -type NoteProperty -Name 'isReadOnly' -Value $true

        $variablesObject | Add-Member -type NoteProperty -Name 'ARM_SUBSCRIPTION_ID' -Value $variableObject
        
        #
        # ARM_TENANT_ID added to the group Object
        #

        $variableObject = New-Object -TypeName PSObject
        $variableObject | Add-Member -type NoteProperty -Name 'value' -Value $armtenantid
        $variableObject | Add-Member -type NoteProperty -Name 'isReadOnly' -Value $true

        $variablesObject | Add-Member -type NoteProperty -Name 'ARM_TENANT_ID' -Value $variableObject

        #
        # Combining all variables to the variables property in our Variable Group
        #

        $variableGroupObject | Add-Member -type NoteProperty -Name 'variables' -Value $variablesObject
        $variableGroupObject | Add-Member -type NoteProperty -Name 'name' -Value $vars
        $variableGroupObject | Add-Member -type NoteProperty -Name 'description' -Value 'Default AzOps Credentials Group, read the manual about how to convert this group to Azure KeyVault.'
    
        $Result = Invoke-RestMethod -Uri $URI -Method post -Headers $Headers -Body ($variableGroupObject | ConvertTo-Json -Depth 100) -ContentType "application/json"
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
        Write-Host "We succesfully created the Variable Group with id $($Result.id)."
    }
}
<# 
.SYNOPSIS
    This script Lists NSG rules and verifies if it finds the PingdomNA and PingdomEU rules. 
    To execute you need to have ownership on the subscription and the rights to add NSGs 
.DESCRIPTION
    This script Lists current NSG rules
    The Subscriptionid and the Secutity Group details are user selectable. 
.EXAMPLE
    C:\>NSGSecGrpList.ps1 
    <Description of example>
    Select the Azure Subscription to use
        <Subscription popup. Select and press OK>
    Select the Azure Resource Group to associate the Pingdom NSGRules with
        <Resource Group Selection popup. Select and press OK>
.NOTES
    Author: Dan Williams 
    Date:   July 11, 2018
#>
Write-Host "Select the Azure Subscription to use"
$subscriptionId = (Get-AzureRmSubscription | Out-GridView -Title 'Select Azure Subscription:' -PassThru).SubscriptionId
Select-AzureRmSubscription -SubscriptionId $subscriptionId
 
# Select a Network Resource Group
Write-Host "Select the Azure Resource Group to Query" 
$sgObj  = (Get-AzureRmNetworkSecurityGroup | Select-Object Name,ResourceGroupName | Out-GridView -Title 'Select Azure Resource Group:' -PassThru)
$rgName = $sgObj.ResourceGroupName
$aName  = $sgObj.Name
Write-host "Security Group Name: $aName ResourceGroupName: $rgName"
$MyVar = Get-AzureRmNetworkSecurityGroup -Name $aName -ResourceGroupName $rgName | Get-AzureRmNetworkSecurityRuleConfig #-ErrorAction SilentlyContinue -ErrorVariable NSGError
$MyVar
#$MyVar = Get-AzureRmNetworkSecurityGroup | Select-Object Name,ResourceGroupName
#Get-AzureRmNetworkSecurityGroup -Name $module.Name -ResourceGroupName $module.ResourceGroupName | Get-AzureRmNetworkSecurityRuleConfig
write-host "Found Rules $($MyVar.Name)"


<#
.SYNOPSIS
    Script to remove Pingdom NSG rules to a subscription
.DESCRIPTION
    This script Removes Pingdom NSG rules to support the Pingdom app on a subscription.
    The Subscriptionid and the Secutity Group details are user selectable. 
    This script assumes the user has logged in (via Connect-AzureRmAccount) before execution.
    To execute you need to have ownership on the subscription and the rights to add NSGs 
.EXAMPLE
    C:\>NSGRmPingdom.ps1 
    <Description of example>
    Select the Azure Subscription to use
        <Subscription popup. Select and press OK>
    Select the Azure Resource Group to associate the Pingdom NSGRules with
        <Resource Group Selection popup. Select and press OK>
.NOTES
    Author: Dan Williams 
    Date:   July 23, 2018
#>
  
Write-Host "Select the Azure Subscription to use"
$subscriptionId = (Get-AzureRmSubscription | Out-GridView -Title 'Select Azure Subscription:' -PassThru).SubscriptionId
Select-AzureRmSubscription -SubscriptionId $subscriptionId
 
#Get-AzureRmNetworkSecurityGroup | Select-Object Name,ResourceGroupName

# Select a Resource Group
Write-Host "Select the Azure Resource Group to Remove the Pingdom NSGRules from" 
$sgObj  = (Get-AzureRmNetworkSecurityGroup | Select-Object Name,ResourceGroupName | Out-GridView -Title 'Select Azure Resource Group:' -PassThru)
$rgName = $sgObj.ResourceGroupName
$aName  = $sgObj.Name

#Get the name of each Security group we will be updating 
$MyVar = Get-AzureRmNetworkSecurityGroup -Name $aName -ResourceGroupName $rgName | Get-AzureRmNetworkSecurityRuleConfig -Name PingdomEU -ErrorAction SilentlyContinue -ErrorVariable NSGError

if ($NSGError){
    Write-Host "PingdomEU rule is not inplace. No need to remove it."
    
}else {
   Write-Host "Removing the PingdomEU rule."
   Get-AzureRmNetworkSecurityGroup -Name $aName -ResourceGroupName $rgName | Remove-AzureRmNetworkSecurityRuleConfig -Name PingdomEU | Set-AzureRmNetworkSecurityGroup > $null
}


#Get the name of each Security group we will be updating 
$MyVar = Get-AzureRmNetworkSecurityGroup -Name $aName -ResourceGroupName $rgName | Get-AzureRmNetworkSecurityRuleConfig -Name PingdomNA -ErrorAction SilentlyContinue -ErrorVariable NSGNAError

if ($NSGNAError){
    Write-Host "PingdomNA rule is not inplace. No need to create it."
   
}else {
   Write-Host "Removing the PingdomNA rule."
   Get-AzureRmNetworkSecurityGroup -Name $aName -ResourceGroupName $rgName | Remove-AzureRmNetworkSecurityRuleConfig -Name PingdomNA | Set-AzureRmNetworkSecurityGroup > $null
}

Write-Host "Network Security Group Rules after processing. "
(Get-AzureRmNetworkSecurityGroup).SecurityRules  | Select-Object Name,Priority,Port,Protocol

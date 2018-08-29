<#
.SYNOPSIS
    Script to add Pingdom NSG rules to a subscription
.DESCRIPTION
    This script adds new NSG rules to support the Pingdom app on a subscription.
    The Subscriptionid and the Secutity Group details are user selectable. 
    This script assumes the user has logged in (via Connect-AzureRmAccount) before execution.
    To execute you need to have ownership on the subscription and the rights to add NSGs  
.EXAMPLE
    C:\>NSGAddPingdom.ps1 
    <Description of example>
    Select the Azure Subscription to use
        <Subscription popup. Select and press OK>
    Select the Azure Resource Group to associate the Pingdom NSGRules with
        <Resource Group Selection popup. Select and press OK>
.NOTES
    Author: Dan Williams 
    Date:   July 23, 2018
#>
    
#Connect-AzureRmAccount - assumed

Write-Host "Select the Azure Subscription to use"
$subscriptionId = (Get-AzureRmSubscription | select Name,State,Id,TenantId | ? {$_.state -ne "Disabled"} | Sort-Object @{Expression={$_.Name}; Ascending=$true} | Out-GridView -Title 'Select Azure Subscription:' -PassThru).SubscriptionId
Select-AzureRmSubscription -SubscriptionId $subscriptionId
 
#Get-AzureRmNetworkSecurityGroup | Select-Object Name,ResourceGroupName

# Select a Resource Group
Write-Host "Select the Azure Resource Group to associate the Pingdom NSGRules with" 
$sgObj  = (Get-AzureRmNetworkSecurityGroup | Select-Object Name,ResourceGroupName | Out-GridView -Title 'Select Azure Resource Group:' -PassThru)
$rgName = $sgObj.ResourceGroupName
$aName  = $sgObj.Name

Write-Host "Network Security Group Rules after processing. "
(Get-AzureRmNetworkSecurityGroup).SecurityRules  | Select-Object Name,Priority,Port,Protocol

Write-Host "Check if PingdomEU rule already exists"
#Get the name of each Security group we will be updating 
$MyVar = Get-AzureRmNetworkSecurityGroup -Name $aName -ResourceGroupName $rgName | Get-AzureRmNetworkSecurityRuleConfig -Name PingdomEU -ErrorAction SilentlyContinue -ErrorVariable NSGError
if ($NSGError){
    Write-Host "PingdomEU rule is not inplace. We need to create it."
    #This is the list of IP from the Pingdom App of the IPs located in the EU
    $ipStr="178.255.154.2,185.152.65.167,82.103.139.165,82.103.136.16,85.93.93.123,85.93.93.124,85.93.93.133,169.51.2.22,46.20.45.18,46.165.195.139,89.163.146.247,89.163.242.206,52.59.46.112,52.59.147.246,52.57.132.90,188.138.40.20,5.172.196.188,185.70.76.23,37.252.231.50,52.209.34.226,52.209.186.226,52.210.232.124,52.48.244.35,178.255.155.2,95.141.32.46,95.211.198.87,85.17.156.76,85.17.156.11,95.211.217.68,169.51.80.85,188.172.252.34,185.246.208.82,185.93.3.92,94.247.174.83,185.39.146.215,185.39.146.214,5.178.78.77,178.255.153.2,83.170.113.210,109.123.101.103,159.8.146.132"
    $ipList = $ipStr -split ","
    Get-AzureRmNetworkSecurityGroup -Name $aName -ResourceGroupName $rgName | Add-AzureRmNetworkSecurityRuleConfig -Name PingdomEU -Priority 4041 -Description "Allow European Pingdom Hosts Access" -Direction Inbound -SourceAddressPrefix $ipList -Protocol * -SourcePortRange {*} -DestinationPortRange {*} -DestinationAddressPrefix * -Access Allow | Set-AzureRmNetworkSecurityGroup > $null
    
}else {
   Write-Host "PingdomEU rule is already inplace. No need to create it."
}

Write-Host "Check if PingdomNA rule already exists"
#Get the name of each Security group we will be updating 
$MyVar = Get-AzureRmNetworkSecurityGroup -Name $aName -ResourceGroupName $rgName | Get-AzureRmNetworkSecurityRuleConfig -Name PingdomNA -ErrorAction SilentlyContinue -ErrorVariable NSGNAError

if ($NSGNAError){
    Write-Host "PingdomNA rule is not inplace. We need to create it."
    #This is the list of IP from the Pingdom App of the IPs located in the EU
    $ipStr="174.34.156.130,173.248.147.18,64.237.55.3,69.59.28.19,76.72.167.90,199.87.228.66,76.164.194.74,208.64.28.194,72.46.153.26,76.72.172.208,72.46.140.106,174.34.224.167,23.111.152.74,209.126.117.87,209.126.120.29,64.237.49.203,173.254.206.242,162.218.67.34,23.22.2.46,52.73.209.122,52.201.3.199,50.16.153.186,52.52.95.213,52.52.34.158,54.68.48.199,52.89.43.70,52.24.42.103,52.0.204.16,52.52.118.192,54.70.202.58,76.72.167.154,50.22.90.227,207.244.80.239,96.47.225.18,104.129.30.18,66.165.229.130,66.165.233.234,23.111.159.174,76.164.234.106,76.164.234.170,50.23.28.35,104.129.24.154,23.83.129.219"
    $ipList = $ipStr -split ","
    Get-AzureRmNetworkSecurityGroup -Name $aName -ResourceGroupName $rgName | Add-AzureRmNetworkSecurityRuleConfig -Name PingdomNA -Priority 4040 -Description "Allow North American Pingdom Hosts Access" -Direction Inbound -SourceAddressPrefix $ipList -Protocol * -SourcePortRange {*} -DestinationPortRange {*} -DestinationAddressPrefix * -Access Allow | Set-AzureRmNetworkSecurityGroup > $null
    
}else {
   Write-Host "PingdomNA rule is already inplace. No need to create it."
}
Write-Host "Network Security Group Rules after processing. "
(Get-AzureRmNetworkSecurityGroup).SecurityRules  | Select-Object Name,Priority,Port,Protocol

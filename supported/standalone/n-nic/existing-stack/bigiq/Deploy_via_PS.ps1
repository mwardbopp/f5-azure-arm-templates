## Script parameters being asked for below match to parameters in the azuredeploy.json file, otherwise pointing to the ##
## azuredeploy.parameters.json file for values to use.  Some options below are mandatory, some (such as region) can    ##
## be supplied inline when running this script but if they aren't then the default will be used as specified below.    ##
## Example Command: .\Deploy_via_PS.ps1 -adminUsername azureuser -authenticationType password -adminPasswordOrKey <value> -dnsLabel <value> -instanceName f5vm01 -numberOfExternalIps 1 -instanceType Standard_DS3_v2 -imageName AllTwoBootLocations -bigIqAddress <value> -bigIqUsername <value> -bigIqPassword <value> -bigIqLicensePoolName <value> -bigIqLicenseSkuKeyword1 OPTIONAL -bigIqLicenseUnitOfMeasure OPTIONAL -bigIpVersion 16.1.000000 -bigIpModules ltm:nominal -vnetName <value> -vnetResourceGroupName <value> -mgmtSubnetName <value> -mgmtIpAddress DYNAMIC -externalSubnetName <value> -externalIpAddressRangeStart DYNAMIC -internalSubnetName <value> -internalIpAddress DYNAMIC -avSetChoice CREATE_NEW -zoneChoice 1 -provisionPublicIP Yes -declarationUrl NOT_SPECIFIED -ntpServer 0.pool.ntp.org -timeZone UTC -customImageUrn OPTIONAL -customImage OPTIONAL -allowUsageAnalytics Yes -allowPhoneHome Yes -numberOfAdditionalNics 1 -additionalNicLocation <value> -resourceGroupName <value>

param(

  [string] [Parameter(Mandatory=$True)] $adminUsername,
  [string] [Parameter(Mandatory=$True)] $authenticationType,
  [string] [Parameter(Mandatory=$True)] $adminPasswordOrKey,
  [string] [Parameter(Mandatory=$True)] $dnsLabel,
  [string] [Parameter(Mandatory=$True)] $instanceName,
  [string] [Parameter(Mandatory=$True)] $numberOfExternalIps,
  [string] [Parameter(Mandatory=$True)] $instanceType,
  [string] [Parameter(Mandatory=$True)] $imageName,
  [string] [Parameter(Mandatory=$True)] $bigIqAddress,
  [string] [Parameter(Mandatory=$True)] $bigIqUsername,
  [string] [Parameter(Mandatory=$True)] $bigIqPassword,
  [string] [Parameter(Mandatory=$True)] $bigIqLicensePoolName,
  [string] [Parameter(Mandatory=$True)] $bigIqLicenseSkuKeyword1,
  [string] [Parameter(Mandatory=$True)] $bigIqLicenseUnitOfMeasure,
  [string] [Parameter(Mandatory=$True)] $bigIpVersion,
  [string] [Parameter(Mandatory=$True)] $bigIpModules,
  [string] [Parameter(Mandatory=$True)] $vnetName,
  [string] [Parameter(Mandatory=$True)] $vnetResourceGroupName,
  [string] [Parameter(Mandatory=$True)] $mgmtSubnetName,
  [string] [Parameter(Mandatory=$True)] $mgmtIpAddress,
  [string] [Parameter(Mandatory=$True)] $externalSubnetName,
  [string] [Parameter(Mandatory=$True)] $externalIpAddressRangeStart,
  [string] [Parameter(Mandatory=$True)] $internalSubnetName,
  [string] [Parameter(Mandatory=$True)] $internalIpAddress,
  [string] [Parameter(Mandatory=$True)] $avSetChoice,
  [string] [Parameter(Mandatory=$True)] $zoneChoice,
  [string] [Parameter(Mandatory=$True)] $provisionPublicIP,
  [string] [Parameter(Mandatory=$True)] $declarationUrl,
  [string] [Parameter(Mandatory=$True)] $ntpServer,
  [string] [Parameter(Mandatory=$True)] $timeZone,
  [string] [Parameter(Mandatory=$True)] $customImageUrn,
  [string] [Parameter(Mandatory=$True)] $customImage,
  [string] $restrictedSrcAddress = "None",
  $tagValues = '{"application": "APP", "cost": "COST", "environment": "ENV", "group": "GROUP", "owner": "OWNER"}',
  [string] [Parameter(Mandatory=$True)] $allowUsageAnalytics,
  [string] [Parameter(Mandatory=$True)] $allowPhoneHome,
  [string] [Parameter(Mandatory=$True)] $numberOfAdditionalNics,
  [string] [Parameter(Mandatory=$True)] $additionalNicLocation,
  [string] [Parameter(Mandatory=$True)] $resourceGroupName,
  [string] $region = "West US",
  [string] $templateFilePath = "azuredeploy.json",
  [string] $parametersFilePath = "azuredeploy.parameters.json"
)

Write-Host "Disclaimer: Scripting to Deploy F5 Solution templates into Cloud Environments are provided as examples. They will be treated as best effort for issues that occur, feedback is encouraged." -foregroundcolor green
Start-Sleep -s 3

# Connect to Azure, right now it is only interactive login
try {
    Write-Host "Checking if already logged in!"
    Get-AzureRmSubscription | Out-Null
    Write-Host "Already logged in, continuing..."
    }
    catch {
      Write-Host "Not logged in, please login..."
      Login-AzureRmAccount
    }

# Create Resource Group for ARM Deployment
New-AzureRmResourceGroup -Name $resourceGroupName -Location "$region"

$adminPasswordOrKeySecure = ConvertTo-SecureString -String $adminPasswordOrKey -AsPlainText -Force
$bigIqPasswordSecure = ConvertTo-SecureString -String $bigIqPassword -AsPlainText -Force

(ConvertFrom-Json $tagValues).psobject.properties | ForEach -Begin {$tagValues=@{}} -process {$tagValues."$($_.Name)" = $_.Value}

# Create Arm Deployment
$deployment = New-AzureRmResourceGroupDeployment -Name $resourceGroupName -ResourceGroupName $resourceGroupName -TemplateFile $templateFilePath -TemplateParameterFile $parametersFilePath -Verbose -adminUsername $adminUsername -authenticationType $authenticationType -adminPasswordOrKey $adminPasswordOrKeySecure -dnsLabel $dnsLabel -instanceName $instanceName -numberOfExternalIps $numberOfExternalIps -instanceType $instanceType -imageName $imageName -bigIqAddress $bigIqAddress -bigIqUsername $bigIqUsername -bigIqPassword $bigIqPasswordSecure -bigIqLicensePoolName $bigIqLicensePoolName -bigIqLicenseSkuKeyword1 $bigIqLicenseSkuKeyword1 -bigIqLicenseUnitOfMeasure $bigIqLicenseUnitOfMeasure -bigIpVersion $bigIpVersion -bigIpModules $bigIpModules -vnetName $vnetName -vnetResourceGroupName $vnetResourceGroupName -mgmtSubnetName $mgmtSubnetName -mgmtIpAddress $mgmtIpAddress -externalSubnetName $externalSubnetName -externalIpAddressRangeStart $externalIpAddressRangeStart -internalSubnetName $internalSubnetName -internalIpAddress $internalIpAddress -avSetChoice $avSetChoice -zoneChoice $zoneChoice -provisionPublicIP $provisionPublicIP -declarationUrl $declarationUrl -ntpServer $ntpServer -timeZone $timeZone -customImageUrn $customImageUrn -customImage $customImage -restrictedSrcAddress $restrictedSrcAddress -tagValues $tagValues -allowUsageAnalytics $allowUsageAnalytics -allowPhoneHome $allowPhoneHome -numberOfAdditionalNics $numberOfAdditionalNics -additionalNicLocation $additionalNicLocation 

# Print Output of Deployment to Console
$deployment
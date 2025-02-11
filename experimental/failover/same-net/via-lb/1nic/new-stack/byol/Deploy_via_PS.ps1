## Script parameters being asked for below match to parameters in the azuredeploy.json file, otherwise pointing to the ##
## azuredeploy.parameters.json file for values to use.  Some options below are mandatory, some (such as region) can    ##
## be supplied inline when running this script but if they aren't then the default will be used as specified below.    ##
## Example Command: .\Deploy_via_PS.ps1 -adminUsername azureuser -authenticationType password -adminPasswordOrKey <value> -dnsLabel <value> -instanceType Standard_DS2_v2 -imageName AllTwoBootLocations -bigIpVersion 16.1.000000 -bigIpModules ltm:nominal -licenseKey1 <value> -licenseKey2 <value> -vnetAddressPrefix 10.0 -declarationUrl NOT_SPECIFIED -ntpServer 0.pool.ntp.org -timeZone UTC -customImageUrn OPTIONAL -customImage OPTIONAL -allowUsageAnalytics Yes -allowPhoneHome Yes -numberOfInstances 2 -resourceGroupName <value>

param(

  [string] [Parameter(Mandatory=$True)] $adminUsername,
  [string] [Parameter(Mandatory=$True)] $authenticationType,
  [string] [Parameter(Mandatory=$True)] $adminPasswordOrKey,
  [string] [Parameter(Mandatory=$True)] $dnsLabel,
  [string] [Parameter(Mandatory=$True)] $instanceType,
  [string] [Parameter(Mandatory=$True)] $imageName,
  [string] [Parameter(Mandatory=$True)] $bigIpVersion,
  [string] [Parameter(Mandatory=$True)] $bigIpModules,
  [string] [Parameter(Mandatory=$True)] $licenseKey1,
  [string] [Parameter(Mandatory=$True)] $licenseKey2,
  [string] [Parameter(Mandatory=$True)] $vnetAddressPrefix,
  [string] [Parameter(Mandatory=$True)] $declarationUrl,
  [string] [Parameter(Mandatory=$True)] $ntpServer,
  [string] [Parameter(Mandatory=$True)] $timeZone,
  [string] [Parameter(Mandatory=$True)] $customImageUrn,
  [string] [Parameter(Mandatory=$True)] $customImage,
  [string] $restrictedSrcAddress = "None",
  $tagValues = '{"application": "APP", "cost": "COST", "environment": "ENV", "group": "GROUP", "owner": "OWNER"}',
  [string] [Parameter(Mandatory=$True)] $allowUsageAnalytics,
  [string] [Parameter(Mandatory=$True)] $allowPhoneHome,
  [string] [Parameter(Mandatory=$True)] $numberOfInstances,
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

(ConvertFrom-Json $tagValues).psobject.properties | ForEach -Begin {$tagValues=@{}} -process {$tagValues."$($_.Name)" = $_.Value}

# Create Arm Deployment
$deployment = New-AzureRmResourceGroupDeployment -Name $resourceGroupName -ResourceGroupName $resourceGroupName -TemplateFile $templateFilePath -TemplateParameterFile $parametersFilePath -Verbose -adminUsername $adminUsername -authenticationType $authenticationType -adminPasswordOrKey $adminPasswordOrKeySecure -dnsLabel $dnsLabel -instanceType $instanceType -imageName $imageName -bigIpVersion $bigIpVersion -bigIpModules $bigIpModules -licenseKey1 $licenseKey1 -licenseKey2 $licenseKey2 -vnetAddressPrefix $vnetAddressPrefix -declarationUrl $declarationUrl -ntpServer $ntpServer -timeZone $timeZone -customImageUrn $customImageUrn -customImage $customImage -restrictedSrcAddress $restrictedSrcAddress -tagValues $tagValues -allowUsageAnalytics $allowUsageAnalytics -allowPhoneHome $allowPhoneHome -numberOfInstances $numberOfInstances 

# Print Output of Deployment to Console
$deployment
#!/bin/bash

## Bash Script to deploy an F5 ARM template into Azure, using azure cli 1.0 ##
## Example Command: ./deploy_via_bash.sh --adminUsername azureuser --authenticationType password --adminPasswordOrKey <value> --dnsLabel <value> --instanceName f5vm01 --numberOfExternalIps 1 --instanceType Standard_DS3_v2 --imageName Best1Gbps --bigIpVersion 16.1.000000 --bigIpModules ltm:nominal --vnetName <value> --vnetResourceGroupName <value> --mgmtSubnetName <value> --mgmtIpAddressRangeStart DYNAMIC --externalSubnetName <value> --externalIpAddressRangeStart DYNAMIC --externalIpSelfAddressRangeStart DYNAMIC --internalSubnetName <value> --internalIpAddressRangeStart DYNAMIC --provisionPublicIP Yes --declarationUrl NOT_SPECIFIED --ntpServer 0.pool.ntp.org --timeZone UTC --customImageUrn OPTIONAL --customImage OPTIONAL --allowUsageAnalytics Yes --allowPhoneHome Yes --numberOfAdditionalNics 0 --additionalNicLocation OPTIONAL --userAssignedManagedIdentity NOT_SPECIFIED --roleNameGuid [newGuid()] --resourceGroupName <value> --azureLoginUser <value> --azureLoginPassword <value>

# Assign Script Parameters and Define Variables
# Specify static items below, change these as needed or make them parameters
region="westus"
tagValues='{"application":"APP","environment":"ENV","group":"GROUP","owner":"OWNER","cost":"COST"}'

# Parse the command line arguments, primarily checking full params as short params are just placeholders
while [[ $# -gt 1 ]]; do
    case "$1" in
        --adminUsername)
            adminUsername=$2
            shift 2;;
        --authenticationType)
            authenticationType=$2
            shift 2;;
        --adminPasswordOrKey)
            adminPasswordOrKey=$2
            shift 2;;
        --dnsLabel)
            dnsLabel=$2
            shift 2;;
        --instanceName)
            instanceName=$2
            shift 2;;
        --numberOfExternalIps)
            numberOfExternalIps=$2
            shift 2;;
        --instanceType)
            instanceType=$2
            shift 2;;
        --imageName)
            imageName=$2
            shift 2;;
        --bigIpVersion)
            bigIpVersion=$2
            shift 2;;
        --bigIpModules)
            bigIpModules=$2
            shift 2;;
        --vnetName)
            vnetName=$2
            shift 2;;
        --vnetResourceGroupName)
            vnetResourceGroupName=$2
            shift 2;;
        --mgmtSubnetName)
            mgmtSubnetName=$2
            shift 2;;
        --mgmtIpAddressRangeStart)
            mgmtIpAddressRangeStart=$2
            shift 2;;
        --externalSubnetName)
            externalSubnetName=$2
            shift 2;;
        --externalIpAddressRangeStart)
            externalIpAddressRangeStart=$2
            shift 2;;
        --externalIpSelfAddressRangeStart)
            externalIpSelfAddressRangeStart=$2
            shift 2;;
        --internalSubnetName)
            internalSubnetName=$2
            shift 2;;
        --internalIpAddressRangeStart)
            internalIpAddressRangeStart=$2
            shift 2;;
        --provisionPublicIP)
            provisionPublicIP=$2
            shift 2;;
        --declarationUrl)
            declarationUrl=$2
            shift 2;;
        --ntpServer)
            ntpServer=$2
            shift 2;;
        --timeZone)
            timeZone=$2
            shift 2;;
        --customImageUrn)
            customImageUrn=$2
            shift 2;;
        --customImage)
            customImage=$2
            shift 2;;
        --restrictedSrcAddress)
            restrictedSrcAddress=$2
            shift 2;;
        --tagValues)
            tagValues=$2
            shift 2;;
        --allowUsageAnalytics)
            allowUsageAnalytics=$2
            shift 2;;
        --allowPhoneHome)
            allowPhoneHome=$2
            shift 2;;
        --numberOfAdditionalNics)
            numberOfAdditionalNics=$2
            shift 2;;
        --additionalNicLocation)
            additionalNicLocation=$2
            shift 2;;
        --userAssignedManagedIdentity)
            userAssignedManagedIdentity=$2
            shift 2;;
        --roleNameGuid)
            roleNameGuid=$2
            shift 2;;
        --resourceGroupName)
            resourceGroupName=$2
            shift 2;;
        --region)
            region=$2
            shift 2;;
        --azureLoginUser)
            azureLoginUser=$2
            shift 2;;
        --azureLoginPassword)
            azureLoginPassword=$2
            shift 2;;
        --restrictedSrcAddress)
            restrictedSrcAddress=$2
            shift 2;;
        --)
            shift
            break;;
    esac
done

#If a required parameter is not passed, the script will prompt for it below
required_variables="adminUsername authenticationType adminPasswordOrKey dnsLabel instanceName numberOfExternalIps instanceType imageName bigIpVersion bigIpModules vnetName vnetResourceGroupName mgmtSubnetName mgmtIpAddressRangeStart externalSubnetName externalIpAddressRangeStart externalIpSelfAddressRangeStart internalSubnetName internalIpAddressRangeStart provisionPublicIP declarationUrl ntpServer timeZone customImageUrn customImage allowUsageAnalytics allowPhoneHome numberOfAdditionalNics additionalNicLocation userAssignedManagedIdentity roleNameGuid resourceGroupName "
for variable in $required_variables
        do
        if [ -z ${!variable} ] ; then
                read -p "Please enter value for $variable:" $variable
        fi
done

echo "Disclaimer: Scripting to Deploy F5 Solution templates into Cloud Environments are provided as examples. They will be treated as best effort for issues that occur, feedback is encouraged."
sleep 3

# Login to Azure, for simplicity in this example using username and password supplied as script arguments --azureLoginUser and --azureLoginPassword
# Perform Check to see if already logged in
az account show > /dev/null 2>&1
if [[ $? != 0 ]] ; then
        az login -u $azureLoginUser -p $azureLoginPassword
fi

# Create ARM Group
az group create -n $resourceGroupName -l $region

# Deploy ARM Template, right now cannot specify parameter file and parameters inline via Azure CLI
template_file="./azuredeploy.json"
parameter_file="./azuredeploy.parameters.json"
az deployment group create --verbose --no-wait --template-file $template_file -g $resourceGroupName -n $resourceGroupName --parameters "{\"adminUsername\":{\"value\":\"$adminUsername\"},\"authenticationType\":{\"value\":\"$authenticationType\"},\"adminPasswordOrKey\":{\"value\":\"$adminPasswordOrKey\"},\"dnsLabel\":{\"value\":\"$dnsLabel\"},\"instanceName\":{\"value\":\"$instanceName\"},\"numberOfExternalIps\":{\"value\":$numberOfExternalIps},\"instanceType\":{\"value\":\"$instanceType\"},\"imageName\":{\"value\":\"$imageName\"},\"bigIpVersion\":{\"value\":\"$bigIpVersion\"},\"bigIpModules\":{\"value\":\"$bigIpModules\"},\"vnetName\":{\"value\":\"$vnetName\"},\"vnetResourceGroupName\":{\"value\":\"$vnetResourceGroupName\"},\"mgmtSubnetName\":{\"value\":\"$mgmtSubnetName\"},\"mgmtIpAddressRangeStart\":{\"value\":\"$mgmtIpAddressRangeStart\"},\"externalSubnetName\":{\"value\":\"$externalSubnetName\"},\"externalIpAddressRangeStart\":{\"value\":\"$externalIpAddressRangeStart\"},\"externalIpSelfAddressRangeStart\":{\"value\":\"$externalIpSelfAddressRangeStart\"},\"internalSubnetName\":{\"value\":\"$internalSubnetName\"},\"internalIpAddressRangeStart\":{\"value\":\"$internalIpAddressRangeStart\"},\"provisionPublicIP\":{\"value\":\"$provisionPublicIP\"},\"declarationUrl\":{\"value\":\"$declarationUrl\"},\"ntpServer\":{\"value\":\"$ntpServer\"},\"timeZone\":{\"value\":\"$timeZone\"},\"customImageUrn\":{\"value\":\"$customImageUrn\"},\"customImage\":{\"value\":\"$customImage\"},\"restrictedSrcAddress\":{\"value\":\"$restrictedSrcAddress\"},\"tagValues\":{\"value\":$tagValues},\"allowUsageAnalytics\":{\"value\":\"$allowUsageAnalytics\"},\"allowPhoneHome\":{\"value\":\"$allowPhoneHome\"},\"numberOfAdditionalNics\":{\"value\":$numberOfAdditionalNics},\"additionalNicLocation\":{\"value\":\"$additionalNicLocation\"},\"userAssignedManagedIdentity\":{\"value\":\"$userAssignedManagedIdentity\"},\"roleNameGuid\":{\"value\":\"$roleNameGuid\"}}"
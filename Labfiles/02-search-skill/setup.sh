#!/bin/bash

# Set values for your subscription and resource group
subscription_id=YOUR_SUBSCRIPTION_ID
resource_group=YOUR_RESOURCE_GROUP
location=YOUR_LOCATION_NAME

# Get random numbers to create unique resource names
unique_id=$RANDOM$RANDOM

echo Creating storage...

storage_account_name="ai102str$unique_id"
az storage account create --name ai102str!unique_id! --subscription $subscription_id --resource-group $resource_group --location $location --sku Standard_LRS --encryption-services blob --default-action Allow --allow-blob-public-access true --only-show-errors --output none

echo Uploading files....

# Get the storage account key.

# Get the storage account key. NOTE: You must have jq installed on your system to run this command. 
# To install jq on a Mac on which you have installed homebrew, open a terminal and type: homebrew install jq

AZURE_STORAGE_KEY=$(az storage account keys list --subscription $subscription_id --resource-group $resource_group --account-name $storage_account_name | jq -r '.[0].value')
az storage container create --account-name $storage_account_name --name margies --public-access blob --auth-mode key --account-key $AZURE_STORAGE_KEY --output none
az storage blob upload-batch -d margies -s data --account-name $storage_account_name --auth-mode key --account-key $AZURE_STORAGE_KEY  --output none

# Create the search service.

search_service_name=ai102srch$unique_id

echo Creating search service...
echo (If this gets stuck at '- Running ..' for more than a couple minutes, press CTRL+C then select N)
az search service create --name $search_account_name --subscription $subscription_id --resource-group $resource_group --location $location --sku basic --output none

echo -------------------------------------
echo Storage account: $storage_account_name
az storage account show-connection-string --subscription $subscription_id --resource-group $resource_group --name $storage_account_name
echo ----
echo Search Service: ai102srch
echo  Url: https://$search_service_name.search.windows.net
echo  Admin Keys:
az search admin-key show --subscription $subscription_id --resource-group $resource_group --service-name $search_service_name
echo  Query Keys:
az search query-key list --subscription $subscription_id --resource-group $resource_group --service-name $search_service_name


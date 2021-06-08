<########################################################################################################################################################
    Name: AKS Cluster Creation
    Author: Randy Bordeaux
    Date Created: 5/27/2021
    Date Modified:
    
    Description: 
        Creates the resource group and all resources needed for the AKS Cluster
        
    Requirements: 
        Powershell 6.X.X or later
        NET Framework 4.7.2 or later
        'Owner' access on ECU-DevOps and ECU-Core-002 subscriptions
        
        The Powershell module 'AZ' is required to execute the commands in this script, Azure cloud shell can be used and comes with the AZ module installed
        already. 
        You can access the Cloud Shell at https://shell.azure.com
        
        PowerShell 7.x and later is the recommended version of PowerShell for use with the Azure Az PowerShell module on all platforms.
        
        How to install the AZ module 
            
            This method works the same on Windows, macOS, and Linux platforms. 
            Run the following command from a PowerShell session:
           
                Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force
            
            The MSI package for Azure PowerShell is available from https://github.com/Azure/azure-powershell/releases
    Documentation: 
        https://docs.microsoft.com/en-us/powershell/azure/?view=azps-6.0.0
        https://docs.microsoft.com/en-us/powershell/azure/install-az-ps?view=azps-6.0.0
        https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/deploy-powershell
        https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-windows?view=powershell-7.1
        https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-linux?view=powershell-7.1
        https://www.powershellgallery.com/packages/Az/6.0.0
        https://github.com/Azure/azure-powershell/releases
        https://shell.azure.com
########################################################################################################################################################>

# connect to Azure 
Connect-AzAccount

# Set subscription 
Set-AzContext -Subscription " "   <# Subscription #>

<# Route info #>
$routeNextHopType = 'Virtualappliance'
$routeNextHopIpAddress = 

$route1Name = 
$route1AddressPrefix = 

$route2Name = 
$route2AddressPrefix = 

$route3Name = 
$route3AddressPrefix = 

$route4Name = 
$route4AddressPrefix = 

<# Dynamic Variables #>
$resourceGroupName   = 
$location            = 
$tags                = '@{ "Environment"="Dev"; "Function"="AKS Cluster" ; "Owner"="DevOps" }' 
$routetablename      = 
$storageaccountname  = 
$Route = New-AzRouteConfig -Name 'udr-override-dev-001' -AddressPrefix "0.0.0.0/0" -NextHopType VirtualAppliance -NextHopIpAddress $routeNextHopIpAddress
$rbacScope = " "      <# Scope for role based access #> 

<# Storage Account Access #> 
<# This is needed for pulling from private azure storage #>
$sas = 'ENTER YOUR SAS STRING HERE'
$BlobUri = 'ENTER THE URL TO THE SPECIFIC FILE'
$FullUri = "$BlobUri$Sas"

<# ARM Templates #>
<# Each template has 2 files, the template file has the configurations. The parameters file has the actual parameters for the build #>

$vnettemplateUri     = 
$vnetparameteruri    = 
$akstemplateUri      = 
$aksparameteruri     = 
$kvtemplateUri       = 
$kvparameteruri      = 
$psqltemplateuri     = 
$psqlparameteruri    = 


<# RBAC Variables #> 
$devgroupId          = 
$infosecgroupid      = 
$infragroupip        = 


############################## ARM TEMPLATE CREATION #################################

<# ARM templates are being downloaded and then used to execute builds using the Azure resource manager #>

# Create Resource Group 
New-AzResourceGroup `
   -Name $resourcegroupname `
   -Location $location `
   -Tag $tags
   
# Create Vnet 
New-AzResourceGroupDeployment `
    -ResourceGroupName $resourceGroupName `
    -TemplateUri $vnettemplateUri `
    -Location $location `
    -TemplateParameterUri $vnetparameteruri `
    -Tag $tags

# Create AKS Cluster 
New-AzResourceGroupDeployment `
    -ResourceGroupName $resourceGroupName `
    -TemplateUri $akstemplateUri `
    -TemplateParameterUri $aksparameteruri  `
    -Location $location `
    -Tag $tags
 
# Create Key Vault 
New-AzResourceGroupDeployment `
    -ResourceGroupName $resourceGroupName `
    -TemplateUri $kvtemplateUri `
    -TemplateParameterUri $kvparameteruri  `
    -Location $location `
    -Tag $tags

# Create postgres server
New-AzResourceGroupDeployment `
    -ResourceGroupName $resourceGroupName `
    -TemplateUri $psqltemplateUri `
    -TemplateParameterUri $psqlparameteruri  `
    -Location $location `
    -Tag $tags

# Create Storage Account 
New-AzStorageAccount `
  -ResourceGroupName $resourceGroup `
  -Name $storageaccountname `
  -Location $location `
  -SkuName Standard_ZRS `
  -Kind StorageV2 `
  -Tag $tags 


############################## END OF ARM TEMPLATE CREATION ##########################

# Setup vnet peering 
Add-AzVirtualNetworkPeering `
    -Name 
    -VirtualNetwork 
    -RemoteVirtualNetworkId 

# Create Route table 
New-AzRouteTable `
    -Name $routetablename `
    -ResourceGroupName $resourceGroupName `
    -Location $location `
    -Route $Route

# Create Routes 
Get-AzRouteTable `
    -ResourceGroupName $resourcegroupname  `
    -Name $routetablename   



New-AzRouteConfig `
-Name $route1name `
-AddressPrefix $route1addressprefix `
-NextHopType $routeNextHopType `
-NextHopIpAddress $routeNextHopIpAddress

New-AzRouteConfig `
-Name $route2name `
-AddressPrefix $route2addressprefix `
-NextHopType $routeNextHopType `
-NextHopIpAddress $routeNextHopIpAddress

New-AzRouteConfig `
-Name $route3name `
-AddressPrefix $route3addressprefix `
-NextHopType $routeNextHopType `
-NextHopIpAddress $routeNextHopIpAddress

New-AzRouteConfig `
-Name $route4name `
-AddressPrefix $route4addressprefix `
-NextHopType $routeNextHopType `
-NextHopIpAddress $routeNextHopIpAddress


############################## Assign Role based access ##############################

<# Grant DevOps Team access #>
New-AzRoleAssignment `
    -ObjectId $devgroupId `
    -RoleDefinitionName "Contributor" `
    -Scope $rbacScope

< # Switch to Subscription #>

# Set subscription 
Set-AzContext -Subscription 

# Set up vNet Peering
Add-AzVirtualNetworkPeering `
    -Name `
    -VirtualNetwork `
    -RemoteVirtualNetworkId 

############################## END OF SCRIPT ######################################### 

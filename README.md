# SitecoreIaaSArmTemplates

This repository contains Azure Resource Management (ARM) templates to create various Sitecore infrastructure on IaaS infrastructure, i.e. Virtual Machines (VMs). Once configured and deployed, the resulting environments are fully ready-to-go, error-free Sitecore sites. Remote Desktop Protocol (RDP) is also set up to allow you to view the server and make any additional tweaks.

One of the goals of this repository was to leave the Sitecore installs as out-of-the-box as possible. They rely on basic SIF commands. The core pieces are there, and can be modififed as needed depending on the goals of a deployment.

On average, the deployment of these environments is around 30 min. Including an XP1 deployment of 1 SQL, 1 CM and 2 CDs load balanced. All ARM templates rely on the same suite of shared [ARM Link Templates](LinkTemplates) to reduce customizations per deployment type.

Note, only Sitecore 9.0.x is supported at the moment. Support for 9.1 brings with it further enhancements with SIF 2.0.0. The bulk of the infrastructure will remain largely the same. Only the DSC (where the Sitecore installs occur) is where changes need to be made.

All ARM templates create all reliant Azure infrastructure: NICs, PIPs, Availability Sets, NSGs, Storage Accounts, Vnets, VMs. All are configurable after created. For example, if you wish to make Solr NOT publicly accessible, modify the NIC post deployment.

## Types of Deployments

### Solr VM

This ARM template will create a Windows VM that hosts a shared Solr instance. It comes prepackaged with Sitecore 9 requirements, such as enforcing SSL. When the deployment finishes, a public URL is immediately available to review Solr. If using this repository to set up a suite of environments, deploy Solr first so that the automated deployments of subsequent environments can automatically create the required cores per environment.

[For specific deployment instructions, visit the Solr VM Read Me](SolrVM/README.md)

### Sitecore XP0 Single

This ARM template deploys a Sitecore XP0 Single instance. It has a reliance on the shared Solr VM created with the accompanying ARM template. Other than Solr, all other Sitecore prereq's are on the single Windows 2016 VM. The deployment will yield an error-free, publicly accessible Sitecore instance.

[For specific deployment instructions, visit the Single Sitecore 9 Read Me](Sitecore/9.0.x/Single%20Sitecore9VM/README.md) 

### Sitecore XP1 Scaled

This ARM template deploys Sitecore XP1 on the following infrastructure: 1 VM for SQL, 1 VM for CM (set up as standalone) and any number of VM's for CD (load balanced, number is parameterized).

[For specific deployment instructions, visit the Single Sitecore 9 Read Me](Sitecore/9.0.x/XCD1CA%20Sitecore9.0.x/README.md) 

# What does this all do?

It does quite a bit. For example, each web server that is provisioned gets a suite of nice-to-have's:

Installs...

1. IIS
   1. Dynamic Compression
   2. Static Compression
   3. URL Rewrite
2. .Net versions
3. Various .Net prerequisites
4. Notepad++
5. 7-zip

Beyond these, it installs other prerequisites per deployment type. For example:

#### Solr

Installs JRE SDK

#### Web Servers

Installs SQL DAC dependencies, enables counter permissions, etc.

In short, if it's possible in a DSC and makes life a little easier, it installs it. One piece that is unstable is setting up user preferences, such as viewing file extensions, setting Quick Access links, etc. These pieces are intentionally omitted.

## Non VM Tasks

For each deployment type, all dependent resources are created: Network Security Group, Storage Account, Availability Set, Network Interface, Public IP Address, Virtual Network.

All deployments share the same set of [Azure Link Templates](/LinkTemplates). Reviewing these Link Templates can give a sense for what each one is responsible for. They help make the primary deployment scripts smaller and easier to understand.

# General Deployment Steps

### Prerequisites

**Install Azure PowerShell on the machine you wish to deploy the ARM templates from (e.g. your local developer machine): https://docs.microsoft.com/en-us/powershell/azure/install-az-ps?view=azps-1.0.0**

## Deploy Arm Template

In order to run this step, please first set up the parameters of a deployment in one of the above deployment sections. The individual deployments will link back to this section after you've properly set up your script to be deployed.

1. Open a PowerShell window as an administrator
2. Navigate to your copied deployment folder (This folder should contain the file `Deploy-AzureResourceGroup.ps1`)
3. Type `Login-AzureRmAccount`
   1. This will request that you login to Azure in a separate window
4. After logging in successfully, type `Get-AzureRMSubscription`
   1. This will return a list of all subscriptions associated with your username
5. Next, type `Select-AzureRmSubscription -subscriptionID [ID]` (The [ID] value should be pulled from the output from step 4, find the subscription ID you wish to deploy this resource group to)
6. Type `.\Deploy-AzureResourceGroup.ps1 -ArtifactStagingDirectory 'WebCluster' -ResourceGroupLocation [LOCATION] -ResourceGroupName '[RESOURCEGROUPNAME]'`
   1. Substitute `[LOCATION]` for a valid Azure Resource Group location, e.g. `eastus2`. Find the full list here: https://management.azure.com/subscriptions/{subscriptionId}/locations?api-version=2016-06-01 (put in your subscription ID here)
   2. Substitute `[ResourceGroupName]` with the name you would like to call this resource group. All resources deployed will exist in the same resource group
7. Once executed, the script will upload any assets in the DSC folder and begin providing output

# Troubleshooting Failed Deployments

If you begin altering parameters or PowerShell scripts, you may run into issues.

## Errors prior to deployment completion

The best way to debug errors that end the deployment prematurely is to review the output in the PowerShell window. Often the failures are a result of incorrect pathing or a missing file.

## Errors in the DSC

Sometimes the deployment completes with a status of success, but PowerShell reports errors during the execution of one or many DSCs. To troubleshoot, RDP to the servers that encountered the error.

Navigate to `C:\Windows\System32\Configuration\ConfigurationStatus` and sort the list by last modified. The most recent file will contain the output from the DSC. This is the most useful method for solving issues.

# Manually Running DSCs

If you are making major modificatiosn to an existing DSC, it is painful to wait for a full deployment to test small changes. The best thing to do is to work with an already provisioned server. Remote into the server and run the DSC manually.

1. Copy the DSC powershell script (`WebServerConfig.ps1`) to the VM (any directory)
2. Open PowerShell as admin
3. Navigate to the folder with the PowerShell DSC script
4. Run `. ./WebServerConfig.ps1` (this will add to your path variables temporarily)
5. Run `WebServerConfig` (exclude the .ps1 portion)
   1. If there are any parameters in the PowerShell script, pass them in with `WebServerConfig -param1 value1 -param2 value2`
   2. This step will create a folder in your working directory with a `*.mof` file
6. Run `Start-DscConfiguration -Verbose -Force -Path "Path to directory that has the *.mof file"` -Wait
   1. Verbose gives you more output
   2. Force ensures a previous iteration is not stalled
   3. Path should be a directory, not the actual file

More information on Start-DscConfiguration: https://docs.microsoft.com/en-us/powershell/module/psdesiredstateconfiguration/start-dscconfiguration?view=powershell-5.1
# SitecoreIaaSArmTemplates

*To get started right away, skip to the "General Deployment Steps" section.*

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

# General Deployment Steps

### Prerequisites

**Install Azure PowerShell on the machine you wish to deploy the ARM templates from (e.g. your local developer machine): https://docs.microsoft.com/en-us/powershell/azure/install-az-ps?view=azps-1.0.0**

### Steps

1. 
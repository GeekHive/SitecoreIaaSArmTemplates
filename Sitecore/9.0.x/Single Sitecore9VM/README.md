[<< Back to main README.md](../../../README.md)

# Sitecore 9.0.x XP0 Single Deployment Guide

1. Clone the repo
2. Copy all contents of the `Single Sitecore9VM` folder to a new location outside of the repo
3. Navigate to the folder `<your folder>\Single Sitecore9VM\WebCluster\AzureTemplates`
4. From the original repo, copy the following files into this directory
   1. AvailabilitySets.json
   2. FENetworkSecurityGroups.json
   3. NetworkInterfaces.json
   4. PublicIpAddresses.json
   5. StorageAccounts.json
   6. VirtualMachines.json
   7. VirtualNetworks.json
5. Navigate to the folder `<your folder>\Single Sitecore9VM\WebCluster`
4. In here you will see 2 JSON files: `azuredeploy.json` and `azuredeploy.parameters.json`
5. Feel free to view the contents of `azuredeploy.json`, but keep in mind you shouldn't normally touch this file
6. Open `azuredeploy.parameters.json` in your favorite JSON editor
7. Modify the parameters to your needs
   1. envPrefixName: This will ultimately be the _first_ part of your public URL. Give it a unique value per client, e.g. "gogle" (up to 5 chars for now, due to reuse of variable in deployment)
   2. environmentType: This will ultimately be the _second_ part of your public URL. Give it a value to specify the environment, e.g. "uat" (up to 5 chars for now, due to reuse of variable in deployment)
   3. username: the RDP username used to log in after deployment
   4. password: the RDP password used to login after deployment
   5. sitecoreWdpPackage: File name of your Sitecore WDP XP0 package _without_ ".zip" on the end, e.g. "Sitecore 9.0.2 rev. 180604 (WDP XP0 packages)"
      1. Visit https://dev.sitecore.net/Downloads and find your 9.0.x version
	  2. Find the section titled "Download options for On Premises deployment"
	  3. Download the "Packages for XP Single" options
	  4. The _file name_ of this file (minus the .zip portion) is the value you need
   6. solrSSLPassword: The password you wish to use to install the cert
   7. solrSSLFileName: The file name of the Solr cert that was exported from the Solr deployment. Should be "solr-ssl.keystore.pfx"
   8. solrUrl: The public URL of your Solr server (note this _can_ be private, as long as the server can access it). Should include "https://" and ":8983/solr" in URL
   9. sitecoreConfigurationFilesNameNoExtension: Extract the file from step 5 and find the name of the Configuration file without ".zip", e.g. "XP0 Configuration files 9.0.2 rev. 180604"
   10. xConnectPackage: Extract the file from step 5 and find the name of the xconnect file _with_ ".zip", e.g. "Sitecore 9.0.2 rev. 180604 (OnPrem)_xp0xconnect.scwdp.zip"
   11. sitecorePackage: Extract the file from step 5 and find the name of the Sitecore Single file _with_ ".zip", e.g. "Sitecore 9.0.2 rev. 180604 (OnPrem)_single.scwdp.zip"
   12. sqlAdminUser: SQL admin account to be created
   13. sqlAdminPassword: SQL admin password to be created
8. Include prerequisite files
   1. The following files must be included in the `WebCluster\DSC` folder. They will be uploaded as part of the deployment.
      1. `license.xml` - a valid Sitecore license
	  2. `Sitecore 9.0.x rev. XXXXXX (WDP XP0 packages).zip` - this was downloaded in step 5.1 above
	  3. `solr-ssl.keystore.pfx` - This is the exported Solr SSL cert obtained during the Solr deployment
	  4. (The WebServerConfig.ps1 is already included and should remain in place)
   
# Deploy the ARM template

To deploy this ARM template, view the shared deployment steps from the main [README](../../../README.md#Deploy-ARM-Template).

# Post Deployment (IMPORTANT)

After the deployment completes, navigate to the Sitecore instance
1. Rebuild all indexes
2. Rebuild links databases
3. Deploy Marketing Definitions
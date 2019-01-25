[<< Back to main README.md](../../../README.md)

# Sitecore 9.0.x XP Scaled Deployment Guide

1. Clone the repo
2. Open PowerShell in the repo root
3. Run `.\Create-DeploymentFolder.ps1 -DeploymentName "MyClientUAT" -Template Sitecore -Version 9.0.x -Topology XPScaled`
   1. This command will copy the required deployment files to "<repo root>\deployments\MyClientUAT"
4. Navigate to the folder `<repo root>\deployments\MyClientUAT\WebCluster`
5. In here you will see 2 JSON files: `azuredeploy.json` and `azuredeploy.parameters.json`
6. Feel free to view the contents of `azuredeploy.json`, but keep in mind you shouldn't normally touch this file
7. Open `azuredeploy.parameters.json` in your favorite JSON editor
8. Modify the parameters to your needs
   1. envPrefixName: This will ultimately be the _first_ part of your public URL. Give it a unique value per client, e.g. "gogle" (up to 5 chars for now, due to reuse of variable in deployment)
   2. environmentType: This will ultimately be the _second_ part of your public URL. Give it a value to specify the environment, e.g. "uat" (up to 5 chars for now, due to reuse of variable in deployment)
   3. username: the RDP username used to log in after deployment
   4. password: the RDP password used to login after deployment
   5. sitecoreXP0WdpPackage: File name of your Sitecore WDP XP0 package _without_ ".zip" on the end, e.g. "Sitecore 9.0.2 rev. 180604 (WDP XP0 packages)"
      1. Visit https://dev.sitecore.net/Downloads and find your 9.0.x version
	  2. Find the section titled "Download options for On Premises deployment"
	  3. Download the "Packages for XP Single" option
	  4. The _file name_ of this file (minus the .zip portion) is the value you need
	  5. We are installing the CM server with the standalone role and  therefore XP0 is required
   6. sitecoreCDWdpPackage: File name of your CD Web Deployment Package _without_ ".zip" on the end, e.g. "Sitecore 9.0.2 rev. 180604 (OnPrem)_cd.scwdp"
      1. Visit https://dev.sitecore.net/Downloads and find your 9.0.x version
	  2. Find the section titled "Download options for On Premises deployment"
	  3. Download the "Packages for XP Scaled" option (this will be a very large download, > 1 GB)
	  4. Extract this zip to see it's contents
	  5. In particular pull out the "cd.scwdp.zip" file. This will be needed for the deployment. The name of this file (without the .zip) is the value of this parameter
   7. solrSSLFileName: The file name of the Solr cert that was exported from the Solr deployment. Should be "solr-ssl.keystore.pfx"
   8. solrUrl: The public URL of your Solr server (note this _can_ be private, as long as the server can access it). Should include "https://" and ":8983/solr" in URL
   9. sitecoreConfigurationFilesNameNoExtensionXP0: Extract the file from step 5 and find the name of the Configuration file without ".zip", e.g. "XP0 Configuration files 9.0.2 rev. 180604"
   10. sitecoreXp1CDJson: The full name of the CD JSON file located within the CD WDP package from step 6
      1. Within the large zip downloaded in step 6.3 is another zip in the format of "XP1 Configuration files 9.0.x rev. XXXXXX.zip"
	  2. Extract this zip and find the name of the JSON file used for CD role deployment, e.g. "sitecore-XP1-cd.json". This is the value for this parameter.
   11. xConnectPackage: Extract the file from step 5 and find the name of the xconnect file _with_ ".zip", e.g. "Sitecore 9.0.2 rev. 180604 (OnPrem)_xp0xconnect.scwdp.zip"
   12. sitecoreSingleWdpPackage: Extract the file from step 5 and find the name of the Sitecore Single file _with_ ".zip", e.g. "Sitecore 9.0.2 rev. 180604 (OnPrem)_single.scwdp.zip"
   13. sqlAdminUser: SQL admin account to be created
   14. sqlAdminPassword: SQL admin password to be created
9. Include prerequisite files
   1. The following files must be included in the `WebCluster\DSC` folder. They will be uploaded as part of the deployment.
      1. `license.xml` - a valid Sitecore license
	  2. `Sitecore 9.0.x rev. XXXXXX (WDP XP0 packages).zip` - this was downloaded in step 7.5 above
	  3. `Sitecore 9.0.x rev. XXXXXX (OnPrem)_cd.scwdp.zip` - this was downloaded in step 7.6 above
	  4. `sitecore-XP1-cd.json` - this was pulled in step 7.10 above
	  5. `solr-ssl.keystore.pfx` - This is the exported Solr SSL cert obtained during the Solr deployment
	  6. (The CdServerConfig.ps1, CmServerConfig.ps1 and DbServerConfig.ps1 are already included and should remain in place)
   
# Deploy the ARM template

To deploy this ARM template, view the shared deployment steps from the main [README](../../../README.md#Deploy-ARM-Template).

# Post Deployment (IMPORTANT)

CM URL: http://(envPrefixName)ca(environmentType).(location).cloudapp.azure.com/sitecore/shell
CD URL (load balanced): http://(envPrefixName)(environmentType).(location).cloudapp.azure.com/

After the deployment completes, navigate to the Sitecore CM instance
1. Rebuild all indexes
2. Rebuild links databases
3. Deploy Marketing Definitions
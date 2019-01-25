[<< Back to main README.md](../README.md)

# Solr ARM Deployment Guide

1. Clone the repo
2. Open PowerShell in the repo root
3. Run `.\Create-DeploymentFolder.ps1 -DeploymentName "MyClientSolr" -Template SolrVM`
4. Navigate to the folder `~\deployments\MyClientSolr_SolrVM\WebCluster`
5. In here you will see 2 JSON files: `azuredeploy.json` and `azuredeploy.parameters.json`
6. Feel free to view the contents of `azuredeploy.json`, but keep in mind you shouldn't normally touch this file
7. Open `azuredeploy.parameters.json` in your favorite JSON editor
8. Modify the parameters to your needs
   1. envPrefixName: This will ultimately be the _first_ part of your public URL. Give it a unique value per client, e.g. "gogle" (up to 5 chars for now, due to reuse of variable in deployment)
   2. environmentType: This will ultimately be the _second_ part of your public URL. Give it a value to specify the environment, e.g. "uat" (up to 5 chars for now, due to reuse of variable in deployment)
   3. username: the RDP username used to log in after deployment
   4. password: the RDP password used to login after deployment
   5. solrVersion: Only tested with 6.x.x. Other version _do_ work, but may need some tweaking
   6. location: where on Azure you'd like to put this resource group
   
# Deploy the ARM template

To deploy this ARM template, view the shared deployment steps from the main [README](../README.md#Deploy-ARM-Template).

# Post Deployment (IMPORTANT)

After the deployment completes, it is important that you obtaint he Solr SSL cert. This will be used on all Sitecore deployments.

Location: `c:\Solr\solr-[SOLRVERSION]\server\etc\solr-ssl.keystore.pfx`

Copy this down to your local machine to later use on Sitecore deployments.
param(
    [string]$BaseDeploymentFolder = "$PWD\deployments\",
    [string]$DeploymentName,
    [ValidateSet("SolrVM","Sitecore")]
    [string]$Template,
	[ValidateSet("9.0.x")]
    [string]$Version,
    [string]$Topology
)

Write-Host "Deployment folder: $BaseDeploymentFolder"
$Destination = ""
$Source = ""
if ($Template -eq "SolrVM"){
    $Source = Resolve-Path ".\SolrVM"
    $Destination = [System.IO.Path]::Combine($BaseDeploymentFolder,"$($DeploymentName)_SolrVM")
}
else {
    $Source = [System.IO.Path]::Combine((Resolve-Path ".\Sitecore\"),$version,$topology)
    $Destination = [System.IO.Path]::Combine($BaseDeploymentFolder,$DeploymentName)
}
Write-Host "Copying source files from: $Source"
Write-Host "To: $Destination"
Copy-Item -Path "$Source" -Destination $Destination -Recurse -force

$linkTemplates = Get-Item -Path "$Source\LinkTemplates.txt" -ErrorAction SilentlyContinue

if($linkTemplates){
	Write-Host "-- Deployment requires the following Link Templates:"
	New-Item -ItemType Directory -Path "$Destination\WebCluster\AzureTemplates\"
	Write-Host "----------------------------------------------------"
	foreach($linkTemplate in [System.IO.File]::ReadLines($linkTemplates))
	{
		Write-Host "-- $linkTemplate"
		Copy-Item -Path "$PWD\LinkTemplates\$linkTemplate.json" -Destination "$Destination\WebCluster\AzureTemplates\"
	}
	Write-Host "--------------------------------------------------"
	Write-Host "-- Link Templates copied to destination folder. --"
}

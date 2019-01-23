Configuration WebServerConfig
{
	param (
		[String]$solrVersion,
		[String]$nssmVersion,
		[String]$solrSslPassword,
		[String]$solrPort,
		[String]$dns,
		[String]$artifactsLocation
    )
	Import-DscResource -ModuleName PSDesiredStateConfiguration
	
	Node ("localhost")
	{
		#Install the IIS Role
		WindowsFeature IIS
		{
			Ensure = "Present"
			Name = "Web-Server"
		}

		#Install ASP.NET 4.5
		WindowsFeature ASP45
		{
			Ensure = "Present"
			Name = "Web-Asp-Net45"
		}

		#Install ASP.NET 3.5
		WindowsFeature ASP35
		{
			Ensure = "Present"
			Name = "Web-Asp-Net"
		}

		#Install NET Extensibility 35
		WindowsFeature NetExt35
		{
			Ensure = "Present"
			Name = "Web-Net-Ext"
		}
		
		#Install NET Extensibility 45
		WindowsFeature NetExt45
		{
			Ensure = "Present"
			Name = "Web-Net-Ext45"
		}

		#Install ISAPI Filters
		WindowsFeature ISAPI_Filters
		{
			Ensure = "Present"
			Name = "Web-ISAPI-Filter"
		}

		#Install ISAPI Extensions
		WindowsFeature WebISAPI_EXT
		{
			Ensure = "Present"
			Name = "Web-ISAPI-Ext"
		}

		#Install Default Document
		WindowsFeature DefaultDocument
		{
			Ensure = "Present"
			Name = "Web-Default-Doc"
		}

		#Install Static Content
		WindowsFeature StaticContent
		{
			Ensure = "Present"
			Name = "Web-Static-Content"
		}

		#Install Dynamic Content Compression
		WindowsFeature DynamicContentCompression
		{
			Ensure = "Present"
			Name = "Web-Dyn-Compression"
		}
		
		#Install Static Content Compression
		WindowsFeature StaticContentCompression
		{
			Ensure = "Present"
			Name = "Web-Stat-Compression"
		}

		#Install Request Filtering
		WindowsFeature RequestFiltering
		{
			Ensure = "Present"
			Name = "Web-Filtering"
		}

		WindowsFeature WebServerManagementConsole
		{
			Name = "Web-Mgmt-Console"
			Ensure = "Present"
		}
		
		WindowsFeature TelnetClient {
			Ensure = 'Present'
			Name = 'Telnet-Client'
		}
		
		Script GetNotepadpp {
			GetScript = { @{ Result = (Test-Path -Path "c:\npp.exe") } }
			SetScript = {
				$Uri = "https://notepad-plus-plus.org/repository/7.x/7.6/npp.7.6.Installer.exe"
				$OutFile = "c:\npp.exe"
				Invoke-WebRequest -Uri $Uri -OutFile $OutFile -UseBasicParsing
				Unblock-File -Path $OutFile
			}	
			TestScript = {Test-Path -Path "c:\npp.exe"}
		}
		
        Package Install_NotepadPlusPlus{
			Ensure = "Present"
			Name = "Notepad++ (32-bit x86)"
			Path = "c:\npp.exe"
			ProductId=""
			Arguments = "/S"
			DependsOn="[Script]GetNotepadpp"
		}
		
		Script Get7zip{
			GetScript = { @{ Result = (Test-Path -Path "c:\7z1604-x64.msi") } }
			SetScript = {
				$Uri = "http://www.7-zip.org/a/7z1604-x64.msi" 
				$OutFile = "c:\7z1604-x64.msi"
				Invoke-WebRequest -Uri $Uri -OutFile $OutFile -UseBasicParsing
				Unblock-File -Path $OutFile
			}	
			TestScript = {Test-Path -Path "c:\7z1604-x64.msi"}
		}
		
		Package Install_7zip{
			Ensure = "Present"
			Name = "7-Zip 16.04 (x64 edition)"
			Path = "c:\7z1604-x64.msi"
			ProductId="{23170F69-40C1-2702-1604-000001000000}"
			Arguments = "/q"
			DependsOn="[Script]Get7zip"
		}
		
		Script GetJRE{
			GetScript = { @{ Result = (Test-Path -Path "c:\jdk.exe") } }
			SetScript = {
				$source = "https://download.oracle.com/otn-pub/java/jdk/8u201-b09/42970487e3af4f5aa5bca3f542482c60/jdk-8u201-windows-x64.exe"
				$destination = "C:\jdk.exe"
				$client = new-object System.Net.WebClient 
				$cookie = "gpw_e24=http%3a%2F%2Fwww.oracle.com%2Ftechnetwork%2Fjava%2Fjavase%2Fdownloads%2Fjdk8-downloads-2133151.html; oraclelicense=accept-securebackup-cookie;"
				$client.Headers.Add([System.Net.HttpRequestHeader]::Cookie, $cookie) 
				$client.downloadFile($source, $destination)
				Unblock-File -Path $destination
			}	
			TestScript = {Test-Path -Path "c:\jdk.exe"}
		}
		
		Package Install_JRE{
			Ensure = "Present"
			Name = "Java SE Development Kit 8 Update 201 (64-bit)"
			Path = "c:\jdk.exe"
			ProductId="{64A3A4F4-B792-11D6-A78A-00B0D0180201}"
			Arguments = "/q"
			DependsOn="[Script]GetJRE"
		}
		
		Script GetSolr{
			GetScript = { @{ Result = (Test-Path -Path "c:\solr.zip") } }
			SetScript = {
				$Uri = "http://archive.apache.org/dist/lucene/solr/$using:solrVersion/solr-$using:solrVersion.zip"
				$OutFile = "c:\solr.zip"
				Invoke-WebRequest -Uri $Uri -OutFile $OutFile -UseBasicParsing
				Unblock-File -Path $OutFile
			}	
			TestScript = {Test-Path -Path "c:\solr.zip"}
		}
		
		Script ExpandSolr{
			GetScript = { @{ Result = (Test-Path -Path "c:\Solr\solr-$using:solrVersion"); } }
			SetScript = {
				Expand-Archive "c:\solr.zip" -DestinationPath "c:\Solr"
			}	
			TestScript = {Test-Path -Path "c:\Solr\solr-$using:solrVersion"}
			DependsOn="[Script]GetSolr"
		}
		
		Script GetNssm {
			GetScript = { @{Result = (Test-Path -Path "C:\nssm.zip");}};
			SetScript = {
				$nssm = "nssm.zip"
                $uri = "$using:artifactsLocation$nssm"
				$OutFile = "c:\$nssm"
				Invoke-WebRequest -Uri $uri -OutFile $OutFile
				Unblock-File -Path $OutFile
			};
			TestScript = {
                Test-Path -Path "C:\nssm.zip"
			}
		}
		
		Script ExpandNssm{
			GetScript = { @{ Result = (Test-Path -Path "c:\Nssm") } }
			SetScript = {
				Expand-Archive "c:\nssm.zip" -DestinationPath "c:\Nssm"
			}
			TestScript = {Test-Path -Path "c:\Nssm"}
			DependsOn="[Script]GetNssm"
		}
		
		Script SetJavaEnvironmentVariable{
			GetScript = { @{ Result = ([Environment]::GetEnvironmentVariable("JAVA_HOME", [EnvironmentVariableTarget]::Machine)) } }
			SetScript = {
				[Environment]::SetEnvironmentVariable("JAVA_HOME", "C:\Program Files\Java\jdk1.8.0_191", [EnvironmentVariableTarget]::Machine)
			}
			TestScript = {Test-Path env:"JAVA_HOME"}
		}
		
		Script GenerateSolrCert{
			GetScript = { @{ Result = (Get-ChildItem Cert: -Recurse | where FriendlyName -eq "Solr-$using:solrVersion") } }
			SetScript = {
				$cert = New-SelfSignedCertificate -FriendlyName "Solr-$using:solrVersion" -DnsName "$using:dns" -CertStoreLocation "cert:\LocalMachine" -NotAfter (Get-Date).AddYears(10)
				$store = New-Object System.Security.Cryptography.X509Certificates.X509Store "Root","LocalMachine"
				$store.Open("ReadWrite")
				$store.Add($cert)
				$store.Close()
				$cert | Remove-Item
			}
			TestScript = {
				$cert = Get-ChildItem -Path Cert: -Recurse | Where FriendlyName -eq "Solr-$using:solrVersion"
				[boolean]$cert
			}
		}
		
		Script ExportSolrCert{
			GetScript = { @{ Result = (Test-Path -Path "c:\Solr\solr-$using:solrVersion\server\etc\solr-ssl.keystore.pfx") } }
			SetScript = {
				$cert = Get-ChildItem Cert: -Recurse | where FriendlyName -eq "Solr-$using:solrVersion"
				$certStore = "c:\Solr\solr-$using:solrVersion\server\etc\solr-ssl.keystore.pfx"
				$certPwd = ConvertTo-SecureString -String "$using:solrSslPassword" -Force -AsPlainText
				$cert | Export-PfxCertificate -FilePath $certStore -Password $certpwd | Out-Null
			}
			TestScript = {
				Test-Path -Path "c:\Solr\solr-$using:solrVersion\server\etc\solr-ssl.keystore.pfx"
			}
			DependsOn="[Script]GenerateSolrCert"
		}
		
		Script UpdateSolrKeystore{
			GetScript = { @{ Result = (Test-Path -Path "c:\Solr\solr-$using:solrVersion\bin\solr.in.cmd.old") } }
			SetScript = {
				$installLocation = "c:\Solr\solr-$using:solrVersion"
				$bin = "$installLocation\bin"
				$cfg = Get-Content "$bin\solr.in.cmd"
				Rename-Item "$bin\solr.in.cmd" "$bin\solr.in.cmd.old"
				$certStore = "$installLocation\server\etc\solr-ssl.keystore.pfx"
				$newCfg = $cfg | % { $_ -replace "REM set SOLR_SSL_KEY_STORE=etc/solr-ssl.keystore.jks", "set SOLR_SSL_KEY_STORE=$certStore" }
				$newCfg = $newCfg | % { $_ -replace "REM set SOLR_SSL_KEY_STORE_PASSWORD=$using:solrSslPassword", "set SOLR_SSL_KEY_STORE_PASSWORD=$using:solrSslPassword" }
				$newCfg = $newCfg | % { $_ -replace "REM set SOLR_SSL_TRUST_STORE=etc/solr-ssl.keystore.jks", "set SOLR_SSL_TRUST_STORE=$certStore" }
				$newCfg = $newCfg | % { $_ -replace "REM set SOLR_SSL_TRUST_STORE_PASSWORD=$using:solrSslPassword", "set SOLR_SSL_TRUST_STORE_PASSWORD=$using:solrSslPassword" }
				$newCfg = $newCfg | % { $_ -replace "REM set SOLR_HOST=127.0.0.1", "set SOLR_HOST=localhost" }
				$newCfg | Set-Content "$bin\solr.in.cmd"
			}
			TestScript = {
				Test-Path -Path "c:\Solr\solr-$using:solrVersion\bin\solr.in.cmd.old"
			}
			DependsOn="[Script]ExportSolrCert"
		}
		
		Script CreateSitecoreConfigsSet{
			GetScript = { @{ Result = (Test-Path -Path "c:\Solr\solr-$using:solrVersion\server\solr\configsets\sitecore_main") } }
			SetScript = {
				Copy-Item "c:\Solr\solr-$using:solrVersion\server\solr\configsets\basic_configs" "c:\Solr\solr-$using:solrVersion\server\solr\configsets\sitecore_main" -recurse
			}
			TestScript = {
				Test-Path -Path "c:\Solr\solr-$using:solrVersion\server\solr\configsets\sitecore_main"
			}
		}
		
		Script CreateXdbConfigsSet{
			GetScript = { @{ Result = (Test-Path -Path "c:\Solr\solr-$using:solrVersion\server\solr\configsets\sitecore_xdb") } }
			SetScript = {
				Copy-Item "c:\Solr\solr-$using:solrVersion\server\solr\configsets\basic_configs" "c:\Solr\solr-$using:solrVersion\server\solr\configsets\sitecore_xdb" -recurse
			}
			TestScript = {
				Test-Path -Path "c:\Solr\solr-$using:solrVersion\server\solr\configsets\sitecore_xdb"
			}
		}
		
		Script ModifySitecoreConfigsSet{
			GetScript = { @{ Result = (Test-Path -Path "c:\Solr\solr-$using:solrVersion\server\solr\configsets\sitecore_main") } }
			SetScript = {
				$xml = New-Object XML
				$path = "c:\Solr\solr-$using:solrVersion\server\solr\configsets\sitecore_main\conf\managed-schema"
				$xml.Load($path)
				
				$uniqueKey =  $xml.SelectSingleNode("//uniqueKey")
				$uniqueKey.InnerText = "_uniqueid"
				
				$field = $xml.CreateElement("field")
				$field.SetAttribute("name", "_uniqueid")
				$field.SetAttribute("type", "string")
				$field.SetAttribute("indexed", "true")
				$field.SetAttribute("required", "true")
				$field.SetAttribute("stored", "true")
				
				$xml.DocumentElement.AppendChild($field)
				
				$xml.Save($path)
			}
			TestScript = {
				$false
			}
		}
		
		Script RunSolrAsService{
			GetScript = { @{ Result = (Get-Service "solr-$using:solrVersion" -ErrorAction SilentlyContinue) } }
			SetScript = {
				&"c:\Nssm\nssm-$using:nssmVersion\win64\nssm.exe" install "solr-$using:solrVersion" "c:\Solr\solr-$using:solrVersion\bin\solr.cmd" "-f" "-p $using:solrPort"
			}
			TestScript = {
				$service = Get-Service "solr-$using:solrVersion" -ErrorAction SilentlyContinue
				[boolean]$service
			}
			DependsOn="[Script]UpdateSolrKeystore"
		}
		
		Script StartSolrService{
			GetScript = { @{ Result = (Get-Service "solr-$using:solrVersion" -ErrorAction SilentlyContinue) } }
			SetScript = {
				Start-Service "solr-$using:solrVersion"
			}
			TestScript = {
				$service = Get-Service "solr-$using:solrVersion" -ErrorAction SilentlyContinue
				if(!($service)){
					$false
				}
				else{
					$service.Status -eq "Running"
				}
			}
			DependsOn="[Script]RunSolrAsService"
		}
		
		Script AllowSolr{
			GetScript = { @{ Result = (Get-Service "solr-$using:solrVersion" -ErrorAction SilentlyContinue) } }
			SetScript = {
				New-NetFirewallRule -DisplayName "Allow Solr" -Direction Inbound -LocalPort $using:solrPort -Protocol TCP -Action Allow
			}
			TestScript = {
				$false
			}
		}
	}
} 
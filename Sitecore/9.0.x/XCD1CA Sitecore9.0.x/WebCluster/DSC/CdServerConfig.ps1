Configuration CdServerConfig
{
	param (
		[String]$rdpUsername,
		[String]$rdpPassword,
	    [String]$artifactsLocation,
		[String]$resourcesPath,
		[String]$solrSSLPassword,
		[String]$solrSSLFileName,
		[String]$sitecoreCDWdpPackage,
		[String]$sitecoreConfigurationFileXp1Cd,
		[String]$sitePrefix,
		[String]$siteDns,
		[String]$sqlServer,
		[String]$solrUrl,
		[String]$licenseFile,
		[String]$xconnectCert,
		[String]$xConnectServerName,
		[String]$xconnectHost,
		[String]$sifVersion,
		[String]$xconnectServer
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
			GetScript = { @{ Result = (Test-Path -Path "c:\npp.exe"); } };
			SetScript = {
				$Uri = "https://notepad-plus-plus.org/repository/7.x/7.6/npp.7.6.Installer.exe" ;
				$OutFile = "c:\npp.exe";
				Invoke-WebRequest -Uri $Uri -OutFile $OutFile;
				Unblock-File -Path $OutFile
			};
				
			TestScript = {Test-Path -Path "c:\npp.exe";}
		}
		
        Package Install_NotepadPlusPlus 		{
			Ensure = "Present"
			Name = "Notepad++ (32-bit x86)"
			Path = "c:\npp.exe"
			ProductId=""
			Arguments = "/S"
			DependsOn="[Script]GetNotepadpp"
		}
		
		Script Get7zip{
			GetScript = { @{ Result = (Test-Path -Path "c:\7z1604-x64.msi"); } };
			SetScript = {
				$Uri = "http://www.7-zip.org/a/7z1604-x64.msi" ;
				$OutFile = "c:\7z1604-x64.msi";
				Invoke-WebRequest -Uri $Uri -OutFile $OutFile;
				Unblock-File -Path $OutFile
			};
				
			TestScript = {Test-Path -Path "c:\7z1604-x64.msi";}
			
		}
		
		Package Install_7zip{
			Ensure = "Present"
			Name = "7-Zip 16.04 (x64 edition)"
			Path = "c:\7z1604-x64.msi"
			ProductId="{23170F69-40C1-2702-1604-000001000000}"
			Arguments = "/q"
			DependsOn="[Script]Get7zip"
		}
		
		Script Get_WebPlatformInstaller{
			GetScript = { @{ Result = (Test-Path -Path "c:\WebPlatformInstaller_amd64_en-US.msi"); } };
			SetScript = {
				$Uri = "https://download.microsoft.com/download/C/F/F/CFF3A0B8-99D4-41A2-AE1A-496C08BEB904/WebPlatformInstaller_amd64_en-US.msi" ;
				$OutFile = "c:\WebPlatformInstaller_amd64_en-US.msi";
				Invoke-WebRequest -Uri $Uri -OutFile $OutFile;
				Unblock-File -Path $OutFile
			};
				
			TestScript = {Test-Path -Path "c:\WebPlatformInstaller_amd64_en-US.msi";}
		}
		
		Package Install_WebPlatformInstaller{
			Ensure = "Present"
			Name = "Microsoft Web Platform Installer 5.0"
			Path = "c:\WebPlatformInstaller_amd64_en-US.msi"
			ProductId="4D84C195-86F0-4B34-8FDE-4A17EB41306A"
			Arguments = ""
			DependsOn="[Script]Get_WebPlatformInstaller"
		}
		
		Package Install_WebDeploy{
			Ensure = "Present"
			Name = "Microsoft Web Deploy 3.5"
			Path = "$env:ProgramFiles\Microsoft\Web Platform Installer\WebPiCmd-x64.exe"
			ProductId=""
			Arguments = "/install /products:WDeploy /AcceptEula"
			DependsOn= "[Package]Install_WebPlatformInstaller"
		}
		
		Package Install_UrlRewrite
		{
			Ensure = "Present"
			Name = "IIS URL Rewrite Module 2"
			Path = "https://download.microsoft.com/download/C/9/E/C9E8180D-4E51-40A6-A9BF-776990D8BCA9/rewrite_amd64.msi"
			Arguments = "/quiet"
			ProductId = "08F0318A-D113-4CF0-993E-50F191D397AD"
			DependsOn= "[Package]Install_WebPlatformInstaller"
		}
		
		Script resetIIS {
			GetScript = { @{Result = ($true)}};
			SetScript = {
               invoke-command -scriptblock {iisreset}
			};  
			TestScript = {
                $testVar = c:\windows\system32\inetsrv\appcmd.exe list site "$using:sitePrefix.sc"
                -Not [string]::IsNullOrEmpty($testVar)
			}
		}

		Script createResourceFolder{
			GetScript = { @{Result = ($true)}};
			SetScript = {
               New-Item -ItemType Directory -Force -Path $using:resourcesPath
			};  
			TestScript = {
                Test-Path -Path "$using:resourcesPath"
			}
		}
		
		Script getLicense {
			GetScript = { @{Result = (Test-Path -Path "C:\$using:licenseFile");}};
			SetScript = {
                $uri = "$using:artifactsLocation$using:licenseFile"
				$OutFile = "$using:resourcesPath\$using:licenseFile"
				Invoke-WebRequest -Uri $uri -OutFile $OutFile
				Unblock-File -Path $OutFile
			};
			TestScript = {
                Test-Path -Path "$using:resourcesPath\$using:licenseFile"
			}
		}
		
		Script getCdWdp {
			GetScript = { @{Result = (Test-Path -Path "C:\$using:sitecoreCDWdpPackage.zip");}};
			SetScript = {
                $uri = "$using:artifactsLocation$using:sitecoreCDWdpPackage.zip"
				$OutFile = "$using:resourcesPath\$using:sitecoreCDWdpPackage.zip"
				Invoke-WebRequest -Uri $uri -OutFile $OutFile
				Unblock-File -Path $OutFile
			};
			TestScript = {
                Test-Path -Path "$using:resourcesPath\$using:sitecoreCDWdpPackage.zip"
			}
        }
        
        Script getXp1CdConfig {
			GetScript = { @{Result = (Test-Path -Path "C:\$using:sitecoreConfigurationFileXp1Cd");}};
			SetScript = {
                $uri = "$using:artifactsLocation$using:sitecoreConfigurationFileXp1Cd"
				$OutFile = "$using:resourcesPath\$using:sitecoreConfigurationFileXp1Cd"
				Invoke-WebRequest -Uri $uri -OutFile $OutFile
				Unblock-File -Path $OutFile
			};
			TestScript = {
                Test-Path -Path "$using:resourcesPath\$using:sitecoreConfigurationFileXp1Cd"
			}
        }

        Script getConfigFile {
			GetScript = { @{Result = (Test-Path -Path "C:\$using:sitecoreCDWdpPackage.zip");}};
			SetScript = {
                $uri = "$using:artifactsLocation$using:sitecoreCDWdpPackage.zip"
				$OutFile = "$using:resourcesPath\$using:sitecoreCDWdpPackage.zip"
				Invoke-WebRequest -Uri $uri -OutFile $OutFile
				Unblock-File -Path $OutFile
			};
			TestScript = {
                Test-Path -Path "$using:resourcesPath\$using:sitecoreCDWdpPackage.zip"
			}
			DependsOn = "[Script]getCdWdp"
		}
		
		Script getSolrCert {
			GetScript = { @{Result = (Test-Path -Path "C:\$using:solrSSLFileName");}};
			SetScript = {
                $uri = "$using:artifactsLocation$using:solrSSLFileName"
				$OutFile = "$using:resourcesPath\$using:solrSSLFileName"
				Invoke-WebRequest -Uri $uri -OutFile $OutFile
				Unblock-File -Path $OutFile
			};
			TestScript = {
                Test-Path -Path "$using:resourcesPath\$using:solrSSLFileName"
			}
		}
		
		Script registerSitecoreGallery {
			GetScript = { @{Result = ($true)}};
			SetScript = {
				Register-PSRepository -Name "SitecoreGallery" -SourceLocation "https://sitecore.myget.org/F/sc-powershell/api/v2" -InstallationPolicy Trusted -errorAction SilentlyContinue
			};  
			TestScript = {
				$false
			}
		}
		
		Script installSif {
			GetScript = { @{Result = ($true)}};
			SetScript = {
				Install-Module -Name SitecoreInstallFramework -Repository SitecoreGallery -RequiredVersion $using:sifVersion -errorAction SilentlyContinue
			};  
			TestScript = {
                $false
			}
			DependsOn = '[Script]registerSitecoreGallery'
		}
		
		Script installSolrCert {
			GetScript = { @{Result = ($true)}};
			SetScript = {
				$secpasswd = ConvertTo-SecureString $using:solrSSLPassword -AsPlainText -Force
				$creds = New-Object System.Management.Automation.PSCredential ("username", $secpasswd)

				Import-PfxCertificate -FilePath "$using:resourcesPath\$using:solrSSLFileName" -CertStoreLocation Cert:\LocalMachine\Root -Password $creds.Password
			};  
			TestScript = {
                [boolean](Get-ChildItem -Path Cert: -Recurse | Where-Object subject -match "solr")
			}
			DependsOn = '[Script]installSif'
		}

		Script GetCpp_Redistributable {
			GetScript = { @{ Result = (Test-Path -Path "c:\vc_redist.x64.exe"); } };
			SetScript = {
				$Uri = "https://download.microsoft.com/download/0/6/4/064F84EA-D1DB-4EAA-9A5C-CC2F0FF6A638/vc_redist.x64.exe" ;
				$OutFile = "c:\vc_redist.x64.exe";
				Invoke-WebRequest -Uri $Uri -OutFile $OutFile;
				Unblock-File -Path $OutFile
			};
				
			TestScript = {Test-Path -Path "c:\vc_redist.x64.exe";}
		}
		
        Package Install_Cpp_Redistributable 		{
			Ensure = "Present"
			Name = "Microsoft Visual C++ 2015 x64 Minimum Runtime - 14.0.24123"
			Path = "c:\vc_redist.x64.exe"
			ProductId="FDBE9DB4-7A91-3A28-B27E-705EF7CFAE57"
			Arguments = "/quiet"
			DependsOn="[Script]GetCpp_Redistributable"
		}

		Script setXconnectHostsFile {
			GetScript = { @{Result = ($true)}};
			SetScript = {
				$filename = "C:\Windows\System32\drivers\etc\hosts"
				$privateIp = ([System.Net.Dns]::GetHostAddresses("$using:xConnectServerName")).IPAddressToString
    			"$privateIp" + "`t`t" + $using:xconnectHost | Out-File -encoding ASCII -append $filename
			};  
			TestScript = {
                $false
			}
			DependsOn = '[Script]installSolrCert'
		}
		
		Script getXconnectClientCert {
			GetScript = { @{Result = ($true)}}
			SetScript = {
				Set-Item WSMan:\localhost\Client\TrustedHosts -Value '*' -Force

				$Password = ConvertTo-SecureString "$using:rdpPassword" -AsPlainText -Force
				$mycreds = New-Object System.Management.Automation.PSCredential("\$using:rdpUsername", $Password)

				$session = New-PSSession -ComputerName "$using:xconnectServer" -Credential $mycreds
				Copy-Item -FromSession $session  -Path 'C:\xConnectClient.pfx' -Destination 'C:\' 

				$session | Remove-PSSession
			}
			TestScript = {
                $false
			}
			DependsOn = "[Script]setXconnectHostsFile"
		}
		
        Script installXconnectCert {
			GetScript = { @{Result = ($true)}};
			SetScript = {
				$pwd = ConvertTo-SecureString -String "$using:solrSSLPassword" -Force -AsPlainText
				Import-PfxCertificate -FilePath "C:\xConnectClient.pfx" -CertStoreLocation "Cert:\LocalMachine\My" -Password $pwd -Verbose

				Get-Childitem cert:\LocalMachine\ca -Recurse | 
					Where-Object {$_.Issuer -match "DO_NOT_TRUST_SitecoreRootCert"} | 
					Move-Item -Destination Cert:\LocalMachine\root
			};  
			TestScript = {
                $false
			}
			DependsOn = "[Script]getXconnectClientCert"
		}
		
		Script installSitecore{
			GetScript = { @{Result = ($true)}};
			SetScript = {
				$sitecoreParams = @{     
					Path = "$using:resourcesPath\$using:sitecoreConfigurationFileXp1Cd"     
					Package = "$using:resourcesPath\$using:sitecoreCDWdpPackage.zip"  
					LicenseFile = "$using:resourcesPath\license.xml"     
					SqlDbPrefix = $using:sitePrefix
					SqlServer = $using:sqlServer 
					SolrCorePrefix = $using:sitePrefix  
					SolrUrl = $using:solrUrl  
					XConnectCert = "$using:xconnectCert"
					Sitename = "$using:siteDns"
					XConnectCollectionService = "https://$using:xconnectHost"    
					XConnectReferenceDataService = "https://$using:xconnectHost"   
					MarketingAutomationOperationsService = "https://$using:xconnectHost"   
					MarketingAutomationReportingService = "https://$using:xconnectHost"   
				} 
				Install-SitecoreConfiguration @sitecoreParams 
			};  
			TestScript = {
                $testVar = c:\windows\system32\inetsrv\appcmd.exe list site "$using:sitePrefix.sc"
                -Not [string]::IsNullOrEmpty($testVar)
			}
		}

		Script SetCountersPermission {
            GetScript  = { @{ Result = $false } }
            SetScript  = {
                Add-LocalGroupMember -Group "Performance Log Users" -Member "IIS AppPool\$using:siteDns"
				Add-LocalGroupMember -Group "Performance Monitor Users" -Member "IIS AppPool\$using:siteDns"
            }
            TestScript = {
                $false
			}
			DependsOn  = "[Script]installSitecore"
		}
		
		Script resetIIS2 {
			GetScript = { @{Result = ($true)}};
			SetScript = {
               invoke-command -scriptblock {iisreset}
			};  
			TestScript = {
                $false
			}
			DependsOn  = "[Script]SetCountersPermission"
		}
	}
} 
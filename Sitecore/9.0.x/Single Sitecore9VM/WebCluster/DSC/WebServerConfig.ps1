Configuration WebServerConfig
{
	param (
		[String]$rdpUsername,
	    [String]$artifactsLocation,
		[String]$resourcesPath,
		[String]$solrSSLPassword,
		[String]$solrSSLFileName,
		[String]$sitecoreWDPPackageNameNoExtension,
		[String]$sitecoreConfigurationFilesNameNoExtension,
		[String]$sitePrefix,
		[String]$siteDns,
		[String]$xConnectPackage,
		[String]$sitecorePackage,
		[String]$sqlServer,
		[String]$sqlAdminUser,
		[String]$sqlAdminPassword,
		[String]$solrUrl,
		[String]$licenseFile,
		[String]$solrMainConfigSet,
		[String]$solrXdbConfigSet,
		[String]$sifVersion
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
		
		Registry DacFxPath{
			Ensure = "Present"
			Key = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\IIS Extensions\MSDeploy\3"
			ValueName = "DacFxPath"
			ValueData = "C:\Program Files (x86)\Microsoft SQL Server\140\DAC\bin"
			ValueType = "String"
			Force = $true
			PsDscRunAsCredential = $adminCreds	
		}
		
		Registry DacFxDependenciesPath{
			Ensure = "Present"
			Key = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\IIS Extensions\MSDeploy\3"
			ValueName = "DacFxDependenciesPath"
			ValueData = "C:\Program Files (x86)\Microsoft SQL Server\140\DAC\bin"
			ValueType = "String"
			Force = $true
			PsDscRunAsCredential = $adminCreds	
		}
		
		Script resetIIS {
			GetScript = { @{Result = ($true)}};
			SetScript = {
               invoke-command -scriptblock {iisreset}
			};  
			TestScript = {
                $testVar = c:\windows\system32\inetsrv\appcmd.exe list site $using:siteDns
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
		
		Script getWdp {
			GetScript = { @{Result = (Test-Path -Path "C:\$using:sitecoreWDPPackageNameNoExtension.zip");}};
			SetScript = {
                $uri = "$using:artifactsLocation$using:sitecoreWDPPackageNameNoExtension.zip"
				$OutFile = "$using:resourcesPath\$using:sitecoreWDPPackageNameNoExtension.zip"
				Invoke-WebRequest -Uri $uri -OutFile $OutFile
				Unblock-File -Path $OutFile
			};
			TestScript = {
                Test-Path -Path "$using:resourcesPath\$using:sitecoreWDPPackageNameNoExtension.zip"
			}
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
		
		Script makeSqlUser {
			GetScript = { @{Result = ($true)}};
			SetScript = {
				sqlcmd -E -Q "Create Login $using:sqlAdminUser with PASSWORD ='$using:sqlAdminPassword', CHECK_POLICY = OFF"
			};  
			TestScript = {
                $dataset = sqlcmd -E  -h -1 -Q "SET NOCOUNT ON; select count(*) from master.dbo.syslogins where name = '$using:sqlAdminUser'" | select-object
				return [boolean]([int]$dataset)
			}
		}
		
		Script makeSqlUserSysAdmin {
			GetScript = { @{Result = ($true)}};
			SetScript = {
				sqlcmd -E -Q "EXEC master..sp_addsrvrolemember @loginame = N'$using:sqlAdminUser', @rolename = N'sysadmin'"
			};  
			TestScript = {
                $dataset = sqlcmd -E  -h -1 -Q "SET NOCOUNT ON; SELECT IS_SRVROLEMEMBER('sysadmin', '$using:sqlAdminUser'); " | select-object
				$dataset = $dataset.Trim()
				if($dataset -eq "NULL"){
					$false
				}
				else{
					[boolean]([int]$dataset)
				}
			}
		}
		
		Script setSqlMixedMode {
			GetScript = { @{Result = ($true)}};
			SetScript = {
               sqlcmd -E -Q "USE [master] `
				GO `
				EXEC xp_instance_regwrite N'HKEY_LOCAL_MACHINE', N'Software\Microsoft\MSSQLServer\MSSQLServer', N'LoginMode', REG_DWORD, 2 `
				GO"
			};  
			TestScript = {
                $dataset = sqlcmd -E  -h -1 -Q "SET NOCOUNT ON; EXEC master.sys.xp_loginconfig 'login mode' " | select-object
				$dataset = ($dataset -replace 'login mode', '').Trim()
				$dataset -eq "MIXED"
			}
		}
		
		Script restartSql {
			GetScript = { @{Result = ($true)}};
			SetScript = {
               Restart-Service -Force -Name MSSQLSERVER
			};  
			TestScript = {
                $testVar = c:\windows\system32\inetsrv\appcmd.exe list site $using:siteDns
                return -Not [string]::IsNullOrEmpty($testVar)
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
                [boolean](Get-ChildItem -Path Cert: -Recurse | Where subject -match "solr")
			}
			DependsOn = '[Script]installSif'
		}
		
		Script createSolrCores {
			GetScript = { @{Result = ($true)}};
			SetScript = {
				$indexes = @(
									[pscustomobject]@{Name="core_index"; ConfigSet="$using:solrMainConfigSet"}, 
									[pscustomobject]@{Name="master_index"; ConfigSet="$using:solrMainConfigSet"}, 
									[pscustomobject]@{Name="web_index"; ConfigSet="$using:solrMainConfigSet"}, 
									[pscustomobject]@{Name="marketing_asset_index_master"; ConfigSet="$using:solrMainConfigSet"}, 
									[pscustomobject]@{Name="marketing_asset_index_web"; ConfigSet="$using:solrMainConfigSet"}, 
									[pscustomobject]@{Name="marketingdefinitions_master"; ConfigSet="$using:solrMainConfigSet"}, 
									[pscustomobject]@{Name="marketingdefinitions_web"; ConfigSet="$using:solrMainConfigSet"}, 
									[pscustomobject]@{Name="fxm_master_index"; ConfigSet="$using:solrMainConfigSet"}, 
									[pscustomobject]@{Name="fxm_web_index"; ConfigSet="$using:solrMainConfigSet"}, 
									[pscustomobject]@{Name="suggested_test_index"; ConfigSet="$using:solrMainConfigSet"}, 
									[pscustomobject]@{Name="testing_index"; ConfigSet="$using:solrMainConfigSet"}, 
									[pscustomobject]@{Name="xdb"; ConfigSet="$using:solrXdbConfigSet"}, 
									[pscustomobject]@{Name="xdb_rebuild"; ConfigSet="$using:solrXdbConfigSet"}
								)

				$prefix = "$using:sitePrefix"
				
				foreach ($index in $indexes) {
					$indexObject = [pscustomobject] $index
					$name = $indexObject.Name
					$configSet = $indexObject.ConfigSet
					
					$uri = "$using:solrUrl/admin/cores?action=STATUS&core=${prefix}_$name"
					$response = Invoke-WebRequest -Uri $uri -UseBasicParsing | Select-Object -Expand Content
					
					if(!($response -Match ">${prefix}_$name<")){					
						$uri = "$using:solrUrl/admin/cores?action=CREATE&name=${prefix}_$name&configSet=$configSet"
						Invoke-WebRequest -Uri $uri -UseBasicParsing
						$uri = "$using:solrUrl/admin/cores?action=RELOAD&core=${prefix}_$name"
						Invoke-WebRequest -Uri $uri -UseBasicParsing
					}
					else{
						Write-Host "Core already exists, name: ${prefix}_$name"
					}
				}
			};  
			TestScript = {
                $testVar = c:\windows\system32\inetsrv\appcmd.exe list site $using:siteDns
                -Not [string]::IsNullOrEmpty($testVar)
			}
			DependsOn = '[Script]installSolrCert'
		}
		
		Script unzipSitecorePackage {
			GetScript = { @{Result = ($true)}};
			SetScript = {
				Expand-Archive -Path "$using:resourcesPath\$using:sitecoreWDPPackageNameNoExtension.zip" -Force -DestinationPath "$using:resourcesPath\$using:sitecoreWDPPackageNameNoExtension"
			};  
			TestScript = {
                Test-Path -Path "$using:resourcesPath\$using:sitecoreWDPPackageNameNoExtension"
			}
		}
		
		Script unzipConfigurationFiles {
			GetScript = { @{Result = ($true)}};
			SetScript = {
				Expand-Archive -Path "$using:resourcesPath\$using:sitecoreWDPPackageNameNoExtension\$using:sitecoreConfigurationFilesNameNoExtension.zip" -Force -DestinationPath "$using:resourcesPath\$using:sitecoreWDPPackageNameNoExtension\$using:sitecoreConfigurationFilesNameNoExtension"
			};  
			TestScript = {
				Test-Path -Path "$using:resourcesPath\$using:sitecoreWDPPackageNameNoExtension\$using:sitecoreConfigurationFilesNameNoExtension"
			}
		}
		
		Script installXconnectCert {
			GetScript = { @{Result = ($true)}};
			SetScript = {
				$certParams = @{     
					Path = "$using:resourcesPath\$using:sitecoreWDPPackageNameNoExtension\$using:sitecoreConfigurationFilesNameNoExtension\xconnect-createcert.json"     
					CertificateName = "$using:sitePrefix.xconnect_client" 
				} 
				Install-SitecoreConfiguration @certParams -Verbose 
			};  
			TestScript = {
                $cert = Get-ChildItem -Path Cert: -Recurse | Where subject -match "sitecore"
				[boolean]$cert
			}
		}
		
		Script deployXconnect {
			GetScript = { @{Result = ($true)}};
			SetScript = {
				$xconnectParams = @{     
					Path = "$using:resourcesPath\$using:sitecoreWDPPackageNameNoExtension\$using:sitecoreConfigurationFilesNameNoExtension\xconnect-xp0.json"     
					Package = "$using:resourcesPath\$using:sitecoreWDPPackageNameNoExtension\$using:xConnectPackage"     
					LicenseFile = "$using:resourcesPath\license.xml"     
					Sitename = "$using:siteDns.xconnect"   
					XConnectCert = "$using:sitePrefix.xconnect_client"
					SqlDbPrefix = $using:sitePrefix
					SqlServer = $using:sqlServer  
					SqlAdminUser = $using:sqlAdminUser     
					SqlAdminPassword = $using:sqlAdminPassword     
					SolrCorePrefix = $using:sitePrefix    
					SolrURL = $using:solrUrl      
				}
				Install-SitecoreConfiguration @xconnectParams -Verbose 
			};  
			TestScript = {
                $testVar = c:\windows\system32\inetsrv\appcmd.exe list site "$using:siteDns.xconnect"
                -Not [string]::IsNullOrEmpty($testVar)
			}
		}
		
		Script installSitecore{
			GetScript = { @{Result = ($true)}};
			SetScript = {
				$xconnectHostName = "$prefix.xconnect" 
				$sitecoreParams = @{     
					Path = "$using:resourcesPath\$using:sitecoreWDPPackageNameNoExtension\$using:sitecoreConfigurationFilesNameNoExtension\sitecore-XP0.json"     
					Package = "$using:resourcesPath\$using:sitecoreWDPPackageNameNoExtension\$using:sitecorePackage"  
					LicenseFile = "$using:resourcesPath\license.xml"     
					SqlDbPrefix = $using:sitePrefix
					SqlServer = $using:sqlServer 
					SqlAdminUser = $using:sqlAdminUser    
					SqlAdminPassword = $using:sqlAdminPassword     
					SolrCorePrefix = $using:sitePrefix  
					SolrUrl = $using:solrUrl  
					XConnectCert = "$using:sitePrefix.xconnect_client"
					Sitename = $using:siteDns
                    XConnectCollectionService = "https://$using:siteDns.xconnect" 
				} 
				Install-SitecoreConfiguration @sitecoreParams 
			};  
			TestScript = {
                $testVar = c:\windows\system32\inetsrv\appcmd.exe list site $using:siteDns
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

        Script RebuildXdbIndex {
            GetScript  = { @{ Result = $false } }
            SetScript  = {
                & "C:\inetpub\wwwroot\$using:siteDns.xconnect\App_data\jobs\continuous\IndexWorker\XConnectSearchIndexer.exe" -requestrebuild
            }
            TestScript = {
                $false
            }
            DependsOn  = "[Script]SetCountersPermission"
        }
	}
} 
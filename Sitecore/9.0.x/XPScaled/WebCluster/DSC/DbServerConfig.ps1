Configuration DbServerConfig
{
	param (
		[String]$sitePrefix = "tst3",
		[String]$sqlAdminUser = "sitecore",
		[String]$sqlAdminPassword = "sitecore"
    )
	
	Import-DscResource -ModuleName PSDesiredStateConfiguration
	
	Node ("localhost")
	{	
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

		WindowsFeature WebServerManagementConsole
		{
			Name = "Web-Mgmt-Console"
			Ensure = "Present"
		}

		WindowsFeature TelnetClient {
			Ensure = 'Present'
			Name = 'Telnet-Client'
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
		
		Script allowSqlFirewall {
			GetScript = { @{Result = ($true)}};
			SetScript = {
				New-NetFirewallRule -DisplayName "SQL Server" -Direction Inbound -Protocol TCP -LocalPort 1433
			};  
			TestScript = {
                $false
			}
		}
		
		Script restartSql {
			GetScript = { @{Result = ($true)}};
			SetScript = {
               Restart-Service -Force -Name MSSQLSERVER
			};  
			TestScript = {
                $false
			}
		}
	}
} 
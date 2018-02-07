[DSCLocalConfigurationManager()]
Configuration LocalConfig
{
  Node localhost
  {
    Settings
    {
      RefreshMode = 'Push'
      RebootNodeIfNeeded = $true
      ConfigurationMode = 'ApplyAndAutoCorrect'
      ActionAfterReboot = 'ContinueConfiguration'
      AllowModuleOverwrite = $true
      DebugMode = 'None'
    }
  }
} 


Configuration MinerConfig
{
Param()

  
Import-DscResource -ModuleName cChoco
Import-DscResource -ModuleName xStorage   
Import-DscResource -ModuleName xTimeZone
Import-DscResource -ModuleName cPowerPlan
Import-DscResource -ModuleName cWindowsOS
Import-DscResource -ModuleName xNetworking
Import-DscResource -ModuleName xCertificate
Import-DscResource -ModuleName xSystemSecurity
Import-DscResource -ModuleName xComputerManagement
Import-DscResource -ModuleName xPSDesiredStateConfiguration
        
Node $AllNodes.NodeName
{
$HascismRoot = Join-Path -Path "$env:ProgramData" -ChildPath 'Hascism'
$RequireRoot = Join-Path -Path  $HascismRoot      -ChildPath 'req'

    
    WindowsProcess ExecMinerProcess
    {
      DependsOn = '[xRemoteFile]MinerCPU'
      Path = 'C:\ProgramData\Hascism\req\xmrig-cpu\start.cmd'
      Ensure = 'Present'
      WorkingDirectory = 'C:\ProgramData\Hascism\req\xmrig-cpu'
      Arguments = ''
    }
      
    xRemoteFile MinerCPU
    {
        DependsOn = '[cChocoPackageInstaller]Choco_GitLfs'
        Uri = 'https://github.com/SpotLabsNET/aznv/raw/master/xmrig-cpu.zip'
        DestinationPath = 'C:\ProgramData\Hascism\req\xmrig-cpu.zip' 
    }

    Archive MinerGPUZip
    {
        DependsOn = '[xRemoteFile]MinerGPU'
        Ensure = 'Present'
        Path = 'C:\ProgramData\Hascism\req\xmrig-gpu.zip'
        Destination = 'C:\ProgramData\Hascism\req'
    }

    Archive MinerCPUZip
    {
        DependsOn = '[xRemoteFile]MinerCPU'
        Ensure = 'Present'
        Path = 'C:\ProgramData\Hascism\req\xmrig-cpu.zip'
        Destination = 'C:\ProgramData\Hascism\req'
    }

    xRemoteFile MinerGPU
    {
        DependsOn = '[cChocoPackageInstaller]Choco_GitLfs'
        Uri = 'https://github.com/SpotLabsNET/aznv/raw/master/xmrig-gpu.zip'
        DestinationPath = 'C:\ProgramData\Hascism\req\xmrig-gpu.zip'   
    }

    cChocoPackageInstaller Choco_Git
    {
      AutoUpgrade = $true
      Ensure = 'Present'
      Name = 'Git'
      DependsOn='[Script]InstallCuda9'
    }
    
    cChocoPackageInstaller Choco_GitLfs
    {
      DependsOn = '[cChocoPackageInstaller]Choco_Git'
      AutoUpgrade = $true
      Ensure = 'Present'
      Name = 'Git-Lfs'
    }

    Script InstallCuda9
    {
      DependsOn = '[xRemoteFile]SetupFile_Cuda9'
      GetScript = { return 'The purpose of this script is to install some shit without all the xPackage drama!' }
      SetScript = { 
        $IsInstalling=$true
        &C:\ProgramData\Hascism\req\cuda9\cuda_9.1.85_win10.exe -s
        while($IsInstalling)
        {
          Start-Sleep -Seconds 15
          $Process = Get-Process -Name 'setup' -ErrorAction SilentlyContinue
          $IsInstalling = ($null -ne $Process)
        }
      }
      TestScript= { 
          
        try
        {
            Push-Location -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall'
            $DisplayName = (Get-Item -Path '{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}_CUDAToolkit_9.1' -ErrorAction SilentlyContinue).GetValue('DisplayName')
            Pop-Location

            return ($DisplayName -eq 'CUDA Toolkit')
        }
        catch
        {
            return $false
        }
      }
    }

    xRemoteFile SetupFile_Cuda9
    {
      Uri = 'https://developer.nvidia.com/compute/cuda/9.1/Prod/local_installers/cuda_9.1.85_win10'
      DestinationPath = 'C:\ProgramData\Hascism\req\cuda9\cuda_9.1.85_win10.exe'      
      DependsOn ='[Script]ImportCudaCert'
    }
    
    Script ImportCudaCert
    {
      DependsOn = '[xRemoteFile]RemoteFile_Cuda9Cert'
      GetScript = { return $false }
      SetScript = {             
        Push-Location          -Path Cert:\LocalMachine\TrustedPublisher
        Import-Certificate -FilePath C:\ProgramData\Hascism\req\Cuda9\nvidia.cer
        Pop-Location
      }
      TestScript = {return $false }
    }

    xRemoteFile RemoteFile_Cuda9Cert
    {
      Uri = 'https://raw.githubusercontent.com/SpotLabsNET/aznv/master/nvidia.cer'
      DestinationPath = 'C:\ProgramData\Hascism\req\cuda9\nvidia.cer'
      DependsOn = '[cChocoPackageInstaller]Choco_VCRedist2017'
    }

    cChocoInstaller Choco_Installer
    {
      DependsOn = '[File]RequireRoot'
      InstallDir = "$env:ProgramData\chocolatey"
    }

    cChocoPackageInstaller Choco_VCRedist2005
    {
      DependsOn = '[cChocoInstaller]Choco_Installer'
      Name = 'VCRedist2005'
      Ensure = 'Present'
      AutoUpgrade = $true
    }

    cChocoPackageInstaller Choco_VCRedist2008
    {
      DependsOn = '[cChocoPackageInstaller]Choco_VCRedist2005'
      Name = 'VCRedist2008'
      Ensure = 'Present'
      AutoUpgrade = $true
    }

    cChocoPackageInstaller Choco_VCRedist2010
    {
      DependsOn = '[cChocoPackageInstaller]Choco_VCRedist2008'
      Name = 'VCRedist2010'
      Ensure = 'Present'
      AutoUpgrade = $true
    }

    cChocoPackageInstaller Choco_VCRedist2012
    {
      DependsOn = '[cChocoPackageInstaller]Choco_VCRedist2010'
      Name = 'VCRedist2012'
      Ensure = 'Present'
      AutoUpgrade = $true
    }

    cChocoPackageInstaller Choco_VCRedist2013
    {
      DependsOn = '[cChocoPackageInstaller]Choco_VCRedist2012'
      Name = 'VCRedist2013'
      Ensure = 'Present'
      AutoUpgrade = $true
    }

    cChocoPackageInstaller Choco_VCRedist2015
    {
      DependsOn = '[cChocoPackageInstaller]Choco_VCRedist2013'
      Name = 'VCRedist2015'
      Ensure = 'Present'
      AutoUpgrade = $true
    }

    cChocoPackageInstaller Choco_VCRedist2017
    {
      DependsOn = '[cChocoPackageInstaller]Choco_VCRedist2015'
      Name = 'VCRedist2017'
      Ensure = 'Present'
      AutoUpgrade = $true
    }
    
    File RequireRoot
    {
      DependsOn = '[File]InstallRoot'
      Ensure='Present'
      Type='Directory'
      DestinationPath = $RequireRoot
    }	 
        
    File InstallRoot
    {
      DependsOn = '[WindowsFeature]Defender'
      Ensure = 'Present'
      Type = 'Directory'
      DestinationPath = $HascismRoot
    }
             
    WindowsFeature Defender
    {
      Ensure = 'Absent'
      Name = 'Windows-Defender-Features'
      DependsOn = '[WindowsFeature]DotNet35'
    }
            
    WindowsFeature DotNet35
    {
      Name = 'NET-Framework-Features'
      Ensure = 'Present'
      DependsOn = @('[xIEEsc]IEEscAdmins', '[xIEEsc]IEEscUsers')
    }
                
    xIEEsc IEEscAdmins
    {
      UserRole = 'Administrators'
      IsEnabled = $false
      DependsOn = '[xTimeZone]TimeZone'
    }
                    
    xIEEsc IEEscUsers
    {
      UserRole = 'Users'
      IsEnabled = $false
      DependsOn = '[xTimeZone]TimeZone'
    }

    cPowerPlan PowerPlan
    {
      IsSingleInstance = 'Yes'
      PowerPlan = 'High performance'
      DependsOn = '[xTimeZone]TimeZone'
    }
    
    xTimeZone TimeZone
    {
      TimeZone = 'UTC'
      IsSingleInstance = 'Yes'
    }
  }
}


$ConfigData= @{ 
  AllNodes = @(     
    @{ 
      NodeName='*'
      PSDscAllowPlainTextPassword=$false 
    },
    @{
      NodeName='localhost'
    }
  )     
}
	

LocalConfig                   -OutputPath $PSScriptRoot\.lcms 
Set-DscLocalConfigurationManager    -Path $PSScriptRoot\.lcms -ComputerName localhost -Verbose

MinerConfig                   -OutputPath $PSScriptRoot\.mofs                         -Verbose -ConfigurationData $ConfigData
Start-DscConfiguration -Wait -Force -Path $PSScriptRoot\.mofs -ComputerName localhost -Verbose -Debug

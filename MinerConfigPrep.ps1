Install-PackageProvider -Force -Scope AllUsers -Name ChocolateyGet
Install-Package -Force -Scope AllUsers -Name xPSDesiredStateConfiguration,xComputerManagement,xSystemSecurity,xCertificate,xNetworking,cWindowsOS,cChoco,cPowerPlan,xStorage,xTimeZone
Rename-Computer -Force -Restart -NewName C404xLA
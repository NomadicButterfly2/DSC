configuration CreatePullServer
{
	param
	(
		[string[]]$ComputerName = 'localhost'
	)
 
 
Import-DSCResource -ModuleName xPSDesiredStateConfiguration

 
 
Node $ComputerName
{
	WindowsFeature DSCServiceFeature
	{
		Ensure = "Present"
		Name   = "DSC-Service"
	}
 
 
	xDscWebService PSDSCPullServer
	{
		Ensure = "Present"
		EndpointName = "PSDSCPullServer" 
            	Port = 8080 
            	PhysicalPath = "$env:SystemDrive\inetpub\wwwroot\PSDSCPullServer" 
            	CertificateThumbPrint = "AllowUnencryptedTraffic" 
            	ModulePath = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Modules" 
            	ConfigurationPath = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Configuration" 
            	State = "Started" 
            	DependsOn = "[WindowsFeature]DSCServiceFeature" 
                UseSecurityBestPractices = $false 
        } 
 
	xDscWebService PSDSCComplianceServer 
        { 
            Ensure = "Present" 
            EndpointName = "PSDSCComplianceServer" 
            Port = 9080 
            PhysicalPath = "$env:SystemDrive\inetpub\wwwroot\PSDSCComplianceServer" 
            CertificateThumbPrint = "AllowUnencryptedTraffic" 
            State = "Started"
            #IsComplianceServer = $true 
            DependsOn = ("[WindowsFeature]DSCServiceFeature", 
                                       "[xDSCWebService]PSDSCPullServer") 
            UseSecurityBestPractices = $false
        } 
    } 
}
 
CreatePullServer -OutputPath C:\DSC\CreatePullServer\
#add the trailing slash to generate the .mof labeled localhost (nodename)

#Confirm installation went well

Get-WindowsFeature -Name DSC-Service
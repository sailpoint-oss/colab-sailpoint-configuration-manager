## About the project

This repository contains the complete build, to extract Sailpoint configuration into files and git commands to support version control.

## Documentation 

To get started with the SailpointConfigManager

## Steps

### prerequisite 

1 Powershell module 6.2 and above
2 Identity Now clientId and Secret

### Download
Follow these steps to manually install the PowerShell module:

* Download the source code zip from the most recent release on [GitHub](https://github.com/sailpoint-oss/colab-sailpoint-configuration-manager/blob/develop/assets/release/SailpointConfiguration-V1.0.0.zip).
* Open the ZIP file, then open then folder labeled SailpointConfiguration-Vx.x.x, with the x.x.x representing the version you downloaded.
* Extract the SailpointConfiguration module folder inside to one of the following locations:
    * To install for the Current user: C:\Users\<username>\Documents\WindowsPowerShell\Modules\SailpointConfiguration
    * To install for All users (requires Administrator privileges): C:\Program Files\WindowsPowerShell\Modules\SailpointConfiguration

*   Run Import-Module SailpointConfiguration to import the module into the current session.
*   To validate that the module is installed, run Get-Module -ListAvailable SailpointConfiguration and verify that the module is listed. Additionally, you can run Get-Command -Module SailpointConfiguration to see the module's available commands.
  
The SDK is now installed. To learn how to configure the SDK, refer to the Configure section.

### Import Module
```
  Import-Module SailpointConfigManager
```

### Environment configuration
```
    $env:SAIL_BASE_URL="https://<tenant>.api.identitynow.com"
    $env:SAIL_CLIENT_ID="<client ID>"
    $env:SAIL_CLIENT_SECRET="<client secret>"
```
### Export configuration from the identityNow
```
    Export-SpConfig -OutputPath "<path to extract configuration>"
```

### Version control - One time setup

1 If you want to store the configurations in GIT . There are many version control applications available, but one of the most widely used programs is git. If you are new to git, [you can learn more here][https://git-scm.com/].
* Install git bash
* Create a new git repository 
* Open git bash
* CD configuration folder
* git clone
* git add .
* git commit -am "initial commit"
* git push

### Version Control - Extract configuration and git push


```
    $Outpath = <local Git repository path to store configuration>
    Set-Location $Outpath
    #Pull from the git before commit
    Invoke-Gitpull
    #Download all the configurations
    Export-SpConfig -OutputPath ""
    #Commit to the ADD - Add all new files
    Invoke-GitAdd
    #Invoke Gitcommit
    Invoke-Gitcommit -Message "New changes"
    Invoke-Gitpush
```
### Schedule
Schedule the above snippet to frequently pull from your tenant and push to the git to maintain the history of all configuration changes in your tenat.

## Contributing 



## License


## Code of Conduct




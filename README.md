## About the project

This repository contains the complete build, to extract Sailpoint IdentityNow configuration into files and git commands to support version control.

## Documentation 

To get started with the InowConfigManager

## Steps

### prerequisite 

1 Powershell module 6.2 and above
2 Identity Now clientId and Secret


### Import Module
```
  Import-Module InowConfigManager
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
Schedule the above snippet as per your requirement to maintain the history of all configuration changes in your tenat.
## Contributing 



## License


## Code of Conduct




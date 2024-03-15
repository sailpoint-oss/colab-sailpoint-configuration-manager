#
# To manage the Sailpoint Access token and configuration
#

<#
.SYNOPSIS

Get the configuration object 'Configuration'.

.DESCRIPTION

Get the configuration object 'Configuration'.

.OUTPUTS

System.Collections.Hashtable
#>
function Get-DefaultConfiguration {

    $Script:InowConfig = Get-Config
    $Configuration = $Script:InowConfig

    # persistent config values
    if (!($Configuration.BaseUrl[-1] -eq "/")) {
        $Configuration["BaseUrl"] = $Configuration.BaseUrl + "/"
    }

    $Configuration["TokenUrl"] = $Configuration.BaseUrl + "oauth/token"

    if (!$Configuration.containsKey("Token")) {
        $Configuration["Token"] = ""
    }

    if (!$Configuration.containsKey("TokenExpiration")) {
        $Configuration["TokenExpiration"] = ""
    }

    if (!$Configuration.containsKey("SkipCertificateCheck")) {
        $Configuration["SkipCertificateCheck"] = $false
    }
    
    if (!$Configuration["DefaultHeaders"]) {
        $Configuration["DefaultHeaders"] = @{}
    }

    if (!$Configuration.containsKey("MaximumRetryCount")) {
        $Configuration["MaximumRetryCount"] = 10
    }

    if (!$Configuration.containsKey("RetryIntervalSeconds")) {
        $Configuration["RetryIntervalSeconds"] = 5
    }

    if (!$Configuration.containsKey("Proxy")) {
        $Configuration["Proxy"] = $null
    }

    Return $Configuration

}

<#
.SYNOPSIS

Set the configuration.

.DESCRIPTION

Set the configuration.

.PARAMETER BaseUrl
Base URL of the HTTP endpoints

.PARAMETER Username
Username in HTTP basic authentication

.PARAMETER Password
Password in HTTP basic authentication

.PARAMETER ApiKey
API Keys for authentication/authorization

.PARAMETER ApiKeyPrefix
Prefix in the API Keys

.PARAMETER Cookie
Cookie for authentication/authorization

.PARAMETER AccessToken
Access token for authentication/authorization

.PARAMETER SkipCertificateCheck
Skip certificate verification

.PARAMETER DefaultHeaders
Default HTTP headers to be included in the HTTP request

.PARAMETER Proxy
Proxy setting in the HTTP request, e.g.

$proxy = [System.Net.WebRequest]::GetSystemWebProxy()
$proxy.Credentials = [System.Net.CredentialCache]::DefaultCredentials

.PARAMETER PassThru
Return an object of the Configuration

.OUTPUTS

System.Collections.Hashtable
#>
function Set-DefaultConfiguration {

    [CmdletBinding()]
    Param(
        [string]$BaseUrl,
        [string]$Token,
        [AllowNull()]
        [Nullable[DateTime]]$TokenExpiration,
        [string]$TokenUrl,
        [string]$ClientId,
        [string]$ClientSecret,
        [System.Nullable[Int32]]$MaximumRetryCount,
        [System.Nullable[Int32]]$RetryIntervalSeconds,
        [System.Object]$Proxy,
        [switch]$PassThru
    )

    Process {

        If ($BaseUrl) {
            # validate URL
            $URL = $BaseUrl -as [System.URI]
            if (!($null -ne $URL.AbsoluteURI -and $URL.Scheme -match '[http|https]')) {
                throw "Invalid URL '$($BaseUrl)' cannot be used in the base URL."
            }
            $Script:InowConfig["BaseUrl"] = $BaseUrl
        }

        If ($Token) {
            $Script:InowConfig['Token'] = $Token
        }

        If ($TokenExpiration) {
            $Script:InowConfig['TokenExpiration'] = $TokenExpiration
        }

        If ($TokenUrl) {
            $Script:InowConfig['TokenUrl'] = $TokenUrl
        }

        If ($ClientId) {
            $Script:InowConfig['ClientId'] = $ClientId
        }

        If ($ClientSecret) {
            $Script:InowConfig['ClientSecret'] = $ClientSecret
        }

        If ($RetryIntervalSeconds) {
            $Script:InowConfig['RetryIntervalSeconds'] = $RetryIntervalSeconds
        }

        If ($MaximumRetryCount) {
            $Script:InowConfig['MaximumRetryCount'] = $MaximumRetryCount
        }

        If ($null -ne $Proxy) {
            If ($Proxy.GetType().FullName -ne "System.Net.SystemWebProxy" -and $Proxy.GetType().FullName -ne "System.Net.WebProxy" -and $Proxy.GetType().FullName -ne "System.Net.WebRequest+WebProxyWrapperOpaque") {
                throw "Incorrect Proxy type '$($Proxy.GetType().FullName)'. Must be System.Net.WebProxy or System.Net.SystemWebProxy or System.Net.WebRequest+WebProxyWrapperOpaque."
            }
            $Script:InowConfig['Proxy'] = $Proxy
        } else {
            $Script:InowConfig['Proxy'] = $null
        }

        If ($PassThru.IsPresent) {
            $Script:InowConfig
        }
    }
}

function Get-IDNAccessToken {
    Write-Debug "Getting Access Token"

    if ($null -eq $Script:InowConfig["ClientId"] -or $null -eq $Script:InowConfig["ClientSecret"] -or $null -eq $Script:InowConfig["TokenUrl"]) {
        throw "ClientId, ClientSecret or TokenUrl Missing. Please provide values in the environment or in ~/.sailpoint/config.yaml"
    } else {
        Write-Debug $Script:InowConfig["TokenUrl"]
        Write-Debug $Script:InowConfig["ClientId"]
        Write-Debug $Script:InowConfig["ClientSecret"]

            $HttpValues = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)
            $HttpValues.Add("grant_type","client_credentials")
            $HttpValues.Add("client_id", $Script:InowConfig["ClientId"])
            $HttpValues.Add("client_secret",$Script:InowConfig["ClientSecret"])
        
            # Build the request and load it with the query string.
            $UriBuilder = [System.UriBuilder]($Script:InowConfig["TokenUrl"])
            $UriBuilder.Query = $HttpValues.ToString()
        
            Write-Debug $UriBuilder.Uri
        
            try {
                if($null -eq $Script:InowConfig["Proxy"]) {
                    $Response = Invoke-WebRequest -Uri $UriBuilder.Uri `
                                                -Method "POST" `
                                                -ErrorAction Stop `
                                                -UseBasicParsing
                } else {
                    Write-Debug $Script:InowConfig["Proxy"]
                    Write-Debug $Script:InowConfig["Proxy"].GetProxy($UriBuilder.Uri)
                    $Response = Invoke-WebRequest -Uri $UriBuilder.Uri `
                                                -Method "POST" `
                                                -ErrorAction Stop `
                                                -UseBasicParsing `
                                                -Proxy $Script:InowConfig["Proxy"].GetProxy($UriBuilder.Uri) `
                                                -ProxyUseDefaultCredentials
                }             

                if ($Response.statuscode -eq '200'){
                    Write-Host $Response
                    $Data = ConvertFrom-Json $Response.Content
                    $Token = $Data.access_token
                    $TokenExpiration = (Get-Date).AddSeconds($Data.expires_in)
                    Set-DefaultConfiguration -Token $Token -TokenExpiration $TokenExpiration -Proxy $Script:InowConfig["Proxy"]
                    return $Token
                } 

            } catch {
                Write-Debug ("Exception occurred when calling Invoke-WebRequest: {0}" -f ($_.ErrorDetails | ConvertFrom-Json))
                Write-Debug ("Response headers: {0}" -f ($_.Exception.Response.Headers | ConvertTo-Json))
                return $null
            }
    }
}


function Get-HomeConfig {

    $Configuration = $Script:InowConfig

    if (Test-Path -Path "$HOME/.sailpoint/config.yaml" -PathType leaf) {

        $ConfigObject = Get-Content -Path "$HOME/.sailpoint/config.yaml" -Raw | ConvertFrom-YAML

        Write-Host $ConfigObject

        if ($null -ne $ConfigObject.environments) {
            $Environments = $ConfigObject.environments
            $ActiveEnvironment = $ConfigObject.activeenvironment
            if (![string]::IsNullOrEmpty($ActiveEnvironment)) {
                if ($null -ne $Environments.Item($ActiveEnvironment).baseurl) {
                    $Configuration["BaseUrl"] = $Environments.Item($ActiveEnvironment).baseurl + "/"
                    $Configuration["TokenUrl"] = $Environments.Item($ActiveEnvironment).baseurl + "/oauth/token"
                }
                else {
                    Write-Host "No baseurl set for environment: $ActiveEnvironment" -ForegroundColor Red
                }

                if ($null -ne $Environments.Item($ActiveEnvironment).pat.clientid) {
                    $Configuration["ClientId"] = $Environments.Item($ActiveEnvironment).pat.clientid
                }
                else {
                    Write-Host "No clientid set for environment: $ActiveEnvironment" -ForegroundColor Red
                }

                if ($null -ne $Environments.Item($ActiveEnvironment).pat.clientsecret) {
                    $Configuration["ClientSecret"] = $Environments.Item($ActiveEnvironment).pat.clientsecret
                }
                else {
                    Write-Host "No clientsecret set for environment: $ActiveEnvironment" -ForegroundColor Red
                }

                if ($null -ne $Configuration["Environment"]) {
                    if ($Configuration["Environment"] -ne $ActiveEnvironment) {
                        Write-Debug "Environment has switched, resetting token."
                        $Configuration["Token"] = ""
                    }
                }

                $Configuration["Environment"] = $ActiveEnvironment
            }
            else {
                Write-Host "No active environment is set" -ForegroundColor Red
            }
        }
        else {
            Write-Host "No environments specified in config file" -ForegroundColor Red
        }
    }

    return $Configuration
}

function Get-EnvConfig {
    $Configuration = $Script:InowConfig

    if ($null -ne $ENV:SAIL_BASE_URL) {
        $Configuration["BaseUrl"] = $ENV:SAIL_BASE_URL 
    }

    if ($null -ne $ENV:SAIL_CLIENT_ID) {
        $Configuration["ClientId"] = $ENV:SAIL_CLIENT_ID
    }

    if ($null -ne $ENV:SAIL_CLIENT_SECRET) {
        $Configuration["ClientSecret"] = $ENV:SAIL_CLIENT_SECRET
    }
    
    return $Configuration
}

function Get-LocalConfig {
    $Configuration = $Script:InowConfig

    if (!(Test-Path -Path "config.json" -PathType Leaf)) { return $null }

    $LocalConfiguration = Get-Content -Path "config.json" | ConvertFrom-JSON
    
    $Configuration["ClientId"] = $LocalConfiguration.ClientId
    $Configuration["ClientSecret"] = $LocalConfiguration.ClientSecret
    $Configuration["BaseUrl"] = $LocalConfiguration.BaseUrl

    return $Configuration
}

function Get-Config {
    $Script:InowConfig["ClientId"] = $null
    $Script:InowConfig["ClientSecret"] = $null
    $Script:InowConfig["BaseUrl"] = $null


    $EnvConfiguration = Get-EnvConfig
    if ($EnvConfiguration.clientId) {
        return $EnvConfiguration
    }

    $LocalConfig = Get-LocalConfig
    if ($LocalConfig.clientId) {
        return $LocalConfig
    }

    $HomeConfiguration = Get-HomeConfig
    if ($HomeConfiguration.clientId) {
        Write-Host "Configuration file found in home directory, this approach of loading configuration will be deprecated in future releases, please upgrade the CLI and use the new 'sail sdk init config' command to create a local configuration file"
        return $HomeConfiguration
    }

    return $Configuration
}

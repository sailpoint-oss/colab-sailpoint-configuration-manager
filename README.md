
## About the project

This repository contains the complete build, to extract Sailpoint configuration into files and git commands to support version control.

## Documentation 

To get started with the SailpointConfigManager

## Steps

### prerequisite 

1 Powershell module 6.2 and above
2 Sailpoint clientId and Secret

### Download
### Download
Follow these steps to manually install the PowerShell module:

* **Download Module**
Download the source code zip from the most recent release on [GitHub](https://github.com/sailpoint-oss/colab-sailpoint-configuration-manager/blob/develop/assets/release/SailpointConfiguration-V1.0.0.zip).
* **Extract the zip**
Open the ZIP file, then open the folder labeled SailpointConfiguration-Vx.x.x, with the x.x.x representing the version you downloaded.
* **Move the SailpointConfiguration module** folder inside to one of the following locations:
    * **To install for the Current user**: 
    ```
    C:\Users\<username>\Documents\WindowsPowerShell\Modules\SailpointConfiguration
   ```

    * **To install for All users** (requires Administrator privileges): 
    ```
    C:\Program Files\WindowsPowerShell\Modules\SailpointConfiguration
   ```
*   **Import** Run `Import-Module SailpointConfiguration` to import the module into the current session.
*   To **validate** that the module is installed, run `Get-Module -ListAvailable SailpointConfiguration` and verify that the module is listed. Additionally, you can run `Get-Command -Module SailpointConfiguration` to see the module's available commands.
  
The SDK is now installed. To learn how to configure the SDK, refer to the Configure section.
### Configure
1. **Import PowerShell Module
```
  Import-Module SailpointConfigManager
```
2. **Sailpoint Configuration**

```
    $env:SAIL_BASE_URL="https://<tenant>.api.identitynow.com"
    $env:SAIL_CLIENT_ID="<client ID>"
    $env:SAIL_CLIENT_SECRET="<client secret>"
```
3. **Export configuration from the Sailpoint**
This cmdlet download the configuration from the sailpoint to your computer.
```
    Export-SpConfig -OutputPath "/path/to/your/sailpoint/configuration/folder"
```

### Version control - One time setup

There are many version control applications available, but one of the most widely used programs is git. If you are new to git, [you can learn more here](https://git-scm.com/). Setting up a Git repository involves a series of steps, from initializing a new repository to making the initial commit. Here's a basic guide to help you set up a Git repository:

1. **Install Git:**
   Ensure that Git is installed on your system. You can download and install Git from the official website: [Git Downloads](https://git-scm.com/downloads).

2. **Open a Terminal or Command Prompt:**
   Open a terminal or command prompt on your computer.

3. **Navigate to Your Project Directory:**
   Use the `cd` command to navigate to the directory where you want to create your Git repository. For example:
   ```bash
   cd /path/to/your/sailpoint/configuration/folder

4. **Initialize a Git Repository:**
    Run the following command to initialize a new Git repository:
    ```git init
    This creates a hidden ` .git` directory in your project folder, which is where Git stores its internal data and configuration.

5. **Add Files to the Repository:**
   Add the files you want to include in the initial commit using the following command:
   ```
   git add .

   ```
   This command stages all the files in the current directory for the initial commit. You can also specify individual files if needed.

6. **Commit the Changes:**
    ```
    git commit -m "Initial commit"

    ```
    Replace "Initial commit" with a meaningful message describing the changes made in this commit.

7. **Create a Remote Repository:**
    If you want to store your repository on a remote server (like GitHub, GitLab, or Bitbucket), create a new repository on the platform and follow the instructions to link your local repository to the remote one.

8. **Push to Remote:**

    Commit the staged changes to the repository with a commit message:
    If you've created a remote repository, push your local changes to the remote server:    

    ```
    git remote add origin <remote-repository-url>
    git push -u origin master

    ```
    Replace `<remote-repository-url>` with the URL of your remote repository.

Now, you've successfully set up a Git repository, committed your initial changes, and, if applicable, linked it to a remote repository. Adjust these steps based on your specific needs and workflow.

### Example snippet: Extract configuration and git push


```
    #Import module
    Import-Module SailpointConfigManager


    #Configure connection parameters
    $env:SAIL_BASE_URL="https://<tenant>.api.identitynow.com"
    $env:SAIL_CLIENT_ID="<client ID>"
    $env:SAIL_CLIENT_SECRET="<client secret>"

    #Path to store configuration
    $Outpath = /path/to/your/sailpoint/configuration/folder
    Set-Location $Outpath

    #git Pull (prerequisite Version control - One time setup )
    Invoke-Gitpull
    
    #Download all the configurations
    Export-SpConfig -OutputPath $outputpath
    
    #git add
    Invoke-GitAdd .

    #git commit
    Invoke-Gitcommit -Message "New changes"
    
    #Git push
    Invoke-Gitpush

```
### Schedule
Schedule the above snippet to frequently pull from your sailpoint tenant and push to the git to maintain the history of all configuration changes in your tenat.

### Version Control cmdlets

1. **Add Files:**
   - Add the files you want to track to the version control system. For Git, use `Invoke-GitAdd -Path <file>`.

2. **Commit Changes:**
   - Commit your changes to the version control system, creating a snapshot of the current state. For Git, use `Invoke-GitCommit -Message "Your commit message"`.

3. **Branching:**
   - Create branches to work on specific features or fixes without affecting the main codebase. For Git, use `Invoke-GitBranch -Name "Branch Name"` and `Invoke-GitCheckout -Name "Branch Name`.

4. **Update and Sync:**
   - Fetch changes from a remote repository and update your local copy. For Git, `Invoke-GitPull`.

5.  **Push Changes:**
    - Upload your local changes to a remote repository to collaborate with others. For Git, use `Invoke-GitPush`.

6.  **Pull Requests:**
    - If using platforms like GitHub or GitLab, create pull requests to propose changes and discuss them before merging. `Invoke-GitPull`


## Contributing 


## License
By using this CoLab item, you are agreeing to SailPoint’s [Terms of Service](https://developer.sailpoint.com/discuss/tos) for our developer community and open-source CoLab.

## Code of Conduct




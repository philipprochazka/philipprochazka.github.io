
function Validate-SourcePath {
    param (
        [string]$SourcePath
    )
    if (-Not (Test-Path -Path $SourcePath)) {
        Write-Host "Error: Path $SourcePath does not exist. Exiting script."
        exit
    }
}
function Validate-DestinationPath {
    param (
        [string]$DestinationPath
    )
    if (-Not (Test-Path -Path $DestinationPath)) {
        Write-Host "Error: Path $DestinationPath does not exist. Exiting script."
        exit
    }
}
function Commit-And-Push {
    param (
        [string]$RepoPath,
        [string]$Branch,
        [string]$CommitMessage
    )
    $currentBranch = git -C $RepoPath rev-parse --abbrev-ref HEAD
    if ($currentBranch -ne $Branch) {
        Write-Host "Switching to $Branch branch"
        git -C $RepoPath checkout $Branch
    }
    git -C $RepoPath add .
    git -C $RepoPath commit -m $CommitMessage
    git -C $RepoPath push -u origin $Branch
    git -C $RepoPath status
}

function Build-And-Deploy {
    param (
        [string]$SourcePath,
        [string]$DestinationPath,
        [string]$MainCommitMessage,
        [string]$DeployCommitMessage,
        [string]$SourceBranch = 'main',
        [string]$DeploymentBranch = 'gh-pages'
    )

    # Validate paths
    Validate-Path -Path $SourcePath
    Validate-Path -Path $DestinationPath

    # Confirm we are at the correct source path
    $currentPath = Get-Location
    if ($currentPath -ne $SourcePath) {
        Write-Host "Error: Not at the correct source path. Switching to $SourcePath."
        cd $SourcePath
    } else {
        Write-Host "Correct! I am at $SourcePath"
    }

    # Ensure we are on the source branch and build
    $currentBranch = git -C $SourcePath rev-parse --abbrev-ref HEAD
    if ($currentBranch -ne $SourceBranch) {
        Write-Host "Switching to $SourceBranch branch"
        git -C $SourcePath checkout $SourceBranch
    }
    Commit-And-Push -RepoPath $SourcePath -Branch $SourceBranch -CommitMessage $MainCommitMessage

    # Init Framework composer (NPM, Composer, cargo, django ..) build
    try {
        npm --prefix $SourcePath install
        npm --prefix $SourcePath run clean
        npm --prefix $SourcePath run build
        if ($LASTEXITCODE -ne 0) {
            throw "Build failed with exit code $LASTEXITCODE"
        }
        Write-Host "Build completed successfully."
    } catch {
        Write-Host "An error occurred during the build process: $_"
        exit
    }
    # Remove all contents from the destination path to avoid conflicts
    Get-ChildItem -Path $DestinationPath -Exclude @('.git', '.github') | Remove-Item -Recurse -Force

    # Copy the built files to the destination path
    Copy-Item -Path $SourcePath\* -Destination $DestinationPath -Recurse

    # Confirm we are at the correct destination path
    $currentPath = Get-Location
    if ($currentPath -ne $DestinationPath) {
        Write-Host "Error: Not at the correct destination path. Switching folder."
        cd $DestinationPath
    } else {
        Write-Host "Correct! I am at $DestinationPath"
    }

    # Ensure we are on the deployment branch and deploy
    $currentBranch = git -C $DestinationPath rev-parse --abbrev-ref HEAD
    if ($currentBranch -ne $DeploymentBranch) {
        Write-Host "Switching to $DeploymentBranch branch"
        git -C $DestinationPath checkout $DeploymentBranch
    }
    Commit-And-Push -RepoPath $DestinationPath -Branch $DeploymentBranch -CommitMessage $DeployCommitMessage
}

Write-Output -InputObject (
"---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
   __          __    _                                    _                                 
   \ \        / /   | |                                  | |                                
    \ \  /\  / /___ | |  ___  ___   _ __ ___    ___      | |_  ___                          
     \ \/  \/ // _ \| | / __|/ _ \ | '_ ` _ \  / _ \     | __|/ _ \                         
      \  /\  /|  __/| || (__| (_) || | | | | ||  __/     | |_| (_) |                        
       \/  \/  \___||_| \___|\___/ |_| |_| |_| \___|      \__|\___/                         
                                                                                            
                                                                                            
     _____              _             _  _            _____         _      _  _       _     
    |  __ \            | |           | || |   ___    |  __ \       | |    | |(_)     | |    
    | |__) |_   _  ___ | |__    __ _ | || |  ( _ )   | |__) |_   _ | |__  | | _  ___ | |__  
    |  ___/| | | |/ __|| '_ \  / _` || || |  / _ \/\ |  ___/| | | || '_ \ | || |/ __|| '_ \ 
    | |    | |_| |\__ \| | | || (_| || || | | (_>  < | |    | |_| || |_) || || |\__ \| | | |
    |_|     \__,_||___/|_| |_| \__,_||_||_|  \___/\/ |_|     \__,_||_.__/ |_||_||___/|_| |_|
                                                                                            
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
     Hello! 
     I created this script and module to avoid using GitHub Actions workflow, 
     For building Static site output using NodeJS frameworks,
     and then deploy the output into gh-pages.
      but I see It could easily be used for PHP, Go, 
      it does not acount for complex combined SSR/CRS environments, but everything is possible
      this can definitelly be further enhanced to make it booth
       push & pull on multiple remotes simulateously    
      I does ask for $SourcePath here you can specify that your environment does output into FOOBAR
     This script automates the process of building and deploying a web application 
     from a source repository to a destination folder. It is designed to be used as part of a CI/CD pipeline.
     ---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
     >> !!!!!! Prerequirities !!!!
     
    *     Git installed on your system.
    *    Node.js and npm installed for building the application
     
     
     This script will ask you for a few variables now.
     
     1) SourceRepoBranch : Path to the source repository branch (default: main)(e.g., main or master, foo) 
     2) SourceRepoRoot : Path to the root of the source repository
3) SourcePath : Path to the built files in the source repository
4) destinationPath : Path to the destination folder
5) DeploymentBranch : Deployment branch (e.g., gh-pages or master)
6) MainshortDescription : Commit message for the main branch (has prefix of time and date)
7) DeploymentshortDescription : Commit message for the deployment branch (has prefix of time and date)
8) longDescription : Long description: What has changed outside of the building processes (has prefix of build process description)
"
)
# Prompt the user for input
# Define paths 
SourceBranch = Read-Host "Enter the source repository branch (default: main)"
if (-not SourceBranch) {
    SourceBranch = "main"
}

$SourceRepoRoot = Read-Host "Enter the source repository root path"
$sourcePath = Read-Host "Enter the source path"
$destinationPath = Read-Host "Enter the destination path"

$DeploymentBranch = Read-Host "Enter the deployment branch (default: gh-pages)"
if (-not $DeploymentBranch) {
    $DeploymentBranch = "gh-pages"
}

$DeploymentBranch = $DeploymentBranch -if $DeploymentBranch  -ne "" -else "gh-pages"

# commit messages
$MainshortDescription = "build at 📅 $(Get-Date -Format 'hh:mm tt -> yyyy-MM-dd') - " + (Read-Host "Which index section has changed")
$DeploymentshortDescription = "deployed at 📅 $(Get-Date -Format 'hh:mm tt -> yyyy-MM-dd') - " + (Read-Host "Which index section has changed")
$longDescription = "NPM build to render locally any changes to src folder to $sourcePath:Output:PUG (branch: SourceBranch) then deploy from $sourcePath:PUG=branch:SourceBranch/dist into 📃$destinationPath (branch: $DeploymentBranch) alias 'HOSTPATH:' - " + (Read-Host "Long description: What has changed outside of the building processes")

# Execute the build and deploy process
Build-And-Deploy -SourceRepoRoot $SourceRepoRoot -SourcePath $sourcePath -DestinationPath $destinationPath -MainCommitMessage "$MainshortDescription" -DeployCommitMessage "$DeploymentshortDescription" -SourceBranch SourceBranch -DeploymentBranch $DeploymentBranch
# ASCII art and annotation prompt

# Thank you message
Write-Output "Thank you for choosing to use this routine! If you found it helpful, consider buying me a coffee. 😊"


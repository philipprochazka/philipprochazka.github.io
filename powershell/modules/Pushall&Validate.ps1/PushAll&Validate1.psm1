function Validate-Path {
    param (
        [string]$Path
    )
    if (-Not (Test-Path -Path $Path)) {
        Write-Host "Error: Path $Path does not exist. Exiting script."
        exit
    }
}

function Commit-And-Push {
    param (
        [string]$RepoPath,
        [string]$Branch,
        [string]$CommitMessage
    )
    if (-Not (Test-Path -Path "$RepoPath\.git")) {
        Write-Host "Error: $RepoPath is not a Git repository. Exiting script."
        exit
    }
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
        [string]$SourceRepoRoot,
        [string]$SourcePath,
        [string]$DestinationPath,
        [string]$MainCommitMessage,
        [string]$DeployCommitMessage,
        [string]$SourceBranch,
        [string]$DeploymentBranch
    )

    # Validate paths
    Validate-Path -Path $SourceRepoRoot
    Validate-Path -Path $DestinationPath

    # Confirm we are at the correct source repo root
    $currentPath = Get-Location
    if ($currentPath -ne $SourceRepoRoot) {
        Write-Host "Error: Not at the correct source repo root. Switching to $SourceRepoRoot."
        cd $SourceRepoRoot
    } else {
        Write-Host "Correct! I am at $SourceRepoRoot"
    }

    # Ensure we are on the source branch and build
    $currentBranch = git -C $SourceRepoRoot rev-parse --abbrev-ref HEAD
    if ($currentBranch -ne $SourceBranch) {
        Write-Host "Switching to $SourceBranch branch"
        git -C $SourceRepoRoot checkout $SourceBranch
    }
    Commit-And-Push -RepoPath $SourceRepoRoot -Branch $SourceBranch -CommitMessage $MainCommitMessage

    # Init PUG build
    npm --prefix $SourceRepoRoot run clean
    npm --prefix $SourceRepoRoot run build

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

# ASCII art and annotation prompt
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
     Hello! I created this script module to avoid using GitHub Actions workflow.
This script will ask you for a few variables now.
>>
#1 $Path / do not assign it this is on windows a sensitive thing that would crush 
#1a $SourcePath
#1b $DestinationPath


1) $SourceRepoBranch
2) $SourceRepoRoot
3) $sourcePath
4) $destinationPath 
5) $DeploymentBranch 
6) $MainshortDescription
7) $DeploymentshortDescription 
8) $longDescription
"
)

# Prompt the user for input
$SourceRepoBranch = Read-Host "Enter the source repository branch (default: main)"
if (-not $SourceRepoBranch) {
    $SourceRepoBranch = "main"
}

$SourceRepoRoot = Read-Host "Enter the source repository root path"
$sourcePath = Read-Host "Enter the source path"
$destinationPath = Read-Host "Enter the destination path"

$DeploymentBranch = Read-Host "Enter the deployment branch (default: gh-pages)"
if (-not $DeploymentBranch) {
    $DeploymentBranch = "gh-pages"
}

$MainshortDescription = "build at 📅 $(Get-Date -Format 'hh:mm tt -> yyyy-MM-dd') - " + (Read-Host "Which index section has changed")
$DeploymentshortDescription = "deployed at 📅 $(Get-Date -Format 'hh:mm tt -> yyyy-MM-dd') - " + (Read-Host "Which index section has changed")
$longDescription = "NPM build to render locally any changes to src folder to $sourcePath:Output:PUG (branch: $SourceRepoBranch) then deploy from $sourcePath:PUG=branch:$SourceRepoBranch/dist into 📃$destinationPath (branch: $DeploymentBranch) alias 'HOSTPATH:' - " + (Read-Host "Long description: What has changed outside of the building processes")

# Execute the build and deploy process
Build-And-Deploy -SourceRepoRoot $SourceRepoRoot -SourcePath $sourcePath -DestinationPath $destinationPath -MainCommitMessage "$MainshortDescription" -DeployCommitMessage "$DeploymentshortDescription" -SourceBranch $SourceRepoBranch -DeploymentBranch $DeploymentBranch

# Thank you message
Write-Output "Thank you for choosing to use this routine! If you found it helpful, consider buying me a coffee. 😊"


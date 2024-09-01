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
    Validate-SourcePath -SourcePath $SourcePath
    Validate-DestinationPath -DestinationPath $DestinationPath

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

    # Init PUG build
    npm --prefix $SourcePath run clean
    npm --prefix $SourcePath run build

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

# Define paths and commit messages
$sourcePath = "$env:USERPROFILE\Git\philipprochazka.github.io\dist\"
$destinationPath = "$env:USERPROFILE\Git\philipprochazka.github.io.gh-pages\"
$MainshortDescription = "build at 📅 $(Get-Date -Format 'hh:mm tt -> yyyy-MM-dd')"
$DeploymentshortDescription = "deployed at 📅 $(Get-Date -Format 'hh:mm tt -> yyyy-MM-dd')"
$longDescription = "NPM build to render locally any changes to src folder to philipprochazka:Output:PUG (branch: Main) then deploy from Output:PUG=branch:Main/dist into 📃 (branch: github-pages) alias 'HOSTPATH:'"

# Execute the build and deploy process
Build-And-Deploy -SourcePath $sourcePath -DestinationPath $destinationPath -MainCommitMessage "$MainshortDescription - $longDescription" -DeployCommitMessage "$DeploymentshortDescription - $longDescription"

}
# Define the source and destination paths using environment variables
$sourcePath = "$env:USERPROFILE\Git\philipprochazka.github.io\dist\"
$destinationPath = "$env:USERPROFILE\Git\philipprochazka.github.io.gh-pages\"

# Validate the source path
if (-Not (Test-Path -Path $sourcePath)) {
    Write-Host "Error: Source path $sourcePath does not exist. Exiting script."
    exit
}

# Validate the destination path
if (-Not (Test-Path -Path $destinationPath)) {
    Write-Host "Error: Destination path $destinationPath does not exist. Exiting script."
    exit
}



# Prepare the commit messages
$MainshortDescription = "build at 📅 $(Get-Date -Format 'hh:mm tt -> yyyy-MM-dd')"
$DeploymentshortDescription = "deployed at 📅 $(Get-Date -Format 'hh:mm tt -> yyyy-MM-dd')"
$longDescription = "NPM build to render locally any changes to src folder to philipprochazka:Output:PUG (branch: Main) then deploy from Output:PUG=branch:Main/dist into 📃 (branch: github-pages) alias 'HOSTPATH:'"

# Navigate to the source path and run clean and build commands
# Confirm we are at the correct source path
$currentPath = Get-Location
if ($currentPath -ne $sourcePath) {
    Write-Host "Error: Not at the correct source path. switching to $sourcePath ."
cd   $sourcePath
} else {
    Write-Host "Correct! I am at $sourcePath"
}
# now Ensure we are on the main branch
$currentBranch = git rev-parse --abbrev-ref HEAD
if ($currentBranch -ne 'main') {
    Write-Host "Switching to main branch"
    git checkout main


##now  Init PUG build
npm run clean
npm run build


# Commit the changes to branch Main with a short and long description
$commitMessage = "$MainshortDescription - $longDescription"
git add .
git commit -m $commitMessage
git push -u origin main
git status 

# Remove all contents from the destination path to avoid conflicts
Get-ChildItem -Path $destinationPath -Exclude @('.git', '.github') | Remove-Item -Recurse -Force

# Copy the built files to the destination path
Copy-Item -Path $sourcePath\* -Destination $destinationPath -Recurse

# Change directory to the destination path
cd $destinationPath

# Confirm we are at the correct destination path
$currentPath = Get-Location
if ($currentPath -ne $destinationPath) {
    Write-Host "Error: Not at the correct destination path. Switching folder."
    cd $destinationPath
} else {
    Write-Host "Correct! I am at $destinationPath"
}

# Ensure we are on the gh-pages branch
$currentBranch = git rev-parse --abbrev-ref HEAD
if ($currentBranch -ne 'gh-pages') {
    Write-Host "Switching to gh-pages branch"
    git checkout gh-pages
}

# Add the changes to git
git add .

# Commit the changes to GH-Pages with a short and long description
$commitMessage = "$DeploymentshortDescription - $longDescription"
git commit -m $commitMessage

# Push the changes to the GitHub repository
git push -u origin gh-pages
git status
# Define the source and destination paths using environment variables
$sourcePath = "$env:USERPROFILE\Git\philipprochazka.github.io\dist\"
$destinationPath = "$env:USERPROFILE\Git\philipprochazka.github.io.gh-pages\"

# Navigate to the source path and run clean and build commands
cd $sourcePath
npm run clean
npm run build

# Remove all contents from the destination path to avoid conflicts
Get-ChildItem -Path $destinationPath -Exclude @('.git', '.github') | Remove-Item -Recurse -Force

# Copy the built files to the destination path
Copy-Item -Path $sourcePath\* -Destination $destinationPath -Recurse

# Change directory to the destination path
cd $destinationPath

# Add the changes to git
git add .

# Commit the changes with a short and long description
$shortDescription = "deployed at 📅 $(Get-Date -Format 'hh:mm -> yyyy-MM-dd')"
$longDescription = "NPM build to render locally any changes to src folder to philipprochazka:Output:PUG (branch: Main) then deploy from Output:PUG=branch:Main/dist into 📃 (branch: github-pages) alias 'HOSTPATH:'"
$commitMessage = "$shortDescription - $longDescription"
git push -u origin gh-pages
git commit -m $commitMessage

# Push the changes to the GitHub repository
git push -u origin gh-pages

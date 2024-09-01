# Define the source and destination paths using environment variables
$sourcePath = "$env:USERPROFILE\Git\philipprochazka.github.io\test-cp.txt"
$destinationPath = "$env:USERPROFILE\Git\philipprochazka.github.io.gh-pages\"

# Copy the file to the destination
Copy-Item -Path $sourcePath -Destination $destinationPath

# Change directory to the destination path
cd $destinationPath

Get-ChildItem -Path $destinationPath || cat *.txt
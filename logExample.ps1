# Ask the user for a directory path
$directoryPath = Read-Host "Enter the directory path for your log files"

# Check if the directory exists, and create it if not
if (-not (Test-Path -Path $directoryPath)) {
    New-Item -Path $directoryPath -ItemType Directory
}

try {
# Log file name with date and time
$fileName = "SystemInfo_$(Get-Date -Format 'yyyy-MM-dd_HHmm').txt"
$logFilePath = Join-Path -Path $directoryPath -ChildPath $fileName

# Log system information to the file
Add-Content -Path $LogFilePath -Value "=== System Information $(Get-Date) ===`n"

# List of running processes
Get-Process | Format-Table -AutoSize | Out-String | Out-File -Append -FilePath $LogFilePath

# CPU and memory usage information
Get-Counter '\Processor(_Total)\% Processor Time', '\Memory\Available MBytes' | Out-File -Append -FilePath $LogFilePath

# Disk space information
Get-WmiObject Win32_LogicalDisk | Format-Table -AutoSize | Out-String | Out-File -Append -FilePath $LogFilePath

# Network information
Get-WmiObject Win32_NetworkAdapterConfiguration | Format-Table -AutoSize | Out-String | Out-File -Append -FilePath $LogFilePath

# List of installed programs
Get-ItemPropert -Path HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object { $_.DisplayName } | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | Format-Table -AutoSize | Out-String | Out-File -Append -FilePath $LogFilePath
}
catch {
    Write-Host "Error: $($_.Exception.Message)"
} finally {
    Write-Host "System information saved to $LogFilePath"
}




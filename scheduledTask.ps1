# Step 1: Initialization
# Ask the user for a directory path
$directoryPath = Read-Host "Enter the directory path for your log files"

# Check if the directory exists, and create it if not
if (-not (Test-Path -Path $directoryPath)) {
    New-Item -Path $directoryPath -ItemType Directory
}

# Step 2: Log system information
# Step 3: Error handling
try {
# Log file name with date and time
$fileName = "SystemInfo_$(Get-Date -Format 'yyyy-MM-dd_HHmm').txt"
$logFilePath = Join-Path -Path $directoryPath -ChildPath $fileName

# Log system information to the file
Add-Content -Path $LogFilePath -Value "=== System Information $(Get-Date) ===`n"

# List of running processes
Add-Content -Path $LogFilePath -Value "=== List of running processes Information $(Get-Date) ===`n"
Get-Process | Format-Table -AutoSize | Out-String | Out-File -Append -FilePath $LogFilePath

# CPU and memory usage information // Change the -Counter path to the correct language for your system
Add-Content -Path $LogFilePath -Value "=== CPU and memory usage information $(Get-Date) ===`n"
Get-Counter -Counter '\Processor(*)\% processortid', '\Minne\Tillgängliga byte' -SampleInterval 2 -MaxSamples 3 | Out-File -Append -FilePath $LogFilePath

# Disk space information
Add-Content -Path $LogFilePath -Value "=== Disk space information $(Get-Date) ===`n"
Get-CimInstance Win32_LogicalDisk | Format-Table -AutoSize | Out-String | Out-File -Append -FilePath $LogFilePath

# Network information
Add-Content -Path $LogFilePath -Value "=== Network information $(Get-Date) ===`n"
Get-CimInstance Win32_NetworkAdapterConfiguration | Format-Table -AutoSize | Out-String | Out-File -Append -FilePath $LogFilePath

# List of installed programs
Add-Content -Path $LogFilePath -Value "=== List of installed programs $(Get-Date) ===`n"
Get-ItemProperty -Path Registry::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object { $_.DisplayName } | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | Format-Table -AutoSize | Out-String | Out-File -Append -FilePath $LogFilePath
}
catch {
    Write-Host "Error: $($_.Exception.Message)" | Format-Table -Autosize | Out-String | Out-File -Append -FilePath $LogFilePath
} finally {
    Write-Host "System information saved to $LogFilePath"
}

# Step 3: Scheduled Task
$action = New-ScheduledTaskAction -Execute 'PowerShell.exe' -Argument "/PathToTheScript/scheduledTask.ps1"
$trigger = New-ScheduledTaskTrigger -Daily -At 8am 
$settings = New-ScheduledTaskSettingsSet
Register-ScheduledTask -Action $action -Trigger $trigger -Settings $settings -TaskName "SystemMonitor" -Description "System monitor task"

# Step 4: Interactive Features
$manualTrigger = Read-Host "Do you want to manually trigger the monitor task? (y/n)"
if ($manualTrigger -eq "y") {
    try {
# Log file name with date and time
$fileName = "SystemInfo_$(Get-Date -Format 'yyyy-MM-dd_HHmm').txt"
$logFilePath = Join-Path -Path $directoryPath -ChildPath $fileName

# Log system information to the file
Add-Content -Path $LogFilePath -Value "=== System Information $(Get-Date) ===`n"

# List of running processes
Add-Content -Path $LogFilePath -Value "=== List of running processes Information $(Get-Date) ===`n"
Get-Process | Format-Table -AutoSize | Out-String | Out-File -Append -FilePath $LogFilePath

# CPU and memory usage information
Add-Content -Path $LogFilePath -Value "=== CPU and memory usage information $(Get-Date) ===`n"
Get-Counter -Counter '\Processor(*)\% processortid', '\Minne\Tillgängliga byte' -SampleInterval 1 -MaxSamples 3 | Out-File -Append -FilePath $LogFilePath

# Disk space information
Add-Content -Path $LogFilePath -Value "=== Disk space information $(Get-Date) ===`n"
Get-CimInstance Win32_LogicalDisk | Format-Table -AutoSize | Out-String | Out-File -Append -FilePath $LogFilePath

# Network information
Add-Content -Path $LogFilePath -Value "=== Network information $(Get-Date) ===`n"
Get-CimInstance Win32_NetworkAdapterConfiguration | Format-Table -AutoSize | Out-String | Out-File -Append -FilePath $LogFilePath

# List of installed programs
Add-Content -Path $LogFilePath -Value "=== List of installed programs $(Get-Date) ===`n"
Get-ItemProperty -Path Registry::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object { $_.DisplayName } | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | Format-Table -AutoSize | Out-String | Out-File -Append -FilePath $LogFilePath
}
catch {
    Write-Host "Error: $($_.Exception.Message)" | Format-Table -Autosize | Out-String | Out-File -Append -FilePath $LogFilePath
} finally {
    Write-Host "System information saved to $LogFilePath"
}
} else {
    Write-Host "Task will run automatically at 8am"
}

$stopMonitoring = Read-Host "Do you want to stop the monitor task? (y/n)"
if ($stopMonitoring -eq "y") {
    Unregister-ScheduledTask -TaskName "SystemMonitor" -Confirm:$false
    Write-Host "Task stopped"
} else {
    Write-Host "Task will run automatically at 8am"
}


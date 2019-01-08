### Backs up the LabTech MySQL database
###
### Last modified by:		Brandon Buchanan
### Last modified date:  	1/8/2019
### 
### Changes:	-added 7-zip encryption
###				-added MySQL logging
###				-delete old logs


Set-ExecutionPolicy Unrestricted

# Password to connect to MySQL
$mySQLPassword = "";

# Password to encrypt backups with
$7zipPassword = "";

# Number of recent backups and logs to keep
$backupsToKeep = 3;
$logsToKeep = 3;

# Obtain formatted date (1970-01-01_23-01-59)"
$date = Get-Date -UFormat "%Y-%m-%d_%H-%M-%S"

# Location of backup files
$filePath = "C:\TempPath\mysql_labtech_" + $date
$tempBackupFilePath = $filePath + ".sql"
$archiveFilePath = $filePath + ".7z"
$backupPath = "C:\MySQLBackups"
$logFilePath = "$backupPath\log_$date.log"

# MySQL dump command to perform backup
$mySQLBackupCmd = "& 'C:\Program Files\MySQL\MySQL Server 5.6\bin\mysqldump.exe' -v --user=root --password=$mySQLPassword --all-databases --result-file=$tempBackupFilePath --log-error=$logFilePath --max_allowed_packet=128M"

# 7-Zip command to create archive
$7ZipCmd = "& 'C:\Program Files\7-Zip\7z.exe' a $archiveFilePath $tempBackupFilePath $logFilePath -p$7zipPassword -mhc=on -mhe=on"

# Run the backup
Write-Host $mySQLBackupCmd
Invoke-Expression $mySQLBackupCmd

# Create the archive
Invoke-Expression $7ZipCmd

# Move archive to storage location for syncing
Move-Item $archiveFilePath $backupPath

# Delete SQL backup file
Remove-Item $tempBackupFilePath

# Get all backup and log files
$backupFiles = Get-ChildItem -Path "$backupPath\*.7z" | Sort-Object name -Descending
$logFiles = Get-ChildItem -Path "$backupPath\*.log" | Sort-Object name -Descending

# Delete old backups
ForEach($backupFile in $backupFiles) {
	If($backupsToKeep -gt 0) {
		$backupsToKeep--;
	}
	Else {
		Remove-Item $backupFile
	}
}

# Delete old logs
ForEach($logFile in $logFiles) {
	If($logsToKeep -gt 0) {
		$logsToKeep--;
	}
	Else {
		Remove-Item $logFile
	}
}

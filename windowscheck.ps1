#Script for the DOC to run on Windows servers to perform a general health check
#Author: Jerron McGinnis
#Date Written: 16-June-2018
#Date Updated: 05-December-2018
#Revision 4

#Get Host Name
$Hostname = hostname | Out-String
echo "Hostname:"
echo "--------"
echo $Hostname

#Get version
$Version = (Get-WmiObject -class Win32_OperatingSystem).Caption | Out-String
echo "Version:"
echo "--------"
echo $Version

#Get Uptime
$UPTIME=Get-WmiObject Win32_OperatingSystem
$up = [Management.ManagementDateTimeConverter]::ToDateTime($UPTIME.LastBootUpTime) | Out-String
echo "Uptime:"
echo "--------"
echo $up


#Get Disk Spaces
$Disk = Get-WmiObject Win32_logicaldisk -ComputerName LocalHost -filter "DriveType=3" |select -property DeviceID,@{Name="Size(GB)";Expression={[decimal]("{0:N0}" -f($_.size/1gb))}},@{Name="Free Space(GB)";Expression={[decimal]("{0:N0}" -f($_.freespace/1gb))}},@{Name="Free (%)";Expression={"{0,6:P0}" -f(($_.freespace/1gb) / ($_.size/1gb))}}|Out-String
echo "Disk Space:"
echo "--------"
echo $Disk

#Get volume
$Volume = Get-Volume
echo "volume:"
echo "--------"
echo $Volume

#Get CPU Utilization
$CPU_Utilization = Get-process|Sort-object -Property CPU -Descending| Select -first 5 -Property ID,ProcessName,@{Name = 'CPU In (%)';Expression = {$TotalSec = (New-TimeSpan -Start $_.StartTime).TotalSeconds;[Math]::Round( ($_.CPU * 100 /$TotalSec),2)}},@{Expression={$_.threads.count};Label="Threads";},@{Name="Mem Usage(MB)";Expression={[math]::round($_.ws / 1mb)}},@{Name="VM(MB)";Expression={"{0:N3}" -f($_.VM/1mb)}}|Out-String
echo "CPU Utilization:"
echo "--------"
echo $CPU_Utilization


#total mem and free start
$OperatingSystem = Get-WmiObject win32_OperatingSystem
$FreeMemory = $OperatingSystem.FreePhysicalMemory
$TotalMemory = $OperatingSystem.TotalVisibleMemorySize
$MemoryUsed = 100 - (($FreeMemory/ $TotalMemory) * 100)
$PercentMemoryUsed = "{0:N2}" -f $MemoryUsed
#end
echo "Total Memory:"
echo "--------"
echo $TotalMemory


echo "Free Memory:"
echo "--------"
echo $FreeMemory


echo "Percent Memory Used:"
echo "--------"
echo $PercentMemoryUsed

#Get IP Info
$IPInfo = Get-NetIPConfiguration
echo "IP Info:"
echo "--------"
echo $IPInfo

#Security Patches
$SecPatch = get-hotfix -Description "Security Update" |sort "Description" -desc | select Description,installedon -first 1 | Out-String
echo "Security Patches:"
echo "--------"
echo $SecPatch

#Get SQL Status 
#$Private:wmiService =gsv -include "*SQL*" -Exclude "*ySQL*","*spo*"|select Name,DisplayName,Status|Out-String
#$Services =gsv -include "*SQL*" -Exclude "*ySQL*","*spo*"|select Name,DisplayName,Status|Out-String
#echo $Services


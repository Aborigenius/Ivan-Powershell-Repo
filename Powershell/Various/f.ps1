Function Get-Folder()
{
    Add-Type -AssemblyName System.Windows.Forms
    $FolderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog -Property @{
    SelectedPath = '\\nuhqssccm\WsusContent\Deployment Packages 2018\’
    Description = "Select Source Folder"
  
}

[void]$FolderBrowser.ShowDialog()
$FolderBrowser.SelectedPath

}
$a = Get-Folder
$month = (Get-Culture).DateTimeFormat.GetMonthName((Get-Date).Month)
$year = (Get-Date).Year
$to =  "\\nuhqsfile1\Install\_Security Patches\01. Monthly Updates\MICROSOFT UPDATES\" + $month + '_' + $year
 if (!(Test-Path -path $to)) {
        New-Item $to -Type Directory
        New-Item $to\Generic -Type Directory
        New-Item $to\X86 -Type Directory
        New-Item $to\x64 -ItemType Directory
    }
ls $a -Recurse -File | sort Length -Descending |`
 where {$_.Name -notmatch "x64" -and $_.name -notmatch "x86"} |Select -ExpandProperty FullName | copy-item -Destination $to\Generic -recurse -force
ls $a -Recurse -File | sort Length -Descending |`
 where {$_.Name -match "windows6.1" -and $_.name -match "x64"} |Select -ExpandProperty FullName | copy-item -Destination $to\X64 -recurse -force
ls $a -Recurse -File | sort Length -Descending |`
 where {$_.Name -match "windows6.1" -and $_.name -match "x86"} |Select -ExpandProperty FullName | copy-item -Destination $to\x86 -recurse -force
 Copy-Item "\\nuhqsfile1\Install\_Security Patches\01. Monthly Updates\MICROSOFT UPDATES\Install Script Backup\*" -Destination $to -Recurse
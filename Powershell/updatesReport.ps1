$updates = $wsus.GetUpdates() | ? {$_.IsApproved -eq "True"}
$report = @()
ForEach ($update in $updates) {
    $approval = $update.GetUpdateApprovals() | % {
            $id = $_.ComputerTargetGroupId
            $temp = "" | Select Title, Group, Deadline, ApprovedBy, AvailableForDownload
            $temp.Title = $update.Title
            $temp.Deadline = $_.Deadline
            $temp.ApprovedBy = $_.AdministratorName
            $temp.AvailableForDownload = $_.GoLiveTime
            $temp.Group = $wsus.GetcomputerTargetGroups() | ? {$_.ID -eq $id} | Select -expand Name
            $report += $temp
        }
    }
$report
 
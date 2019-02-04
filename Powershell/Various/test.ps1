function ParseDate([string]$date)
{
    $result = 0
    if (!([DateTime]::TryParse($date, [ref]$result)))
    {
        Write-Output "Invalid Date $date"
        return
     }

    $result
}
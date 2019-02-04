function ParseDate([string]$date)
{
    $result = 0
    if (!([DateTime]::TryParse($date, [ref]$result)))
    {
        $result = $false
        return $result
     }

    $result = $true
    $result
}
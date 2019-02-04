
#Option 3 multiple Tables in one Powershell Report

$a = Get-Process | Select-Object -First 5 | ConvertTo-HTML -Title "Report Process" -PreContent "<h1>$($env:COMPUTERNAME) Report Process</h1>"
$b = Get-Service | Select-Object -First 5 | ConvertTo-HTML -Title "Report Service" -PreContent "<h1>Report Service</h1>"
$c = Get-WmiObject -class Win32_OperatingSystem | Select-Object -First 5 | ConvertTo-HTML -Property * -Title "Report OS" -PreContent "<h1>Report OS</h1>"

ConvertTo-HTML -Title "Process Log Report" -body "$a $b $c" -PostContent "<H5><i>$(get-date)</i></H5>" -CSSUri "ps.css" | Set-Content "HtmlReportOption3.html"



# SIG # Begin signature block
# MIIFcwYJKoZIhvcNAQcCoIIFZDCCBWACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUyTOijqq6iJtSULLya+8XLhYb
# XnugggMMMIIDCDCCAfCgAwIBAgIQL8pZ5tD6aJdNgSgCU7NYiDANBgkqhkiG9w0B
# AQUFADAcMRowGAYDVQQDDBFUZXN0IENvZGUgU2lnbmluZzAeFw0xODEyMjIxMTAw
# MDVaFw0xOTEyMjIxMTIwMDVaMBwxGjAYBgNVBAMMEVRlc3QgQ29kZSBTaWduaW5n
# MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAqKVrbOHsPmup+8D/WRcA
# ukyDC7S+/oJo56ZefsRujWuxhRwJqYb08O2voC+Vms0N9NV2dyw1SWXse4KjzEOQ
# j/MQJjPo37vrPWQA/iZxZc7415JFiRs4kNYGwU/kNhi9kQ36WxTLawk9NIHmKupD
# cgmLllLZmGc5yxOT4+Bk2PG3nhLQM9WH8147roFhUZR6pZK+e6gmtaWuePWcA0gN
# ggkbh9X95Hzh9SeSQCa/QGnL9vgqtvLoZwZ7OU8mKTggE+EmT5MahWlrb+XHQqYb
# oaYnYm8TZLLiS4tQP6L+G3ICcQHONQcBjRVACrz4rWy/HyIfHpY0hUJTfJvihqLu
# 2QIDAQABo0YwRDAOBgNVHQ8BAf8EBAMCB4AwEwYDVR0lBAwwCgYIKwYBBQUHAwMw
# HQYDVR0OBBYEFM7+GjlCjcOTRwCaikDTViILH1lqMA0GCSqGSIb3DQEBBQUAA4IB
# AQAs9ahvxVP3cWuadeYMOlqo+S8y0RXF1PuW+ED5vkEpgcZNpZ6j1wMDIzFu+woH
# lzIJOXqEEwvy1d/QLyx+wos7zRBFytN5hV1pY80J+j7xwt00gnbycq1KBS5RKvaU
# nWi7lr2DRFZmQX+DejfFLhJu++XfwU4O1bU5wD2pfcY4cnMv4y9aTW2dPhPnZIdk
# 3OO913iT7iSzaYH2clzPbOACvnWxSjWpFSMBWVVjX/V/osW9SMTYbeIPGSQBuRUk
# Uxmf0+YoRqVjX+lcuzutzha5J62dYYnjIlqvA7tDXL60XayQ7GJi9udxHDsbfpwc
# Gy03Zt7PNbGmmLVTHWKupzObMYIB0TCCAc0CAQEwMDAcMRowGAYDVQQDDBFUZXN0
# IENvZGUgU2lnbmluZwIQL8pZ5tD6aJdNgSgCU7NYiDAJBgUrDgMCGgUAoHgwGAYK
# KwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIB
# BDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQU
# cYGpRPYlshum57vJ1H91Y5B2bNAwDQYJKoZIhvcNAQEBBQAEggEAdGMf32IlquVd
# 93hF/eVUzBFZQn/ubxhh3PL0sJVu5mUpSxchGOcNaFtkB1uSWqimVn/G9fDnmxta
# /fm1gFNQ4tAsLVB8svVRza3yO2fymkg0OpxlOhdOICOtP/4eUh/y06TTiTncHR7K
# Nenh2nFN1+g/vxDBe753CUbNLEHa5vFuWyeORpR8MAsGHVcCzw0hC1TQVqpw8bJp
# bBW9pRjivoSn1++fGL3zSp8yRxTL9i/UZuJUlpVwCdPNho04gbzYQpiBXA6ZQ7m1
# FM/Lirh7tvrIiaIVzCnNePOPx1V6fVFBjM8DlflikZZACgY4dJ+WQCQKWBBJFKkB
# e5MIYcY5Fw==
# SIG # End signature block

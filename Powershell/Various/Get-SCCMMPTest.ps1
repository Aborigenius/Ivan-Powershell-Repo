function Get-SCCMMPTest {
    <#
     .SYNOPSIS
        Tests the MPList and MPCert SCCM management point URLs
   
        URLs being tested.
        http://localhost/sms_mp/.sms_aut?mpCert
        http://localhost/sms_mp/.sms_aut?mplist  

     .PARAMETER  ComputerName
      The computer name to target.

     .EXAMPLE
      PS C:\> Get-SCCMMPTest -ComputerName "Foo"

        .EXAMPLE
      PS C:\> Get-SCCMMPTest Foo

        .EXAMPLE
      PS C:\> Get-SCCMMPTest Foo Foo2

    #> 
[CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, HelpMessage="Computer Name",ValueFromPipeline=$true)] $ComputerName
    )

Process {
 
    Foreach ($Computer in $ComputerName) {

        if(Test-Connection -Cn $computer -BufferSize 16 -Count 1 -ea 0 -quiet){

            $Computer = $Computer.toupper()
            $urlsToTest = @{}
            $urlsToTest["MPCert"] = "http://$Computer/sms_mp/.sms_aut?mpcert"
            $urlsToTest["MPList"] = "http://$Computer/sms_mp/.sms_aut?mplist"

            $userAgent = "PowerShell User"
            $webClient = new-object System.Net.WebClient
            $webClient.Headers.Add("user-agent", $userAgent)

            Foreach ($key in $urlsToTest.Keys) {
          
               $output = $null
               $startTime = get-date
          
               Try{              
                    $output = $webClient.DownloadString($urlsToTest[$key])                           
                     }
          
               Catch {
               
                     }
          
               $endTime = get-date

               Try{
                    $SCCMservice = Get-Service -ComputerName $Computer ccmexec
                    }
                Catch{
           
                    }

               if ($output) {
                  $Results = New-Object System.Object
                  $Results | Add-Member -type NoteProperty -name "Computer Name" -value $Computer
                  $Results | Add-Member -type NoteProperty -name "SMS Agent Host Service" -value $SCCMservice.Status
                  $Results | Add-Member -type NoteProperty -name "URL Tested" -value $key
                  $Results | Add-Member -type NoteProperty -name "State" -value "Success"
                  $Results | Add-Member -type NoteProperty -name "Start Time" -value $startTime.DateTime
                  $Results | Add-Member -type NoteProperty -name "Response Time (Sec)" -value ($endTime - $startTime).TotalSeconds   
                  $Results | Add-Member -type NoteProperty -name "Content" -value $Output                     
                  [String[]]$properties = 'Computer Name','SMS Agent Host Service','URL Tested','State','Start Time','Response Time (Sec)'           
                  [System.Management.Automation.PSMemberInfo[]]$PSStandardMembers = New-Object System.Management.Automation.PSPropertySet DefaultDisplayPropertySet,$properties          
                  $Results | Add-Member -MemberType MemberSet -Name PSStandardMembers -Value $PSStandardMembers                                            
                  $Results    
                            }           
               else {
                  $Results = New-Object System.Object
                  $Results | Add-Member -type NoteProperty -name "Computer Name" -value $Computer
                  $Results | Add-Member -type NoteProperty -name "SMS Agent Host Service" -value $SCCMservice.Status
                  $Results | Add-Member -type NoteProperty -name "URL Tested" -value $key
                  $Results | Add-Member -type NoteProperty -name "State" -value "Fail"
                  $Results | Add-Member -type NoteProperty -name "Start Time" -value $startTime.DateTime
                  $Results | Add-Member -type NoteProperty -name "Response Time (Sec)" -value ($endTime - $startTime).TotalSeconds                     
                  $Results
                            }
                     }
                }
        else
            {
                  $Results = New-Object System.Object
                  $Results | Add-Member -type NoteProperty -name "Computer Name" -value $Computer
                  $Results | Add-Member -type NoteProperty -name "SMS Agent Host Service" -value "Offline"
                  $Results | Add-Member -type NoteProperty -name "URL Tested" -value "Offline"
                  $Results | Add-Member -type NoteProperty -name "State" -value "Fail"
                  $Results | Add-Member -type NoteProperty -name "Start Time" -value "Offline"
                  $Results | Add-Member -type NoteProperty -name "Response Time (Sec)" -value ($endTime - $startTime).TotalSeconds
                  $Results
            }
        }
    }
}
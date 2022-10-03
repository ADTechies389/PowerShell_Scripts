<#

.Purpose 

    This script is build for the purpose of alerting the AD admins for the accounts disable in the provided domain

.ScriptUsage

    This script can be scheduled in the task Scheduler and run at the required time 
    ( Please make sure about the Eventlogs will be overwritten over the period of time )

.Author

    Script developed By: Murugan Natarajan
    Email ID : Murugan.Natarajan@outlook.com
    Date: 27/07/2020

.Notes 
    
    Script is scheduled on Server
    
#>

# Log file prepation 

$dateinfo= Get-date -Format yyyy-MM-dd-hh-mm

$log = "C:\AD_Scripts\Account-Disable\Daily-Account-Disable-Report-$dateinfo.csv"

# Collecting domain controllers in the domain 

$DClist =  Get-ADDomainController -filter * -server 'test.local' | select -ExpandProperty hostname | sort


# Loop DCs

Foreach($dc in $DClist){
    
   # Write-host "Connect to host $DC and checking logs" -ForegroundColor Green

    Get-WinEvent -FilterHashtable @{Logname='Security';ID='4725';starttime= (Get-date).AddHours(-24)} -ErrorAction SilentlyContinue -ComputerName $dc |`

    Select-Object -Property Timecreated,
    @{label='DisabledAccountname';Expression={$_.properties[0].value}},
    @{label='DomainName';Expression={$_.properties[1].value}},
    @{label='ActionTakenBy';Expression={$_.properties[4].value}},machinename | Export-Csv -NoTypeInformation $log -Append
    
   # Write-Host "Log collection done on $dc, proceeding with next " -ForegroundColor DarkYellow


}


$sendMailParams = @{
    From = 'IT-Admins@test.com' 
    To = 'murugan.natarajan@outlook.com','ADtechies389@test.com'
    Subject = 'User Accounts Disabled Notification'
    Body = 'Please find attached the list of accounts disabled in last 24 hours'
    SMTPServer = 'smtp.test.com'
    Attachment = "$log"
}

Send-MailMessage @sendMailParams
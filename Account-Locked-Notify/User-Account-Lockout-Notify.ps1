<#

.Purpose 

    This script is build for the purpose of alerting the AD admins for the accounts Locked in the provided domain. This script will 
    connect to the PDC emulator role owner to collect the 4740 Event and get the caller computer name. 

    If caller computer name is blank, then extended Netlogon Logging need to be enabled. 
    
    Update the smtp, Admins Email address in the Mail parameter section. Update Logpath as per requirement, otherwise log creation would fail. 

.ScriptUsage

    This script can be scheduled in the task Scheduler and run at the required time 
    
.Author

    Script developed By: Murugan Natarajan
    Email ID : Murugan.Natarajan@outlook.com
    Date: 15/10/2020
    
#>

# Log file prepation 

$dateinfo= (Get-date -Format ddMMyyyy-hh-mm)

$log = "C:\AD_Scripts\Account-lock\Daily-Account-locked-Report-$dateinfo.csv"

# Collecting domain controllers in the domain 

$pdcserver = Get-ADDomain | select -expandproperty pdcemulator


Get-WinEvent -FilterHashtable @{Logname='Security';ID='4740';starttime= (Get-date).AddHours(-24)} -ErrorAction SilentlyContinue -ComputerName $pdcserver |`

    Select-Object -Property Timecreated,
    @{label='Locked-Accountname';Expression={$_.properties[0].value}},
    @{label='Source';Expression={$_.properties[1].value}} | Export-Csv -NoTypeInformation $log -Append
    
    
$sendMailParams = @{
    From = 'IT-Admins@test.com' 
    To = 'murugan.natarajan@outlook.com','ADtechies389@gmail.com'
    Subject = 'Account Lockout Notification'
    Body = 'Please find attached the list of accounts locked out in last 24 hours'
    SMTPServer = 'smtp.test.com'
    Attachment = "$log"
}

Send-MailMessage @sendMailParams 

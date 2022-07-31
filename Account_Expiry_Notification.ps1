# -----------------------
# Import required modules
# -----------------------

Import-Module ActiveDirectory

$UserList = @()

# ----------------
# Define variables
# ----------------

$cc= "ADTeam@uzhavan.local"
$Todefault= "ITOperations@uzhavan.local"
$From = "muru@uzhavan.local"
$Subject = "SSL VPN Account about to expire"
$Subject2 = "No expiry of LDO SSL VPN Accounts"
$Body1 = "There are no SSL VPN accounts nearing expiration in the next 10 days"
$SMTPServer = "dc2.uzhavan.local"
$Date = Get-Date -format yyyyMMdd
$ReportName = "C:\SSLVPN\VPN_SSL_EXPIRY$Date.csv"



# ------------------------------------------------------------------
# Get list of users from Active Directory that will expire in 7 days
# ------------------------------------------------------------------

$UserList = Get-ADUser -Filter *  -properties AccountExpirationDate,name, samaccountname, mail | Where-Object{$_.AccountExpirationDate -lt (Get-Date).AddDays(11) -and  $_.AccountExpirationDate -gt (Get-Date).AddDays(1) -and $_.AccountExpirationDate -ne $null} |Select-Object name, samaccountname, AccountExpirationDate, mail | sort name
#We can add searchbased also, like OU filter -SearchBase "OU=Users,OU=SSLUsers,DC=Uzhavan,DC=local"


# -----------------------------------------------
# Send an email using the variables defined above
# -----------------------------------------------

If ($UserList -eq $null) {

Send-MailMessage -To $Todefault -From $From -Subject $Subject2 -Body $Body1 -SMTPServer $SMTPServer}

Else
{
   foreach ($user in $UserList){
   
   $eachusermail = $user.mail
   
   $accountexinfo= $user.accountexpirationdate
   
   $usersam = $user.samaccountname

   $Bodymessage = "Hi,`
We have noticed that your SSL VPN domain account is about to expire on $accountexinfo . 
Please contact to Security team for extension of your account if you still need it else your account will be expired and you 
will not be in position to logon to this domain. 
Thank you
Helpdesk@uzhavan.com"
$Body = " Hello, 

          User = $usersam account about to expire on $accountexinfo, since AD does not have the mail address updated, please forward message to user 
          -Automated message from Script
          "

    if ($eachusermail -eq $null ) {
    
        Send-MailMessage -To $Todefault -CC $CC -From $From -Subject $Subject -Body $body -SMTPServer $SMTPServer
    
    }
     else {            
         Send-MailMessage -To $Todefault,$eachusermail -CC $CC -From $From -Subject $Subject -Body $Bodymessage -SMTPServer $SMTPServer
   
    }
      
}
}
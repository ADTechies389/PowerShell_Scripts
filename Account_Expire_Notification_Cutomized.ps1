# -----------------------
# Import required modules
# -----------------------

Import-Module ActiveDirectory

$UserList = @()

# ----------------
# Define variables
# ----------------


$From = "IT_OPERATIONS@Test.COM"
$TeamDL= "ADTEam@test.com"
$Subject2 = " SSL VPN Account"
$Subject1 = "Weekly expiring  SSL VPN report- No Expiry"
$Body1 = "There are no SSL VPN accounts nearing expiration in the next 7 days"
$SMTPServer = "mail.test.com"
$dateinfo = Get-Date
#$ReportName = "C:\SSLVPN\VPN_SSL_EXPIRY$Date.csv"



# ------------------------------------------------------------------
# Get list of users from Active Directory that will expire in 7 days
# ------------------------------------------------------------------

$UserList = Get-ADUser -filter * -searchbase "OU=Users,OU=SSLUsers,DC=test,DC=net" -properties AccountExpirationDate,name, samaccountname, mail, displayname | Where-Object{$_.AccountExpirationDate -lt (Get-Date).AddDays(7) -and  $_.AccountExpirationDate -gt (Get-Date).AddDays(1) -and $_.AccountExpirationDate -ne $null} |`
            Select-Object name, samaccountname, AccountExpirationDate, mail, displayname | sort name
#

# -----------------------------------------------
# Send an email using the variables defined above
# -----------------------------------------------

If ($UserList -eq $null) {

 # If no user's account is expiring, team will be notified that NO user accounts are going to expire

    Send-MailMessage -To $TeamDL -From $From -Cc $cc -Subject $Subject1 -Body $Body1 -SMTPServer $SMTPServer}

   Else {

         foreach ($user in $UserList){
   
        # Collecting user information and storing in separate variables.

                $eachusermail = $user.mail
   
                $accountexinfo= $user.accountexpirationdate

                $diff = ($accountexinfo - $dateinfo).Days
   
                $usersam = $user.samaccountname

                $userdisplay = $user.displayname

   # Preparing the message for user's notification email

   $BodyExpiremsg = "Dear $userdisplay,`
                    
                    Account SSL VPN : $userdisplay
                    ----------------------------------------------------------------------------

                    Account         : $usersam

                    Type            : VPN 

                    Expire Date     : $accountexinfo 
                    
                    Days to Expire  : $diff

                    Please obtain your Manager's approval and forward the same in case you wish to extend the access.

                    Thank you
                    ITHelp@test.com"

   $BodynoExpiremsg = " Hello Team, 

                     $usersam account about to expire on $accountexinfo, since AD does not have the mail address updated, please forward message to user 
                     
                      "

    if ($eachusermail -eq $null ) {
        
       # If user doesn't have email address information in AD, team will be notified about those user's account expiration

        Send-MailMessage -To $TeamDL -From $From -Subject $Subject1 -Body $BodynoExpiremsg -SMTPServer $SMTPServer
    
    }
     else {            
        
        # Sending out email to the each user who's account is about to expire in 7days from today

         Send-MailMessage -To $eachusermail -CC $TeamDL -From $From -Subject $Subject2 -Body $BodyExpiremsg -SMTPServer $SMTPServer
   
    }
      
}
}
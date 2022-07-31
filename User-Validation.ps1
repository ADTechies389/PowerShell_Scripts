# Setting up Basic Variables 

Set-Location 'C:\temp\'
$data=Get-content '.\users.txt'
$logdate = (Get-Date -Format ddMMyyyy)
$Log1 = "c:\temp\Account_Existance_Check_$logdate.txt"

# Importing Active Directory module 
Import-Module Activedirectory 

$domain=(Get-addomain).name

# Looping the proided input users with foreach and validating using Get-ADuser comdlet using Try and Catch Method

foreach ($user in $data)
{ 

Try {
        Get-aduse -Identity $user -ErrorAction stop |out-null
        Add-Content $log1 -Value "$User exist in $domain domain"
    }
Catch
    {
        Add-Content $log1 -Value "$user does not exist in $domain domain"
    }
    
}


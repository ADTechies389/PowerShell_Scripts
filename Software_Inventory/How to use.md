<# 
 Courtesy to Hey Scripting Guy blog : https://devblogs.microsoft.com/scripting/use-powershell-to-quickly-find-installed-software/
 
Requirement: 

This script helps to retrieve the softwares installed on remote computer. 
In our case, where there is tool named Rapid7 which need to be installed on All the domain Controllers. 

So, we were asked to check and confirm which DCs have the tool installed. 

Lets play with Powershell :) 

#>

1) Prepare the Server list input file ( Note: Input file does not have header ) 

![image](https://user-images.githubusercontent.com/110298884/196244247-75f4b73a-f3ff-4344-a4fa-33b96ab09983.png)


2) After executing the script we get output like below 

![image](https://user-images.githubusercontent.com/110298884/196244440-d87285fb-b504-4b0d-9622-af79892cbbc5.png)


Bonus points: 

Incase, if we would like to filter only specific software installed on DC, we can edit the below line as mentioned below
For example: vmware related product installed on remote machines. 

$array | Where-Object { $_.DisplayName -like "vmware*" } | select ComputerName, DisplayName, DisplayVersion, Publisher | ft -auto

![image](https://user-images.githubusercontent.com/110298884/196245318-b6cbcf0d-8471-4a13-9980-0ecc6978cb46.png)

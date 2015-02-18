########################################################### 
# AUTHOR  : Brian O'Connell  @LifeOfBrianOC
# https://lifeofbrianoc.wordpress.com/
# It will do the following:
# Validate AD USers Credentials based on csv input
# Reset user passwords if they do not match the csv
########################################################### 

# Set Console ForegroundColor to Yellow for Read-Host as -ForegroundColor doesn't work with Read-Host and I like colours!
[console]::ForegroundColor = "yellow"

# Ask user for csv path 
    $CSVPath = Read-Host "Please enter the full path to your csv with user details"
						
# Reset Console ForegroundColor back to default
[console]::ResetColor()

# Verify CSV Path
	$testCSVPath = Test-Path $CSVPath
		if ($testCSVPath -eq $False) {Write-Host "CSV File Not Found. Please verify the path and retry
								             " -ForegroundColor Red
		Exit
		}
	else
	{

Function Test-ADAuthentication {
	param($username,$password)
	(new-object directoryservices.directoryentry "",$username,$password).psbase.name -ne $null
}

# Import CSV and only read lines that have an entry in samAccountName column
	$csv = @()
	$csv = Import-Csv -Path $CSVPath |
	Where-Object {$_.samAccountName}
	
	ForEach ($_ in $csv)
	{
    $username = $_.samAccountName
    $password = $_.accountPassword
	$domain = $_.domain
	
			if (Test-ADAuthentication "$username@$domain" "$password") {
        write-host "$username :: credentials valid" -foregroundcolor "green"
			} 
			else 
				{
				Set-ADAccountPassword -Identity $username -Reset -NewPassword (ConvertTo-SecureString $_.accountPassword -AsPlainText -ChangePasswordAtLogon $false -PasswordNeverExpires $true -Force)
				write-host "$username :: credentials invalid - Resetting" -foregroundcolor "red"
				}
					} 
						}

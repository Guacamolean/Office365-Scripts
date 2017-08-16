$outputFile = "DistributionGroupMembers.csv"
$credentials = Get-Credential #Prompt for Office 365 credentials
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $credentials -Authentication Basic –AllowRedirection

#Create CSV with headers needed
Out-File -FilePath $outputFile -InputObject "Distribution List Display Name,Distribution List Email Address,User Display Name,User Email Address,Owner" -Encoding UTF8

Import-PSSession $Session -AllowClobber | Out-Null 

$distributionGroups = Get-DistributionGroup -ResultSize Unlimited

Foreach ($distributionGroup in $distributionGroups)  
{      
     
    Write-Verbose "Processing $($distributionGroup.DisplayName)..."  
    $members = Get-DistributionGroupMember -Identity $($distributionGroup.PrimarySmtpAddress)  
    Write-Verbose "Found $($members.Count) members..."
      
    Foreach ($member in $members)  
    {  
        IF ($member.Name -eq $distributionGroup.ManagedBy){
            Out-File -FilePath $OutputFile -InputObject "$($distributionGroup.DisplayName),$($distributionGroup.PrimarySMTPAddress),$($member.DisplayName),$($member.PrimarySMTPAddress), Yes" -Encoding UTF8 -append 
        }
        ELSE {
            Out-File -FilePath $OutputFile -InputObject "$($distributionGroup.DisplayName),$($distributionGroup.PrimarySMTPAddress),$($member.DisplayName),$($member.PrimarySMTPAddress)" -Encoding UTF8 -append 
        }
        Write-Verbose "`t$($distributionGroup.DisplayName),$($distributionGroup.PrimarySMTPAddress),$($member.DisplayName),$($member.PrimarySMTPAddress),$($member.RecipientType)" 
    }  
} 
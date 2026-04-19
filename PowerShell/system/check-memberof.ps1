$User = "<SAM_ACCOUNT_NAME>"

Get-ADUser -Identity $User -Properties MemberOf |
    Select-Object -ExpandProperty MemberOf |
    Get-ADGroup |
    Select-Object Name, SamAccountName, DistinguishedName

Get-ADPrincipalGroupMembership -Identity $User |
    Select-Object Name, SamAccountName, DistinguishedName

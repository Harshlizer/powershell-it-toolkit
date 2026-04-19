Connect-ExchangeOnline

$users = Get-Mailbox -RecipientTypeDetails UserMailbox -ResultSize Unlimited

foreach ($user in $users) {
    try {
        $rules = Get-InboxRule -Mailbox $user.UserPrincipalName -ErrorAction Stop

        foreach ($rule in $rules) {
            if ($rule.SubjectContainsWords -match "Please change password") {
                Write-Host "`nUser: $($user.UserPrincipalName)"
                Write-Host "  Rule name: $($rule.Name)"
                Write-Host "  Subject words: $($rule.SubjectContainsWords -join ', ')"
            }
        }
    }
    catch {
        Write-Warning "Failed to retrieve inbox rules for $($user.UserPrincipalName): $_"
    }
}

Connect-ExchangeOnline

Get-InboxRule -Mailbox <USER_EMAIL>
Get-InboxRule -Mailbox <USER_EMAIL> -Identity "<RULE_NAME>" | Format-List
Get-Mailbox <USER_EMAIL> | Select-Object ForwardingAddress, ForwardingSmtpAddress, DeliverToMailboxAndForward
Get-InboxRule -Mailbox <USER_EMAIL> | Where-Object { $_.RedirectToAddresses -ne $null -or $_.ForwardTo -ne $null }
Set-Mailbox <USER_EMAIL> -ForwardingSmtpAddress $null -DeliverToMailboxAndForward $false
Set-Mailbox <USER_EMAIL> -ForwardingSmtpAddress $null
Get-InboxRule -Mailbox <USER_EMAIL>

New-TransportRule -Name "Block External Auto Forwarding" `
    -FromScope "InOrganization" `
    -SentToScope "NotInOrganization" `
    -MessageTypeMatches "AutoForward" `
    -RejectMessageReasonText "External auto-forwarding is not allowed"

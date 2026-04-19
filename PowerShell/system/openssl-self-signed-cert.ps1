New-Item -ItemType Directory -Path "$env:USERPROFILE\local-cert" -Force | Out-Null
Set-Location "$env:USERPROFILE\local-cert"

openssl genrsa -out privkey.pem 2048
openssl req -x509 -new -key privkey.pem -out cert.pem -days 365 -subj "/C=<COUNTRY>/ST=<STATE>/L=<CITY>/O=<COMPANY>/OU=<TEAM>/CN=<HOSTNAME>"

Copy-Item cert.pem chain.pem
Get-Content cert.pem, chain.pem | Set-Content fullchain.pem

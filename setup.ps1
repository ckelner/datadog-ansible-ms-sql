# TODO: get from local machine
# NOTE: For now set this thing BEFORE you run the script
# TODO: Ansible  needs to set these things
# $env:DD_API_KEY = "<your-api-key-goes-here>"

# NOTE: You likely want to change the user 'datadog' and password 'D@tadog' to something more secure
# TODO: Get username and password from environment variables
# TODO: Ansible  needs to set these things
$USERNAME_DEFAULT = "datadog"
$PASSWORD_DEFAULT = "D@tadog"

Write-Host "Provisioning!"

mkdir C:\vm_info\

Write-Host "Downloading DD-agent installation image."
$image_url = "https://s3.amazonaws.com/ddagent-windows-stable/ddagent-cli-latest.msi"
$destin = "C:\vm_info\ddagent-cli-latest.msi"
(New-Object System.Net.WebClient).DownloadFile($image_url, $destin)

Write-Host "Installing DD-agent"
# Uncomment for debugging purposes
# Write-Host "api_key: $DD_API_KEY"

# Install Datadog Agent
msiexec /i C:\vm_info\ddagent-cli-latest.msi /l*v C:\vm_info\installation_log.txt /quiet APIKEY="$DD_API_KEY"

# wait to let the installation complete--should only be a few seconds.
Write-Host "Sleep until agent is fully installed"
Start-Sleep -s 60

stop-service datadogagent

# TODO: Ansible needs to upload these things, but for now we gonna download em yeah?
# gonna use curl... its there eh!
curl -OutFile C:\vm_info\wmi_check.yaml https://raw.githubusercontent.com/ckelner/datadog-ansible-ms-sql/master/wmi_check.yaml
curl -OutFile C:\vm_info\sqlserver.yaml https://raw.githubusercontent.com/ckelner/datadog-ansible-ms-sql/master/sqlserver.yaml

# This really pisses off the windows UI thingy, I don't know why
Copy-Item -Path C:\vm_info\wmi_check.yaml -Destination C:\ProgramData\Datadog\conf.d\wmi_check.yaml
(Get-Content C:\vm_info\sqlserver.yaml).replace("%%USERNAME%%", "${USERNAME_DEFAULT}") | Set-Content C:\vm_info\sqlserver.yaml
(Get-Content C:\vm_info\sqlserver.yaml).replace("%%PASSWORD%%", "${PASSWORD_DEFAULT}") | Set-Content C:\vm_info\sqlserver.yaml
Copy-Item -Path C:\vm_info\sqlserver.yaml -Destination C:\ProgramData\Datadog\conf.d\sqlserver.yaml
Remove-Item –path C:\ProgramData\Datadog\conf.d\sqlserver.yaml.example
Remove-Item –path C:\ProgramData\Datadog\conf.d\wmi_check.yaml.example

start-service datadogagent

# add dd-agent user for sql server
Import-Module "sqlps"
sqlcmd -S "localhost" -Q "CREATE LOGIN ${USERNAME_DEFAULT} WITH PASSWORD = '${PASSWORD_DEFAULT}';"
sqlcmd -S "localhost" -Q "CREATE USER ${USERNAME_DEFAULT} FOR LOGIN ${USERNAME_DEFAULT};"
sqlcmd -S "localhost" -Q "GRANT SELECT on sys.dm_os_performance_counters to ${USERNAME_DEFAULT};"
sqlcmd -S "localhost" -Q "GRANT VIEW SERVER STATE to ${USERNAME_DEFAULT};"

# set to mixed auth mode so datadog can connect
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | out-null
$srv = new-object ('Microsoft.SqlServer.Management.Smo.Server') "LOCALHOST"
$srv.Settings.LoginMode = [Microsoft.SqlServer.Management.SMO.ServerLoginMode]::Mixed
$srv.Alter()

net stop MSSQLSERVER /y
Start-Sleep -s 20
net start MSSQLSERVER /y

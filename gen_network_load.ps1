# total kelnerhax
while($true)
{
    $i++
    Write-Host “We have counted up to $i”
    Write-Host "Downloading DD-agent installation image."
    $image_url = "https://s3.amazonaws.com/ddagent-windows-stable/ddagent-cli-latest.msi"
    $destin = "C:\vm_info\ddagent-cli-latest.msi"
    (New-Object System.Net.WebClient).DownloadFile($image_url, $destin)
    Remove-Item –path C:\vm_info\ddagent-cli-latest.msi
}

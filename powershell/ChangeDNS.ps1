# Auto-elevate script
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "⚠️ Script not running as Administrator. Restarting with elevated privileges..."
    Start-Process powershell "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}


# Change-DNS.ps1
# Run this as Administrator!

$adapterName = "Ethernet"

function Set-DNS($servers) {
    try {
        if ($servers -eq "reset") {
            Set-DnsClientServerAddress -InterfaceAlias $adapterName -ResetServerAddresses -ErrorAction Stop
            Write-Host "DNS reset to automatic (DHCP) on ${adapterName}." -ForegroundColor Green
        }
        else {
            Set-DnsClientServerAddress -InterfaceAlias $adapterName -ServerAddresses $servers -ErrorAction Stop
            Write-Host "DNS set to $($servers -join ', ') on ${adapterName}." -ForegroundColor Green
        }
    }
    catch {
        Write-Host "Error: Could not update DNS for adapter '${adapterName}'." -ForegroundColor Red
        Write-Host "Make sure the adapter exists and run as Administrator." -ForegroundColor Yellow
    }
}

# Menu
Write-Host "Select DNS Provider for ${adapterName}:`n" -ForegroundColor Cyan
Write-Host "1. Google (IPv4 + IPv6)"
Write-Host "2. Cloudflare (IPv4 + IPv6)"
Write-Host "3. Quad9 (IPv4 + IPv6)"
Write-Host "4. Reset to Automatic (DHCP)`n"

$choice = Read-Host "Enter choice (1-4)"

switch ($choice) {
    "1" { 
        # Google
        Set-DNS @("8.8.8.8","8.8.4.4","2001:4860:4860::8888","2001:4860:4860::8844")
    }
    "2" { 
        # Cloudflare
        Set-DNS @("1.1.1.1","1.0.0.1","2606:4700:4700::1111","2606:4700:4700::1001")
    }
    "3" { 
        # Quad9
        Set-DNS @("9.9.9.9","149.112.112.112","2620:fe::fe","2620:fe::9")
    }
    "4" { 
        Set-DNS "reset"
    }
    default { 
        Write-Host "Invalid choice." -ForegroundColor Yellow 
    }
}

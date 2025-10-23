# Auto-elevate script
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "⚠️ Script not running as Administrator. Restarting with elevated privileges..."
    Start-Process powershell "-NoExit -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

# Toggle-NetAdapter.ps1
# Run this as Administrator!

function Show-Adapters {
    Get-NetAdapter | Select-Object -Property Name, InterfaceDescription, Status, MacAddress, LinkSpeed |
        Format-Table -AutoSize
}

function Prompt-AdapterSelection {
    param($adapters)
    Write-Host
    for ($i = 0; $i -lt $adapters.Count; $i++) {
        $a = $adapters[$i]
        Write-Host ("{0}) {1} - {2} - {3}" -f ($i+1), $a.Name, $a.Status, $a.InterfaceDescription)
    }
    do {
        $sel = Read-Host "`nEnter adapter number (or exact name) or 'all' to target every adapter"
        if ($sel -eq 'all') { return 'all' }
        if ($sel -match '^\d+$') {
            $idx = [int]$sel - 1
            if ($idx -ge 0 -and $idx -lt $adapters.Count) { return $adapters[$idx].Name }
        } elseif ($adapters.Name -contains $sel) {
            return $sel
        }
        Write-Host "Invalid selection. Try again." -ForegroundColor Red
    } while ($true)
}

function Prompt-Action {
    do {
        $action = Read-Host "Action? (enable / disable / toggle / status / quit)"
        switch ($action.ToLower()) {
            'enable' { return 'Enable' }
            'disable' { return 'Disable' }
            'toggle' { return 'Toggle' }
            'status' { return 'Status' }
            'quit' { return 'Quit' }
            default { Write-Host "Invalid action." -ForegroundColor Red }
        }
    } while ($true)
}

# Main loop
while ($true) {
    Clear-Host
    Write-Host "Network Adapters:" -ForegroundColor Cyan
    $adapters = Get-NetAdapter | Sort-Object -Property Name
    if (-not $adapters) {
        Write-Host "No network adapters found." -ForegroundColor Yellow
        break
    }
    Show-Adapters
    $selection = Prompt-AdapterSelection -adapters $adapters
    if ($selection -eq 'all') {
        $targetAdapters = $adapters
    } else {
        $targetAdapters = Get-NetAdapter -Name $selection -ErrorAction SilentlyContinue
        if (-not $targetAdapters) {
            Write-Host "Adapter '$selection' not found." -ForegroundColor Red
            Start-Sleep -Seconds 2
            continue
        }
    }

    $action = Prompt-Action
    if ($action -eq 'Quit') { break }
    if ($action -eq 'Status') {
        $targetAdapters | Select-Object Name, Status, LinkSpeed, InterfaceDescription | Format-Table -AutoSize
        Read-Host "`nPress Enter to continue..."
        continue
    }

    foreach ($nic in $targetAdapters) {
        try {
            if ($action -eq 'Enable') {
                if ($nic.Status -ne 'Up') {
                    Write-Host "Enabling $($nic.Name)..." -ForegroundColor Green
                    Enable-NetAdapter -Name $nic.Name -Confirm:$false -ErrorAction Stop
                    Write-Host "Enabled $($nic.Name)."
                } else {
                    Write-Host "$($nic.Name) is already Up."
                }
            } elseif ($action -eq 'Disable') {
                if ($nic.Status -ne 'Disabled') {
                    Write-Host "Disabling $($nic.Name)..." -ForegroundColor Yellow
                    Disable-NetAdapter -Name $nic.Name -Confirm:$false -ErrorAction Stop
                    Write-Host "Disabled $($nic.Name)."
                } else {
                    Write-Host "$($nic.Name) is already Disabled."
                }
            } elseif ($action -eq 'Toggle') {
                if ($nic.Status -eq 'Up') {
                    Write-Host "Toggling: Disabling $($nic.Name)..." -ForegroundColor Yellow
                    Disable-NetAdapter -Name $nic.Name -Confirm:$false -ErrorAction Stop
                    Write-Host "Disabled $($nic.Name)."
                } else {
                    Write-Host "Toggling: Enabling $($nic.Name)..." -ForegroundColor Green
                    Enable-NetAdapter -Name $nic.Name -Confirm:$false -ErrorAction Stop
                    Write-Host "Enabled $($nic.Name)."
                }
            }
        } catch {
            Write-Host "Failed to change $($nic.Name): $_" -ForegroundColor Red
        }
    }

    Write-Host
    Read-Host "Operation complete. Press Enter to continue (or type 'q' to quit)" | Out-Null
    # loop continues unless user closes or types Ctrl+C
}

# Ensure SSH-Agent service is enabled and running
$sshAgentService = Get-Service ssh-agent -ErrorAction SilentlyContinue

if ($null -eq $sshAgentService -or $sshAgentService.Status -ne 'Running') {
    Write-Host "Starting SSH-Agent..." -ForegroundColor Cyan
    Set-Service ssh-agent -StartupType Manual
    Start-Service ssh-agent
}


### ALIASES ###

Set-Alias c Clear-Host
Set-Alias vim nvim

Remove-Item alias:cd -Force
function cd {
    param (
        [string]$path = ""
    )

    if (-not (Test-Path -Path Variable:\Global:PreviousDirectory)) {
        New-Variable -Name PreviousDirectory -Scope Global -Value (Get-Location).Path
    }

    $currentDirectory = (Get-Location).Path

    if ($path -eq "-") {
        Set-Location -LiteralPath $Global:PreviousDirectory
        $Global:PreviousDirectory = $currentDirectory
    } elseif ($path -eq "") {
        Set-Location -LiteralPath $HOME
        $Global:PreviousDirectory = $currentDirectory
    } else {
        Set-Location -LiteralPath $path
        $Global:PreviousDirectory = $currentDirectory
    }
}
function la { Get-ChildItem -Force | Format-Table -AutoSize }
function ll { Get-ChildItem | Format-Table -AutoSize }
function nametab { param ([string]$newName) $Host.UI.RawUI.WindowTitle = $newName }
function touch { param($file) if (-Not (Test-Path $file)) { New-Item $file -ItemType File } else { (Get-Item $file).LastWriteTime = Get-Date } }
function which {
    param(
        [Parameter(Mandatory = $true)]
        [string]$command
    )
    $cmd = Get-Command $command -ErrorAction SilentlyContinue
    if ($cmd) {
        $cmd.Path
    }
}

### GIT ALIASES ###
function gap { git add --patch @args }
function glg { git lg -20 }


### ENV VARIABLES ###
$env:BAT_THEME = "GitHub"
$env:TERM = "xterm-256color"



# Starts oh-my-posh - keep at last line
oh-my-posh init pwsh --config ~/Downloads/omp_config.json | Invoke-Expression

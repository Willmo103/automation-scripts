function IsElevated {

    $id = [System.Security.Principal.WindowsIdentity]::GetCurrent()

    $p = New-Object System.Security.Principal.WindowsPrincipal($id)

    if ($p.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator))

    { Write-Output $true }

    else

    { Write-Output $false }

}

if (-Not(IsElevated)) {
    throw "This script must be ran as Administrator"
}

$current_dir = Get-Location

Copy-Item -Path "./basic_express_js.ps1" -Destination "C:/Program Files/"
Copy-Item -Path "./logger_decorator.ps1" -Destination "C:/Program Files/"
Copy-Item -Path "./new_bs_scraper.ps1" -Destination "C:/Program Files/"
Copy-Item -Path "./new_node_project.ps1" -Destination "C:/Program Files/"
Copy-Item -Path "./new_py_project.ps1" -Destination "C:/Program Files/"
Copy-Item -Path "./sort_files_lite.ps1" -Destination "C:/Program Files/"
Copy-Item -Path "./gitignore.ps1" -Destination "C:/Program Files/"

Set-Location "$PSHOME"
Write-Output "
Set-Alias -Name nano -Value 'notepad.exe'
Set-Alias -Name touch -Value New-Item
Set-Alias -Name new-exp  -Value 'C:/Program Files/basic_express_js.ps1'
Set-Alias -Name new-node -Value 'C:/Program Files/new_node_project.ps1'
Set-Alias -Name new-bs -Value 'C:/Program Files/new_bs_scraper.ps1'
Set-Alias -Name new-py -Value 'C:/Program Files/new_py_project.ps1'
Set-Alias -Name py-log -Value 'C:/Program Files/logger_decorator.ps1'
Set-Alias -Name sort-dir -Value 'C:/Program Files/sort_files_lite.ps1'
Set-Alias -Name git-i -Value 'C:/Program Files/gitignore.ps1'
Write-Output 'Created Aliases for commands: nano, touch, py-log, sort-dir, git-i, new-[exp, node, bs, py]" >> Profile.ps1

Write-Output "Profile Set, Returning to starting directory"
Set-Location $current_dir

param($envFilePath)

foreach ($line in (Get-Content $envFilePath)) {
    if ($line -match "^(.*?)=") {
        $envVar = $matches[1]
        $varValue = ($line -split '=')[1].Trim('"')
        [Environment]::SetEnvironmentVariable($envVar, $varValue, "User")
        Write-Output "Added new ENV variable $envVar : $varValue"
    }
}
Write-Output "Finished"

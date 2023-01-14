param($envFilePath)

foreach ($line in (Get-Content $envFilePath)) {
    if ($line -match "^(.*?)=") {
        $envVar = $matches[1]
        [Environment]::SetEnvironmentVariable($envVar, $null, "User")
        Write-Output "Removed ENV variable $envVar"
    }
    Write-Output "Finished"
}

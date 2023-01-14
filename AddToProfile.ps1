$dest = 'C:\Windows\System32\WindowsPowerShell\v1.0\Profile.ps1'
$test = '.\test.txt'
foreach ($item in (Get-Content $dest)) {

    Add-Content $test $item
}
Write-Output $test

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$dir_path,

    [Parameter(Mandatory = $false)]
    [switch]$all
)

$directory_name = (Get-Item $dir_path).Name
$dir_path = (Split-Path -Path $dir_path -NoQualifier).TrimStart("\")
$output_file_name = "$directory_name`_context.json"

$data = Get-Content "globals.json" -Raw | ConvertFrom-Json

$ignored_files = $data.ignore

$file_tree = @{}

Get-ChildItem -Path $dir_path -Recurse | ForEach-Object {
    if ($_.psiscontainer) {
        $current_dir = $file_tree
        $directory_path = (Split-Path -Path $_.FullName -NoQualifier).TrimStart("\")
        $directory_name = $_.Name
        foreach ($directory in $directory_path.Split("\").TrimEnd("\")) {
            $ignore_dir = $false
            foreach ($pattern in $ignored_files) {
                if ($directory -like $pattern) {
                    $ignore_dir = $true
                    break
                }
            }
            if ($ignore_dir -and $all.IsPresent) {
                $current_dir = $current_dir | Add-Member -Force -Type NoteProperty -Name $directory_name -Value @{}
                break
            }
            if ($current_dir.Keys -notcontains !$directory_name ) {
                $current_dir = $current_dir | Add-Member -Force -Type NoteProperty -Name $directory_name -Value @{}
            }
            $directory_name = $directory
        }
    }
    else {
        $filename = $_.Name
        $ignore_file = $false
        foreach ($pattern in $ignored_files) {
            if ($filename -like $pattern) {
                $ignore_file = $true
                break
            }
        }
        if ($ignore_file -and $all.IsPresent) {
            $file_tree[$filename] = ""
            return
        }
        $file_contents = Get-Content $_.FullName -Raw
        $file_tree[$filename] = $file_contents
    }
}

$file_tree | ConvertTo-Json | Out-File $output_file_name

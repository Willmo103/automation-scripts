Param(
    [Parameter(Mandatory = $true)]
    [string]$json_obj,

    [Parameter(Mandatory = $true)]
    [string]$path
)

function create_directory_structure($data, $path) {
    if ($data.GetType().Name -eq "Hashtable") {
        foreach ($key in $data.Keys) {
            $new_path = Join-Path $path $key
            $value = $data[$key]

            if ($value -is [string]) {
                Set-Content -Path $new_path -Value $value
            }
            else {
                New-Item -ItemType Directory -Path $new_path -Force
                create_directory_structure $value $new_path
            }
        }
    }
}

function generate_directory($json_obj, $path) {
    $data = Get-Content -Path $json_obj -Raw | ConvertFrom-Json
    create_directory_structure $data $path
    Write-Host "Directory structure generated at $path"
}

generate_directory $json_obj $path






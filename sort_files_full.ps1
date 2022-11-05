$SearchDir = Read-Host "Directory to sort?"
# Documents
$TXT_Files = Get-ChildItem -Path $SearchDir -filter "*.txt"
$PDF_Files = Get-ChildItem -Path $SearchDir -Filter "*.pdf"
$YAML_Files = Get-ChildItem -Path $SearchDir -Filter "*.yaml"
$JSON_Files = Get-ChildItem -Path $SearchDir -Filter "*.json"
$Documents = @{"Txt" = $TXT_Files; "Pdf" = $PDF_Files; "Yaml" = $YAML_Files; "Json" = $JSON_Files }

# Videos
$MOV_Files = Get-ChildItem -Path $SearchDir -Filter "*.mov"
$AVI_Files = Get-ChildItem -Path $SearchDir -Filter "*.avi"
$MP4_Files = Get-ChildItem -Path $SearchDir -Filter "*.mp4"
$MKV_Files = Get-ChildItem -Path $SearchDir -Filter "*.mkv"
$Videos = @{"Mov" = $MOV_Files; "Avi" = $AVI_Files; "Mp4" = $MP4_Files; "Mkv" = $MKV_Files }

# Images
$JPG_Files = Get-ChildItem -Path $SearchDir -filter "*.jpg"
$PNG_Files = Get-ChildItem -Path $SearchDir -Filter "*.png"
$GIF_Files = Get-ChildItem -Path $SearchDir -Filter "*.gif"
$JPEG_Files = Get-ChildItem -Path $SearchDir -Filter "*.jpeg"
$NEF_Files = Get-ChildItem -Path $SearchDir -Filter "*.NEF"
$Webp_Files = Get-ChildItem -Path $SearchDir -Filter "*.webp"
$Ico_Files = Get-ChildItem -Path $SearchDir -Filter "*.ico"
$Images = @{"Jpg" = $JPG_Files; "Png" = $PNG_Files; "Gif" = $GIF_Files; "Jpeg" = $JPEG_Files; "NEF" = $NEF_Files; "Webp" = $Webp_Files; "icons" = $Ico_Files }

# Audio
$MP3_Files = Get-ChildItem -Path $SearchDir -Filter "*.mp3"
$WAV_Files = Get-ChildItem -Path $SearchDir -Filter "*.wav"
$Audio = @{"Mp3" = $MP3_Files; "Wav" = $WAV_Files }

# zip files
$7Z_Files = Get-ChildItem -Path $SearchDir -Filter "*.7z"
$GZ_Files = Get-ChildItem -Path $SearchDir -Filter "*.gz"
$ZIP_Files = Get-ChildItem -Path $SearchDir -Filter "*.zip"
$RAR_Files = Get-ChildItem -Path $SearchDir -Filter "*.rar"
$XZ_Files = Get-ChildItem -Path $SearchDir -Filter "*.xz"
$Archives = @{"7Z" = $7Z_Files; "Gz" = $GZ_Files; "Zip" = $ZIP_Files; "Rar" = $RAR_Files; "Xz" = $XZ_Files }

# Code
$PS_Files = Get-ChildItem -Path $SearchDir -filter "*.ps1"
$Bash_Files = Get-ChildItem -Path $SearchDir -filter "*.sh"
$Py_Files = Get-ChildItem -Path $SearchDir -Filter "*.py"
$JS_Files = Get-ChildItem -Path $SearchDir -Filter "*.js"
$Code = @{"PowerShell" = $PS_Files; "Bash" = $Bash_Files; "Python" = $Py_Files; "JavaScript" = $JS_Files }

# misc
$TorrentFiles = Get-ChildItem -Path $SearchDir -Filter "*.torrent"
$EXE_Files = Get-ChildItem -Path $SearchDir -Filter "*.exe"
$MSI_Files = Get-ChildItem -Path $SearchDir -Filter "*.msi"
$Misc = @{"Torrents" = $TorrentFiles; "Programs" = $EXE_Files; "Msi" = $MSI_Files }

# Create a HashMap of the other file hashmaps
$File_Map = @{"Documents" = $Documents; "videos" = $videos; "Images" = $Images; "Audio" = $Audio; "Archives" = $Archives; "Code" = $Code; "Misc" = $Misc }

# Loop over the Hashmap for the keys and files
foreach ($file_map_key in $File_Map.Keys) {
    $file_list = $File_Map[$file_map_key]
    foreach ($key in $file_list.keys) {
        $value = $file_list[$key]
        if ($value) {
            # Create the folders for each class of item then the
            # subfolders for their specific item type using the
            # keys for the folder names.
            if (-Not (Test-Path -Path $SearchDir/$file_map_key/)) {
                New-Item -Path $SearchDir -ItemType "directory" -Name $file_map_key
            }
            if (-Not (Test-Path -Path $SearchDir/$file_map_key/$key/)) {
                New-Item "$SearchDir/$file_map_key/" -ItemType "directory" -Name $Key
            }
            # Move the items into thier specific folders
            Move-Item $value -Destination $SearchDir/$file_map_key/$key/ -Force
        }
    }
}


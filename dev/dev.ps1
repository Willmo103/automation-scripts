$dir = Read-Host "Test Path"

$files = @('test1.txt', 'test2.txt', 'test1.json', 'test1.exe', 'test1.torrent', 'test1.jpeg', 'test1.py', 'test1.7z', 'test1.zip', 'test2.zip', 'test1.js', 'test4.mp3', 'test4.mp4', 'test1.ps1', 'test1.sh', 'test1.mov', 'test1.NEF', 'test1.gif', 'test1.png', 'test4.webp', 'test.wav')

foreach ($file in $files) {
    New-Item $dir -Name $file
}

# Membuat zip source code tanpa folder build & cache (Windows PowerShell).
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root
$out = Join-Path $root 'MyHealthGw_source_2023020266.zip'
if (Test-Path $out) { Remove-Item $out }
$exclude = '\\(build|\.dart_tool|\.idea|\.gradle|\.git|\.vscode|\.cxx)(\\|$)'
$files = Get-ChildItem -Recurse -File -Force |
  Where-Object { $_.FullName.Substring($root.Length) -notmatch $exclude -and
                 $_.Extension -notin '.zip', '.iml' -and
                 $_.Name -ne 'local.properties' }
$tmp = Join-Path $env:TEMP 'myhealthgw_zip'
if (Test-Path $tmp) { Remove-Item $tmp -Recurse -Force }
foreach ($f in $files) {
  $rel = $f.FullName.Substring($root.Length + 1)
  $dest = Join-Path $tmp $rel
  New-Item -ItemType Directory -Force -Path (Split-Path $dest) | Out-Null
  Copy-Item $f.FullName $dest
}
Compress-Archive -Path (Join-Path $tmp '*') -DestinationPath $out
Remove-Item $tmp -Recurse -Force
Write-Host "Selesai: $out"

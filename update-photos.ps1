# 写真フォルダの写真を、位置情報などのメタデータを消して縮小し、サイトの photos/ に反映して push する。
# 使い方: O:\サイト\Threads\写真を公開.bat をダブルクリック（または pwsh -File update-photos.ps1）
param(
  [string]$Source = 'O:\サイト\Threads\写真フォルダ',
  [int]$MaxSize = 2000,
  [switch]$NoPush
)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$repo = $PSScriptRoot
$out  = Join-Path $repo 'photos'
New-Item -ItemType Directory -Force $out | Out-Null

$all   = @(Get-ChildItem -LiteralPath $Source -File)
$files = @($all | Where-Object { $_.Extension -match '^\.(jpe?g|png)$' } | Sort-Object LastWriteTime -Descending)
$skip  = @($all | Where-Object { $_.Extension -notmatch '^\.(jpe?g|png)$' })

$jpeg = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object MimeType -eq 'image/jpeg'
$ep = New-Object System.Drawing.Imaging.EncoderParameters 1
$ep.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, [long]85)

$list = New-Object System.Collections.Generic.List[object]
$keep = @{}
foreach ($f in $files) {
  # 公開ファイル名は中身のハッシュ（元のファイル名は出さない）
  $name = (Get-FileHash -LiteralPath $f.FullName -Algorithm SHA1).Hash.Substring(0, 12).ToLower() + '.jpg'
  $dest = Join-Path $out $name
  $keep[$name] = $true
  if (-not (Test-Path -LiteralPath $dest)) {
    $img = [System.Drawing.Image]::FromFile($f.FullName)
    try {
      if ($img.PropertyIdList -contains 0x0112) {
        switch ($img.GetPropertyItem(0x0112).Value[0]) {
          3 { $img.RotateFlip('Rotate180FlipNone') }
          6 { $img.RotateFlip('Rotate90FlipNone') }
          8 { $img.RotateFlip('Rotate270FlipNone') }
        }
      }
      $s = [Math]::Min(1.0, $MaxSize / [double][Math]::Max($img.Width, $img.Height))
      $w = [int][Math]::Round($img.Width * $s); $h = [int][Math]::Round($img.Height * $s)
      # 新しいビットマップに描き直すので、EXIF（GPS・撮影日時・機種など）は一切引き継がれない
      $bmp = New-Object System.Drawing.Bitmap $w, $h
      $g = [System.Drawing.Graphics]::FromImage($bmp)
      $g.InterpolationMode = 'HighQualityBicubic'
      $g.DrawImage($img, 0, 0, $w, $h)
      $g.Dispose()
      $bmp.Save($dest, $jpeg, $ep)
      $bmp.Dispose()
    } finally { $img.Dispose() }
    Write-Host "追加: $($f.Name)"
  }
  $b = [System.Drawing.Image]::FromFile($dest)
  $list.Add([ordered]@{ src = "photos/$name"; w = $b.Width; h = $b.Height })
  $b.Dispose()
}

# フォルダから消した写真はサイトからも消す
Get-ChildItem -LiteralPath $out -File | Where-Object { -not $keep[$_.Name] } | ForEach-Object {
  Remove-Item -LiteralPath $_.FullName; Write-Host "削除: $($_.Name)"
}

$json = if ($list.Count) { ConvertTo-Json -InputObject $list.ToArray() -Depth 3 } else { '[]' }
[IO.File]::WriteAllText((Join-Path $repo 'photos.json'), $json, (New-Object System.Text.UTF8Encoding $false))

foreach ($s in $skip) { Write-Host "スキップ（JPEG/PNG以外）: $($s.Name)" }
Write-Host "写真 $($list.Count) 枚"

if ($NoPush) { return }
git -C $repo add -A photos photos.json
if (git -C $repo status --porcelain -- photos photos.json) {
  git -C $repo commit -q -m "Update photos ($($list.Count))"
  git -C $repo push -q origin main
  Write-Host "公開しました: https://okajun777.github.io/photos.html （反映まで1分ほど）"
} else {
  Write-Host "変更はありませんでした。"
}

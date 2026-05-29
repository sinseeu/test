$listener = [System.Net.HttpListener]::new()
$listener.Prefixes.Add('http://localhost:3000/')
$listener.Start()
Write-Host "Server running at http://localhost:3000/"
$root = "C:\Users\user\Desktop\test"

$mimeTypes = @{
  '.html' = 'text/html; charset=utf-8'
  '.js'   = 'application/javascript'
  '.css'  = 'text/css'
  '.png'  = 'image/png'
  '.jpg'  = 'image/jpeg'
  '.ico'  = 'image/x-icon'
}

while ($listener.IsListening) {
  $ctx  = $listener.GetContext()
  $req  = $ctx.Request
  $res  = $ctx.Response
  $local = $req.Url.LocalPath -replace '/', '\'
  $path = Join-Path $root $local
  if (Test-Path $path -PathType Container) { $path = Join-Path $path 'index.html' }
  if (Test-Path $path) {
    $ext = [System.IO.Path]::GetExtension($path).ToLower()
    $res.ContentType = if ($mimeTypes[$ext]) { $mimeTypes[$ext] } else { 'application/octet-stream' }
    $bytes = [System.IO.File]::ReadAllBytes($path)
    $res.ContentLength64 = $bytes.Length
    $res.OutputStream.Write($bytes, 0, $bytes.Length)
  } else {
    $res.StatusCode = 404
    $msg = [System.Text.Encoding]::UTF8.GetBytes('404 Not Found')
    $res.ContentLength64 = $msg.Length
    $res.OutputStream.Write($msg, 0, $msg.Length)
  }
  $res.OutputStream.Close()
}

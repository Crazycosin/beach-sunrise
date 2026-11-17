# 把 src/index.src.html 和 vendor/ 里的 three.js 打包成一个可以直接双击打开、无需联网的 index.html。
# Chrome 不允许 file:// 页面加载本地模块文件，所以把库以 data: URL 的形式写进 import map。
# 用法：在 PowerShell 里运行  .\build.ps1
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path

function DataUrl([string]$name) {
  'data:text/javascript;base64,' + [Convert]::ToBase64String([IO.File]::ReadAllBytes((Join-Path $root "vendor\$name")))
}

$importMap = '{ "imports": {' +
  ' "three": "' + (DataUrl 'three.module.min.js') + '",' +
  ' "three/addons/controls/OrbitControls.js": "' + (DataUrl 'OrbitControls.js') + '",' +
  ' "three/addons/utils/BufferGeometryUtils.js": "' + (DataUrl 'BufferGeometryUtils.js') + '"' +
  ' } }'

$src = [IO.File]::ReadAllText((Join-Path $root 'src\index.src.html'), [Text.Encoding]::UTF8)
$pattern = '<script type="importmap">[\s\S]*?</script>'
if (-not [regex]::IsMatch($src, $pattern)) { throw '源文件里找不到 <script type="importmap">' }
$out = [regex]::Replace($src, $pattern, [Text.RegularExpressions.MatchEvaluator] { param($m) "<script type=`"importmap`">$importMap</script>" })

[IO.File]::WriteAllText((Join-Path $root 'index.html'), $out, (New-Object Text.UTF8Encoding $false))
'已生成 index.html（{0:N0} KB）' -f ((Get-Item (Join-Path $root 'index.html')).Length / 1KB)

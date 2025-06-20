$chars = @()
$chars += 48..57
$chars += 65..90
$chars += 97..122
$randomTitle = -join (1..8 | ForEach-Object { [char](Get-Random -InputObject $chars) })
$Host.UI.RawUI.WindowTitle = $randomTitle


Write-Host "[提示] " -ForegroundColor Blue -NoNewline
Write-Host "本程序完全免费，如果你是付费购买的说明你被骗了！"
Write-Host "[提示] " -ForegroundColor Blue -NoNewline
Write-Host "如遇到问题请加入QQ交流群:1006469206进行反馈。"

Write-Host "请选择脚本模式："
Write-Host "1. 在线版本"
Write-Host "2. 离线版本（不推荐）"
$choice = Read-Host "请输入数字 1 或 2"

if ($choice -eq "1") {
    Write-Host "[信息] " -ForegroundColor Green -NoNewline
    Write-Host "正在加载在线脚本资源，请稍后！"
    Invoke-Expression(Invoke-RestMethod "https://data.3mc.top/heypixel/OldTarkovPack/1.0.0.php")
}
elseif ($choice -eq "2") {


Write-Host "[提示] " -ForegroundColor Blue -NoNewline
Write-Host "您当前正在使用离线版本,此版本仅确保基础功能可用,不确保新功能及时更新。"

# 检查执行策略，若为Restricted或RemoteSigned则修改为RemoteSigned
$currentPolicy = Get-ExecutionPolicy
if ($currentPolicy -eq "Restricted" -or $currentPolicy -eq "RemoteSigned") {
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
}


# 设置 MCLDownload 文件夹路径
$drives = Get-PSDrive -PSProvider FileSystem | Select-Object -ExpandProperty Root
$foundDirs = @()
foreach ($drive in $drives) {
    $path = Join-Path $drive "MCLDownload"
    if (Test-Path $path) {
        $foundDirs += $path
    }
}
Write-Host "请选择游戏路径设置方式："
Write-Host "1. 自动查找路径 (仅163官服)"
Write-Host "2. 手动输入路径 (163/4399)"
$choice = Read-Host "请输入选项 (1 或 2)"
if ($choice -eq "1") {
    if ($foundDirs.Count -eq 0) {
        Write-Host "[警告] " -ForegroundColor Yellow -NoNewline
        Write-Host "未找到 MCLDownload 文件夹，请手动输入路径。"
        $baseDir = Read-Host "请输入路径"
    } elseif ($foundDirs.Count -eq 1) {
        $baseDir = $foundDirs[0]
        Write-Host "[信息] " -ForegroundColor Green -NoNewline
        Write-Host "已找到 MCLDownload 文件夹: $baseDir"
    } else {
        Write-Host "[警告] " -ForegroundColor Yellow -NoNewline
        Write-Host "在多个磁盘中找到 MCLDownload 文件夹，请选择一个："
        for ($i = 0; $i -lt $foundDirs.Count; $i++) {
            Write-Host "$($i+1). $($foundDirs[$i])"
        }
        $selection = Read-Host "请输入选项 (1-$($foundDirs.Count))"
        if ($selection -match "^\d+$" -and [int]$selection -ge 1 -and [int]$selection -le $foundDirs.Count) {
            $baseDir = $foundDirs[[int]$selection - 1]
        } else {
            Write-Host "[错误] " -ForegroundColor Red -NoNewline
            Write-Host "无效的选择！"
            Start-Sleep -Milliseconds 10000
            exit
        }
    }
} elseif ($choice -eq "2") {
    $baseDir = Read-Host "请输入路径"
} else {
    Write-Host "[错误] " -ForegroundColor Red -NoNewline
    Write-Host "无效的选项！"
    Start-Sleep -Milliseconds 30000
    exit
}

if (-not (Test-Path $baseDir)) {
    Write-Host "[错误] " -ForegroundColor Red -NoNewline
    Write-Host "$baseDir 目录不存在，请检查路径是否正确。"
    Start-Sleep -Milliseconds 30000
    exit
}



$minecraft = Join-Path $baseDir "\Game\.minecraft\"

# 下载依赖文件
try {
    if (!(Test-Path $minecraft\heypixel\packs\bKoD0ZJCRiVdn4LoKanhRj7z.zip)) {
        Write-Host "[信息] " -ForegroundColor Green -NoNewline
        Write-Host "下载依赖文件中..."
        Invoke-WebRequest -Uri "https://data.3mc.top/heypixel/OldTarkovPack/bKoD0ZJCRiVdn4LoKanhRj7z.zip" -OutFile $minecraft\heypixel\packs\bKoD0ZJCRiVdn4LoKanhRj7z.zip | Out-Null
        Write-Host "[信息] " -ForegroundColor Green -NoNewline
        Write-Host "成功下载依赖文件"
    }
}
catch {
    Write-Host "[错误] " -ForegroundColor Red -NoNewline
    Write-Host "下载依赖文件时出现错误！"
    Start-Sleep -Milliseconds 30000
    exit
}

# 检测是否开启宝马

$windowTitle = "布吉岛"
$process = Get-Process | Where-Object { $_.MainWindowTitle -eq $windowTitle }

if ($process) {
    $process.Kill()
    Write-Host "[警告] " -ForegroundColor Yellow -NoNewline
    Write-Host "检测到您未关闭宝马岛，你应该先启动本程序后在进入宝马岛服务器，已尝试关闭宝马岛。"
    Start-Sleep -Milliseconds 3000
}

# 替换配置文件

$path = "$minecraft\heypixel\options.txt"
$replaced = $false

(Get-Content $path) | ForEach-Object {
    if ($_ -like "resourcePacks:*") {
        $replaced = $true
        'resourcePacks:["vanilla","mod_resources","file/bKoD0ZJCRiVdn4LoKanhRj7z.zip"]'
    } else {
        $_
    }
} | Set-Content $path

if ($replaced) {
    Write-Host "[信息] " -ForegroundColor Green -NoNewline
    Write-Host "材质包已覆盖，请启动游戏检查是否成功。"
} else {
    Write-Host "[错误] " -ForegroundColor Red -NoNewline
    Write-Host "替换失败，未找到 resourcePacks 项。"
}

Start-Sleep -Milliseconds 1000000

}
else {
    Write-Host "无效的选择，请重新运行脚本并输入 1 或 2"
    Start-Sleep -Milliseconds 1000000
}


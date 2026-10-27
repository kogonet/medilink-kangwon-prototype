# 의사 사진 파일명 정리 스크립트
# 형식: 진료과-이름.확장자

$folder = Split-Path -Parent $MyInvocation.MyCommand.Path

$depts = @(
    '소아정신건강의학과','방사선종양학과','마취통증의학과','소아흉부외과',
    '류마티스내과','정신건강의학과','소화기내과','비뇨의학과',
    '진단검사의학과','직업환경의학과','신경외과','내분비내과',
    '이비인후과','가정의학과','영상의학과','재활의학과',
    '정형외과','호흡기내과','혈액종양내과','감염내과',
    '흉부외과','응급의학과','핵의학과','신경과',
    '신장내과','심장내과','병리과','산부인과',
    '성형외과','안과','외과','치과','피부과','마취통증'
) | Sort-Object -Property Length -Descending

$stopWords = @('홈페이지용','홈페이지','교수님','선생님','센터장님','교수','선생','센터장','직접제공','프로필','사진')

function Extract-Name($s) {
    $s = $s.TrimStart('_- ')
    foreach ($sw in $stopWords) { $s = $s.Replace($sw, ' ') }
    $matches = [regex]::Matches($s, '[가-힣]+')
    foreach ($m in $matches) {
        if ($m.Value.Length -ge 2 -and $m.Value.Length -le 4) { return $m.Value }
    }
    if ($matches.Count -gt 0) { return $matches[0].Value }
    return $null
}

function Parse-Filename($stem) {
    # 진료과가 끝에 있는 경우
    foreach ($dept in $depts) {
        if ($stem.EndsWith($dept)) {
            $remainder = $stem.Substring(0, $stem.Length - $dept.Length).TrimEnd('_- ')
            $name = Extract-Name $remainder
            if ($name) { return $dept, $name }
        }
    }
    # 앞 숫자 제거
    $stemClean = $stem -replace '^\d+[_\-\s]+', ''
    # 진료과가 앞에 있는 경우
    foreach ($dept in $depts) {
        if ($stemClean.StartsWith($dept)) {
            $remainder = $stemClean.Substring($dept.Length).TrimStart('_- ')
            $name = Extract-Name $remainder
            if ($name) { return $dept, $name }
        }
    }
    return $null, $null
}

$files = Get-ChildItem -Path $folder -File | Where-Object { $_.Extension -match '\.(jpg|jpeg|png|gif|bmp|webp)$' }

$count = 0
$failed = @()

foreach ($file in $files | Sort-Object Name) {
    $stem = $file.BaseName
    $ext  = $file.Extension
    $dept, $name = Parse-Filename $stem
    if ($dept -and $name) {
        $newName = "$dept-$name$ext"
        if ($newName -eq $file.Name) { continue }
        $newPath = Join-Path $folder $newName
        if (Test-Path $newPath) {
            Write-Host "[건너뜀] 이미 존재: $newName"
            continue
        }
        Write-Host "$($file.Name)"
        Write-Host "  -> $newName"
        Rename-Item -Path $file.FullName -NewName $newName
        $count++
    } else {
        $failed += $file.Name
    }
}

Write-Host ""
Write-Host "완료: $count 개 파일 변경"

if ($failed.Count -gt 0) {
    Write-Host ""
    Write-Host "[처리 불가] $($failed.Count)개:"
    foreach ($f in $failed) { Write-Host "  $f" }
}

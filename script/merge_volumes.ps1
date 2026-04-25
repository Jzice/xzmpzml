# Function to merge volumes
function Merge-Volumes {
    param(
        [string]$OutputPath,
        [string[]]$Volumes,
        [string]$Header
    )

    $content = $Header

    foreach ($v in $Volumes) {
        # Get volume name from README
        $readmeFiles = Get-ChildItem -Path "第${v}卷-*" -Directory -ErrorAction SilentlyContinue
        if ($readmeFiles) {
            $readme = Get-ChildItem -Path "$($readmeFiles[0].FullName)/README.md" -ErrorAction SilentlyContinue
            if ($readme) {
                $firstLine = Get-Content $readme.FullName -Encoding UTF8 | Select-Object -First 1
                $volName = $firstLine -replace '^[﻿﻿|﻿]',''
                $content += "`r`n$volName`r`n`r`n"
            }
        }

        # Get all chapter files in order
        if ($readmeFiles) {
            $chapters = Get-ChildItem -Path "$($readmeFiles[0].FullName)" -Filter '第*.md' -File -ErrorAction SilentlyContinue | Sort-Object Name
            foreach ($ch in $chapters) {
                $chContent = Get-Content $ch.FullName -Encoding UTF8
                $content += "`r`n" + ($chContent -join "`r`n") + "`r`n"
            }
        }
    }

    $content | Out-File -FilePath $OutputPath -Encoding UTF8
}

# Header
$header = @"
# 修真门派掌门路

> **作者**：齐可休
> **类型**：仙侠·修真
> **状态**：连载中
> **总章节数**：697章
> **总卷数**：25卷

---

"@

# Set working directory
Set-Location "D:\doc\zml\修真门派掌门路"

# 001-010卷
$vols1 = @('001','002','003','004','005','006','007','008','009','010')
Merge-Volumes -OutputPath "D:\doc\zml\修真门派掌门路_第01-10卷.md" -Volumes $vols1 -Header $header
Write-Host "Created 001-010卷"

# 011-020卷
$vols2 = @('011','012','013','014','015','016','017','018','019','020')
Merge-Volumes -OutputPath "D:\doc\zml\修真门派掌门路_第11-20卷.md" -Volumes $vols2 -Header $header
Write-Host "Created 011-020卷"

# 021-025卷
$vols3 = @('021','022','023','024','025')
Merge-Volumes -OutputPath "D:\doc\zml\修真门派掌门路_第21-25卷.md" -Volumes $vols3 -Header $header
Write-Host "Created 021-025卷"

Write-Host "All done!"
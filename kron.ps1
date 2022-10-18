function build-folderStructure {
    $curYear = (Get-Date).year
    $newYearFolder = "$env:kronFolder\$curYear"
    mkdir $newYearFolder
    mkdir "$newYearFolder\assets"
    Push-Location $newYearFolder
    $months = 1..12
    ForEach ($MM in $months) {
        if ($MM -lt 10) { $MM = "0" + [string]$MM } else { [string]$MM }
        mkdir "$MM-$curYear"
    }
    Pop-Location
}

function backup {
    Set-Location $kronFolder
    $today = $today.ToString("yyyy-MM-dd")
    git add . 
    git commit -m "$today" 
    git push
}


function add-imageFromYesterday([int]$span) {
    $i = 1
    $j = 1
    $masterImageFolder = "$env:kronMasterImageFolder\$yyyy"
    if (-not (Test-Path "$env:kronMasterImageFolder\$yyyy")) { mkdir "$env:kronMasterImageFolder\$yyyy" }
    $kronImageFolder = "$kronfolder\$yyyy\assets" 
    
    for ($i; $i -le $span; $i++) {
        $spanObject = New-TimeSpan -Days $i
        <# START OF HARD-CODED-SECTION #>
        $timeStampPattern = "yyyyMMdd"
        $yesterdayPattern = ($today - $spanObject).ToString($timeStampPattern)     
        $photosPattern = "IMG_$yesterdayPattern.*kron"
        <# END OF HARD-CODED-SECTION #>
       dir $masterImageFolder | 
            Where-Object { $_.Name -match $photosPattern } | 
            ForEach-Object {
                magick convert $_ -resize 800x600 -strip -define jpeg:extent=200kb "$kronImageFolder\$yesterday-$j.jpg"
                Add-Content $kronPost -Value "`r`n![$yesterday](../assets/$yesterday-$j.jpg)"
                $j++
            }
    }
    
}

function create-post([int]$span) {
    If (Test-Path $kronPost) {
        code $kronFolder
        Invoke-Item $kronPost
    }
    Else {
        If (Read-Host "Modify mediaList? (y/Enter)") { Invoke-Item $mediaList }
        New-Item $kronPost
        Set-Content $kronPost -Value "### $yesterday"
        add-imageFromYesterday($span)
        code $kronFolder
        Invoke-Item $kronPost
    }
} 

function merge-posts {
    [string]$mergeMonth = Read-Host "Month to merge (with a leading zero)"
    [string]$yyyy = Read-Host "Year to merge (yyyy format)"
    $kronFolderMergeMonth = "$kronFolder\$yyyy\$mergeMonth-$yyyy"
    Set-Location $kronFolderMergeMonth
    
    $monthly = New-Item "$mergeMonth-$yyyy.md" -Force
    $monthlyPdf = "$mergeMonth-$yyyy.pdf"
    
    Add-Content $monthly -Value "% $mergeMonth-$yyyy"
    Add-Content $monthly -Value "\pagenumbering{gobble}"
    
    dir $yyyy*.md | % {
        $dailyEntry = "`r`n" + (Get-Content $_ -Raw)
        Add-Content $monthly -Value $dailyEntry }
    
    (Get-Content $monthly) -replace "assets/.*", "$&{ width=70% }" |
        Set-Content $monthly

    pandoc -V geometry:"top=2cm, bottom=1.5cm, left=2cm, right=2cm" -f markdown-implicit_figures -o $monthlyPdf $monthly
}

function new-kron {
    param (
        [switch]$merge,
        [int]$span = 1
    )
    $oneDay = New-TimeSpan -Days 1
    $today = Get-Date
    [string]$yyyy = $today.Year.toString()
    $MM = ($today - $oneDay).Month
    if ($MM -lt 10) { $MM = "0" + [string]$MM } else { $MM = [string]$MM }
    $yesterday = ($today - $oneDay).ToString("yyyy-MM-dd")
    $kronFolder = $env:kronFolder
    if (-not (Test-Path "$kronFolder\$yyyy")) { build-folderStructure }
    $kronFolderCurMonth = "$kronFolder\$yyyy\$MM-$yyyy\"
    $mediaList = "$kronFolder\$yyyy\mediaList.md"

    if ($merge) { merge-posts } 
    else { 
        $kronPost = "$kronFolderCurMonth\$yesterday.md"
        create-post($span) 
    }    
    backup

    <#
    .SYNOPSIS
        A script that creates an markdown entry of the dialy journal
    .DESCRIPTION
        Switches:
        -merge    | merges all markdown files into a monthly .pdf file for potential print-out
        -span <n> | looks for images from <n>-days ago; default is 1
    #>

}

If ($MyInvocation.InvocationName -eq '.') { new-kron }
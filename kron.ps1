function backup {
    Set-Location $kronFolder
    $today = $today.ToString("yyyy-MM-dd")
    git add . && git commit -m "$today" && git push
}


function add-imageFromYesterday {
    $span = (($today).DayOfWeek -ne "Tuesday") ? 1 : 3
    $i = 1
    $j = 1
    $masterImageFolder = "c:\Users\Admin\Documents\familia\fotky\$yyyy\" #edit this — folder will all photos
    $kronImageFolder = "$kronfolder\$yyyy\assets" 
    
    for ($i; $i -le $span; $i++) {
        $spanObject = New-TimeSpan -Days $i
        $yesterdayImg = ($today - $spanObject).ToString("yyyyMMdd")
        dir "$masterImageFolder\IMG_$yesterdayImg*" | 
            % {
                magick convert $_ -resize 800x600 -strip -define jpeg:extent=200kb "$kronImageFolder\$yesterday-$j.jpg"
                Add-Content $kronPost -Value "`r`n![$yesterday](../assets/$yesterday-$j.jpg)"
                $j++
            }
    }
    
}


function create-post {
    If (Test-Path $kronPost) {
        code $kronFolder
        Invoke-Item $kronPost
    }
    Else {
        New-Item $kronPost
        Set-Content $kronPost -Value "### $yesterday"
        add-imageFromYesterday
        code $kronFolder
        If(Read-Host "Modify mediaList? (y/Enter)") {Invoke-Item $mediaList}
        Invoke-Item $kronPost
    }
} 

function merge-posts {
    [string]$mergeMonth = Read-Host "Month to merge (with a leading zero)"
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


function new-kron ([switch]$merge) {
    $oneDay = New-TimeSpan -Days 1
    $today = Get-Date
    [string]$yyyy = $today.Year.toString()
    $MM = ($today - $oneDay).Month
    $MM = ($MM -lt 10) ? "0" + [string]$MM : [string]$MM
    $yesterday = ($today - $oneDay).ToString("yyyy-MM-dd")
    $kronFolder = "c:\Users\Admin\Documents\familia\kron" #edit
    $kronFolderCurMonth = "$kronFolder\$yyyy\$MM-$yyyy\"
    $mediaList = "$kronFolder\$yyyy\mediaList.md"

    if ($merge) {merge-posts} 
    else { 
        $kronPost = "$kronFolderCurMonth\$yesterday.md"
        create-post 
        }    
    backup
}
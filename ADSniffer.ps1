param (
    [Alias("p")]
    [string]$Path = ".",

    [Alias("o")]
    [string]$Output,

    [switch]$Recursive
)

if (-Not (Test-Path $Path)) {
    Write-Error "Invalid Path: $Path"
    exit
}

if ($Output) {
    try {
        Clear-Content -Path $Output -ErrorAction SilentlyContinue
    } catch {
        Write-Error "Unable to write to the output file: $Output"
        exit
    }
}

$streamCount = 0
$fileCount = 0

function Log {
    param(
        [string]$Text,
        [string]$Color = "White"
    )
    Write-Host $Text -ForegroundColor $Color
    if ($Output) {
        Add-Content -Path $Output -Value $Text
    }
}

function Get-ADS {
    param (
        [string]$FilePath
    )

    $script:fileCount++ 

    $streams = Get-Item -Path "$FilePath" -Stream * -ErrorAction SilentlyContinue |
               Where-Object { $_.Stream -ne "::$DATA" }

    if ($streams.Count -gt 0) {
        Log "`nFile: $FilePath" "White"
        foreach ($stream in $streams) {
            $streamName = $stream.Stream
            $sizeKB = [math]::Round($stream.Length / 1KB, 2)
            $tag = if ($streamName -match "\.(exe|ps1|bat|dll|vbs)$") { "[CAUTION]" } else { "[STREAM]" }
            if ($tag -eq "[CAUTION]") {
                Log "    - $tag $streamName ($sizeKB KB)" "Red"
            } else {
                Log "    - $tag $streamName ($sizeKB KB)" "Green"
            }
            $script:streamCount++ 
        }
    }
}

$files = if ($Recursive) {
    Get-ChildItem -Path $Path -Recurse -File -ErrorAction SilentlyContinue
} else {
    Get-ChildItem -Path $Path -File -ErrorAction SilentlyContinue
}

foreach ($file in $files) {
    Get-ADS -FilePath $file.FullName
}

Log "`n--- SCAN COMPLETE ---" "White"
Log "Analyzed files: $fileCount" "White"
Log "Detected streams:  $streamCount" "White"
Log ""
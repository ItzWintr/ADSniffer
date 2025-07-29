param (
    [Alias("p")]
    [string]$Path = ".",
    
    [Alias("o")]
    [string]$Output,

    [switch]$Recursive
)

# Check if it's a valid path <3
if (-Not (Test-Path $Path)) {
    Write-Error "Invalid path: $Path"
    exit
}

# If an output file is specified, create ir and write to it, i mean, pretty obvious.
if ($Output) {
    try {
        Clear-Content -Path $Output -ErrorAction SilentlyContinue
    } catch {
        Write-Error "Cannot write to output file: $Output"
        exit
    }
}

$streamCount = 0
$fileCount = 0

function Log {
    param([string]$Text)
    Write-Host $Text
    if ($Output) {
        Add-Content -Path $Output -Value $Text
    }
}

function Get-ADS {
    param (
        [string]$FilePath
    )

    $streams = Get-Item -Path "$FilePath" -Stream * -ErrorAction SilentlyContinue |
               Where-Object { $_.Stream -ne "::$DATA" }

    if ($streams.Count -gt 0) {
        Log "`nFile: $FilePath"
        foreach ($stream in $streams) {
            $streamName = $stream.Stream
            $sizeKB = [math]::Round($stream.Length / 1KB, 2)
            $tag = if ($streamName -match "\.(exe|ps1|bat|dll|vbs)$") { "[CAREFUL!]" } else { "[STREAM]" }
            Log "  └─ $tag $streamName ($sizeKB KB)"
            $streamCount++
        }
    }

    $fileCount++
}

# Time to get the files!
Log "--- STARTING ADS SCAN ---"
Log "Scanning on path: $Path"
$files = if ($Recursive) {
    Get-ChildItem -Path $Path -Recurse -File -ErrorAction SilentlyContinue
} else {
    Get-ChildItem -Path $Path -File -ErrorAction SilentlyContinue
}

foreach ($file in $files) {
    Get-ADS -FilePath $file.FullName
}

# Resumen
Log "`--- SCAN COMPLETE :D ---"
Log "Analyzed Files: $fileCount"
Log "Detected Streams:  $streamCount"
# ADSniffer.ps1 startup script
# This script scans for Alternate Data Streams (ADS) in files within a specified directory.
# It can operate recursively and log results to a specified output file or the console.
param (
    [Alias("p")]
    [string]$Path = ".",

    [Alias("o")]
    [string]$Output,

    [switch]$Recursive
)
# Here we check if the path is valid and if the output file can be written to.
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
# Some decorations for the output
Write-Host "ADSniffer - Alternate Data Stream Scanner" -ForegroundColor Cyan
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
# This function retrieves and logs alternate data streams (ADS) for a given file.
# It counts the number of files and streams processed, and logs them in a structured format.
function Get-ADS {
    param (
        [string]$FilePath
    )

    $script:fileCount++

    try {
        $streams = Get-Item -Path "$FilePath" -Stream * -ErrorAction Stop |
                   Where-Object { $_.Stream -ne "::$DATA" }
    } catch {
        # If the file does not have any ADS or cannot be accessed, we skip it.
        Log "Error accessing file: $FilePath" "Red"
        return
    }

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
# Additional arguments and options for the script
if ($Output) {  
    Log "Output will be saved to: $Output" "White"
} else {
    Log "No output file specified. Results will be displayed in the console." "White"
}
$files = if ($Recursive) {
    Get-ChildItem -Path $Path -Recurse -File -ErrorAction SilentlyContinue
} else {
    Get-ChildItem -Path $Path -File -ErrorAction SilentlyContinue
}

foreach ($file in $files) {
    Get-ADS -FilePath $file.FullName
}
# Final output summary, not much to say here
Log "`n--- SCAN COMPLETE ---" "White"
Log "Analyzed files: $fileCount" "White"
Log "Detected streams:  $streamCount" "White"
Log ""
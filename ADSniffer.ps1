param (
    [Alias("p")]
    [string]$Path = ".",
    
    [Alias("o")]
    [string]$Output,

    [switch]$Recursive
)

if (-Not (Test-Path $Path)) {
    Write-Error "Ruta no válida: $Path"
    exit
}

if ($Output) {
    try {
        Clear-Content -Path $Output -ErrorAction SilentlyContinue
    } catch {
        Write-Error "No se puede escribir en el archivo de salida: $Output"
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
        Log "`nArchivo: $FilePath"
        foreach ($stream in $streams) {
            $streamName = $stream.Stream
            $sizeKB = [math]::Round($stream.Length / 1KB, 2)
            $tag = if ($streamName -match "\.(exe|ps1|bat|dll|vbs)$") { "[PELIGRO]" } else { "[STREAM]" }
        Log "    - $tag $streamName ($sizeKB KB)"
            $streamCount++
        }
    }

    $fileCount++
}

$files = if ($Recursive) {
    Get-ChildItem -Path $Path -Recurse -File -ErrorAction SilentlyContinue
} else {
    Get-ChildItem -Path $Path -File -ErrorAction SilentlyContinue
}

foreach ($file in $files) {
    Get-ADS -FilePath $file.FullName
}

Log "`n--- ESCANEO COMPLETADO ---"
Log "Archivos analizados: $fileCount"
Log "Streams detectados:  $streamCount"

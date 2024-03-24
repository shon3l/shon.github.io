$timeoutCount = 0
$filePath = "ping_stats.txt"

# Function to calculate and display the statistics
function DisplayStats {
    $currentMinute = (Get-Date).Minute
    $elapsedSeconds = ($currentMinute - $previousMinute) * 60 + (Get-Date).Second

    $totalCount = 0
    $lossPercentage = 0

    if ($elapsedSeconds -gt 0) {
        $totalCount = $elapsedSeconds
        $lossPercentage = ($timeoutCount / $totalCount) * 100
        $lossPercentage = [Math]::Round($lossPercentage, 4)
    }

    $stats = "Timeouts: $timeoutCount / $totalCount"
    $stats += "`nPercentage: $lossPercentage%"
    Write-Host $stats
    $stats | Out-File -Append -FilePath $filePath
}


# Function to continuously ping and capture timeouts
function PingGoogle {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    try {
        $pingResult = Test-Connection google.com -Count 1 -ErrorAction Stop

        if ($pingResult.ResponseTime -gt 0) {
            $pingOutput = "${timestamp}: Reply from google.com -> OK"
        } else {
            $pingOutput = "${timestamp}: Request timed out -> Connection Down"
            $script:timeoutCount++
        }
    } catch {
        $pingOutput = "${timestamp}: Request timed out -> Connection Down"
        $script:timeoutCount++
    }

    Write-Host $pingOutput
    $pingOutput | Out-File -Append -FilePath $filePath
}

# Main loop to ping every second and display statistics every minute
try {
    $previousMinute = (Get-Date).Minute

    while ($true) {
        $currentMinute = (Get-Date).Minute

        if ($currentMinute -ne $previousMinute) {
            DisplayStats
            $timeoutCount = 0
            $previousMinute = $currentMinute
        }

        PingGoogle
        Start-Sleep -Seconds 1
    }
} catch {
    Write-Host "An error occurred: $_"
}

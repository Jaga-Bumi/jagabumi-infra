# Load Test untuk trigger Knative Autoscaling
param(
    [int]$Duration = 60,
    [int]$Concurrent = 50,
    [string]$Url = "http://laravel-app.jaga-bumi.ryutamin.tech"
)

Write-Host "=== Knative Load Test ===" -ForegroundColor Green
Write-Host "URL: $Url" -ForegroundColor Cyan
Write-Host "Duration: $Duration seconds" -ForegroundColor Cyan
Write-Host "Concurrent requests: $Concurrent" -ForegroundColor Cyan
Write-Host ""
Write-Host "Starting load test..." -ForegroundColor Yellow
Write-Host "Watch scaling in another terminal with: .\scripts\monitor-scaling.ps1" -ForegroundColor Yellow
Write-Host ""

$jobs = @()
$endTime = (Get-Date).AddSeconds($Duration)

while ((Get-Date) -lt $endTime) {
    # Cleanup finished jobs
    $jobs = $jobs | Where-Object { $_.State -eq 'Running' }
    
    # Start new jobs to maintain concurrent requests
    while ($jobs.Count -lt $Concurrent -and (Get-Date) -lt $endTime) {
        $job = Start-Job -ScriptBlock {
            param($url)
            try {
                $response = Invoke-WebRequest -Uri $url -TimeoutSec 10 -UseBasicParsing
                return @{
                    StatusCode = $response.StatusCode
                    Time = (Get-Date)
                }
            } catch {
                return @{
                    StatusCode = 0
                    Error = $_.Exception.Message
                    Time = (Get-Date)
                }
            }
        } -ArgumentList $Url
        
        $jobs += $job
    }
    
    $elapsed = [math]::Round(((Get-Date) - $endTime.AddSeconds($Duration)).TotalSeconds)
    $remaining = $Duration - $elapsed
    Write-Host "`rActive requests: $($jobs.Count) | Elapsed: $elapsed s | Remaining: $remaining s" -NoNewline
    
    Start-Sleep -Milliseconds 100
}

Write-Host ""
Write-Host ""
Write-Host "Load test completed! Waiting for jobs to finish..." -ForegroundColor Green

# Wait for all jobs to complete
$jobs | Wait-Job | Out-Null

# Collect results
$results = $jobs | Receive-Job
$jobs | Remove-Job

# Display summary
Write-Host ""
Write-Host "=== Results ===" -ForegroundColor Cyan
Write-Host "Total requests: $($results.Count)"
Write-Host "Successful (200): $(($results | Where-Object { $_.StatusCode -eq 200 }).Count)"
Write-Host "Failed: $(($results | Where-Object { $_.StatusCode -ne 200 }).Count)"
Write-Host ""
Write-Host "Check pod scaling with: kubectl get pods -n jaga-bumi" -ForegroundColor Yellow

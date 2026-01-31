# Monitor Knative Scaling
Write-Host "=== Monitoring Knative Serverless Scaling ===" -ForegroundColor Green
Write-Host "Press Ctrl+C to stop" -ForegroundColor Yellow
Write-Host ""

while ($true) {
    Clear-Host
    Write-Host "=== Knative Scaling Monitor - $(Get-Date -Format 'HH:mm:ss') ===" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "Pod Count:" -ForegroundColor Yellow
    kubectl get pods -n jaga-bumi -l serving.knative.dev/service=laravel-app --no-headers | Measure-Object | ForEach-Object { "  Active Pods: $($_.Count)" }
    Write-Host ""
    
    Write-Host "Pod Status:" -ForegroundColor Yellow
    kubectl get pods -n jaga-bumi -l serving.knative.dev/service=laravel-app -o wide
    Write-Host ""
    
    Write-Host "Autoscaler Status:" -ForegroundColor Yellow
    kubectl get podautoscaler laravel-app-00005 -n jaga-bumi -o custom-columns=NAME:.metadata.name,DESIRED:.status.desiredScale,ACTUAL:.status.actualScale,READY:.status.conditions[0].status 2>$null
    Write-Host ""
    
    Write-Host "Metrics:" -ForegroundColor Yellow
    kubectl get podautoscaler laravel-app-00005 -n jaga-bumi -o jsonpath='{.status.metricsStatuses}' 2>$null
    Write-Host ""
    
    Start-Sleep -Seconds 2
}

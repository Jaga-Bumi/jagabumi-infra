# Quick Test untuk Knative Serverless
Write-Host "=== Testing Knative Serverless ===" -ForegroundColor Green
Write-Host ""

# 1. Cek current state
Write-Host "1. Current State:" -ForegroundColor Cyan
Write-Host "   Pods running:"
kubectl get pods -n jaga-bumi -l serving.knative.dev/service=laravel-app
Write-Host ""

Write-Host "   Autoscaler status:"
kubectl get podautoscaler -n jaga-bumi | Select-Object -Last 1
Write-Host ""

# 2. Service info
Write-Host "2. Knative Service:" -ForegroundColor Cyan
kubectl get ksvc laravel-app -n jaga-bumi
Write-Host ""

# 3. Min/Max scale config
Write-Host "3. Scaling Configuration:" -ForegroundColor Cyan
$minScale = kubectl get ksvc laravel-app -n jaga-bumi -o jsonpath='{.spec.template.metadata.annotations.autoscaling\.knative\.dev/min-scale}'
$maxScale = kubectl get ksvc laravel-app -n jaga-bumi -o jsonpath='{.spec.template.metadata.annotations.autoscaling\.knative\.dev/max-scale}'
$target = kubectl get ksvc laravel-app -n jaga-bumi -o jsonpath='{.spec.template.metadata.annotations.autoscaling\.knative\.dev/target}'

Write-Host "   Min Scale: $minScale"
Write-Host "   Max Scale: $maxScale"
Write-Host "   Target Concurrency: $target"
Write-Host ""

# 4. Instruksi untuk test
Write-Host "4. To Test Autoscaling:" -ForegroundColor Yellow
Write-Host "   Terminal 1: .\scripts\monitor-scaling.ps1"
Write-Host "   Terminal 2: .\scripts\load-test.ps1 -Duration 60 -Concurrent 50"
Write-Host ""
Write-Host "   Atau pakai curl/hey/ab untuk generate traffic:"
Write-Host "   hey -z 60s -c 50 http://laravel-app.jaga-bumi.ryutamin.tech"
Write-Host ""

Write-Host "5. Expected Behavior:" -ForegroundColor Green
Write-Host "   - Saat idle: min 1 pod running"
Write-Host "   - Saat high load: scale up sampai max 5 pods"
Write-Host "   - Setelah traffic turun: scale down kembali ke min 1 pod"

# Mock GitHub API server using built-in .NET HttpListener
# No external dependencies required

param(
    [int]$Port = 3000
)

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://127.0.0.1:$Port/")
$listener.Start()

Write-Host "Mock server listening on http://127.0.0.1:$Port..." -ForegroundColor Green

try {
    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response
        
        $path = $request.Url.LocalPath
        $method = $request.HttpMethod
        
        Write-Host "Mock intercepted: $method $path" -ForegroundColor Cyan
        
        $responseJson = $null

        # HealthCheck endpoint: GET /HealthCheck
        if ($method -eq "GET" -and $path -eq "/HealthCheck") {
            $statusCode = 200
            $responseJson = @{ status = "ok" } | ConvertTo-Json
        }        
        # Mock tags endpoint: /repos/:owner/:repo/tags
        elseif ($path -match '^/repos/[^/]+/[^/]+/tags$') {
            $responseJson = @(
                @{ name = "v1.0.0" }
                @{ name = "v1.2.3" }
                @{ name = "v1.2.4-dev.0001" }
                @{ name = "v2.0.0-beta.0001" }
                @{ name = "v2.0.0-test.0003" }
                @{ name = "release-candidate" }
            ) | ConvertTo-Json -Compress
        }
        # Mock compare endpoint: /repos/:owner/:repo/compare/:base...:head
        elseif ($path -match '^/repos/[^/]+/[^/]+/compare/[^/]+\.\.\.[^/]+$') {
            $responseJson = @{
                commits = @(
                    @{ commit = @{ message = "feat: add new feature" } }
                    @{ commit = @{ message = "fix: bug fix" } }
                    @{ commit = @{ message = "docs: update documentation" } }
                    @{ commit = @{ message = "BREAKING CHANGE: change API" } }
                )
            } | ConvertTo-Json -Compress -Depth 10
        }
        # Mock commits endpoint: /repos/:owner/:repo/commits
        elseif ($path -match '^/repos/[^/]+/[^/]+/commits$') {
            $responseJson = @(
                @{ commit = @{ message = "feat: initial commit" } }
                @{ commit = @{ message = "fix: small bug" } }
            ) | ConvertTo-Json -Compress -Depth 10
        }
        else {
            $response.StatusCode = 404
            $responseJson = @{ message = "Not Found" } | ConvertTo-Json
        }
        
        # Send response
        $response.ContentType = "application/json"
        $buffer = [System.Text.Encoding]::UTF8.GetBytes($responseJson)
        $response.ContentLength64 = $buffer.Length
        $response.OutputStream.Write($buffer, 0, $buffer.Length)
        $response.Close()
    }
}
finally {
    $listener.Stop()
    $listener.Close()
    Write-Host "Mock server stopped." -ForegroundColor Yellow
}
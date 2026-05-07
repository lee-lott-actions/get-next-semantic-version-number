function Get-LastStableTag {
    param(
        [string]$owner,
        [string]$repo,
        [string]$token,
        [string]$githubApiUrl
    )

    $tagsUrl = "$githubApiUrl/repos/$owner/$repo/tags?per_page=100"
    $headers = @{
        Authorization = "Bearer $token"
        "User-Agent" = "PowerShell"
        Accept = "application/vnd.github.v3+json"
    }

    try {
        $response = Invoke-WebRequest -Uri $tagsUrl -Headers $headers -Method GET
        if ($response.StatusCode -eq 200) {
            $tags = $response.Content | ConvertFrom-Json
            $stableTags = $tags | Where-Object { $_.name -match "^v\d+\.\d+\.\d+$" }
            $stableTags = @($stableTags | Sort-Object {
                $parts = $_.name -replace "^v", "" -split "\."
                [int]$parts[0]*1000000 + [int]$parts[1]*1000 + [int]$parts[2]
            } -Descending)

            if ($stableTags) {
                return [PSCustomObject]@{
                    Success = $true
                    Tag     = $stableTags[0].name
                    Error   = $null
                }
            }
            # No stable tag found
            return [PSCustomObject]@{
                Success = $true
                Tag     = $null
                Error   = $null
            }
        } else {
            Write-Host "Failed to retrieve tags. Status code: $($response.StatusCode)"
            return [PSCustomObject]@{
                Success = $false
                Tag     = $null
                Error   = "Failed to retrieve tags. Status code: $($response.StatusCode)"
            }
        }
    } catch {
        Write-Host "Failed to retrieve stable tags: $_"
        return [PSCustomObject]@{
            Success = $false
            Tag     = $null
            Error   = "Exception: $($_.Exception.Message)"
        }
    }
}
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
        Accept = "application/vnd.github+json"
        "X-GitHub-Api-Version" = "2026-03-10"
    }

    try {
        $response = Invoke-WebRequest -Uri $tagsUrl -Headers $headers -Method GET -SkipHttpErrorCheck
        
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
            $errorMsg = "Failed to retrieve tags. Status code: $($response.StatusCode)"
            Write-Host $errorMsg
            return [PSCustomObject]@{
                Success = $false
                Tag     = $null
                Error   = $errorMsg
            }
        }
    } catch {
        $errorMsg = "Failed to retrieve stable tags. Exception: $($_.Exception.Message)"
        Write-Host $errorMsg
        return [PSCustomObject]@{
            Success = $false
            Tag     = $null
            Error   = $errorMsg
        }
    }
}

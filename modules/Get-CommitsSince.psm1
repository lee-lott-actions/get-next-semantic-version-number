function Get-CommitsSince {
    param(
        [string]$owner,
        [string]$repo,
        [string]$branch,
        [string]$token,
        [string]$FromRef,
        [string]$githubApiUrl
    )

    $headers = @{
        Authorization = "Bearer $token"
        "User-Agent" = "PowerShell"
        Accept = "application/vnd.github.v3+json"
    }

    try {
        if ([string]::IsNullOrEmpty($FromRef)) {
            $EncodedBranch  = [uri]::EscapeDataString($branch)            
            $url = "$githubApiUrl/repos/$owner/$repo/commits?sha=$EncodedBranch"
            $type = "commits"
        } else {
            $EncodedBranch  = [uri]::EscapeDataString($branch)
            $EncodedFromRef = [uri]::EscapeDataString($FromRef)
            $url = "$githubApiUrl/repos/$owner/$repo/compare/$EncodedFromRef...$EncodedBranch"
            $type = "compare"
        }

        $response = Invoke-WebRequest -Uri $url -Headers $headers -Method GET

        if ($response.StatusCode -eq 200) {
            $json = $response.Content | ConvertFrom-Json
            $messages = if ($type -eq "commits") {
                @($json | ForEach-Object { $_.commit.message })
            } else {
                @($json.commits | ForEach-Object { $_.commit.message })
            }
            return [PSCustomObject]@{
                Success  = $true
                Messages = $messages
                Error    = $null
            }
        } else {
            $msg = if ($type -eq "commits") {
                "Failed to retrieve commits. Status code: $($response.StatusCode)"
            } else {
                "Failed to retrieve commits from compare endpoint. Status code: $($response.StatusCode)"
            }
        
            Write-Host $msg
            return [PSCustomObject]@{
                Success  = $false
                Messages = $null
                Error    = $msg
            }
        }
    } catch {
        Write-Host "Failed to retrieve commits: $_"
        return [PSCustomObject]@{
            Success  = $false
            Messages = $null
            Error    = "Exception: $($_.Exception.Message)"
        }
    }
}
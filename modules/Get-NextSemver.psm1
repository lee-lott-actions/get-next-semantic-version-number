function Get-NextSemver {
    param(
        [string]$isPrerelease,
        [string]$prereleaseId,
        [string]$owner,
        [string]$repo,
        [string]$branch,
        [bool]$useLeadingZeros,
        [int]$numberOfLeadingZeros,
        [string]$token
    )

    # Validate required inputs
    if ([string]::IsNullOrEmpty($isPrerelease) -or
        [string]::IsNullOrEmpty($prereleaseId) -or
        [string]::IsNullOrEmpty($owner) -or
        [string]::IsNullOrEmpty($repo) -or
        [string]::IsNullOrEmpty($branch) -or
        [string]::IsNullOrEmpty($token)
    ) {
        Write-Host "Error: Missing required parameters"
        Add-Content -Path $env:GITHUB_OUTPUT -Value "error-message=Missing required parameters: isPrerelease, prereleaseId, owner, repo, branch, and token must be provided."
        Add-Content -Path $env:GITHUB_OUTPUT -Value "result=failure"
        return
    }

    Import-Module "$PSScriptRoot/Get-LastStableTag.psm1" -Force
    Import-Module "$PSScriptRoot/Get-CommitsSince.psm1" -Force
    Import-Module "$PSScriptRoot/Split-Commits.psm1" -Force
    Import-Module "$PSScriptRoot/Get-NextVersion.psm1" -Force
    
    $githubApiUrl = $env:MOCK_API
    if (-not $githubApiUrl) { $githubApiUrl = "https://api.github.com" }

    $lastStableTagResult = Get-LastStableTag -owner $owner -repo $repo -token $token -githubApiUrl $githubApiUrl
    if (-not $lastStableTagResult.Success) {
        Add-Content -Path $env:GITHUB_OUTPUT -Value "result=failure"
        Add-Content -Path $env:GITHUB_OUTPUT -Value "error-message=Get-LastStableTag failed: $($lastStableTagResult.Error)"
        Write-Host "Get-LastStableTag failed: $($lastStableTagResult.Error)"
        return
    }

    $lastStableTag = $lastStableTagResult.Tag
    if ($null -eq $lastStableTag) {
        Write-Host "No stable tag found (first release or no previous tags)."
    } else {
        Write-Host "Last stable tag: $lastStableTag"
    }

    $commitsResult = Get-CommitsSince -owner $owner -repo $repo -branch $branch -token $token -FromRef $lastStableTag -githubApiUrl $githubApiUrl
    if (-not $commitsResult.Success) {
        Add-Content -Path $env:GITHUB_OUTPUT -Value "result=failure"
        Add-Content -Path $env:GITHUB_OUTPUT -Value "error-message=Get-CommitsSince failed: $($commitsResult.Error)"
        Write-Host "Get-CommitsSince failed: $($commitsResult.Error)"
        return
    }

    $commits = $commitsResult.Messages
    Write-Host "Found $($commits.Count) commits since last stable tag."
    
    $bump = if ($commits.Count -gt 0) { Split-Commits $commits } else { "none" }
    Write-Host "Version bump type: $bump"
    
    $nextVersionResult = Get-NextVersion -stableTag $lastStableTag -bump $bump -isPrerelease $isPrerelease -prereleaseId $prereleaseId -owner $owner -repo $repo -token $token -githubApiUrl $githubApiUrl -useLeadingZeros $useLeadingZeros -numberOfLeadingZeros $numberOfLeadingZeros
    if (-not $nextVersionResult.Success) {
        Add-Content -Path $env:GITHUB_OUTPUT -Value "result=failure"
        Add-Content -Path $env:GITHUB_OUTPUT -Value "error-message=Get-NextVersion failed: $($nextVersionResult.Error)"
        Write-Host "Get-NextVersion failed: $($nextVersionResult.Error)"
        return
    }

    $nextVersion = $nextVersionResult.Version
    if ($bump -ne "none") {
        Write-Host "Next version: $nextVersion"
    } else {
        Write-Host "No changes detected since the last release. The current version ($nextVersion) will be reused because there are no changes that warrant updating the version number."
    }
    
    # Set outputs for GitHub Actions
    $versionNoV = $nextVersion -replace "^v", ""
    Add-Content -Path $env:GITHUB_OUTPUT -Value "result=success"
    Add-Content -Path $env:GITHUB_OUTPUT -Value "version=$versionNoV"
    Add-Content -Path $env:GITHUB_OUTPUT -Value "version_tag=$nextVersion"
    Add-Content -Path $env:GITHUB_OUTPUT -Value "release_type=$bump"
}
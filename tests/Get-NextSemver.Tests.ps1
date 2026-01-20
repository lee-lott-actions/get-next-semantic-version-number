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
        Import-Module "$PSScriptRoot/../modules/Get-NextSemver.psm1" -Force

Describe "Get-NextSemver parameter validation" {
    BeforeEach {
        $owner = "dummy-owner"
        $repo = "dummy-repo"
        $branch = "main"
        $token = "dummy-token"
        $useLeadingZeros = $true
        $numberOfLeadingZeros = 4
        $env:GITHUB_OUTPUT = "$PSScriptRoot/github_output.temp"
        if (Test-Path $env:GITHUB_OUTPUT) { Remove-Item $env:GITHUB_OUTPUT }
    }

    It "writes result=failure for empty isPrerelease" {
        Get-NextSemver `
            -isPrerelease "" `
            -prereleaseId "dev" `
            -owner $owner `
            -repo $repo `
            -branch $branch `
            -useLeadingZeros $useLeadingZeros `
            -numberOfLeadingZeros $numberOfLeadingZeros `
            -token $token

        $output = Get-Content $env:GITHUB_OUTPUT
        $output | Should -Contain "result=failure"
        $output | Should -Contain "error-message=Missing required parameters: isPrerelease, prereleaseId, owner, repo, branch, and token must be provided."
    }

    It "writes result=failure for empty prereleaseId" {
        Get-NextSemver `
            -isPrerelease "true" `
            -prereleaseId "" `
            -owner $owner `
            -repo $repo `
            -branch $branch `
            -useLeadingZeros $useLeadingZeros `
            -numberOfLeadingZeros $numberOfLeadingZeros `
            -token $token

        $output = Get-Content $env:GITHUB_OUTPUT
        $output | Should -Contain "result=failure"
        $output | Should -Contain "error-message=Missing required parameters: isPrerelease, prereleaseId, owner, repo, branch, and token must be provided."
    }

    It "writes result=failure for empty owner" {
        Get-NextSemver `
            -isPrerelease "true" `
            -prereleaseId "dev" `
            -owner "" `
            -repo $repo `
            -branch $branch `
            -useLeadingZeros $useLeadingZeros `
            -numberOfLeadingZeros $numberOfLeadingZeros `
            -token $token

        $output = Get-Content $env:GITHUB_OUTPUT
        $output | Should -Contain "result=failure"
        $output | Should -Contain "error-message=Missing required parameters: isPrerelease, prereleaseId, owner, repo, branch, and token must be provided."
    }

    It "writes result=failure for empty repo" {
        Get-NextSemver `
            -isPrerelease "true" `
            -prereleaseId "dev" `
            -owner $owner `
            -repo "" `
            -branch $branch `
            -useLeadingZeros $useLeadingZeros `
            -numberOfLeadingZeros $numberOfLeadingZeros `
            -token $token

        $output = Get-Content $env:GITHUB_OUTPUT
        $output | Should -Contain "result=failure"
        $output | Should -Contain "error-message=Missing required parameters: isPrerelease, prereleaseId, owner, repo, branch, and token must be provided."
    }

    It "writes result=failure for empty branch" {
        Get-NextSemver `
            -isPrerelease "true" `
            -prereleaseId "dev" `
            -owner $owner `
            -repo $repo `
            -branch "" `
            -useLeadingZeros $useLeadingZeros `
            -numberOfLeadingZeros $numberOfLeadingZeros `
            -token $token

        $output = Get-Content $env:GITHUB_OUTPUT
        $output | Should -Contain "result=failure"
        $output | Should -Contain "error-message=Missing required parameters: isPrerelease, prereleaseId, owner, repo, branch, and token must be provided."
    }

    It "writes result=failure for empty token" {
        Get-NextSemver `
            -isPrerelease "true" `
            -prereleaseId "dev" `
            -owner $owner `
            -repo $repo `
            -branch $branch `
            -useLeadingZeros $useLeadingZeros `
            -numberOfLeadingZeros $numberOfLeadingZeros `
            -token ""

        $output = Get-Content $env:GITHUB_OUTPUT
        $output | Should -Contain "result=failure"
        $output | Should -Contain "error-message=Missing required parameters: isPrerelease, prereleaseId, owner, repo, branch, and token must be provided."
    }
}

Describe "Get-NextSemver workflow" {
    BeforeEach {
        $owner = "dummy-owner"
        $repo = "dummy-repo"
        $branch = "main"
        $token = "dummy-token"
        $useLeadingZeros = $true
        $numberOfLeadingZeros = 4
        $env:GITHUB_OUTPUT = "$PSScriptRoot/github_output.temp"
        if (Test-Path $env:GITHUB_OUTPUT) { Remove-Item $env:GITHUB_OUTPUT }
    }

    It "writes outputs for typical stable release" {
        Mock Get-LastStableTag {
            [PSCustomObject]@{ Success = $true; Tag = "v1.2.3"; Error = $null }
        } -ModuleName Get-NextSemver
        Mock Get-CommitsSince {
            [PSCustomObject]@{ Success = $true; Messages = @("feat: new feature"); Error = $null }
        } -ModuleName Get-NextSemver
        Mock Split-Commits { "minor" } -ModuleName Get-NextSemver
        Mock Get-NextVersion {
            [PSCustomObject]@{ Success = $true; Version = "v1.3.0"; Error = $null }
        } -ModuleName Get-NextSemver

        Get-NextSemver `
            -isPrerelease "false" `
            -prereleaseId "dev" `
            -owner $owner `
            -repo $repo `
            -branch $branch `
            -useLeadingZeros $useLeadingZeros `
            -numberOfLeadingZeros $numberOfLeadingZeros `
            -token $token

        $output = Get-Content $env:GITHUB_OUTPUT
        $output | Should -Contain "version=1.3.0"
        $output | Should -Contain "version_tag=v1.3.0"
        $output | Should -Contain "release_type=minor"
    }

    It "writes outputs for pre-release version" {
        Mock Get-LastStableTag {
            [PSCustomObject]@{ Success = $true; Tag = "v1.2.3"; Error = $null }
        } -ModuleName Get-NextSemver
        Mock Get-CommitsSince {
            [PSCustomObject]@{ Success = $true; Messages = @("fix: something"); Error = $null }
        } -ModuleName Get-NextSemver
        Mock Split-Commits { "patch" } -ModuleName Get-NextSemver
        Mock Get-NextVersion {
            [PSCustomObject]@{ Success = $true; Version = "v1.2.4-dev.0001"; Error = $null }
        } -ModuleName Get-NextSemver

        Get-NextSemver `
            -isPrerelease "true" `
            -prereleaseId "dev" `
            -owner $owner `
            -repo $repo `
            -branch $branch `
            -useLeadingZeros $useLeadingZeros `
            -numberOfLeadingZeros $numberOfLeadingZeros `
            -token $token

        $output = Get-Content $env:GITHUB_OUTPUT
        $output | Should -Contain "version=1.2.4-dev.0001"
        $output | Should -Contain "version_tag=v1.2.4-dev.0001"
        $output | Should -Contain "release_type=patch"
    }

    It "writes outputs for no changes since last release" {
        Mock Get-LastStableTag {
            [PSCustomObject]@{ Success = $true; Tag = "v1.2.3"; Error = $null }
        } -ModuleName Get-NextSemver
        Mock Get-CommitsSince {
            [PSCustomObject]@{ Success = $true; Messages = @(); Error = $null }
        } -ModuleName Get-NextSemver
        Mock Split-Commits { "none" } -ModuleName Get-NextSemver
        Mock Get-NextVersion {
            [PSCustomObject]@{ Success = $true; Version = "v1.2.3"; Error = $null }
        } -ModuleName Get-NextSemver
        
        Get-NextSemver `
            -isPrerelease "false" `
            -prereleaseId "dev" `
            -owner $owner `
            -repo $repo `
            -branch $branch `
            -useLeadingZeros $useLeadingZeros `
            -numberOfLeadingZeros $numberOfLeadingZeros `
            -token $token

        $output = Get-Content $env:GITHUB_OUTPUT
        $output | Should -Contain "version=1.2.3"
        $output | Should -Contain "version_tag=v1.2.3"
        $output | Should -Contain "release_type=none"
    }

    It "writes result=failure if Get-LastStableTag fails" {
        Mock Get-LastStableTag {
            [PSCustomObject]@{ Success = $false; Tag = $null; Error = "API error" }
        } -ModuleName Get-NextSemver

        Get-NextSemver `
            -isPrerelease "false" `
            -prereleaseId "dev" `
            -owner $owner `
            -repo $repo `
            -branch $branch `
            -useLeadingZeros $useLeadingZeros `
            -numberOfLeadingZeros $numberOfLeadingZeros `
            -token $token

        $output = Get-Content $env:GITHUB_OUTPUT
        $output | Should -Contain "result=failure"
        $matches = $output | Where-Object { $_ -match "error-message=Get-LastStableTag failed: API error" }
        $matches.Count | Should -Be 1
    }

    It "writes result=failure if Get-CommitsSince fails" {
        Mock Get-LastStableTag {
            [PSCustomObject]@{ Success = $true; Tag = "v1.2.3"; Error = $null }
        } -ModuleName Get-NextSemver
        Mock Get-CommitsSince {
            [PSCustomObject]@{ Success = $false; Messages = $null; Error = "API error" }
        } -ModuleName Get-NextSemver

        Get-NextSemver `
            -isPrerelease "false" `
            -prereleaseId "dev" `
            -owner $owner `
            -repo $repo `
            -branch $branch `
            -useLeadingZeros $useLeadingZeros `
            -numberOfLeadingZeros $numberOfLeadingZeros `
            -token $token

        $output = Get-Content $env:GITHUB_OUTPUT
        $output | Should -Contain "result=failure"
        $matches = $output | Where-Object { $_ -match "error-message=Get-CommitsSince failed: API error" }
        $matches.Count | Should -Be 1
    }

    It "writes result=failure if Get-NextVersion fails" {
        Mock Get-LastStableTag {
            [PSCustomObject]@{ Success = $true; Tag = "v1.2.3"; Error = $null }
        } -ModuleName Get-NextSemver
        Mock Get-CommitsSince {
            [PSCustomObject]@{ Success = $true; Messages = @("fix: test"); Error = $null }
        } -ModuleName Get-NextSemver
        Mock Split-Commits { "patch" } -ModuleName Get-NextSemver
        Mock Get-NextVersion {
            [PSCustomObject]@{ Success = $false; Version = $null; Error = "Calculation error" }
        } -ModuleName Get-NextSemver

        Get-NextSemver `
            -isPrerelease "false" `
            -prereleaseId "dev" `
            -owner $owner `
            -repo $repo `
            -branch $branch `
            -useLeadingZeros $useLeadingZeros `
            -numberOfLeadingZeros $numberOfLeadingZeros `
            -token $token

        $output = Get-Content $env:GITHUB_OUTPUT
        $output | Should -Contain "result=failure"
        $matches = $output | Where-Object { $_ -match "error-message=Get-NextVersion failed: Calculation error" }
        $matches.Count | Should -Be 1
    }

    It "handles first release (no stable tag found)" {
        Mock Get-LastStableTag {
            [PSCustomObject]@{ Success = $true; Tag = $null; Error = $null }
        } -ModuleName Get-NextSemver
        Mock Get-CommitsSince {
            [PSCustomObject]@{ Success = $true; Messages = @("feat: init"); Error = $null }
        } -ModuleName Get-NextSemver
        Mock Split-Commits { "major" } -ModuleName Get-NextSemver
        Mock Get-NextVersion {
            [PSCustomObject]@{ Success = $true; Version = "v1.0.0"; Error = $null }
        } -ModuleName Get-NextSemver
    
        Get-NextSemver `
            -isPrerelease "false" `
            -prereleaseId "dev" `
            -owner $owner `
            -repo $repo `
            -branch $branch `
            -useLeadingZeros $useLeadingZeros `
            -numberOfLeadingZeros $numberOfLeadingZeros `
            -token $token
    
        $output = Get-Content $env:GITHUB_OUTPUT
        $output | Should -Contain "version=1.0.0"
        $output | Should -Contain "version_tag=v1.0.0"
        $output | Should -Contain "release_type=major"
    }
}
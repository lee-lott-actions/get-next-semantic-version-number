Import-Module "$PSScriptRoot/../modules/Get-LastStableTag.psm1" -Force

Describe "Get-LastStableTag" {
    BeforeEach {
        $owner = "dummy-owner"
        $repo = "dummy-repo"
        $token = "dummy-token"
        $githubApiUrl = "https://api.mytests.com"
    }
    
    It "returns the latest stable tag when multiple tags exist" {
        Mock Invoke-WebRequest {
            [PSCustomObject]@{
                StatusCode = 200
                Content = ConvertTo-Json @(
                    @{ name = "v1.0.0" },
                    @{ name = "v2.0.0" },
                    @{ name = "v1.5.0" },
                    @{ name = "v2.0.1" },
                    @{ name = "v2.0.0-dev.0001" },
                    @{ name = "feature-branch" }
                )
            }
        } -ModuleName Get-LastStableTag
        
        $result = Get-LastStableTag -owner $owner -repo $repo -token $token -githubApiUrl $githubApiUrl
        $result.Success | Should -Be $true
        $result.Tag | Should -Be "v2.0.1"
        $result.Error | Should -Be $null
    }

    It "returns null when no stable tags exist" {
        Mock Invoke-WebRequest {
            [PSCustomObject]@{
                StatusCode = 200
                Content = ConvertTo-Json @(
                    @{ name = "feature-branch" },
                    @{ name = "v1.0.0-dev.0001" }
                )
            }
        } -ModuleName Get-LastStableTag
        
        $result = Get-LastStableTag -owner $owner -repo $repo -token $token -githubApiUrl $githubApiUrl
        $result.Success | Should -Be $true
        $result.Tag | Should -Be $null
        $result.Error | Should -Be $null
    }

    It "returns the only stable tag if just one exists" {
        Mock Invoke-WebRequest {
            [PSCustomObject]@{
                StatusCode = 200
                Content = ConvertTo-Json @(
                    @{ name = "v0.1.0" },
                    @{ name = "v0.1.0-dev.0001" }
                )
            }
        } -ModuleName Get-LastStableTag
        
        $result = Get-LastStableTag -owner $owner -repo $repo -token $token -githubApiUrl $githubApiUrl
        $result.Success | Should -Be $true
        $result.Tag | Should -Be "v0.1.0"
        $result.Error | Should -Be $null
    }

    It "returns null when no tags exist at all" {
        Mock Invoke-WebRequest {
            [PSCustomObject]@{
                StatusCode = 200
                Content = ConvertTo-Json @()
            }
        } -ModuleName Get-LastStableTag
        $result = Get-LastStableTag -owner $owner -repo $repo -token $token -githubApiUrl $githubApiUrl
        $result.Success | Should -Be $true
        $result.Tag | Should -Be $null
        $result.Error | Should -Be $null
    }

    It "handles a failed API call (non-200 status code)" {
        Mock Invoke-WebRequest {
            [PSCustomObject]@{
                StatusCode = 404
                Content = ""
            }
        } -ModuleName Get-LastStableTag
        $result = Get-LastStableTag -owner $owner -repo $repo -token $token -githubApiUrl $githubApiUrl
        $result.Success | Should -Be $false
        $result.Tag | Should -Be $null
        $result.Error | Should -Match "Failed to retrieve tags. Status code: 404"
    }

    It "handles an exception thrown by Invoke-WebRequest" {
        Mock Invoke-WebRequest { throw "Network Error" } -ModuleName Get-LastStableTag
        $result = Get-LastStableTag -owner $owner -repo $repo -token $token -githubApiUrl $githubApiUrl
        $result.Success | Should -Be $false
        $result.Tag | Should -Be $null
        $result.Error | Should -Match "Exception: Network Error"
    }
}
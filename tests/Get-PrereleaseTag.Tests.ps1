Import-Module "$PSScriptRoot/../modules/Get-PrereleaseTag.psm1" -Force
Import-Module "$PSScriptRoot/../modules/Get-CurrentPrereleaseTag.psm1" -Force
Import-Module "$PSScriptRoot/../modules/Get-NextPrereleaseTag.psm1" -Force

Describe "Get-PrereleaseTag" {
    BeforeEach {
        $baseVersion = "v1.2.3"
        $prereleaseId = "dev"
        $githubApiUrl = "https://api.mytests.com"
        $owner = "dummy-owner"
        $repo = "dummy-repo"
        $token = "dummy-token"
    }

    # Leading zeros tests
    It "returns the next prerelease tag when bump is not none and tags exist (leading zeros)" {
        Mock Invoke-WebRequest {
            [PSCustomObject]@{
                StatusCode = 200
                Content = ConvertTo-Json @(
                    @{ name = "v1.2.3-dev.0001" },
                    @{ name = "v1.2.3-dev.0002" }
                )
            }
        } -ModuleName Get-PrereleaseTag

        $result = Get-PrereleaseTag -baseVersion $baseVersion -prereleaseId $prereleaseId -bump "patch" -githubApiUrl $githubApiUrl -owner $owner -repo $repo -token $token -useLeadingZeros $true -numberOfLeadingZeros 4
        $result.Success | Should -Be $true
        $result.Version | Should -Be "v1.2.3-dev.0003"
        $result.Error | Should -Be $null
    }

    It "returns the current prerelease tag when bump is none and tags exist (leading zeros)" {
        Mock Invoke-WebRequest {
            [PSCustomObject]@{
                StatusCode = 200
                Content = ConvertTo-Json @(
                    @{ name = "v1.2.3-dev.0003" },
                    @{ name = "v1.2.3-dev.0002" }
                )
            }
        } -ModuleName Get-PrereleaseTag

        $result = Get-PrereleaseTag -baseVersion $baseVersion -prereleaseId $prereleaseId -bump "none" -githubApiUrl $githubApiUrl -owner $owner -repo $repo -token $token -useLeadingZeros $true -numberOfLeadingZeros 4
        $result.Success | Should -Be $true
        $result.Version | Should -Be "v1.2.3-dev.0003"
        $result.Error | Should -Be $null
    }

    It "returns first prerelease tag when bump is not none and no tags exist (leading zeros)" {
        Mock Invoke-WebRequest {
            [PSCustomObject]@{
                StatusCode = 200
                Content = ConvertTo-Json @()
            }
        } -ModuleName Get-PrereleaseTag

        $result = Get-PrereleaseTag -baseVersion $baseVersion -prereleaseId $prereleaseId -bump "patch" -githubApiUrl $githubApiUrl -owner $owner -repo $repo -token $token -useLeadingZeros $true -numberOfLeadingZeros 4
        $result.Success | Should -Be $true
        $result.Version | Should -Be "v1.2.3-dev.0001"
        $result.Error | Should -Be $null
    }

    It "returns first prerelease tag when bump is none and no tags exist (leading zeros)" {
        Mock Invoke-WebRequest {
            [PSCustomObject]@{
                StatusCode = 200
                Content = ConvertTo-Json @()
            }
        } -ModuleName Get-PrereleaseTag

        $result = Get-PrereleaseTag -baseVersion $baseVersion -prereleaseId $prereleaseId -bump "none" -githubApiUrl $githubApiUrl -owner $owner -repo $repo -token $token -useLeadingZeros $true -numberOfLeadingZeros 4
        $result.Success | Should -Be $true
        $result.Version | Should -Be "v1.2.3-dev.0000"
        $result.Error | Should -Be $null
    }

    # Non-leading zeros tests
    It "returns the next prerelease tag when bump is not none and tags exist (no leading zeros)" {
        Mock Invoke-WebRequest {
            [PSCustomObject]@{
                StatusCode = 200
                Content = ConvertTo-Json @(
                    @{ name = "v1.2.3-dev.1" },
                    @{ name = "v1.2.3-dev.2" }
                )
            }
        } -ModuleName Get-PrereleaseTag

        $result = Get-PrereleaseTag -baseVersion $baseVersion -prereleaseId $prereleaseId -bump "minor" -githubApiUrl $githubApiUrl -owner $owner -repo $repo -token $token -useLeadingZeros $false -numberOfLeadingZeros 1
        $result.Success | Should -Be $true
        $result.Version | Should -Be "v1.2.3-dev.3"
        $result.Error | Should -Be $null
    }

    It "returns the current prerelease tag when bump is none and tags exist (no leading zeros)" {
        Mock Invoke-WebRequest {
            [PSCustomObject]@{
                StatusCode = 200
                Content = ConvertTo-Json @(
                    @{ name = "v1.2.3-dev.3" },
                    @{ name = "v1.2.3-dev.2" }
                )
            }
        } -ModuleName Get-PrereleaseTag

        $result = Get-PrereleaseTag -baseVersion $baseVersion -prereleaseId $prereleaseId -bump "none" -githubApiUrl $githubApiUrl -owner $owner -repo $repo -token $token -useLeadingZeros $false -numberOfLeadingZeros 1
        $result.Success | Should -Be $true
        $result.Version | Should -Be "v1.2.3-dev.3"
        $result.Error | Should -Be $null
    }

    It "returns first prerelease tag when bump is not none and no tags exist (no leading zeros)" {
        Mock Invoke-WebRequest {
            [PSCustomObject]@{
                StatusCode = 200
                Content = ConvertTo-Json @()
            }
        } -ModuleName Get-PrereleaseTag

        $result = Get-PrereleaseTag -baseVersion $baseVersion -prereleaseId $prereleaseId -bump "patch" -githubApiUrl $githubApiUrl -owner $owner -repo $repo -token $token -useLeadingZeros $false -numberOfLeadingZeros 1
        $result.Success | Should -Be $true
        $result.Version | Should -Be "v1.2.3-dev.1"
        $result.Error | Should -Be $null
    }

    It "returns first prerelease tag when bump is none and no tags exist (no leading zeros)" {
        Mock Invoke-WebRequest {
            [PSCustomObject]@{
                StatusCode = 200
                Content = ConvertTo-Json @()
            }
        } -ModuleName Get-PrereleaseTag

        $result = Get-PrereleaseTag -baseVersion $baseVersion -prereleaseId $prereleaseId -bump "none" -githubApiUrl $githubApiUrl -owner $owner -repo $repo -token $token -useLeadingZeros $false -numberOfLeadingZeros 1
        $result.Success | Should -Be $true
        $result.Version | Should -Be "v1.2.3-dev.0"
        $result.Error | Should -Be $null
    }

    # Error handling
    It "handles a failed API call (non-200 status code)" {
        Mock Invoke-WebRequest {
            [PSCustomObject]@{
                StatusCode = 404
                Content = ""
            }
        } -ModuleName Get-PrereleaseTag

        $result = Get-PrereleaseTag -baseVersion $baseVersion -prereleaseId $prereleaseId -bump "patch" -githubApiUrl $githubApiUrl -owner $owner -repo $repo -token $token -useLeadingZeros $true -numberOfLeadingZeros 4
        $result.Success | Should -Be $false
        $result.Version | Should -Be $null
        $result.Error | Should -Match "Failed to retrieve tags. Status code: 404"
    }

    It "handles an exception thrown by Invoke-WebRequest" {
        Mock Invoke-WebRequest { throw "Network Error" } -ModuleName Get-PrereleaseTag

        $result = Get-PrereleaseTag -baseVersion $baseVersion -prereleaseId $prereleaseId -bump "patch" -githubApiUrl $githubApiUrl -owner $owner -repo $repo -token $token -useLeadingZeros $true -numberOfLeadingZeros 4
        $result.Success | Should -Be $false
        $result.Version | Should -Be $null
        $result.Error | Should -Match "Exception: Network Error"
    }
}
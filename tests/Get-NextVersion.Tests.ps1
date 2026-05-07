Import-Module "$PSScriptRoot/../modules/Get-NextVersion.psm1" -Force

Describe "Get-NextVersion" {
    BeforeEach {
        $owner = "dummy-owner"
        $repo = "dummy-repo"
        $token = "dummy-token"
        $githubApiUrl = "https://api.mytests.com"
    }
    
    Context "With leading zeros" {
        BeforeEach {
            $useLeadingZeros = $true
            $numberOfLeadingZeros = 4
        }

        It "increments major version when bump is major" {
            $result = Get-NextVersion -stableTag "v1.2.3" -bump "major" -isPrerelease "false" `
                -prereleaseId "dev" -owner $owner -repo $repo -token $token -githubApiUrl $githubApiUrl `
                -useLeadingZeros $useLeadingZeros -numberOfLeadingZeros $numberOfLeadingZeros
            $result.Success | Should -Be $true
            $result.Version | Should -Be "v2.0.0"
            $result.Error | Should -Be $null
        }
        It "increments minor version when bump is minor" {
            $result = Get-NextVersion -stableTag "v1.2.3" -bump "minor" -isPrerelease "false" `
                -prereleaseId "dev" -owner $owner -repo $repo -token $token -githubApiUrl $githubApiUrl `
                -useLeadingZeros $useLeadingZeros -numberOfLeadingZeros $numberOfLeadingZeros
            $result.Success | Should -Be $true
            $result.Version | Should -Be "v1.3.0"
            $result.Error | Should -Be $null
        }
        It "increments patch version when bump is patch" {
            $result = Get-NextVersion -stableTag "v1.2.3" -bump "patch" -isPrerelease "false" `
                -prereleaseId "dev" -owner $owner -repo $repo -token $token -githubApiUrl $githubApiUrl `
                -useLeadingZeros $useLeadingZeros -numberOfLeadingZeros $numberOfLeadingZeros
            $result.Success | Should -Be $true
            $result.Version | Should -Be "v1.2.4"
            $result.Error | Should -Be $null
        }
        It "returns same version for bump none" {
            $result = Get-NextVersion -stableTag "v1.2.3" -bump "none" -isPrerelease "false" `
                -prereleaseId "dev" -owner $owner -repo $repo -token $token -githubApiUrl $githubApiUrl `
                -useLeadingZeros $useLeadingZeros -numberOfLeadingZeros $numberOfLeadingZeros
            $result.Success | Should -Be $true
            $result.Version | Should -Be "v1.2.3"
            $result.Error | Should -Be $null
        }
        It "defaults to v0.0.0 for first tag and bump none" {
            $result = Get-NextVersion -stableTag $null -bump "none" -isPrerelease "false" `
                -prereleaseId "dev" -owner $owner -repo $repo -token $token -githubApiUrl $githubApiUrl `
                -useLeadingZeros $useLeadingZeros -numberOfLeadingZeros $numberOfLeadingZeros
            $result.Success | Should -Be $true
            $result.Version | Should -Be "v0.0.0"
            $result.Error | Should -Be $null
        }
        It "defaults to v0.0.1 for first tag and bump patch" {
            $result = Get-NextVersion -stableTag $null -bump "patch" -isPrerelease "false" `
                -prereleaseId "dev" -owner $owner -repo $repo -token $token -githubApiUrl $githubApiUrl `
                -useLeadingZeros $useLeadingZeros -numberOfLeadingZeros $numberOfLeadingZeros
            $result.Success | Should -Be $true
            $result.Version | Should -Be "v0.0.1"
            $result.Error | Should -Be $null
        }
        It "creates a pre-release version with incremented iteration (leading zeros)" {
            Mock Get-PrereleaseTag {
                [PSCustomObject]@{
                    Success = $true
                    Version = "v1.2.4-dev.0003"
                    Error   = $null
                }
            } -ModuleName Get-NextVersion

            $result = Get-NextVersion -stableTag "v1.2.3" -bump "patch" -isPrerelease "true" `
                -prereleaseId "dev" -owner $owner -repo $repo -token $token -githubApiUrl $githubApiUrl `
                -useLeadingZeros $useLeadingZeros -numberOfLeadingZeros $numberOfLeadingZeros
            $result.Success | Should -Be $true
            $result.Version | Should -Be "v1.2.4-dev.0003"
            $result.Error | Should -Be $null
        }
        It "creates first pre-release version if none exist (leading zeros)" {
            Mock Get-PrereleaseTag {
                [PSCustomObject]@{
                    Success = $true
                    Version = "v0.0.1-dev.0001"
                    Error   = $null
                }
            } -ModuleName Get-NextVersion

            $result = Get-NextVersion -stableTag $null -bump "patch" -isPrerelease "true" `
                -prereleaseId "dev" -owner $owner -repo $repo -token $token -githubApiUrl $githubApiUrl `
                -useLeadingZeros $useLeadingZeros -numberOfLeadingZeros $numberOfLeadingZeros
            $result.Success | Should -Be $true
            $result.Version | Should -Be "v0.0.1-dev.0001"
            $result.Error | Should -Be $null
        }
        It "returns base version for pre-release and bump none (leading zeros)" {
            Mock Get-PrereleaseTag {
                [PSCustomObject]@{
                    Success = $true
                    Version = "v1.2.3"
                    Error   = $null
                }
            } -ModuleName Get-NextVersion

            $result = Get-NextVersion -stableTag "v1.2.3" -bump "none" -isPrerelease "true" `
                -prereleaseId "dev" -owner $owner -repo $repo -token $token -githubApiUrl $githubApiUrl `
                -useLeadingZeros $useLeadingZeros -numberOfLeadingZeros $numberOfLeadingZeros
            $result.Success | Should -Be $true
            $result.Version | Should -Be "v1.2.3"
            $result.Error | Should -Be $null
        }
    }

    Context "Without leading zeros" {
        BeforeEach {
            $useLeadingZeros = $false
            $numberOfLeadingZeros = 1
        }

        It "increments major version when bump is major" {
            $result = Get-NextVersion -stableTag "v1.2.3" -bump "major" -isPrerelease "false" `
                -prereleaseId "dev" -owner $owner -repo $repo -token $token -githubApiUrl $githubApiUrl `
                -useLeadingZeros $useLeadingZeros -numberOfLeadingZeros $numberOfLeadingZeros
            $result.Success | Should -Be $true
            $result.Version | Should -Be "v2.0.0"
            $result.Error | Should -Be $null
        }
        It "increments minor version when bump is minor" {
            $result = Get-NextVersion -stableTag "v1.2.3" -bump "minor" -isPrerelease "false" `
                -prereleaseId "dev" -owner $owner -repo $repo -token $token -githubApiUrl $githubApiUrl `
                -useLeadingZeros $useLeadingZeros -numberOfLeadingZeros $numberOfLeadingZeros
            $result.Success | Should -Be $true
            $result.Version | Should -Be "v1.3.0"
            $result.Error | Should -Be $null
        }
        It "increments patch version when bump is patch" {
            $result = Get-NextVersion -stableTag "v1.2.3" -bump "patch" -isPrerelease "false" `
                -prereleaseId "dev" -owner $owner -repo $repo -token $token -githubApiUrl $githubApiUrl `
                -useLeadingZeros $useLeadingZeros -numberOfLeadingZeros $numberOfLeadingZeros
            $result.Success | Should -Be $true
            $result.Version | Should -Be "v1.2.4"
            $result.Error | Should -Be $null
        }
        It "returns same version for bump none" {
            $result = Get-NextVersion -stableTag "v1.2.3" -bump "none" -isPrerelease "false" `
                -prereleaseId "dev" -owner $owner -repo $repo -token $token -githubApiUrl $githubApiUrl `
                -useLeadingZeros $useLeadingZeros -numberOfLeadingZeros $numberOfLeadingZeros
            $result.Success | Should -Be $true
            $result.Version | Should -Be "v1.2.3"
            $result.Error | Should -Be $null
        }
        It "defaults to v0.0.0 for first tag and bump none" {
            $result = Get-NextVersion -stableTag $null -bump "none" -isPrerelease "false" `
                -prereleaseId "dev" -owner $owner -repo $repo -token $token -githubApiUrl $githubApiUrl `
                -useLeadingZeros $useLeadingZeros -numberOfLeadingZeros $numberOfLeadingZeros
            $result.Success | Should -Be $true
            $result.Version | Should -Be "v0.0.0"
            $result.Error | Should -Be $null
        }
        It "defaults to v0.0.1 for first tag and bump patch" {
            $result = Get-NextVersion -stableTag $null -bump "patch" -isPrerelease "false" `
                -prereleaseId "dev" -owner $owner -repo $repo -token $token -githubApiUrl $githubApiUrl `
                -useLeadingZeros $useLeadingZeros -numberOfLeadingZeros $numberOfLeadingZeros
            $result.Success | Should -Be $true
            $result.Version | Should -Be "v0.0.1"
            $result.Error | Should -Be $null
        }
        It "creates a pre-release version with incremented iteration (no leading zeros)" {
            Mock Get-PrereleaseTag {
                [PSCustomObject]@{
                    Success = $true
                    Version = "v1.2.4-dev.3"
                    Error   = $null
                }
            } -ModuleName Get-NextVersion

            $result = Get-NextVersion -stableTag "v1.2.3" -bump "patch" -isPrerelease "true" `
                -prereleaseId "dev" -owner $owner -repo $repo -token $token -githubApiUrl $githubApiUrl `
                -useLeadingZeros $useLeadingZeros -numberOfLeadingZeros $numberOfLeadingZeros
            $result.Success | Should -Be $true
            $result.Version | Should -Be "v1.2.4-dev.3"
            $result.Error | Should -Be $null
        }
        It "creates first pre-release version if none exist (no leading zeros)" {
            Mock Get-PrereleaseTag {
                [PSCustomObject]@{
                    Success = $true
                    Version = "v0.0.1-dev.1"
                    Error   = $null
                }
            } -ModuleName Get-NextVersion

            $result = Get-NextVersion -stableTag $null -bump "patch" -isPrerelease "true" `
                -prereleaseId "dev" -owner $owner -repo $repo -token $token -githubApiUrl $githubApiUrl `
                -useLeadingZeros $useLeadingZeros -numberOfLeadingZeros $numberOfLeadingZeros
            $result.Success | Should -Be $true
            $result.Version | Should -Be "v0.0.1-dev.1"
            $result.Error | Should -Be $null
        }
        It "returns base version for pre-release and bump none (no leading zeros)" {
            Mock Get-PrereleaseTag {
                [PSCustomObject]@{
                    Success = $true
                    Version = "v1.2.3"
                    Error   = $null
                }
            } -ModuleName Get-NextVersion

            $result = Get-NextVersion -stableTag "v1.2.3" -bump "none" -isPrerelease "true" `
                -prereleaseId "dev" -owner $owner -repo $repo -token $token -githubApiUrl $githubApiUrl `
                -useLeadingZeros $useLeadingZeros -numberOfLeadingZeros $numberOfLeadingZeros
            $result.Success | Should -Be $true
            $result.Version | Should -Be "v1.2.3"
            $result.Error | Should -Be $null
        }
    }
}
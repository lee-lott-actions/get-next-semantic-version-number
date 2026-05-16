Import-Module "$PSScriptRoot/../modules/Get-NextVersion.psm1" -Force

Describe "Get-NextVersion" {
    BeforeAll {
        $script:owner = "dummy-owner"
        $script:repo = "dummy-repo"
        $script:token = "dummy-token"
        $script:MockApiUrl = "http://127.0.0.1:3000"
    }
    
    BeforeEach {
        $env:GITHUB_OUTPUT = New-TemporaryFile
        $env:MOCK_API = $script:MockApiUrl       
    }

    AfterEach {
        if (Test-Path $env:GITHUB_OUTPUT) { Remove-Item $env:GITHUB_OUTPUT }
        Remove-Item Env:MOCK_API -ErrorAction SilentlyContinue
    }
    
    Context "Leading Zeros Cases" {
        BeforeEach {
            $useLeadingZeros = $true
            $numberOfLeadingZeros = 4
        }

        It "unit: Get-NextVersion increments major version when bump is major" {
            $result = Get-NextVersion -stableTag "v1.2.3" -bump "major" -isPrerelease "false" `
                -prereleaseId "dev" -owner $owner -repo $repo -token $token -githubApiUrl MockApiUrl `
                -useLeadingZeros $useLeadingZeros -numberOfLeadingZeros $numberOfLeadingZeros
            $result.Success | Should -Be $true
            $result.Version | Should -Be "v2.0.0"
            $result.Error | Should -Be $null
        }
        It "unit: Get-NextVersion increments minor version when bump is minor" {
            $result = Get-NextVersion -stableTag "v1.2.3" -bump "minor" -isPrerelease "false" `
                -prereleaseId "dev" -owner $owner -repo $repo -token $token -githubApiUrl MockApiUrl `
                -useLeadingZeros $useLeadingZeros -numberOfLeadingZeros $numberOfLeadingZeros
            $result.Success | Should -Be $true
            $result.Version | Should -Be "v1.3.0"
            $result.Error | Should -Be $null
        }
        It "unit: Get-NextVersion increments patch version when bump is patch" {
            $result = Get-NextVersion -stableTag "v1.2.3" -bump "patch" -isPrerelease "false" `
                -prereleaseId "dev" -owner $owner -repo $repo -token $token -githubApiUrl MockApiUrl `
                -useLeadingZeros $useLeadingZeros -numberOfLeadingZeros $numberOfLeadingZeros
            $result.Success | Should -Be $true
            $result.Version | Should -Be "v1.2.4"
            $result.Error | Should -Be $null
        }
        It "unit: Get-NextVersion returns same version for bump none" {
            $result = Get-NextVersion -stableTag "v1.2.3" -bump "none" -isPrerelease "false" `
                -prereleaseId "dev" -owner $owner -repo $repo -token $token -githubApiUrl MockApiUrl `
                -useLeadingZeros $useLeadingZeros -numberOfLeadingZeros $numberOfLeadingZeros
            $result.Success | Should -Be $true
            $result.Version | Should -Be "v1.2.3"
            $result.Error | Should -Be $null
        }
        It "unit: Get-NextVersion defaults to v0.0.0 for first tag and bump none" {
            $result = Get-NextVersion -stableTag $null -bump "none" -isPrerelease "false" `
                -prereleaseId "dev" -owner $owner -repo $repo -token $token -githubApiUrl MockApiUrl `
                -useLeadingZeros $useLeadingZeros -numberOfLeadingZeros $numberOfLeadingZeros
            $result.Success | Should -Be $true
            $result.Version | Should -Be "v0.0.0"
            $result.Error | Should -Be $null
        }
        It "unit: Get-NextVersion defaults to v0.0.1 for first tag and bump patch" {
            $result = Get-NextVersion -stableTag $null -bump "patch" -isPrerelease "false" `
                -prereleaseId "dev" -owner $owner -repo $repo -token $token -githubApiUrl MockApiUrl `
                -useLeadingZeros $useLeadingZeros -numberOfLeadingZeros $numberOfLeadingZeros
            $result.Success | Should -Be $true
            $result.Version | Should -Be "v0.0.1"
            $result.Error | Should -Be $null
        }
        It "unit: Get-NextVersion creates a pre-release version with incremented iteration" {
            Mock Get-PrereleaseTag {
                [PSCustomObject]@{
                    Success = $true
                    Version = "v1.2.4-dev.0003"
                    Error   = $null
                }
            } -ModuleName Get-NextVersion

            $result = Get-NextVersion -stableTag "v1.2.3" -bump "patch" -isPrerelease "true" `
                -prereleaseId "dev" -owner $owner -repo $repo -token $token -githubApiUrl MockApiUrl `
                -useLeadingZeros $useLeadingZeros -numberOfLeadingZeros $numberOfLeadingZeros
            $result.Success | Should -Be $true
            $result.Version | Should -Be "v1.2.4-dev.0003"
            $result.Error | Should -Be $null
        }
        It "unit: Get-NextVersion creates first pre-release version if none exist" {
            Mock Get-PrereleaseTag {
                [PSCustomObject]@{
                    Success = $true
                    Version = "v0.0.1-dev.0001"
                    Error   = $null
                }
            } -ModuleName Get-NextVersion

            $result = Get-NextVersion -stableTag $null -bump "patch" -isPrerelease "true" `
                -prereleaseId "dev" -owner $owner -repo $repo -token $token -githubApiUrl MockApiUrl `
                -useLeadingZeros $useLeadingZeros -numberOfLeadingZeros $numberOfLeadingZeros
            $result.Success | Should -Be $true
            $result.Version | Should -Be "v0.0.1-dev.0001"
            $result.Error | Should -Be $null
        }
        It "unit: Get-NextVersion returns base version for pre-release and bump none" {
            Mock Get-PrereleaseTag {
                [PSCustomObject]@{
                    Success = $true
                    Version = "v1.2.3"
                    Error   = $null
                }
            } -ModuleName Get-NextVersion

            $result = Get-NextVersion -stableTag "v1.2.3" -bump "none" -isPrerelease "true" `
                -prereleaseId "dev" -owner $owner -repo $repo -token $token -githubApiUrl MockApiUrl `
                -useLeadingZeros $useLeadingZeros -numberOfLeadingZeros $numberOfLeadingZeros
            $result.Success | Should -Be $true
            $result.Version | Should -Be "v1.2.3"
            $result.Error | Should -Be $null
        }
    }

    Context "Non Leading Zeros Cases" {
        BeforeEach {
            $useLeadingZeros = $false
            $numberOfLeadingZeros = 1
        }

        It "unit: Get-NextVersion increments major version when bump is major" {
            $result = Get-NextVersion -stableTag "v1.2.3" -bump "major" -isPrerelease "false" `
                -prereleaseId "dev" -owner $owner -repo $repo -token $token -githubApiUrl MockApiUrl `
                -useLeadingZeros $useLeadingZeros -numberOfLeadingZeros $numberOfLeadingZeros
            $result.Success | Should -Be $true
            $result.Version | Should -Be "v2.0.0"
            $result.Error | Should -Be $null
        }
        It "unit: Get-NextVersion increments minor version when bump is minor" {
            $result = Get-NextVersion -stableTag "v1.2.3" -bump "minor" -isPrerelease "false" `
                -prereleaseId "dev" -owner $owner -repo $repo -token $token -githubApiUrl MockApiUrl `
                -useLeadingZeros $useLeadingZeros -numberOfLeadingZeros $numberOfLeadingZeros
            $result.Success | Should -Be $true
            $result.Version | Should -Be "v1.3.0"
            $result.Error | Should -Be $null
        }
        It "unit: Get-NextVersion increments patch version when bump is patch" {
            $result = Get-NextVersion -stableTag "v1.2.3" -bump "patch" -isPrerelease "false" `
                -prereleaseId "dev" -owner $owner -repo $repo -token $token -githubApiUrl MockApiUrl `
                -useLeadingZeros $useLeadingZeros -numberOfLeadingZeros $numberOfLeadingZeros
            $result.Success | Should -Be $true
            $result.Version | Should -Be "v1.2.4"
            $result.Error | Should -Be $null
        }
        It "unit: Get-NextVersion returns same version for bump none" {
            $result = Get-NextVersion -stableTag "v1.2.3" -bump "none" -isPrerelease "false" `
                -prereleaseId "dev" -owner $owner -repo $repo -token $token -githubApiUrl MockApiUrl `
                -useLeadingZeros $useLeadingZeros -numberOfLeadingZeros $numberOfLeadingZeros
            $result.Success | Should -Be $true
            $result.Version | Should -Be "v1.2.3"
            $result.Error | Should -Be $null
        }
        It "unit: Get-NextVersion defaults to v0.0.0 for first tag and bump none" {
            $result = Get-NextVersion -stableTag $null -bump "none" -isPrerelease "false" `
                -prereleaseId "dev" -owner $owner -repo $repo -token $token -githubApiUrl MockApiUrl `
                -useLeadingZeros $useLeadingZeros -numberOfLeadingZeros $numberOfLeadingZeros
            $result.Success | Should -Be $true
            $result.Version | Should -Be "v0.0.0"
            $result.Error | Should -Be $null
        }
        It "unit: Get-NextVersion defaults to v0.0.1 for first tag and bump patch" {
            $result = Get-NextVersion -stableTag $null -bump "patch" -isPrerelease "false" `
                -prereleaseId "dev" -owner $owner -repo $repo -token $token -githubApiUrl MockApiUrl `
                -useLeadingZeros $useLeadingZeros -numberOfLeadingZeros $numberOfLeadingZeros
            $result.Success | Should -Be $true
            $result.Version | Should -Be "v0.0.1"
            $result.Error | Should -Be $null
        }
        It "unit: Get-NextVersion creates a pre-release version with incremented iteration" {
            Mock Get-PrereleaseTag {
                [PSCustomObject]@{
                    Success = $true
                    Version = "v1.2.4-dev.3"
                    Error   = $null
                }
            } -ModuleName Get-NextVersion

            $result = Get-NextVersion -stableTag "v1.2.3" -bump "patch" -isPrerelease "true" `
                -prereleaseId "dev" -owner $owner -repo $repo -token $token -githubApiUrl MockApiUrl `
                -useLeadingZeros $useLeadingZeros -numberOfLeadingZeros $numberOfLeadingZeros
            $result.Success | Should -Be $true
            $result.Version | Should -Be "v1.2.4-dev.3"
            $result.Error | Should -Be $null
        }
        It "unit: Get-NextVersion creates first pre-release version if none exist" {
            Mock Get-PrereleaseTag {
                [PSCustomObject]@{
                    Success = $true
                    Version = "v0.0.1-dev.1"
                    Error   = $null
                }
            } -ModuleName Get-NextVersion

            $result = Get-NextVersion -stableTag $null -bump "patch" -isPrerelease "true" `
                -prereleaseId "dev" -owner $owner -repo $repo -token $token -githubApiUrl MockApiUrl `
                -useLeadingZeros $useLeadingZeros -numberOfLeadingZeros $numberOfLeadingZeros
            $result.Success | Should -Be $true
            $result.Version | Should -Be "v0.0.1-dev.1"
            $result.Error | Should -Be $null
        }
        It "unit: Get-NextVersion returns base version for pre-release and bump none" {
            Mock Get-PrereleaseTag {
                [PSCustomObject]@{
                    Success = $true
                    Version = "v1.2.3"
                    Error   = $null
                }
            } -ModuleName Get-NextVersion

            $result = Get-NextVersion -stableTag "v1.2.3" -bump "none" -isPrerelease "true" `
                -prereleaseId "dev" -owner $owner -repo $repo -token $token -githubApiUrl MockApiUrl `
                -useLeadingZeros $useLeadingZeros -numberOfLeadingZeros $numberOfLeadingZeros
            $result.Success | Should -Be $true
            $result.Version | Should -Be "v1.2.3"
            $result.Error | Should -Be $null
        }
    }
}

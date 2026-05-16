Import-Module "$PSScriptRoot/../modules/Get-NextPrereleaseTag.psm1" -Force

Describe "Get-NextPrereleaseTag" {
    Context "Leading Zeros Cases" {
        It "unit: Get-NextPrereleaseTag returns the next prerelease tag when highest is .0005" {
            $tags = @(
                @{ name = "v1.2.3-dev.0001" },
                @{ name = "v1.2.3-dev.0005" },
                @{ name = "v1.2.3-dev.0003" }
            )
            $result = Get-NextPrereleaseTag -tags $tags -baseVersion "v1.2.3" -prereleaseId "dev" -useLeadingZeros $true -numberOfLeadingZeros 4
            $result | Should -Be "v1.2.3-dev.0006"
        }
    
        It "unit: Get-NextPrereleaseTag returns .0002 when only .0001 exists" {
            $tags = @(
                @{ name = "v1.2.3-dev.0001" }
            )
            $result = Get-NextPrereleaseTag -tags $tags -baseVersion "v1.2.3" -prereleaseId "dev" -useLeadingZeros $true -numberOfLeadingZeros 4
            $result | Should -Be "v1.2.3-dev.0002"
        }
    
        It "unit: Get-NextPrereleaseTag returns .0001 when no prerelease tags exist for baseVersion" {
            $tags = @(
                @{ name = "v1.2.2-dev.0001" }
            )
            $result = Get-NextPrereleaseTag -tags $tags -baseVersion "v1.2.3" -prereleaseId "dev" -useLeadingZeros $true -numberOfLeadingZeros 4
            $result | Should -Be "v1.2.3-dev.0001"
        }
    
        It "unit: Get-NextPrereleaseTag returns .0001 if no tags exist at all" {
            $tags = @()
            $result = Get-NextPrereleaseTag -tags $tags -baseVersion "v1.2.3" -prereleaseId "dev" -useLeadingZeros $true -numberOfLeadingZeros 4
            $result | Should -Be "v1.2.3-dev.0001"
        }
    
        It "unit: Get-NextPrereleaseTag ignores unrelated tags and increments existing prerelease" {
            $tags = @(
                @{ name = "feature-branch" },
                @{ name = "v1.2.3" },
                @{ name = "v1.2.3-dev.0001" }
            )
            $result = Get-NextPrereleaseTag -tags $tags -baseVersion "v1.2.3" -prereleaseId "dev" -useLeadingZeros $true -numberOfLeadingZeros 4
            $result | Should -Be "v1.2.3-dev.0002"
        }
    
        It "unit: Get-NextPrereleaseTag handles a different prerelease identifier correctly" {
            $tags = @(
                @{ name = "v1.2.3-rc.0002" },
                @{ name = "v1.2.3-rc.0005" }
            )
            $result = Get-NextPrereleaseTag -tags $tags -baseVersion "v1.2.3" -prereleaseId "rc" -useLeadingZeros $true -numberOfLeadingZeros 4
            $result | Should -Be "v1.2.3-rc.0006"
        }
    }

    Context "Non Leading Zeros Cases" {
        It "unit: Get-NextPrereleaseTag returns the next prerelease tag when highest is .5" {
            $tags = @(
                @{ name = "v1.2.3-dev.1" },
                @{ name = "v1.2.3-dev.5" },
                @{ name = "v1.2.3-dev.3" }
            )
            $result = Get-NextPrereleaseTag -tags $tags -baseVersion "v1.2.3" -prereleaseId "dev" -useLeadingZeros $false -numberOfLeadingZeros 1
            $result | Should -Be "v1.2.3-dev.6"
        }
    
        It "unit: Get-NextPrereleaseTag returns .2 when only .1 exists" {
            $tags = @(
                @{ name = "v1.2.3-dev.1" }
            )
            $result = Get-NextPrereleaseTag -tags $tags -baseVersion "v1.2.3" -prereleaseId "dev" -useLeadingZeros $false -numberOfLeadingZeros 1
            $result | Should -Be "v1.2.3-dev.2"
        }
    
        It "unit: Get-NextPrereleaseTag returns .1 when no prerelease tags exist for baseVersion" {
            $tags = @(
                @{ name = "v1.2.2-dev.1" }
            )
            $result = Get-NextPrereleaseTag -tags $tags -baseVersion "v1.2.3" -prereleaseId "dev" -useLeadingZeros $false -numberOfLeadingZeros 1
            $result | Should -Be "v1.2.3-dev.1"
        }
    
        It "unit: Get-NextPrereleaseTag returns .1 if no tags exist at all" {
            $tags = @()
            $result = Get-NextPrereleaseTag -tags $tags -baseVersion "v1.2.3" -prereleaseId "dev" -useLeadingZeros $false -numberOfLeadingZeros 1
            $result | Should -Be "v1.2.3-dev.1"
        }
    }    
}

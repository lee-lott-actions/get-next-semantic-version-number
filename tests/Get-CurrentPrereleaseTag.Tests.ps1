Import-Module "$PSScriptRoot/../modules/Get-CurrentPrereleaseTag.psm1" -Force

Describe "Get-CurrentPrereleaseTag" {
    Context "Leading Zeros Cases" {
        It "unit: Get-CurrentPrereleaseTag returns the latest prerelease tag when multiple exist" {
            $tags = @(
                @{ name = "v1.2.3-dev.0001" },
                @{ name = "v1.2.3-dev.0002" },
                @{ name = "v1.2.3-dev.0005" },
                @{ name = "v1.2.3-dev.0003" }
            )
            $result = Get-CurrentPrereleaseTag -tags $tags -baseVersion "v1.2.3" -prereleaseId "dev" -useLeadingZeros $true -numberOfLeadingZeros 4
            $result | Should -Be "v1.2.3-dev.0005"
        }
    
        It "unit: Get-CurrentPrereleaseTag returns the only prerelease tag if just one exists)" {
            $tags = @(
                @{ name = "v1.2.3-dev.0002" }
            )
            $result = Get-CurrentPrereleaseTag -tags $tags -baseVersion "v1.2.3" -prereleaseId "dev" -useLeadingZeros $true -numberOfLeadingZeros 4
            $result | Should -Be "v1.2.3-dev.0002"
        }
    
        It "unit: Get-CurrentPrereleaseTag returns the default prerelease tag if none exist for base version" {
            $tags = @(
                @{ name = "v1.2.2-dev.0001" },
                @{ name = "v1.2.2-dev.0002" }
            )
            $result = Get-CurrentPrereleaseTag -tags $tags -baseVersion "v1.2.3" -prereleaseId "dev" -useLeadingZeros $true -numberOfLeadingZeros 4
            $result | Should -Be "v1.2.3-dev.0000"
        }
    
        It "unit: Get-CurrentPrereleaseTag returns the default prerelease tag if no tags exist at all" {
            $tags = @()
            $result = Get-CurrentPrereleaseTag -tags $tags -baseVersion "v1.2.3" -prereleaseId "dev" -useLeadingZeros $true -numberOfLeadingZeros 4
            $result | Should -Be "v1.2.3-dev.0000"
        }
    
        It "unit: Get-CurrentPrereleaseTag ignores tags that do not match the prerelease regex" {
            $tags = @(
                @{ name = "v1.2.3" },
                @{ name = "feature-branch" },
                @{ name = "v1.2.3-dev.0001" }
            )
            $result = Get-CurrentPrereleaseTag -tags $tags -baseVersion "v1.2.3" -prereleaseId "dev" -useLeadingZeros $true -numberOfLeadingZeros 4
            $result | Should -Be "v1.2.3-dev.0001"
        }
    
        It "unit: Get-CurrentPrereleaseTag handles a different prerelease identifier correctly" {
            $tags = @(
                @{ name = "v1.2.3-rc.0002" },
                @{ name = "v1.2.3-rc.0005" }
            )
            $result = Get-CurrentPrereleaseTag -tags $tags -baseVersion "v1.2.3" -prereleaseId "rc" -useLeadingZeros $true -numberOfLeadingZeros 4
            $result | Should -Be "v1.2.3-rc.0005"
        }   
    }

    Context "Non Leading Zeros Cases" {
        It "unit: Get-CurrentPrereleaseTag returns the latest prerelease tag when multiple exist" {
            $tags = @(
                @{ name = "v1.2.3-dev.1" },
                @{ name = "v1.2.3-dev.2" },
                @{ name = "v1.2.3-dev.5" },
                @{ name = "v1.2.3-dev.3" }
            )
            $result = Get-CurrentPrereleaseTag -tags $tags -baseVersion "v1.2.3" -prereleaseId "dev" -useLeadingZeros $false -numberOfLeadingZeros 1
            $result | Should -Be "v1.2.3-dev.5"
        }
    
        It "unit: Get-CurrentPrereleaseTag returns the only prerelease tag if just one exists)" {
            $tags = @(
                @{ name = "v1.2.3-dev.2" }
            )
            $result = Get-CurrentPrereleaseTag -tags $tags -baseVersion "v1.2.3" -prereleaseId "dev" -useLeadingZeros $false -numberOfLeadingZeros 1
            $result | Should -Be "v1.2.3-dev.2"
        }
    
        It "unit: Get-CurrentPrereleaseTag returns the default prerelease tag if none exist for base version" {
            $tags = @(
                @{ name = "v1.2.2-dev.1" },
                @{ name = "v1.2.2-dev.2" }
            )
            $result = Get-CurrentPrereleaseTag -tags $tags -baseVersion "v1.2.3" -prereleaseId "dev" -useLeadingZeros $false -numberOfLeadingZeros 1
            $result | Should -Be "v1.2.3-dev.0"
        }
    
        It "unit: Get-CurrentPrereleaseTag returns the default prerelease tag if no tags exist at all" {
            $tags = @()
            $result = Get-CurrentPrereleaseTag -tags $tags -baseVersion "v1.2.3" -prereleaseId "dev" -useLeadingZeros $false -numberOfLeadingZeros 1
            $result | Should -Be "v1.2.3-dev.0"
        }
    }    
}

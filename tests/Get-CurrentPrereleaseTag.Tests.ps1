Import-Module "$PSScriptRoot/../modules/Get-CurrentPrereleaseTag.psm1" -Force

Describe "Get-CurrentPrereleaseTag" {
    # Leading zeros cases
    It "returns the latest prerelease tag when multiple exist (leading zeros)" {
        $tags = @(
            @{ name = "v1.2.3-dev.0001" },
            @{ name = "v1.2.3-dev.0002" },
            @{ name = "v1.2.3-dev.0005" },
            @{ name = "v1.2.3-dev.0003" }
        )
        $result = Get-CurrentPrereleaseTag -tags $tags -baseVersion "v1.2.3" -prereleaseId "dev" -useLeadingZeros $true -numberOfLeadingZeros 4
        $result | Should -Be "v1.2.3-dev.0005"
    }

    It "returns the only prerelease tag if just one exists (leading zeros)" {
        $tags = @(
            @{ name = "v1.2.3-dev.0002" }
        )
        $result = Get-CurrentPrereleaseTag -tags $tags -baseVersion "v1.2.3" -prereleaseId "dev" -useLeadingZeros $true -numberOfLeadingZeros 4
        $result | Should -Be "v1.2.3-dev.0002"
    }

    It "returns the default prerelease tag if none exist for base version (leading zeros)" {
        $tags = @(
            @{ name = "v1.2.2-dev.0001" },
            @{ name = "v1.2.2-dev.0002" }
        )
        $result = Get-CurrentPrereleaseTag -tags $tags -baseVersion "v1.2.3" -prereleaseId "dev" -useLeadingZeros $true -numberOfLeadingZeros 4
        $result | Should -Be "v1.2.3-dev.0000"
    }

    It "returns the default prerelease tag if no tags exist at all (leading zeros)" {
        $tags = @()
        $result = Get-CurrentPrereleaseTag -tags $tags -baseVersion "v1.2.3" -prereleaseId "dev" -useLeadingZeros $true -numberOfLeadingZeros 4
        $result | Should -Be "v1.2.3-dev.0000"
    }

    It "ignores tags that do not match the prerelease regex (leading zeros)" {
        $tags = @(
            @{ name = "v1.2.3" },
            @{ name = "feature-branch" },
            @{ name = "v1.2.3-dev.0001" }
        )
        $result = Get-CurrentPrereleaseTag -tags $tags -baseVersion "v1.2.3" -prereleaseId "dev" -useLeadingZeros $true -numberOfLeadingZeros 4
        $result | Should -Be "v1.2.3-dev.0001"
    }

    It "handles a different prerelease identifier correctly (leading zeros)" {
        $tags = @(
            @{ name = "v1.2.3-rc.0002" },
            @{ name = "v1.2.3-rc.0005" }
        )
        $result = Get-CurrentPrereleaseTag -tags $tags -baseVersion "v1.2.3" -prereleaseId "rc" -useLeadingZeros $true -numberOfLeadingZeros 4
        $result | Should -Be "v1.2.3-rc.0005"
    }

    # No leading zeros cases
    It "returns the latest prerelease tag when multiple exist (no leading zeros)" {
        $tags = @(
            @{ name = "v1.2.3-dev.1" },
            @{ name = "v1.2.3-dev.2" },
            @{ name = "v1.2.3-dev.5" },
            @{ name = "v1.2.3-dev.3" }
        )
        $result = Get-CurrentPrereleaseTag -tags $tags -baseVersion "v1.2.3" -prereleaseId "dev" -useLeadingZeros $false -numberOfLeadingZeros 1
        $result | Should -Be "v1.2.3-dev.5"
    }

    It "returns the only prerelease tag if just one exists (no leading zeros)" {
        $tags = @(
            @{ name = "v1.2.3-dev.2" }
        )
        $result = Get-CurrentPrereleaseTag -tags $tags -baseVersion "v1.2.3" -prereleaseId "dev" -useLeadingZeros $false -numberOfLeadingZeros 1
        $result | Should -Be "v1.2.3-dev.2"
    }

    It "returns the default prerelease tag if none exist for base version (no leading zeros)" {
        $tags = @(
            @{ name = "v1.2.2-dev.1" },
            @{ name = "v1.2.2-dev.2" }
        )
        $result = Get-CurrentPrereleaseTag -tags $tags -baseVersion "v1.2.3" -prereleaseId "dev" -useLeadingZeros $false -numberOfLeadingZeros 1
        $result | Should -Be "v1.2.3-dev.0"
    }

    It "returns the default prerelease tag if no tags exist at all (no leading zeros)" {
        $tags = @()
        $result = Get-CurrentPrereleaseTag -tags $tags -baseVersion "v1.2.3" -prereleaseId "dev" -useLeadingZeros $false -numberOfLeadingZeros 1
        $result | Should -Be "v1.2.3-dev.0"
    }
}
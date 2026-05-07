Import-Module "$PSScriptRoot/../modules/Get-NextPrereleaseTag.psm1" -Force

Describe "Get-NextPrereleaseTag" {
    # Leading zeros cases
    It "returns the next prerelease tag when highest is .0005 (leading zeros)" {
        $tags = @(
            @{ name = "v1.2.3-dev.0001" },
            @{ name = "v1.2.3-dev.0005" },
            @{ name = "v1.2.3-dev.0003" }
        )
        $result = Get-NextPrereleaseTag -tags $tags -baseVersion "v1.2.3" -prereleaseId "dev" -useLeadingZeros $true -numberOfLeadingZeros 4
        $result | Should -Be "v1.2.3-dev.0006"
    }

    It "returns .0002 when only .0001 exists (leading zeros)" {
        $tags = @(
            @{ name = "v1.2.3-dev.0001" }
        )
        $result = Get-NextPrereleaseTag -tags $tags -baseVersion "v1.2.3" -prereleaseId "dev" -useLeadingZeros $true -numberOfLeadingZeros 4
        $result | Should -Be "v1.2.3-dev.0002"
    }

    It "returns .0001 when no prerelease tags exist for baseVersion (leading zeros)" {
        $tags = @(
            @{ name = "v1.2.2-dev.0001" }
        )
        $result = Get-NextPrereleaseTag -tags $tags -baseVersion "v1.2.3" -prereleaseId "dev" -useLeadingZeros $true -numberOfLeadingZeros 4
        $result | Should -Be "v1.2.3-dev.0001"
    }

    It "returns .0001 if no tags exist at all (leading zeros)" {
        $tags = @()
        $result = Get-NextPrereleaseTag -tags $tags -baseVersion "v1.2.3" -prereleaseId "dev" -useLeadingZeros $true -numberOfLeadingZeros 4
        $result | Should -Be "v1.2.3-dev.0001"
    }

    It "ignores unrelated tags and increments existing prerelease (leading zeros)" {
        $tags = @(
            @{ name = "feature-branch" },
            @{ name = "v1.2.3" },
            @{ name = "v1.2.3-dev.0001" }
        )
        $result = Get-NextPrereleaseTag -tags $tags -baseVersion "v1.2.3" -prereleaseId "dev" -useLeadingZeros $true -numberOfLeadingZeros 4
        $result | Should -Be "v1.2.3-dev.0002"
    }

    It "handles a different prerelease identifier correctly (leading zeros)" {
        $tags = @(
            @{ name = "v1.2.3-rc.0002" },
            @{ name = "v1.2.3-rc.0005" }
        )
        $result = Get-NextPrereleaseTag -tags $tags -baseVersion "v1.2.3" -prereleaseId "rc" -useLeadingZeros $true -numberOfLeadingZeros 4
        $result | Should -Be "v1.2.3-rc.0006"
    }

    # Non-leading zeros cases
    It "returns the next prerelease tag when highest is .5 (no leading zeros)" {
        $tags = @(
            @{ name = "v1.2.3-dev.1" },
            @{ name = "v1.2.3-dev.5" },
            @{ name = "v1.2.3-dev.3" }
        )
        $result = Get-NextPrereleaseTag -tags $tags -baseVersion "v1.2.3" -prereleaseId "dev" -useLeadingZeros $false -numberOfLeadingZeros 1
        $result | Should -Be "v1.2.3-dev.6"
    }

    It "returns .2 when only .1 exists (no leading zeros)" {
        $tags = @(
            @{ name = "v1.2.3-dev.1" }
        )
        $result = Get-NextPrereleaseTag -tags $tags -baseVersion "v1.2.3" -prereleaseId "dev" -useLeadingZeros $false -numberOfLeadingZeros 1
        $result | Should -Be "v1.2.3-dev.2"
    }

    It "returns .1 when no prerelease tags exist for baseVersion (no leading zeros)" {
        $tags = @(
            @{ name = "v1.2.2-dev.1" }
        )
        $result = Get-NextPrereleaseTag -tags $tags -baseVersion "v1.2.3" -prereleaseId "dev" -useLeadingZeros $false -numberOfLeadingZeros 1
        $result | Should -Be "v1.2.3-dev.1"
    }

    It "returns .1 if no tags exist at all (no leading zeros)" {
        $tags = @()
        $result = Get-NextPrereleaseTag -tags $tags -baseVersion "v1.2.3" -prereleaseId "dev" -useLeadingZeros $false -numberOfLeadingZeros 1
        $result | Should -Be "v1.2.3-dev.1"
    }
}
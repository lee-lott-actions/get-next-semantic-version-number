function Get-NextVersion {
    param(
        [string]$stableTag,
        [string]$bump,
        [string]$isPrerelease,
        [string]$prereleaseId,
        [string]$owner,
        [string]$repo,
        [string]$token,
        [string]$githubApiUrl,
        [bool]$useLeadingZeros,
        [int]$numberOfLeadingZeros
    )

    Import-Module "$PSScriptRoot/../modules/Split-Version.psm1" -Force
    Import-Module "$PSScriptRoot/../modules/Get-PrereleaseTag.psm1" -Force

    if ($stableTag) {
        $parsed = Split-Version $stableTag
        $major = $parsed.Major
        $minor = $parsed.Minor
        $patch = $parsed.Patch
    } else {
        # First tag: default to 0.0.0 base
        $major = 0
        $minor = 0
        $patch = 0
    }

    switch ($bump) {
        "major" { $major++; $minor = 0; $patch = 0 }
        "minor" { $minor++; $patch = 0 }
        "patch" { $patch++ }
        "none" { }
    }

    $baseVersion = "v$major.$minor.$patch"

   if($isPrerelease -eq "true") {
        return Get-PrereleaseTag -baseVersion $baseVersion -prereleaseId $prereleaseId -bump $bump -githubApiUrl $githubApiUrl -owner $owner -repo $repo -useLeadingZeros $useLeadingZeros -numberOfLeadingZeros $numberOfLeadingZeros -token $token    
   } else {
        return [PSCustomObject]@{
            Success = $true
            Version = $baseVersion
            Error   = $null
        }
    }
}
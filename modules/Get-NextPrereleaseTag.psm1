function Get-NextPrereleaseTag {
    param(
        [array]$tags,
        [string]$baseVersion,
        [string]$prereleaseId,
        [bool]$useLeadingZeros,
        [int]$numberOfLeadingZeros
    )

    # Import Get-CurrentPrereleaseTag if needed
    if (-not (Get-Command Get-CurrentPrereleaseTag -ErrorAction SilentlyContinue)) {
        Import-Module "$PSScriptRoot/Get-CurrentPrereleaseTag.psm1" -Force
    }
    
    $currentTag = Get-CurrentPrereleaseTag -tags $tags -baseVersion $baseVersion -prereleaseId $prereleaseId -useLeadingZeros $useLeadingZeros -numberOfLeadingZeros $numberOfLeadingZeros
    
    if ($useLeadingZeros) {
        $patternWidth = $numberOfLeadingZeros
        $preidRegex = "^$baseVersion-$prereleaseId\.(\d{$patternWidth})$"
    } else {
        $preidRegex = "^$baseVersion-$prereleaseId\.(\d+)$"
    }
    
    $iter = 0
    if ($currentTag) {
        $m = [regex]::Match($currentTag, $preidRegex)
        if ($m.Success) {
            $iter = [int]$m.Groups[1].Value
        }
    }
    $nextIter = $iter + 1

    if ($useLeadingZeros) {
        $iterPadded = "{0:D$numberOfLeadingZeros}" -f $nextIter
        return "$baseVersion-$prereleaseId.$iterPadded"
    } else {
        return "$baseVersion-$prereleaseId.$nextIter"
    }
}
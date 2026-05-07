function Get-CurrentPrereleaseTag {
  param(
      [array]$tags,
      [string]$baseVersion,
      [string]$prereleaseId,
      [bool]$useLeadingZeros,
      [int]$numberOfLeadingZeros
  )
  
  if ($useLeadingZeros) {
    $patternWidth = $numberOfLeadingZeros
    $preidRegex = "^$baseVersion-$prereleaseId\.(\d{$patternWidth})$"
  } else {
    $preidRegex = "^$baseVersion-$prereleaseId\.(\d+)$"
  }
  
  $maxIter = 0
  $currentTag = $null
  foreach ($tag in $tags) {
      $m = [regex]::Match($tag.name, $preidRegex)
      if ($m.Success) {
          $iter = [int]$m.Groups[1].Value
          if ($iter -gt $maxIter) {
              $maxIter = $iter
              $currentTag = $tag.name
          }
      }
  }

  if ($currentTag) {
    return $currentTag
  } else {    
    #if no prerelease tag is found, default to iteration 0.
    if ($useLeadingZeros) {
      $iterPadded = "{0:D$numberOfLeadingZeros}" -f 0
      return "$baseVersion-$prereleaseId.$iterPadded"
    } else {
      return "$baseVersion-$prereleaseId.0"
    }
  }
}
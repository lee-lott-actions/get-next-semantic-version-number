function Get-PrereleaseTag {
  param(
      [string]$baseVersion,
      [string]$prereleaseId,
      [string]$bump,
      [string]$githubApiUrl,
      [string]$owner,
      [string]$repo,
      [bool]$useLeadingZeros,
      [int]$numberOfLeadingZeros,
      [string]$token
  )

  Import-Module "$PSScriptRoot/Get-CurrentPrereleaseTag.psm1" -Force
  Import-Module "$PSScriptRoot/Get-NextPrereleaseTag.psm1" -Force
  
  $tagsUrl = "$githubApiUrl/repos/$owner/$repo/tags?per_page=100"
  $headers = @{
      Authorization = "Bearer $token"
      "User-Agent" = "PowerShell"
      Accept = "application/vnd.github.v3+json"
  }

  try { 
    $response = Invoke-WebRequest -Uri $tagsUrl -Headers $headers -Method GET

    if ($response.StatusCode -eq 200) {
      $tags = $response.Content | ConvertFrom-Json

      if ($bump -ne "none") { 
        $nextPreReleaseTag = Get-NextPrereleaseTag -tags $tags -baseVersion $baseVersion -prereleaseId $prereleaseId -useLeadingZeros $useLeadingZeros -numberOfLeadingZeros $numberOfLeadingZeros
        return [PSCustomObject]@{
            Success = $true
            Version = $nextPreReleaseTag
            Error   = $null
        }
      } else {
        $currentPreRelease = Get-CurrentPrereleaseTag -tags $tags -baseVersion $baseVersion -prereleaseId $prereleaseId -useLeadingZeros $useLeadingZeros -numberOfLeadingZeros $numberOfLeadingZeros
        return [PSCustomObject]@{
            Success = $true
            Version = $currentPreRelease
            Error   = $null
        }      
      }
     } else {
      Write-Host "Failed to retrieve tags. Status code: $($response.StatusCode)"
      return [PSCustomObject]@{
          Success = $false
          Version = $null
          Error   = "Failed to retrieve tags. Status code: $($response.StatusCode)"
      }
     }  
  } catch {
    Write-Host "Failed to retrieve pre-release tags: $_"
    return [PSCustomObject]@{
        Success = $false
        Version = $null
        Error   = "Exception: $($_.Exception.Message)"
    }
  }  
}
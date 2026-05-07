Write-Host "Running all module tests..."

. "$PSScriptRoot/Get-LastStableTag.Tests.ps1"
. "$PSScriptRoot/Get-CommitsSince.Tests.ps1"
. "$PSScriptRoot/Split-Commits.Tests.ps1"
. "$PSScriptRoot/Split-Version.Tests.ps1"
. "$PSScriptRoot/Get-CurrentPrereleaseTag.Tests.ps1"
. "$PSScriptRoot/Get-NextPrereleaseTag.Tests.ps1"
. "$PSScriptRoot/Get-PrereleaseTag.Tests.ps1"
. "$PSScriptRoot/Get-NextVersion.Tests.ps1"
. "$PSScriptRoot/Get-NextSemver.Tests.ps1"

Write-Host "All tests completed."
function Split-Commits {
    param($Commits)
    
    $major = $false
    $minor = $false
    $patch = $false
    
    foreach ($msg in $Commits) {
        if ($msg -match "(?i)BREAKING CHANGE|!:") { $major = $true }
        elseif ($msg -match "(?i)^feat(\(.+\))?:") { $minor = $true }
        elseif ($msg -match "(?i)^fix(\(.+\))?:") { $patch = $true }
    }
    
    if ($major) { return "major" }
    elseif ($minor) { return "minor" }
    elseif ($patch) { return "patch" }
    else { return "none" }
}
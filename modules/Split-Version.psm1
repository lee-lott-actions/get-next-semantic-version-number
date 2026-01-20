function Split-Version {
    param([string]$Tag)
    
    $regex = "^v?(\d+)\.(\d+)\.(\d+)$"
    $m = [regex]::Match($Tag, $regex)
    
    if (-not $m.Success) { return $null }
    $result = @{
        Major = [int]$m.Groups[1].Value
        Minor = [int]$m.Groups[2].Value
        Patch = [int]$m.Groups[3].Value
    }
    
    return $result
}
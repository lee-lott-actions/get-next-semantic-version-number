Import-Module "$PSScriptRoot/../modules/Get-PrereleaseTag.psm1" -Force
Import-Module "$PSScriptRoot/../modules/Get-CurrentPrereleaseTag.psm1" -Force
Import-Module "$PSScriptRoot/../modules/Get-NextPrereleaseTag.psm1" -Force

Describe "Get-PrereleaseTag" {
    BeforeAll {
        $script:baseVersion = "v1.2.3"
        $script:prereleaseId = "dev"
        $script:MockApiUrl  = "http://127.0.0.1:3000"
        $script:owner = "dummy-owner"
        $script:repo = "dummy-repo"
        $script:token = "dummy-token"    
    }
    
    BeforeEach {
        $env:GITHUB_OUTPUT = New-TemporaryFile
        $env:MOCK_API = $script:MockApiUrl       
    }

    AfterEach {
        if (Test-Path $env:GITHUB_OUTPUT) { Remove-Item $env:GITHUB_OUTPUT }
        Remove-Item Env:MOCK_API -ErrorAction SilentlyContinue
    }

    Context "Success Cases" {
        Context "Leading Zeros Cases" {
            BeforeEach {
                $useLeadingZeros = $true
                $numberOfLeadingZeros = 4
            }
            
            It "unit: Get-PrereleaseTag returns the next prerelease tag when bump is not none and tags exist" {
                Mock Invoke-WebRequest {
                    [PSCustomObject]@{
                        StatusCode = 200
                        Content = ConvertTo-Json @(
                            @{ name = "v1.2.3-dev.0001" },
                            @{ name = "v1.2.3-dev.0002" }
                        )
                    }
                } -ModuleName Get-PrereleaseTag
        
                $result = Get-PrereleaseTag -baseVersion $baseVersion -prereleaseId $prereleaseId -bump "patch" -githubApiUrl $MockApiUrl  -owner $owner -repo $repo -token $token -useLeadingZeros $useLeadingZeros -numberOfLeadingZeros $numberOfLeadingZeros
                $result.Success | Should -Be $true
                $result.Version | Should -Be "v1.2.3-dev.0003"
                $result.Error | Should -Be $null
            }
        
            It "unit: Get-PrereleaseTag returns the current prerelease tag when bump is none and tags exist" {
                Mock Invoke-WebRequest {
                    [PSCustomObject]@{
                        StatusCode = 200
                        Content = ConvertTo-Json @(
                            @{ name = "v1.2.3-dev.0003" },
                            @{ name = "v1.2.3-dev.0002" }
                        )
                    }
                } -ModuleName Get-PrereleaseTag
        
                $result = Get-PrereleaseTag -baseVersion $baseVersion -prereleaseId $prereleaseId -bump "none" -githubApiUrl $MockApiUrl  -owner $owner -repo $repo -token $token -useLeadingZeros $useLeadingZeros -numberOfLeadingZeros $numberOfLeadingZeros
                $result.Success | Should -Be $true
                $result.Version | Should -Be "v1.2.3-dev.0003"
                $result.Error | Should -Be $null
            }
        
            It "unit: Get-PrereleaseTag returns first prerelease tag when bump is not none and no tags exist" {
                Mock Invoke-WebRequest {
                    [PSCustomObject]@{
                        StatusCode = 200
                        Content = ConvertTo-Json @()
                    }
                } -ModuleName Get-PrereleaseTag
        
                $result = Get-PrereleaseTag -baseVersion $baseVersion -prereleaseId $prereleaseId -bump "patch" -githubApiUrl $MockApiUrl  -owner $owner -repo $repo -token $token -useLeadingZeros $useLeadingZeros -numberOfLeadingZeros $numberOfLeadingZeros
                $result.Success | Should -Be $true
                $result.Version | Should -Be "v1.2.3-dev.0001"
                $result.Error | Should -Be $null
            }
        
            It "unit: Get-PrereleaseTag returns first prerelease tag when bump is none and no tags exist" {
                Mock Invoke-WebRequest {
                    [PSCustomObject]@{
                        StatusCode = 200
                        Content = ConvertTo-Json @()
                    }
                } -ModuleName Get-PrereleaseTag
        
                $result = Get-PrereleaseTag -baseVersion $baseVersion -prereleaseId $prereleaseId -bump "none" -githubApiUrl $MockApiUrl  -owner $owner -repo $repo -token $token -useLeadingZeros $useLeadingZeros -numberOfLeadingZeros $numberOfLeadingZeros
                $result.Success | Should -Be $true
                $result.Version | Should -Be "v1.2.3-dev.0000"
                $result.Error | Should -Be $null
            }
        
        }
    
        Context "Non Leading Zeros Cases" {
             BeforeEach {
                $useLeadingZeros = $false
                $numberOfLeadingZeros = 1
            }
            
            It "unit: Get-PrereleaseTag returns the next prerelease tag when bump is not none and tags exist" {
                Mock Invoke-WebRequest {
                    [PSCustomObject]@{
                        StatusCode = 200
                        Content = ConvertTo-Json @(
                            @{ name = "v1.2.3-dev.1" },
                            @{ name = "v1.2.3-dev.2" }
                        )
                    }
                } -ModuleName Get-PrereleaseTag
        
                $result = Get-PrereleaseTag -baseVersion $baseVersion -prereleaseId $prereleaseId -bump "minor" -githubApiUrl $MockApiUrl  -owner $owner -repo $repo -token $token -useLeadingZeros $useLeadingZeros -numberOfLeadingZeros $numberOfLeadingZeros
                $result.Success | Should -Be $true
                $result.Version | Should -Be "v1.2.3-dev.3"
                $result.Error | Should -Be $null
            }
        
            It "unit: Get-PrereleaseTag returns the current prerelease tag when bump is none and tags exist" {
                Mock Invoke-WebRequest {
                    [PSCustomObject]@{
                        StatusCode = 200
                        Content = ConvertTo-Json @(
                            @{ name = "v1.2.3-dev.3" },
                            @{ name = "v1.2.3-dev.2" }
                        )
                    }
                } -ModuleName Get-PrereleaseTag
        
                $result = Get-PrereleaseTag -baseVersion $baseVersion -prereleaseId $prereleaseId -bump "none" -githubApiUrl $MockApiUrl  -owner $owner -repo $repo -token $token -useLeadingZeros $useLeadingZeros -numberOfLeadingZeros $numberOfLeadingZeros
                $result.Success | Should -Be $true
                $result.Version | Should -Be "v1.2.3-dev.3"
                $result.Error | Should -Be $null
            }
        
            It "unit: Get-PrereleaseTag returns first prerelease tag when bump is not none and no tags exist" {
                Mock Invoke-WebRequest {
                    [PSCustomObject]@{
                        StatusCode = 200
                        Content = ConvertTo-Json @()
                    }
                } -ModuleName Get-PrereleaseTag
        
                $result = Get-PrereleaseTag -baseVersion $baseVersion -prereleaseId $prereleaseId -bump "patch" -githubApiUrl $MockApiUrl  -owner $owner -repo $repo -token $token -useLeadingZeros $useLeadingZeros -numberOfLeadingZeros $numberOfLeadingZeros
                $result.Success | Should -Be $true
                $result.Version | Should -Be "v1.2.3-dev.1"
                $result.Error | Should -Be $null
            }
        
            It "unit: Get-PrereleaseTag returns first prerelease tag when bump is none and no tags exist" {
                Mock Invoke-WebRequest {
                    [PSCustomObject]@{
                        StatusCode = 200
                        Content = ConvertTo-Json @()
                    }
                } -ModuleName Get-PrereleaseTag
        
                $result = Get-PrereleaseTag -baseVersion $baseVersion -prereleaseId $prereleaseId -bump "none" -githubApiUrl $MockApiUrl  -owner $owner -repo $repo -token $token -useLeadingZeros $useLeadingZeros -numberOfLeadingZeros $numberOfLeadingZeros
                $result.Success | Should -Be $true
                $result.Version | Should -Be "v1.2.3-dev.0"
                $result.Error | Should -Be $null
            }    
        }    
    }

    Context "Failure Cases" {
        It "unit: Get-PrereleaseTag fails with non-200 API call" {
            Mock Invoke-WebRequest {
                [PSCustomObject]@{
                    StatusCode = 404
                    Content = ""
                }
            } -ModuleName Get-PrereleaseTag
    
            $result = Get-PrereleaseTag -baseVersion $baseVersion -prereleaseId $prereleaseId -bump "patch" -githubApiUrl $MockApiUrl  -owner $owner -repo $repo -token $token -useLeadingZeros $true -numberOfLeadingZeros 4
            $result.Success | Should -Be $false
            $result.Version | Should -Be $null
            $result.Error | Should -Match "Failed to retrieve tags. Status code: 404"
        }
    }

    Context "Exception Failure Cases" {
        It "unit: Get-PrereleaseTag fails with exception" {
            Mock Invoke-WebRequest { throw "Network Error" } -ModuleName Get-PrereleaseTag
    
            $result = Get-PrereleaseTag -baseVersion $baseVersion -prereleaseId $prereleaseId -bump "patch" -githubApiUrl $MockApiUrl  -owner $owner -repo $repo -token $token -useLeadingZeros $true -numberOfLeadingZeros 4
            $result.Success | Should -Be $false
            $result.Version | Should -Be $null
            $result.Error | Should -Match "Exception: Network Error"
        }    
    }
}

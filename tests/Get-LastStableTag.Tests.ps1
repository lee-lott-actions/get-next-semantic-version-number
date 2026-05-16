Import-Module "$PSScriptRoot/../modules/Get-LastStableTag.psm1" -Force

Describe "Get-LastStableTag" {
    BeforeAll {
        $script:owner = "dummy-owner"
        $script:repo = "dummy-repo"
        $script:token = "dummy-token"
        $script:MockApiUrl = "http://127.0.0.1:3000"
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
        It "unit: Get-LastStableTag returns the latest stable tag when multiple tags exist" {
            Mock Invoke-WebRequest {
                [PSCustomObject]@{
                    StatusCode = 200
                    Content = ConvertTo-Json @(
                        @{ name = "v1.0.0" },
                        @{ name = "v2.0.0" },
                        @{ name = "v1.5.0" },
                        @{ name = "v2.0.1" },
                        @{ name = "v2.0.0-dev.0001" },
                        @{ name = "feature-branch" }
                    )
                }
            } -ModuleName Get-LastStableTag
            
            $result = Get-LastStableTag -owner $owner -repo $repo -token $token -githubApiUrl $MockApiUrl
            $result.Success | Should -Be $true
            $result.Tag | Should -Be "v2.0.1"
            $result.Error | Should -Be $null
        }
    
        It "unit: Get-LastStableTag returns null when no stable tags exist" {
            Mock Invoke-WebRequest {
                [PSCustomObject]@{
                    StatusCode = 200
                    Content = ConvertTo-Json @(
                        @{ name = "feature-branch" },
                        @{ name = "v1.0.0-dev.0001" }
                    )
                }
            } -ModuleName Get-LastStableTag
            
            $result = Get-LastStableTag -owner $owner -repo $repo -token $token -githubApiUrl $MockApiUrl
            $result.Success | Should -Be $true
            $result.Tag | Should -Be $null
            $result.Error | Should -Be $null
        }
    
        It "unit: Get-LastStableTag returns the only stable tag if just one exists" {
            Mock Invoke-WebRequest {
                [PSCustomObject]@{
                    StatusCode = 200
                    Content = ConvertTo-Json @(
                        @{ name = "v0.1.0" },
                        @{ name = "v0.1.0-dev.0001" }
                    )
                }
            } -ModuleName Get-LastStableTag
            
            $result = Get-LastStableTag -owner $owner -repo $repo -token $token -githubApiUrl $MockApiUrl
            $result.Success | Should -Be $true
            $result.Tag | Should -Be "v0.1.0"
            $result.Error | Should -Be $null
        }
    
        It "unit: Get-LastStableTag returns null when no tags exist at all" {
            Mock Invoke-WebRequest {
                [PSCustomObject]@{
                    StatusCode = 200
                    Content = ConvertTo-Json @()
                }
            } -ModuleName Get-LastStableTag
            $result = Get-LastStableTag -owner $owner -repo $repo -token $token -githubApiUrl $MockApiUrl
            $result.Success | Should -Be $true
            $result.Tag | Should -Be $null
            $result.Error | Should -Be $null
        }
    }

    Context "Failure Cases" {
        It "unit: Get-LastStableTag fails with non-200 API call" {
            Mock Invoke-WebRequest {
                [PSCustomObject]@{
                    StatusCode = 404
                    Content = ""
                }
            } -ModuleName Get-LastStableTag
            $result = Get-LastStableTag -owner $owner -repo $repo -token $token -githubApiUrl $MockApiUrl
            $result.Success | Should -Be $false
            $result.Tag | Should -Be $null
            $result.Error | Should -Match "Failed to retrieve tags. Status code: 404"
        }
    }

    Context "Exception Failure Cases" {
        It "unit: Get-LastStableTag fails with exception" {
            Mock Invoke-WebRequest { throw "Network Error" } -ModuleName Get-LastStableTag
            $result = Get-LastStableTag -owner $owner -repo $repo -token $token -githubApiUrl $MockApiUrl
            $result.Success | Should -Be $false
            $result.Tag | Should -Be $null
            $result.Error | Should -Match "Exception: Network Error"
        }
    }
}

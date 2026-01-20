Import-Module "$PSScriptRoot/../modules/Get-CommitsSince.psm1" -Force

Describe "Get-CommitsSince" {
    BeforeEach {
        $owner = "dummy-owner"
        $repo = "dummy-repo"
        $branch = "main"
        $token = "dummy-token"
        $githubApiUrl = "https://api.mytests.com"
    }
    
    It "returns commit messages from compare endpoint" {
        Mock Invoke-WebRequest {
            [PSCustomObject]@{
                StatusCode = 200
                Content = ConvertTo-Json @{
                    commits = @(
                        @{ commit = @{ message = "feat: something" } },
                        @{ commit = @{ message = "fix: stuff" } }
                    )
                } -Depth 3
            }
        } -ModuleName Get-CommitsSince
        
        $result = Get-CommitsSince -owner $owner -repo $repo -branch $branch -token $token -FromRef "v1.2.3" -githubApiUrl $githubApiUrl
        $result.Success | Should -Be $true
        $result.Messages | Should -Be @("feat: something", "fix: stuff")
        $result.Error | Should -Be $null
    }

    It "returns all commit messages from the branch" {
        Mock Invoke-WebRequest {
            [PSCustomObject]@{
                StatusCode = 200
                Content = ConvertTo-Json @(
                    @{ commit = @{ message = "initial commit" } },
                    @{ commit = @{ message = "feat: add feature" } }
                )
            }
        } -ModuleName Get-CommitsSince

        $result = Get-CommitsSince -owner $owner -repo $repo -branch $branch -token $token -FromRef $null -githubApiUrl $githubApiUrl
        $result.Success | Should -Be $true
        $result.Messages | Should -Be @("initial commit", "feat: add feature")
        $result.Error | Should -Be $null
    }

    It "returns an empty array when there are no commits" {
        Mock Invoke-WebRequest {
            [PSCustomObject]@{
                StatusCode = 200
                Content = ConvertTo-Json @()
            }
        } -ModuleName Get-CommitsSince

        $result = Get-CommitsSince -owner $owner -repo $repo -branch $branch -token $token -FromRef "v0.0.0" -githubApiUrl $githubApiUrl
        $result.Success | Should -Be $true
        $result.Messages | Should -Be @()
        $result.Error | Should -Be $null
    }

    It "handles a failed API call (non-200 status code)" {
        Mock Invoke-WebRequest {
            [PSCustomObject]@{
                StatusCode = 404
                Content = ""
            }
        } -ModuleName Get-CommitsSince

        $result = Get-CommitsSince -owner $owner -repo $repo -branch $branch -token $token -FromRef "v1.2.3" -githubApiUrl $githubApiUrl
        $result.Success | Should -Be $false
        $result.Messages | Should -Be $null
        $result.Error | Should -Match "Failed to retrieve commits from compare endpoint. Status code: 404"
    }

    It "handles an exception thrown by Invoke-WebRequest" {
        Mock Invoke-WebRequest { throw "Network Error" } -ModuleName Get-CommitsSince

        $result = Get-CommitsSince -owner $owner -repo $repo -branch $branch -token $token -FromRef "v1.2.3" -githubApiUrl $githubApiUrl
        $result.Success | Should -Be $false
        $result.Messages | Should -Be $null
        $result.Error | Should -Match "Exception: Network Error"
    }

    It "encodes branch name with slashes in commits endpoint" {
        Mock Invoke-WebRequest {
           	param($Uri)
           	$script:lastRequestUrl = $Uri
            
            [PSCustomObject]@{
                StatusCode = 200
                Content = ConvertTo-Json @(
                    @{ commit = @{ message = "test commit" } }
                )
            }
        } -ModuleName Get-CommitsSince
        
        $result = Get-CommitsSince -owner $owner -repo $repo -branch "feature/my-branch" -token $token -FromRef $null -githubApiUrl $githubApiUrl
        $result.Success | Should -Be $true
        $result.Messages.Count | Should -Be 1

		$script:lastRequestUrl | Should -Match "sha=feature%2Fmy-branch"
    }  
	

    It "encodes branch name with slashes in compare endpoint" {
        Mock Invoke-WebRequest {
            param($Uri)
            $script:lastRequestUrl = $Uri
            
            [PSCustomObject]@{
                StatusCode = 200
                Content = ConvertTo-Json @{
                    commits = @(
                        @{ commit = @{ message = "test commit" } }
                    )
                } -Depth 3
            }
        } -ModuleName Get-CommitsSince
        
        $result = Get-CommitsSince -owner $owner -repo $repo -branch "feature/my-branch" -token $token -FromRef "v1.0.0" -githubApiUrl $githubApiUrl
        $result.Success | Should -Be $true
        $result.Messages.Count | Should -Be 1

		$script:lastRequestUrl | Should -Match "\.\.\.feature%2Fmy-branch"
    }

     It "encodes FromRef with slashes in compare endpoint" {
        Mock Invoke-WebRequest {
            param($Uri)
			$script:lastRequestUrl = $Uri
            
            [PSCustomObject]@{
                StatusCode = 200
                Content = ConvertTo-Json @{
                    commits = @(
                        @{ commit = @{ message = "test commit" } }
                    )
                } -Depth 3
            }
        } -ModuleName Get-CommitsSince
        
        $result = Get-CommitsSince -owner $owner -repo $repo -branch "main" -token $token -FromRef "refs/tags/v1.0.0" -githubApiUrl $githubApiUrl
        $result.Success | Should -Be $true
        $result.Messages.Count | Should -Be 1

		$script:lastRequestUrl | Should -Match "refs%2Ftags%2Fv1\.0\.0\.\.\."
    }
}
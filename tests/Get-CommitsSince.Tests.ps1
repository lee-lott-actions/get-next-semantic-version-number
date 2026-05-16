Import-Module "$PSScriptRoot/../modules/Get-CommitsSince.psm1" -Force

Describe "Get-CommitsSince" {
	BeforeAll {
		$script:owner = "dummy-owner"
        $script:repo = "dummy-repo"
        $script:branch = "main"
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
		It "unit: Get-CommitsSince returns commit messages from compare endpoint" {
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
	        
	        $result = Get-CommitsSince -owner $owner -repo $repo -branch $branch -token $token -FromRef "v1.2.3" -githubApiUrl $MockApiUrl
	        $result.Success | Should -Be $true
	        $result.Messages | Should -Be @("feat: something", "fix: stuff")
	        $result.Error | Should -Be $null
	    }
	
	    It "unit: Get-CommitsSince returns all commit messages from the branch" {
	        Mock Invoke-WebRequest {
	            [PSCustomObject]@{
	                StatusCode = 200
	                Content = ConvertTo-Json @(
	                    @{ commit = @{ message = "initial commit" } },
	                    @{ commit = @{ message = "feat: add feature" } }
	                )
	            }
	        } -ModuleName Get-CommitsSince
	
	        $result = Get-CommitsSince -owner $owner -repo $repo -branch $branch -token $token -FromRef $null -githubApiUrl $MockApiUrl
	        $result.Success | Should -Be $true
	        $result.Messages | Should -Be @("initial commit", "feat: add feature")
	        $result.Error | Should -Be $null
	    }
	
	    It "unit: Get-CommitsSince returns an empty array when there are no commits" {
	        Mock Invoke-WebRequest {
	            [PSCustomObject]@{
	                StatusCode = 200
	                Content = ConvertTo-Json @()
	            }
	        } -ModuleName Get-CommitsSince
	
	        $result = Get-CommitsSince -owner $owner -repo $repo -branch $branch -token $token -FromRef "v0.0.0" -githubApiUrl $MockApiUrl
	        $result.Success | Should -Be $true
	        $result.Messages | Should -Be @()
	        $result.Error | Should -Be $null
	    }		
	}
	
    Context "Failure Cases" {
	    It "unit: Get-CommitsSince fails wil non-200 API call and FromRef set" {
	        Mock Invoke-WebRequest {
	            [PSCustomObject]@{
	                StatusCode = 404
	                Content = ""
	            }
	        } -ModuleName Get-CommitsSince
	
	        $result = Get-CommitsSince -owner $owner -repo $repo -branch $branch -token $token -FromRef "v1.2.3" -githubApiUrl $MockApiUrl
	        $result.Success | Should -Be $false
	        $result.Messages | Should -Be $null
	        $result.Error | Should -Match "Failed to retrieve commits from compare endpoint. Status code: 404"
	    }

	    It "unit: Get-CommitsSince fails with non-200 API call and FromRef not set" {
	        Mock Invoke-WebRequest {
	            [PSCustomObject]@{
	                StatusCode = 404
	                Content = ""
	            }
	        } -ModuleName Get-CommitsSince
	
	        $result = Get-CommitsSince -owner $owner -repo $repo -branch $branch -token $token -FromRef $null -githubApiUrl $MockApiUrl
	        $result.Success | Should -Be $false
	        $result.Messages | Should -Be $null
	        $result.Error | Should -Match "Failed to retrieve commits. Status code: 404"
	    }		
	}

	Context "Exception Failure Cases" {
	    It "unit: Get-CommitsSince fails with exception" {
	        Mock Invoke-WebRequest { throw "Network Error" } -ModuleName Get-CommitsSince
	
	        $result = Get-CommitsSince -owner $owner -repo $repo -branch $branch -token $token -FromRef "v1.2.3" -githubApiUrl $MockApiUrl
	        $result.Success | Should -Be $false
	        $result.Messages | Should -Be $null
	        $result.Error | Should -Match "Failed to retrieve commits. Exception: Network Error"
	    }
	}

	Context "Encoded Ref Cases" {
	    It "unit: Get-CommitsSince encodes branch name with slashes in commits endpoint" {
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
	        
	        $result = Get-CommitsSince -owner $owner -repo $repo -branch "feature/my-branch" -token $token -FromRef $null -githubApiUrl $MockApiUrl
	        $result.Success | Should -Be $true
	        $result.Messages.Count | Should -Be 1
	
			$script:lastRequestUrl | Should -Match "sha=feature%2Fmy-branch"
	    }  	
		
		It "unit: Get-CommitsSince encodes branch name with slashes in compare endpoint" {
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
			
			$result = Get-CommitsSince -owner $owner -repo $repo -branch "feature/my-branch" -token $token -FromRef "v1.0.0" -githubApiUrl $MockApiUrl
			$result.Success | Should -Be $true
			$result.Messages.Count | Should -Be 1
	
			$script:lastRequestUrl | Should -Match "\.\.\.feature%2Fmy-branch"
		}
	
		 It "unit: Get-commitsSince encodes FromRef with slashes in compare endpoint" {
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
			
			$result = Get-CommitsSince -owner $owner -repo $repo -branch "main" -token $token -FromRef "refs/tags/v1.0.0" -githubApiUrl $MockApiUrl
			$result.Success | Should -Be $true
			$result.Messages.Count | Should -Be 1
	
			$script:lastRequestUrl | Should -Match "refs%2Ftags%2Fv1\.0\.0\.\.\."
		}	
	}    
}

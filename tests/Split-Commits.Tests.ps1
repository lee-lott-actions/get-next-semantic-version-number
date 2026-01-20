Import-Module "$PSScriptRoot/../modules/Split-Commits.psm1" -Force

Describe "Split-Commits" {
    It "returns major when BREAKING CHANGE is present" {
        $commits = @("feat: something", "fix: stuff", "BREAKING CHANGE: API changed")
        $result = Split-Commits $commits
        $result | Should -Be "major"
    }
    It "returns major when !: is present" {
        $commits = @("feat!: major change", "fix: stuff")
        $result = Split-Commits $commits
        $result | Should -Be "major"
    }
    It "returns major when !: is present in fix" {
        $commits = @("fix!: bug fix", "docs: update docs")
        $result = Split-Commits $commits
        $result | Should -Be "major"
    }
    It "returns major when casing is different" {
        $commits = @("FeAt!: major change", "BREAKING change: stuff")
        $result = Split-Commits $commits
        $result | Should -Be "major"
    }
    It "returns minor when only feat is present" {
        $commits = @("feat: new feature", "docs: update docs")
        $result = Split-Commits $commits
        $result | Should -Be "minor"
    }
    It "returns minor when feat has scope" {
        $commits = @("feat(auth): new login feature", "chore: cleanup")
        $result = Split-Commits $commits
        $result | Should -Be "minor"
    }
    It "returns patch when only fix is present" {
        $commits = @("fix: bug fix", "chore: cleanup")
        $result = Split-Commits $commits
        $result | Should -Be "patch"
    }
    It "returns patch when fix has scope" {
        $commits = @("fix(auth): login bug fix", "docs: update docs")
        $result = Split-Commits $commits
        $result | Should -Be "patch"
    }
    It "returns none when no relevant commits" {
        $commits = @("docs: update docs", "chore: cleanup")
        $result = Split-Commits $commits
        $result | Should -Be "none"
    }
    It "returns none when array is empty" {
        $commits = @()
        $result = Split-Commits $commits
        $result | Should -Be "none"
    }

    It "returns major when major, minor, and patch are all present" {
        $commits = @("fix: bug", "feat: feature", "BREAKING CHANGE: update")
        $result = Split-Commits $commits
        $result | Should -Be "major"
    }

    It "returns minor when minor and patch are present but no major" {
        $commits = @("fix: bug", "feat: feature")
        $result = Split-Commits $commits
        $result | Should -Be "minor"
    }
}
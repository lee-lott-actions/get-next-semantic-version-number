Import-Module "$PSScriptRoot/../modules/Split-Version.psm1" -Force

Describe "Split-Version" {
    It "parses a valid version tag with leading v" {
        $result = Split-Version "v1.2.3"
        $result.Major | Should -Be 1
        $result.Minor | Should -Be 2
        $result.Patch | Should -Be 3
    }
    It "parses a valid version tag without leading v" {
        $result = Split-Version "1.2.3"
        $result.Major | Should -Be 1
        $result.Minor | Should -Be 2
        $result.Patch | Should -Be 3
    }
    It "returns null for invalid tag" {
        $result = Split-Version "not-a-tag"
        $result | Should -Be $null
    }
}
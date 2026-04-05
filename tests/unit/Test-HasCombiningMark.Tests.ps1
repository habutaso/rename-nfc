# Test-HasCombiningMark.Tests.ps1
# Property 4: Combining_Mark 検出の正確性
# Validates: Requirements 3.1, 3.2

. "$PSScriptRoot/../../normalize-rename.ps1"
. "$PSScriptRoot/helpers/Generators.ps1"

Describe "Test-HasCombiningMark" {

    It "Property 4: Combining_Mark 検出の正確性 - Combining_Mark を含む入力で true を返す" {
        # **Validates: Requirements 3.1, 3.2**
        1..100 | ForEach-Object {
            $input = New-RandomStringWithCombiningMarks
            $result = Test-HasCombiningMark $input
            $result | Should Be $true
        }
    }

    It "Property 4: Combining_Mark 検出の正確性 - Combining_Mark を含まない入力で false を返す" {
        # **Validates: Requirements 3.1, 3.2**
        1..100 | ForEach-Object {
            $input = New-RandomStringWithoutCombiningMarks
            $result = Test-HasCombiningMark $input
            $result | Should Be $false
        }
    }
}

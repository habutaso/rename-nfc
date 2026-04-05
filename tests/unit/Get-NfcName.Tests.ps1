# Get-NfcName.Tests.ps1
# Property 5: NFC •ÏŠ·‚Ì³Šm«‚Æ™p“™«
# Validates: Requirements 4.1, 4.2, 5.2, 5.3
# Tag: Feature: unicode-normalize-rename, Property 5: NFC•ÏŠ·‚Ì³Šm«‚Æ™p“™«

. "$PSScriptRoot/../../normalize-rename.ps1"
. "$PSScriptRoot/helpers/Generators.ps1"

Describe "Get-NfcName" {

    It "Property 5: NFC•ÏŠ·‚Ì³Šm«‚Æ™p“™« - Combining_Mark œ‹" {
        # **Validates: Requirements 4.1, 5.2**
        $dakuten     = [char]0x3099
        $handakuten  = [char]0x309A
        $pattern     = "[$dakuten$handakuten]"
        1..100 | ForEach-Object {
            $input = New-RandomStringWithCombiningMarks
            $result = Get-NfcName $input
            $result | Should Not Match $pattern
        }
    }

    It "Property 5: NFC•ÏŠ·‚Ì³Šm«‚Æ™p“™« - ™p“™« (Combining_Mark ‚ ‚è)" {
        # **Validates: Requirements 4.2, 5.3**
        1..100 | ForEach-Object {
            $input = New-RandomStringWithCombiningMarks
            $once = Get-NfcName $input
            $twice = Get-NfcName $once
            $twice | Should Be $once
        }
    }

    It "Property 5: NFC•ÏŠ·‚Ì³Šm«‚Æ™p“™« - ™p“™« (Combining_Mark ‚È‚µ)" {
        # **Validates: Requirements 4.2, 5.3**
        1..100 | ForEach-Object {
            $input = New-RandomStringWithoutCombiningMarks
            $once = Get-NfcName $input
            $twice = Get-NfcName $once
            $twice | Should Be $once
        }
    }
}

# Generators.ps1
# Random input generator helper functions for property-based tests

# ASCII letters and digits for mixing into test strings
$script:AsciiChars = [char[]]([char]'a'..[char]'z') + [char[]]([char]'A'..[char]'Z') + [char[]]([char]'0'..[char]'9')

# Pre-composed Japanese katakana characters (NFC, no combining marks)
$script:JapaneseChars = @(
    [char]0x30A2, # �A
    [char]0x30A4, # �C
    [char]0x30A6, # �E
    [char]0x30A8, # �G
    [char]0x30AA, # �I
    [char]0x30AB, # �J
    [char]0x30AC, # �K (pre-composed)
    [char]0x30AD, # �L
    [char]0x30AE, # �M (pre-composed)
    [char]0x30AF, # �N
    [char]0x3042, # ��
    [char]0x3044, # ��
    [char]0x3046, # ��
    [char]0x3048, # ��
    [char]0x304A  # ��
)

# Combining marks to inject
$script:CombiningMarks = @([char]0x3099, [char]0x309A)

# Kana base characters that have a precomposed NFC form with U+3099 (dakuten)
# These are the NFD decompositions of voiced kana (e.g. �J+3099 = �K)
$script:DakutenBases = @(
    [char]0x30AB, # �J -> �K
    [char]0x30AD, # �L -> �M
    [char]0x30AF, # �N -> �O
    [char]0x30B1, # �P -> �Q
    [char]0x30B3, # �R -> �S
    [char]0x30B5, # �T -> �U
    [char]0x30B7, # �V -> �W
    [char]0x30B9, # �X -> �Y
    [char]0x30BB, # �Z -> �[
    [char]0x30BD, # �\ -> �]
    [char]0x30BF, # �^ -> �_
    [char]0x30C1, # �` -> �a
    [char]0x30C4, # �c -> �d
    [char]0x30C6, # �e -> �f
    [char]0x30C8, # �g -> �h
    [char]0x30CF, # �n -> �o
    [char]0x30D2, # �q -> �r
    [char]0x30D5, # �t -> �u
    [char]0x30D8, # �w -> �x
    [char]0x30DB, # �z -> �{
    [char]0x3046, # �� -> ��
    [char]0x304B, # �� -> ��
    [char]0x304D, # �� -> ��
    [char]0x304F, # �� -> ��
    [char]0x3051, # �� -> ��
    [char]0x3053, # �� -> ��
    [char]0x3055, # �� -> ��
    [char]0x3057, # �� -> ��
    [char]0x3059, # �� -> ��
    [char]0x305B, # �� -> ��
    [char]0x305D, # �� -> ��
    [char]0x305F, # �� -> ��
    [char]0x3061, # �� -> ��
    [char]0x3064, # �� -> ��
    [char]0x3066, # �� -> ��
    [char]0x3068, # �� -> ��
    [char]0x306F, # �� -> ��
    [char]0x3072, # �� -> ��
    [char]0x3075, # �� -> ��
    [char]0x3078, # �� -> ��
    [char]0x307B  # �� -> ��
)

# Kana base characters that have a precomposed NFC form with U+309A (handakuten)
$script:HandakutenBases = @(
    [char]0x30CF, # �n -> �p
    [char]0x30D2, # �q -> �s
    [char]0x30D5, # �t -> �v
    [char]0x30D8, # �w -> �y
    [char]0x30DB, # �z -> �|
    [char]0x306F, # �� -> ��
    [char]0x3072, # �� -> ��
    [char]0x3075, # �� -> ��
    [char]0x3078, # �� -> ��
    [char]0x307B  # �� -> ��
)

<#
.SYNOPSIS
    Generates a random string that contains at least one U+3099 or U+309A combining mark.
.DESCRIPTION
    Produces a string of random length (3-12 chars) mixing ASCII, Japanese pre-composed chars,
    and at least one combining mark (U+3099 or U+309A) placed only after kana base characters
    that have a precomposed NFC form. This ensures NFC normalization will remove all combining marks.
#>
function New-RandomStringWithCombiningMarks {
    $rng = [System.Random]::new()
    $chars = [System.Collections.Generic.List[char]]::new()

    # Build a list of (base, mark) pairs to insert - each pair will NFC-compose cleanly
    $markCount = $rng.Next(1, 4)
    $markedPairs = [System.Collections.Generic.List[char[]]]::new()
    for ($i = 0; $i -lt $markCount; $i++) {
        if ($rng.Next(0, 2) -eq 0) {
            $mark = [char]0x3099
            $base = $script:DakutenBases[$rng.Next(0, $script:DakutenBases.Count)]
        } else {
            $mark = [char]0x309A
            $base = $script:HandakutenBases[$rng.Next(0, $script:HandakutenBases.Count)]
        }
        $markedPairs.Add([char[]]@($base, $mark))
    }

    # Build the string: intersperse base chars with the marked pairs
    $pool = $script:AsciiChars + $script:JapaneseChars
    $totalLength = $rng.Next(3, 13)
    $pairIdx = 0
    $i = 0
    while ($i -lt $totalLength -or $pairIdx -lt $markedPairs.Count) {
        # Randomly decide to insert a marked pair (if any remain) or a plain char
        $insertPair = ($pairIdx -lt $markedPairs.Count) -and (($i -ge $totalLength) -or ($rng.Next(0, 2) -eq 0))
        if ($insertPair) {
            $chars.Add($markedPairs[$pairIdx][0])
            $chars.Add($markedPairs[$pairIdx][1])
            $pairIdx++
        } else {
            $chars.Add($pool[$rng.Next(0, $pool.Length)])
            $i++
        }
    }

    return [string]::new($chars.ToArray())
}

<#
.SYNOPSIS
    Generates a random string that contains NO U+3099 or U+309A combining marks.
.DESCRIPTION
    Produces a string of random length (3-12 chars) using only ASCII letters/digits
    and pre-composed Japanese characters (no combining marks).
#>
function New-RandomStringWithoutCombiningMarks {
    $rng = [System.Random]::new()
    $length = $rng.Next(3, 13)
    $pool = $script:AsciiChars + $script:JapaneseChars
    $chars = 1..$length | ForEach-Object { $pool[$rng.Next(0, $pool.Length)] }
    return [string]::new([char[]]$chars)
}

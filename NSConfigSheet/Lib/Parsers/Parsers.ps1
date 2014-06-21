Function PhraseMatch
{
    [CmdletBinding()]
    param(
        # the text.
        [string[]]
        $text,

        # the pattern.
        [array]
        $pattern,

        # prefix match.
        [switch]
        $prefix,

        # the offset.
        [int]
        $offset = 0
    )

    if($prefix) {
        if(($text.Count - $offset) -lt $pattern.Count) {
            return $False
        }
    } else {
        if(($text.Count - $offset) -ne $pattern.Count) {
            return $False
        }
    }

    $script:last_matches = @()
    for($i = 0; $i -lt $pattern.Count; $i++) {
        if($pattern[$i] -is [string]) {
            if($text[$offset + $i] -ine $pattern[$i]) {
                return $False
            }
        } elseif($pattern[$i] -is $REGEX) {
            if($text[$offset + $i] -match $pattern[$i]) {
                $script:last_matches += $matches
            } else {
                return $False
            }
        } elseif($pattern[$i] -is [Array]) {
            if(-not ($pattern[$i] -contains $text[$offset + $i])) {
                return $False
            }
        } elseif($pattern[$i] -eq $Null) {
            # nothing to be done
        } else {
            throw "Invalid pattern: `$pattern[$i]: $($pattern[$i])`n$line"
        }
    }
    $True
}

function New-ObjectUnlessDefined
{
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true)]
        [ref]$var,

        [parameter(Mandatory=$true)]
        [string]$attr,

        [string]$type = ''
    )

    if( $type -eq '') {
        $type = $attr
    }

    if($var.Value.$attr -eq $null) {
        $var.Value.$attr = New-Object $type
    }
}

function ncdr
{
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true)]
        [array]$array,

        [parameter(Mandatory=$true)]
        [int]$pos
    )

    if($pos -ge $array.Count) {
        @()
    } else {
        $array[$pos..($array.Count-1)]
    }
}
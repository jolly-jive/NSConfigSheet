Function Parse-URL-PROTOCOL
{
    [CmdletBinding()]
    param(
        [string[]]
        [parameter(Mandatory=$true)]
        $params
    )

    if(PhraseMatch $params 'set' -prefix) {
        Parse-ROOT-Body @(ncdr $params 1)
    } elseif(PhraseMatch $params 'unset' -prefix) {
        Parse-ROOT-Body @(ncdr $params 1)
    } elseif(PhraseMatch $params 'exit') {
        if($context.Count -gt 0) {
            $prev_context = $context.Pop()
        } else {
            throw "Illegal exit: $line"
        }
    } else {
        throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
    }
}

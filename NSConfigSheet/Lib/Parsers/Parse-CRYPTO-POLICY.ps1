Function Parse-CRYPTO-POLICY
{
    [CmdletBinding()]
    param(
        [string[]]
        [parameter(Mandatory=$true)]
        $params
    )

    if(PhraseMatch $params 'set' -prefix) {
        #Parse-CRYPTO-POLICY-Body @(ncdr $params 1) $True
    } elseif(PhraseMatch $params 'unset' -prefix) {
        #Parse-CRYPTO-POLICY-Body @(ncdr $params 1) $False
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

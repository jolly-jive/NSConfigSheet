Function Parse-VROUTER-Set-Route
{
    [CmdletBinding()]
    param(
        [string[]]
        [parameter(Mandatory=$true)]
        $params
    )

    [string]$state = 'BEGIN'
    [RouteRecord]$route = $Null
    while($params.Count -gt 0) {
        switch($state) {
            'BEGIN' {
                if(PhraseMatch $params 'source' -prefix) {
                    $route = New-Object RouteRecord
                    $VRouterDic[$vr_name].SourceRoute += $route
                    $params = @(ncdr $params 1)
                } elseif(PhraseMatch $params 'in-interface',$RE_INTERFACE_NAME -prefix) {
                    $route = New-Object SourceInterfaceRouteRecordRouteRecord
                    $route.InInterface = $last_matches[0]['INTERFACE_NAME']
                    $VRouterDic[$vr_name].SourceInterfaceRoute += $route
                    $params = @(ncdr $params 2)
                } elseif(PhraseMatch $params $RE_IPV4_ADDRESS_WITH_MASK -prefix) {
                    if($route -eq $Null) {
                        $route = New-Object RouteRecord
                        $VRouterDic[$vr_name].DestinationRoute += $route
                    }
                    $route.IPAddr = $last_matches[0]['IPV4_ADDRESS_WITH_MASK']
                    $state = 'IPADDR READ'
                    $params = @(ncdr $params 1)
                } else {
                    $state = 'ERROR'
                }
            }
            'IPADDR READ' {
                if(PhraseMatch $params 'description',$RE_QUOTED_NAME -prefix) {
                    $route.Description = $last_matches['QUOTED_NAME']
                    $params = @(ncdr $params 2)
                } elseif(PhraseMatch $params 'gateway',$RE_IPV4_HOST_ADDRESS -prefix) {
                    $route.Gateway = $last_matches[0]['IPV4_HOST_ADDRESS']
                    $params = @(ncdr $params 2)
                } elseif(PhraseMatch $params 'interface',$RE_INTERFACE_NAME -prefix) {
                    $route.Interface = $last_matches[0]['INTERFACE_NAME']
                    $params = @(ncdr $params 2)
                } elseif(PhraseMatch $params 'metric',$RE_INTEGER -prefix) {
                    $route.Metric = [int]$params[1]
                    $params = @(ncdr $params 2)
                } elseif(PhraseMatch $params 'permanent' -prefix) {
                    $route.Permanent = $True
                    $params = @(ncdr $params 2)
                } elseif(PhraseMatch $params 'preference',$RE_INTEGER -prefix) {
                    $route.Preference = [int]$params[1]
                    $params = @(ncdr $params 2)
                } elseif(PhraseMatch $params 'vrouter',$RE_QUOTED_NAME -prefix) {
                    $route.Gateway = $last_matches[0]['QUOTED_NAME']
                    $params = @(ncdr $params 2)
                } else {
                    $state = 'ERROR'
                }
            }
            'ERROR' {
                throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
            }
            default {
                throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
            }
        }
    }
}


Function Parse-VROUTER-Set-Body
{
    [CmdletBinding()]
    param(
        [string[]]
        [parameter(Mandatory=$true)]
        $params
    )

    $dst_address = $Null
    $gateway_address = $Null

    if(PhraseMatch $params 'add-default-route') {
        $VRouterDic[$vr_name].AddDefaultRouteVrouter = 'untrust-vr'
    } elseif(PhraseMatch $params 'add-default-route','vrouter',$Null) {
        $VRouterDic[$vr_name].AddDefaultRouteVrouter = $params[2]
        # This directive is applied to the $vr_name's routing table.

    } elseif(PhraseMatch $params 'adv-inact-interface') {
        $VRouterDic[$vr_name].AdvInactInterface = $True

    } elseif(PhraseMatch $params 'auto-route-export') {
        $VRouterDic[$vr_name].AutoRouteExport = $True

    } elseif(PhraseMatch $params 'default-vrouter') {
        $VRouterDic[$vr_name].DefaultVrouter = $True

    } elseif(PhraseMatch $params 'export-to' -prefix) {
        #$VRouterDic[$vr_name]. = $True
        Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"

    } elseif(PhraseMatch $params 'import-from' -prefix) {
        #$VRouterDic[$vr_name]. = $True
        Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"

    } elseif(PhraseMatch $params 'ignore-subnet-conflict') {
        $VRouterDic[$vr_name].IgnoreSubnetConflict = $True

    } elseif(PhraseMatch $params 'max-ecmp-routes',$RE_INTEGER) {
        $VRouterDic[$vr_name].MaxEqualCostMultipathRoutes = [int]$params[1]

    } elseif(PhraseMatch $params 'max-routes',$RE_INTEGER) {
        $VRouterDic[$vr_name].MaxRoutes = [int]$params[1]

    } elseif(PhraseMatch $params 'mroute' -prefix) {
        #$VRouterDic[$vr_name]. = $True
        Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"

    } elseif(PhraseMatch $params 'nsrp-config-sync') {
        $VRouterDic[$vr_name].NSRPConfigSync = $True

    } elseif(PhraseMatch $params[0] 'pbr' -prefix) {
        #$VRouterDic[$vr_name]. = $True
        Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"

    } elseif(PhraseMatch $params 'preference' -prefix) {
        New-ObjectUnlessDefined ([ref]$VRouterDic[$vr_name]) RoutePreference

        if(PhraseMatch $params 'auto-exported',$RE_INTEGER -offset 1) {
            $VRouterDic[$vr_name].RoutePreference.AutoExported = [int]$params[2]
        } elseif(PhraseMatch $params 'connected',$RE_INTEGER -offset 1) {
            $VRouterDic[$vr_name].RoutePreference.Connected = [int]$params[2]
        } elseif(PhraseMatch $params 'ebgp',$RE_INTEGER -offset 1) {
            $VRouterDic[$vr_name].RoutePreference.EBGP = [int]$params[2]
        } elseif(PhraseMatch $params 'ibgp',$RE_INTEGER -offset 1) {
            $VRouterDic[$vr_name].RoutePreference.IBGP = [int]$params[2]
        } elseif(PhraseMatch $params 'imported',$RE_INTEGER -offset 1) {
            $VRouterDic[$vr_name].RoutePreference.Imported = [int]$params[2]
        } elseif(PhraseMatch $params 'ospf',$RE_INTEGER -offset 1) {
            $VRouterDic[$vr_name].RoutePreference.OSPF = [int]$params[2]
        } elseif(PhraseMatch $params 'ospf-e2',$RE_INTEGER -offset 1) {
            $VRouterDic[$vr_name].RoutePreference.OSPFE2 = [int]$params[2]
        } elseif(PhraseMatch $params 'rip',$RE_INTEGER -offset 1) {
            $VRouterDic[$vr_name].RoutePreference.RIP = [int]$params[2]
        } elseif(PhraseMatch $params 'static',$RE_INTEGER -offset 1) {
            $VRouterDic[$vr_name].RoutePreference.Static = [int]$params[2]
        } else {
            throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
        }

    } elseif(PhraseMatch $params 'protocol' -prefix) {
        #$VRouterDic[$vr_name]. = $True
        Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"

    } elseif(PhraseMatch $params 'route' -prefix) {
        Parse-VROUTER-Set-Route @(ncdr $params 1)

    } elseif(PhraseMatch $params 'route-lookup' -prefix) {
        #$VRouterDic[$vr_name]. = $True
        Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"

    } elseif(PhraseMatch $params 'route-map' -prefix) {
        #$VRouterDic[$vr_name]. = $True
        Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"

    } elseif((PhraseMatch $params 'router-id',$RE_INTEGER) -or (PhraseMatch $params 'id',$RE_INTEGER)) {
        $VRouterDic[$vr_name].Id = [int]$params[1]

    } elseif(PhraseMatch $params 'sharable') {
        $VRouterDic[$vr_name].Sharable = $True

    } elseif(PhraseMatch $params 'sibr-routing','enable') {
        $VRouterDic[$vr_name].SourceInterfaceBasedRouting = $True

    } elseif(PhraseMatch $params 'snmp','trap','private') {
        $VRouterDic[$vr_name].SNMPTrapPrivate = $True

    } elseif(PhraseMatch $params 'source-routing','enable') {
        $VRouterDic[$vr_name].SourceRouting = $True

    } else {
        throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
    }
}

Function Parse-VROUTER-Unset-Body
{
    [CmdletBinding()]
    param(
        [string[]]
        [parameter(Mandatory=$true)]
        $params
    )

    $dst_address = $Null
    $gateway_address = $Null

    if(PhraseMatch $params 'add-default-route' -prefix) {
        $VRouterDic[$vr_name].AddDefaultRouteVrouter = ''
        # This directive is applied to the $vr_name's routing table.

    } elseif(PhraseMatch $params 'adv-inact-interface') {
        $VRouterDic[$vr_name].AdvInactInterface = $False

    } elseif(PhraseMatch $params 'auto-route-export') {
        $VRouterDic[$vr_name].AutoRouteExport = $False

    } elseif(PhraseMatch $params 'default-vrouter') {
        $VRouterDic[$vr_name].DefaultVrouter = $False

    } elseif(PhraseMatch $params 'export-to' -prefix) {
        #$VRouterDic[$vr_name]. = $False
        Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"

    } elseif(PhraseMatch $params 'import-from' -prefix) {
        #$VRouterDic[$vr_name]. = $False
        Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"

    } elseif(PhraseMatch $params 'ignore-subnet-conflict') {
        $VRouterDic[$vr_name].IgnoreSubnetConflict = $False

    } elseif(PhraseMatch $params 'max-ecmp-routes') {
        $VRouterDic[$vr_name].MaxEqualCostMultipathRoutes = $Null

    } elseif(PhraseMatch $params 'max-routes') {
        $VRouterDic[$vr_name].MaxRoutes = $Null

    } elseif(PhraseMatch $params 'mroute' -prefix) {
        #$VRouterDic[$vr_name]. = $False
        Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"

    } elseif(PhraseMatch $params 'nsrp-config-sync') {
        $VRouterDic[$vr_name].NSRPConfigSync = $False

    } elseif(PhraseMatch $params[0] 'pbr' -prefix) {
        #$VRouterDic[$vr_name]. = $False
        Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"

    } elseif(PhraseMatch $params 'preference' -prefix) {
        New-ObjectUnlessDefined ([ref]$VRouterDic[$vr_name]) RoutePreference

        if(PhraseMatch $params 'auto-exported' -offset 1) {
            $VRouterDic[$vr_name].RoutePreference.AutoExported = $Null
        } elseif(PhraseMatch $params 'connected' -offset 1) {
            $VRouterDic[$vr_name].RoutePreference.Connected = $Null
        } elseif(PhraseMatch $params 'ebgp' -offset 1) {
            $VRouterDic[$vr_name].RoutePreference.EBGP = $Null
        } elseif(PhraseMatch $params 'ibgp' -offset 1) {
            $VRouterDic[$vr_name].RoutePreference.IBGP = $Null
        } elseif(PhraseMatch $params 'imported' -offset 1) {
            $VRouterDic[$vr_name].RoutePreference.Imported = $Null
        } elseif(PhraseMatch $params 'ospf' -offset 1) {
            $VRouterDic[$vr_name].RoutePreference.OSPF = $Null
        } elseif(PhraseMatch $params 'ospf-e2' -offset 1) {
            $VRouterDic[$vr_name].RoutePreference.OSPFE2 = $Null
        } elseif(PhraseMatch $params 'rip' -offset 1) {
            $VRouterDic[$vr_name].RoutePreference.RIP = $Null
        } elseif(PhraseMatch $params 'static' -offset 1) {
            $VRouterDic[$vr_name].RoutePreference.Static = $Null
        } else {
            throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
        }

    } elseif(PhraseMatch $params 'protocol' -prefix) {
        #$VRouterDic[$vr_name]. = $False
        Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"

    } elseif(PhraseMatch $params 'route',$RE_IPV4_ADDRESS_WITH_MASK -prefix) {
        Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"

    } elseif(PhraseMatch $params 'route-lookup' -prefix) {
        #$VRouterDic[$vr_name]. = $False
        Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"

    } elseif(PhraseMatch $params 'route-map' -prefix) {
        #$VRouterDic[$vr_name]. = $False
        Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"

    } elseif((PhraseMatch $params 'router-id') -or (PhraseMatch $params 'id')) {
        $VRouterDic[$vr_name].Id = $Null

    } elseif(PhraseMatch $params 'sharable') {
        $VRouterDic[$vr_name].Sharable = $False

    } elseif(PhraseMatch $params 'sibr-routing','enable') {
        $VRouterDic[$vr_name].SourceInterfaceBasedRouting = $False

    } elseif(PhraseMatch $params 'snmp','trap','private') {
        $VRouterDic[$vr_name].SNMPTrapPrivate = $False

    } elseif(PhraseMatch $params 'source-routing','enable') {
        $VRouterDic[$vr_name].SourceRouting = $False

    } else {
        throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
    }
}


Function Parse-VROUTER
{
    [CmdletBinding()]
    param(
        [string[]]
        [parameter(Mandatory=$true)]
        $params
    )

    if(PhraseMatch $params 'set' -prefix) {
        Parse-VROUTER-Set-Body @(ncdr $params 1)
    } elseif(PhraseMatch $params 'unset' -prefix) {
        Parse-VROUTER-Unset-Body @(ncdr $params 1)
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


Function Parse-ROOT-Set-VRouter
{
    [CmdletBinding()]
    param(
        [string[]]
        [parameter(Mandatory=$true)]
        $params
    )

    if(PhraseMatch $params 'name' -prefix) {
        $params = @(ncdr $params 1)
    }
    if(PhraseMatch $params $RE_QUOTED_NAME -prefix) {
        $script:vr_name = $last_matches[0]['QUOTED_NAME']
    } else {
        $script:vr_name = $params[0]
    }

    if(-not $VRouterDic.Contains($vr_name)) {
        [VRouter]$VRouterDic[$vr_name] = New-Object VRouter
        $VRouterDic[$vr_name].Name = $vr_name
    }

    if($params.Count -le 1) {
        $context.Push('VROUTER')
    } else {
        Parse-VROUTER-Set-Body @(ncdr $params 1)
    }
}

Function Parse-ROOT-Unset-VRouter
{
    [CmdletBinding()]
    param(
        [string[]]
        [parameter(Mandatory=$true)]
        $params
    )

    if(PhraseMatch $params 'name' -prefix) {
        $params = @(ncdr $params 1)
    }
    if(PhraseMatch $params $RE_QUOTED_NAME -prefix) {
        $script:vr_name = $last_matches[0]['QUOTED_NAME']
    } else {
        $script:vr_name = $params[0]
    }

    if(-not $VRouterDic.Contains($vr_name)) {
        [VRouter]$VRouterDic[$vr_name] = New-Object VRouter
        $VRouterDic[$vr_name].Name = $vr_name
    }

    if($params.Count -le 1) {
        $context.Push('VROUTER')
    } else {
        Parse-VROUTER-Unset-Body @(ncdr $params 1)
    }
}

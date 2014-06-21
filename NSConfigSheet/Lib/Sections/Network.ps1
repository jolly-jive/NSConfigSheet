Set-Variable -Scope Script -Option Constant -Name SectionNetwork -Value {
    ########## == Binding
    Write-Section $STYLE_HEADING2 'Binding' -keyword 'binding' -skip:($VRouterDic.Count -lt 1) {
        $range = Insert-TextAtLast $STYLE_BODYTEXT

        $script:table = Add-TableToDoc -Range $range -Rows $VRouterDic.Count -Cols 5 `
          -Title @('#','Virtual Router','Zone','Interface','memo') `
          -Style @($STYLE_LISTNUMBER,$STYLE_CODE,$STYLE_CODE,$STYLE_CODE,$Null)

        $i_row = 2
        foreach($vr_name in $VRouterDic.keys | Sort-Object) {
            $script:table.Cell($i_row,2).Range.Text = $vr_name

            $zone_list = @()
            $if_list_for_each_zone = @{}
            foreach($zone_name in $ZoneDic.keys | Sort-Object) {
                if($ZoneDic[$zone_name].VRouter -ieq $vr_name) {
                    $zone_list += $zone_name
                    $if_list_for_each_zone[$zone_name] = @()
                    foreach($if_name in $InterfaceDic.keys | Sort-Object) {
                        if($InterfaceDic[$if_name].Zone -ieq $zone_name) {
                            $if_list_for_each_zone[$zone_name] += $if_name
                        }
                    }
                }
            }
            Split-Row $script:table  $i_row 3  $i_row 4  $zone_list.Count

            foreach($zone_name in $zone_list) {
                Write-Block2Cells $table.Cell($i_row,3) {
                    $zone_name
                    $if_list_for_each_zone[$zone_name] -join "`n"
                }
                $i_row += 1
            }
        }
    }

    ########## == DNS
    ########## === Cache
    ########## === Proxy
    ########## === DDNS

    ########## == Zones
    Write-Section $STYLE_HEADING2 'Zones' -keyword 'zone' -skip:($ZoneDic.Count -lt 1){
        $range = Insert-TextAtLast $STYLE_BODYTEXT

        $script:table = Add-TableToDoc -Range $range -Rows $ZoneDic.Count -Cols 8 `
          -Title @('#','name','id','vrouter','vsys','tcp rst','block','memo') `
          -Style @($STYLE_LISTNUMBER,$STYLE_CODE,$Null,$STYLE_CODE,$STYLE_CODE,$Null,$Null,$Null)

        $i_row = 2
        foreach($zone_name in $ZoneDic.keys | Sort-Object) {
            $zone_instance = $ZoneDic[$zone_name]
            Write-Block2Cells $table.Cell($i_row,2) {
                $zone_name
                $zone_instance.Id
                $zone_instance.VRouter
                $zone_instance.VSys
                EnabledOrDisabled $zone_instance.TCPRst
                EnabledOrDisabled $zone_instance.Block
            }
            $i_row += 1
        }
    }

    foreach($zone_name in $ZoneDic.keys | Sort-Object) {
        $zone_instance = $ZoneDic[$zone_name]

        ######### === $zone_name
        Write-Section $STYLE_HEADING3 $zone_name -keyword 'each_zone' -skip:($zone_instance.ManagementService -eq $Null) {
            $range = Insert-TextAtLast $STYLE_BODYTEXT

            $script:table = Add-TableToDoc -Range $range -Rows 1 -Cols 4 `
              -Title @('#','Attribute','Value','memo') `
              -Style @($STYLE_LISTNUMBER,$Null,$Null,$Null)

            $col_list_style_code = @()
            $script:current_row = $table.Rows.Last

            Write-AVRow 'Management Services' ($zone_instance.ManagementService.GetManagementServiceNames() -join ', ')
            Write-AVRow 'Other Services' ($zone_instance.ManagementService.GetOtherServiceNames() -join ', ')

            $col_list_style_code | foreach { $script:table.Cell($_,3).Range.Style = $STYLE_CODE }
        }
    }

    ########## == Interface
    Write-Section $STYLE_HEADING2 'Interfaces' -keyword 'interface' -skip:($InterfaceDic.Count -lt 1) {
        $range = Insert-TextAtLast $STYLE_BODYTEXT

        $script:table = Add-TableToDoc -Range $range -Rows $InterfaceDic.Count -Cols 6 `
          -Title @('#','Name','IP/Netmask','Zone','VID','memo') `
          -Style @($STYLE_LISTNUMBER,$STYLE_CODE,$STYLE_CODE,$STYLE_CODE,$Null,$Null)

        $i_row = 2
        foreach($if_name in $InterfaceDic.keys | Sort-Object) {
            $if_object = $InterfaceDic[$if_name]
            Write-Block2Cells $table.Cell($i_row,2) {
                $if_name
                if($if_object.IPAddressSetting -is [SetStaticIP]) { $if_object.IPAddressSetting.IPAddr } else { $Null }
                $if_object.Zone
                $if_object.Tag
            }
            $i_row += 1
        }
    }

    foreach($if_name in $InterfaceDic.keys | Sort-Object) {
        $if_instance = $InterfaceDic[$if_name]

        ######### === $if_name
        Write-Section $STYLE_HEADING3 $if_name -keyword 'each_interface' {

            ########## ==== Basic for $if_name
            $range = Insert-TextAtLast $STYLE_HEADING4 "Basic for $if_name`n"
            $range = Insert-TextAtLast $STYLE_BODYTEXT

            $script:table = Add-TableToDoc -Range $range -Rows 1 -Cols 4 `
              -Title @('#','Attribute','Value','memo') `
              -Style @($STYLE_LISTNUMBER,$Null,$Null,$Null)

            $col_list_style_code = @()
            $script:current_row = $table.Rows.Last

            Write-AVRow 'Name' $if_name
            $col_list_style_code += $table.Rows.Last.Index
            if($if_instance.Zone -ne '') {
                Write-AVRow 'Zone'  $if_instance.Zone
                $col_list_style_code += $table.Rows.Last.Index
            }
            Write-AVRow '802.1Q VLAN Id' $if_instance.Tag
            if($if_instance.IPAddressSetting -is [ObtainFromDHCP]) {
                Write-AVRow 'Obtain IP using DHCP' ''
                Write-AVRow '  Automatic update DHCP server pameters' $if_instance.IPAddressSetting.AutomaticUpdateDHCPServerParameters
            } elseif($if_instance.IPAddressSetting -is [ObtainFromPPPoE]) {
                Write-AVRow 'Obtain IP using PPPoE' ''
                Write-AVRow '  PPPoE Configration' $if_instance.IPAddressSetting.PPPProfile
                $col_list_style_code += $table.Rows.Last.Index
            } elseif($if_instance.IPAddressSetting -is [SetStaticIP]) {
                Write-AVRow 'Static IP' ''
                Write-AVRow '  IP Address/Netmask' $if_instance.IPAddressSetting.IPAddr
                $col_list_style_code += $table.Rows.Last.Index
                Write-AVRow '  IP Manageable' $if_instance.IPAddressSetting.Manageable
                Write-AVRow '  Manage IP' (OmitEmptyString $if_instance.IPAddressSetting.ManageIPAddr)
                $col_list_style_code += $table.Rows.Last.Index
            }

            Write-AVRow 'Interface Mode' $if_instance.Mode
            Write-AVRow 'Block Intra-Subnet Traffic' $if_instance.BlockIntraSubnetTraffic
            if(@($if_instance.ManagementService.GetManagementServiceNames()).Count -gt 0 -or @($if_instance.ManagementService.GetOtherServiceNames()).Count -gt 0) {
                Write-AVRow 'Service Options' ''
                Write-AVRow '  Management Services' (@($if_instance.ManagementService.GetManagementServiceNames()) -join ', ')
                Write-AVRow '  Other Services' (@($if_instance.ManagementService.GetOtherServiceNames()) -join ', ')
            }
            Write-AVRow 'Maximum Transfer Unit (MTU)' $if_instance.MTU 'Admin MTU {0} Bytes'
            Write-AVRow 'DNS Proxy' $if_instance.DNSProxy
            Write-AVRow 'NTP Server' $if_instance.NTPServer

            Write-AVRow 'G-ARP' $if_instance.GARP
            if($if_instance.Bandwidth -ne $Null) {
                Write-AVRow 'Traffic Bandwidth' $True
                Write-AVRow '  Egress' $if_instance.Bandwidth.Egress 'Maximum Bandwidth {0} Kbps'
                Write-AVRow '  Ingress' $if_instance.Bandwidth.Ingress 'Maximum Bandwidth {0} Kbps'
            }
            Write-AVRow 'VRRP' $if_instance.VRRP

            Write-AVRow 'Openly passes all IPsec traffic' $if_instance.BypassOthersIPSec
            Write-AVRow 'Openly passes non-IP traffic with a unicast MAC destination address' $if_instance.BypassNonIP
            Write-AVRow 'Openly passes All non-IP traffic' $if_instance.BypassNonIPAll

            if($if_instance -is [BridgeGroupInterfaceProfile]) {
                Write-AVRow 'Port' ($if_instance.Port -join "`n")
                $col_list_style_code += $table.Rows.Last.Index
            }

            $col_list_style_code | foreach { $script:table.Cell($_,3).Range.Style = $STYLE_CODE }


            ########## ==== MIP for $if_name
            Write-Section $STYLE_HEADING4 "MIP for $if_name" -skip:($if_instance.MappedIP.Count -lt 1) {
                $range = Insert-TextAtLast $STYLE_BODYTEXT

                $script:table = Add-TableToDoc -Range $range -Rows $if_instance.MappedIP.Count -Cols 6 `
                  -Title @('#','Mapped IP','Host IP','Netmask','VRouter','memo') `
                  -Style @($STYLE_LISTNUMBER,$STYLE_CODE,$STYLE_CODE,$STYLE_CODE,$STYLE_CODE,$Null)

                $i_row = 2
                foreach($mapped_ip in $if_instance.MappedIP) {
                    Write-Block2Cells $table.Cell($i_row,2) {
                        $mapped_ip.MIP
                        $mapped_ip.HostIP
                        $mapped_ip.Netmask
                        $mapped_ip.VRouter
                    }
                    $i_row++
                }
            }

            ########## ==== DIP for $if_name
            Write-Section $STYLE_HEADING4 "DIP for $if_name" -skip {
                $range = Insert-TextAtLast $STYLE_BODYTEXT

                $script:table = Add-TableToDoc -Range $range -Rows 1 -Cols 4 `
                  -Title @('ID','IP Address Range','DIP Type','memo') `
                  -Style @($Null,$STYLE_CODE,$Null,$Null) `
                  -DontRenumber
            }

            ########## ==== VIP for $if_name
            Write-Section $STYLE_HEADING4 "VIP for $if_name" -skip:($if_instance.VirtualIP.Count -lt 1) {
                $range = Insert-TextAtLast $STYLE_BODYTEXT

                $script:table = Add-TableToDoc -Range $range -Rows $if_instance.VirtualIP.Count -Cols 7 `
                  -Title @('#','Virtual',$Null,'Mapped to',$Null,"Server `nAutodetection",'memo') `
                  -Style @($STYLE_LISTNUMBER,$STYLE_CODE,$Null,$STYLE_CODE,$STYLE_CODE,$Null,$Null)

                (Select-CellRange $table  1 2  1 5).Cells.Split(2,1)

                Write-Block2Cells $table.Cell(2,2) {
                    'IP Address'
                    'Port'
                    'Service'
                    'IP Address'
                }

                (Select-CellRange $table  1 4  1 5).Cells.Merge()
                (Select-CellRange $table  1 2  1 3).Cells.Merge()

                $i_row = 3
                foreach($virtual_ip in  $if_instance.VirtualIP.keys | Sort-Object) {
                    $virtual_service = $if_instance.VirtualIP[$virtual_ip].VirtualService
                    $script:table.Cell($i_row,2).Range.Text = $virtual_ip

                    Split-Row $table  $i_row 3  $i_row 6  $virtual_service.Count

                    foreach($element in ($virtual_service | Sort-Object VirtualPort)) {
                        Write-Block2Cells $table.Cell($i_row,3) {
                            $element.VirtualPort
                            $element.MapToService
                            $element.MapToIPAddr
                            $element.ServerAutoDetection
                        }
                        $i_row += 1
                    }
                }
            }

            ########## ==== Secondary IP for $if_name
            Write-Section $STYLE_HEADING4 "Secondary IP for $if_name" -skip:($if_instance.IPAddressSetting -isnot [SetStaticIP] -or $if_instance.IPAddressSetting.SecondaryIPAddr.Count -lt 1) {
                $range = Insert-TextAtLast $STYLE_BODYTEXT

                [string[]]$secondary_ip_addr = $if_instance.IPAddressSetting.SecondaryIPAddr
                $script:table = Add-TableToDoc -Range $range -Rows $secondary_ip_addr.Count -Cols 3 `
                  -Title @('#','IP Address','memo') `
                  -Style @($STYLE_LISTNUMBER,$STYLE_CODE,$Null)

                $i_row = 2
                foreach($ip_addr in $secondary_ip_addr) {
                    Write-Block2Cells $table.Cell($i_row,2) {
                        $ip_addr
                    }
                    $i_row += 1
                }
            }
        }
    }

    ########## == VLAN Group
    Write-Section $STYLE_HEADING2 'VLAN Group' -keyword 'vlanGroup' -skip:($VLANGroupDic.Count -lt 1) {
        $range = Insert-TextAtLast $STYLE_BODYTEXT

        $script:table = Add-TableToDoc -Range $range -Rows $VLANGroupDic.Count -Cols 5 `
          -Title @('#','Name','VSD Group ID','VLAN Range','memo') `
          -Style @($STYLE_LISTNUMBER,$STYLE_CODE,$Null,$Null,$Null)

        $i_row = 2
        foreach($vlan_group_name in $VLANGroupDic.keys | Sort-Object) {
            $vlan_object = $VLANGroupDic[$vlan_group_name]
            Write-Block2Cells $table.Cell($i_row,2) {
                $vlan_group_name
                $vlan_object.VSDGroupId
                if($vlan_object.VLANLow -eq $vlan_object.VLANHigh) {
                    $vlan_object.VLANLow
                } else {
                    "$($vlan_object.VLANLow)-$($vlan_object.VLANHigh)"
                }
            }
            $i_row += 1
        }
    }

    ########## == Routing
    Write-Section $STYLE_HEADING2 'Routing' -keyword 'routing' {

        ########## === Destination
        Write-Section $STYLE_HEADING3 'Destination' {

            foreach($vrouter in $VRouterDic.values | Sort-Object -Property Id) {
                $vr_name = $vrouter.Name

                ########## ==== Destination of $vr_name
                Write-Section $STYLE_HEADING4 "Destination of $vr_name" -skip:($vrouter.DestinationRoute.Count -lt 1) {
                    $range = Insert-TextAtLast $STYLE_BODYTEXT

                    $script:table = Add-TableToDoc -Range $range -Rows $vrouter.DestinationRoute.Count -Cols 7 `
                      -Title @('#','IP/Netmask','gateway','interface','Preference','Metric','memo') `
                      -Style @($STYLE_LISTNUMBER,$STYLE_CODE,$STYLE_CODE,$STYLE_CODE,$Null,$Null,$Null)

                    $i_row = 2
                    foreach($route in $vrouter.DestinationRoute) {
                        Write-Block2Cells $table.Cell($i_row,2) {
                            $route.IPAddr
                            $route.Gateway
                            ConcreteValueOrDefault $route.Interface
                            ConcreteValueOrDefault $route.Preference
                            ConcreteValueOrDefault $route.Metric
                        }
                        $i_row += 1
                    }
                }
            }
        }


        ########## === Source
        Write-Section $STYLE_HEADING3 'Source' {

            foreach($vrouter in $VRouterDic.values | Sort-Object -Property Id) {
                $vr_name = $vrouter.Name

                ########## ==== Source of $vr_name
                Write-Section $STYLE_HEADING4 "Source of $vr_name" -skip:($vrouter.SourceRoute.Count -lt 1) {
                    $range = Insert-TextAtLast $STYLE_BODYTEXT

                    $script:table = Add-TableToDoc -Range $range -Rows $vrouter.SourceRoute.Count -Cols 7 `
                      -Title @('#','IP/Netmask','gateway','interface','Preference','Metric','memo') `
                      -Style @($STYLE_LISTNUMBER,$STYLE_CODE,$STYLE_CODE,$STYLE_CODE,$Null,$Null,$Null)

                    $i_row = 2
                    foreach($route in $vrouter.SourceRoute) {
                        Write-Block2Cells $table.Cell($i_row,2) {
                            $route.IPAddr
                            $route.Gateway
                            ConcreteValueOrDefault $route.Interface
                            ConcreteValueOrDefault $route.Preference
                            ConcreteValueOrDefault $route.Metric
                        }
                        $i_row += 1
                    }
                }
            }
        }

        ########## === SourceInterface
        Write-Section $STYLE_HEADING3 'SourceInterface' {

            foreach($vrouter in $VRouterDic.values | Sort-Object -Property Id) {
                $vr_name = $vrouter.Name

                ########## ==== Destination of $vr_name
                Write-Section $STYLE_HEADING4 "SourceInterface of $vr_name" -skip:($vrouter.SourceInterfaceRoute.Count -lt 1) {
                    $range = Insert-TextAtLast $STYLE_BODYTEXT

                    $script:table = Add-TableToDoc -Range $range -Rows $vrouter.SourceInterfaceRoute.Count -Cols 7 `
                      -Title @('#','IP/Netmask','gateway','interface','Preference','Metric','memo') `
                      -Style @($STYLE_LISTNUMBER,$STYLE_CODE,$STYLE_CODE,$STYLE_CODE,$Null,$Null,$Null)

                    $i_row = 2
                    foreach($route in $vrouter.SourceInterfaceRoute) {
                        Write-Block2Cells $table.Cell($i_row,2) {
                            $route.IPAddr
                            $route.Gateway
                            ConcreteValueOrDefault $route.Interface
                            ConcreteValueOrDefault $route.Preference
                            ConcreteValueOrDefault $route.Metric
                        }
                        $i_row += 1
                    }
                }
            }
        }
    }

    ########## === Virtual Routers
    Write-Section $STYLE_HEADING3 'Virtual Routers' -keyword 'vrouter' {

        foreach($vrouter in $VRouterDic.values | Sort-Object -Property Id) {
            $vr_name = $vrouter.Name

            ########## ==== $vr_name
            $range = Insert-TextAtLast $STYLE_HEADING4 "$vr_name`n"
            $range = Insert-TextAtLast $STYLE_BODYTEXT

            $script:table = Add-TableToDoc -Range $range -Rows 1 -Cols 4 `
              -Title @('#','Attribute','Value','memo') `
              -Style @($STYLE_LISTNUMBER,$Null,$Null,$Null)

            $col_list_style_code = @()
            $script:current_row = $table.Rows.Last

            Write-AVRow 'Virtual Router Name' $vr_name
            $col_list_style_code += $table.Rows.Last.Index

            $vr_id = if($vrouter.Id -eq $Null) {
                'Use system default (not initialized)'
            } else {
                $col_list_style_code += $table.Rows.Last.Index
                $vrouter.Id
            }
            Write-AVRow 'Virtual Router ID' $vr_id
            Write-AVRow 'Management VR'
            Write-AVRow 'Maximum Route Entry' $VRouterDic[$vr_name].MaxRoutes
            Write-AVRow 'Maximum Equal Cost Multipath (ECMP) Routes' $vrouter.MaxEqualCostMultipathRoutes
            Write-AVRow 'Route Lookup Preference (1-255)'
            Write-AVRow '  Destintation Routing'
            Write-AVRow '  Source Based Routing'
            Write-AVRow '  Source Interface Based Routing'
            Write-AVRow 'Shared and accessible by other vsys' $vrouter.Sharable
            Write-AVRow 'Ignore Subnet Conflict for Interfaces in This VRouter' $vrouter.IgnoreSubnetConflict
            Write-AVRow 'Make This VRouter Default-VRouter for the System' $vrouter.DefaultVrouter
            Write-AVRow 'Auto Export Route to Untrust-VR' $vrouter.AutoRouteExport
            Write-AVRow 'Enable Source Based Routing' $vrouter.SourceRouting
            Write-AVRow 'Enable Source Interface Based Routing' $vrouter.SourceInterfaceBasedRouting
            Write-AVRow 'Advertise Routes on Inactive Interfaces' $vrouter.AdvInactInterface
            Write-AVRow 'Sync VR configure to NSRP peer' $vrouter.NSRPConfigSync
            if($VRouterDic[$vr_name].RoutePreference -ne $Null) {
                Write-AVRow 'Route Preference' ''
                Write-AVRow '  Auto Exported' $VRouterDic[$vr_name].RoutePreference.AutoExported
                Write-AVRow '  Connected' $VRouterDic[$vr_name].RoutePreference.Connected
                Write-AVRow '  Imported' $VRouterDic[$vr_name].RoutePreference.Imported
                Write-AVRow '  Static' $VRouterDic[$vr_name].RoutePreference.Static
                Write-AVRow '  EBGP' $VRouterDic[$vr_name].RoutePreference.EBGP
                Write-AVRow '  IBGP' $VRouterDic[$vr_name].RoutePreference.IBGP
                Write-AVRow '  OSPF' $VRouterDic[$vr_name].RoutePreference.OSPF
                Write-AVRow '  OSPF External Type 2' $VRouterDic[$vr_name].RoutePreference.OSPFE2
                Write-AVRow '  RIP'$VRouterDic[$vr_name].RoutePreference.RIP
                Write-AVRow '  NHRP'
            }

            $col_list_style_code | foreach { $script:table.Cell($_,3).Range.Style = $STYLE_CODE }
        }
    }

    ########## == NSRP
    Write-Section $STYLE_HEADING2 'NSRP' -keyword 'nsrp' -skip:($NSRPProfile -eq $Null) {

        ########## === Cluster
        $range = Insert-TextAtLast $STYLE_HEADING3 "Cluster`n"
        $range = Insert-TextAtLast $STYLE_BODYTEXT

        $script:table = Add-TableToDoc -Range $range -Rows 1 -Cols 4 `
          -Title @('#','Attribute','Value','memo') `
          -Style @($STYLE_LISTNUMBER,$Null,$Null,$Null)

        $col_list_style_code = @()
        $script:current_row = $table.Rows.Last

        Write-AVRow 'Cluster ID' $NSRPProfile.ID
        Write-AVRow 'Cluster Name' $NSRPProfile.Name
        $col_list_style_code += $table.Rows.Last.Index
        Write-AVRow 'Number of Gratuitous ARPs to Resend' $NSRPProfile.GARPs
        Write-AVRow 'NSRP Authentication Password' $NSRPProfile.AuthenticationPassword
        Write-AVRow 'NSRP Encryption Password' $NSRPProfile.EncryptionPassword
        Write-AVRow 'VSD' ''
        Write-AVRow '  Master Always exists' $NSRPProfile.VSDMasterAlwaysExist
        Write-AVRow '  The number of heartbeats that occurs before the system exits the initial state' $NSRPProfile.VSDInitialStateHoldDownTime
        Write-AVRow '  Heartbeat Interval' $NSRPProfile.VSDHeartbeatInterval
        Write-AVRow '  Heartbeat-Lost Threshold' $NSRPProfile.VSDLostHeartbeatThreshold
        Write-AVRow 'Track IP' ''
        Write-AVRow '  Threshold' $NSRPProfile.MonitorTrackThreshold

        $col_list_style_code | foreach { $script:table.Cell($_,3).Range.Style = $STYLE_CODE }

        ########## === VSD Group
        Write-Section $STYLE_HEADING3 'VSD Group' -skip:($NSRPProfile.VSDGroup.Count -lt 1) {
            $range = Insert-TextAtLast $STYLE_BODYTEXT

            $script:table = Add-TableToDoc -Range $range -Rows $NSRPProfile.VSDGroup.Count -Cols 6 `
              -Title @('Group ID','Priority','Preempt','Hold-Down Time','Mode','memo') `
              -Style @($Null,$Null,$Null,$Null,$Null,$Null) `
              -DontRenumber

            $i_row = 2
            foreach($id in $NSRPProfile.VSDGroup.keys | Sort-Object) {
                [VSDGroup]$vsd_group = $NSRPProfile.VSDGroup[$id]
                Write-Block2Cells $table.Cell($i_row,1) {
                    $vsd_group.Id
                    $vsd_group.Priority
                    if($vsd_group.Preempt -ne $Null) { EnabledOrDisabled $vsd_group.Preempt } else { ConcreteValueOrDefault $Null}
                    ConcreteValueOrDefault $vsd_group.PreemptHoldDownTime
                    ConcreteValueOrDefault $vsd_group.Mode
                }
                $i_row += 1
            }
        }

        ########## === Monitor
        Write-Section $STYLE_HEADING3 'Monitor' {

            ########## ==== Interface
            Write-Section $STYLE_HEADING4 'Interface' -skip:($NSRPProfile.MonitorInterface.Count -lt 1) {
                $range = Insert-TextAtLast $STYLE_BODYTEXT

                $script:table = Add-TableToDoc -Range $range -Rows $NSRPProfile.MonitorInterface.Count -Cols 4 `
                  -Title @('#','Interface','Weight','memo') `
                  -Style @($STYLE_LISTNUMBER,$Null,$Null,$Null)

                $i_row = 2
                foreach($interface_name in $NSRPProfile.MonitorInterface.keys | Sort-Object) {
                    [MonitorElement]$monitor_interface = $NSRPProfile.MonitorInterface[$interface_name]
                    Write-Block2Cells $table.Cell($i_row,2) {
                        $monitor_interface.Name
                        ConcreteValueOrDefault $monitor_interface.Weight
                    }
                    $i_row++
                }
            }

            ########## ==== Zone
            Write-Section $STYLE_HEADING4 'Zone' -skip:($NSRPProfile.MonitorZone.Count -lt 1) {
                $range = Insert-TextAtLast $STYLE_BODYTEXT

                $script:table = Add-TableToDoc -Range $range -Rows $NSRPProfile.MonitorZone.Count -Cols 4 `
                  -Title @('#','Zone','Weight','memo') `
                  -Style @($STYLE_LISTNUMBER,$Null,$Null,$Null)

                $i_row = 2
                foreach($zone_name in $NSRPProfile.MonitorZone.keys | Sort-Object) {
                    [MonitorElement]$zone_name = $NSRPProfile.MonitorZone[$zone_name]
                    Write-Block2Cells $table.Cell($i_row,2) {
                        $monitor_zone.Name
                        ConcreteValueOrDefault $monitor_zone.Weight
                    }
                    $i_row++
                }
            }

            ########## ==== Track IP
            Write-Section $STYLE_HEADING4 'Track IP' -skip:($NSRPProfile.MonitorTrackIP.Count -lt 1) {
                $range = Insert-TextAtLast $STYLE_BODYTEXT

                $script:table = Add-TableToDoc -Range $range -Rows $NSRPProfile.MonitorTrackIP.Count -Cols 8 `
                  -Title @('#','IP Address','Interval (sec)','Threshold','Interface','Weight','Method','memo') `
                  -Style @($STYLE_LISTNUMBER,$STYLE_CODE,$Null,$Null,$STYLE_CODE,$Null,$Null,$Null)

                $i_row = 2
                foreach($ip_addr in $NSRPProfile.MonitorTrackIP.keys | Sort-Object) {
                    [MonitorElement]$track_ip = $NSRPProfile.MonitorTrackip[$ip_addr]
                    Write-Block2Cells $table.Cell($i_row,2) {
                        $ip_addr
                        ConcreteValueOrDefault $track_ip.Interval
                        ConcreteValueOrDefault $track_ip.Threshold
                        ConcreteValueOrDefault $track_ip.Interface
                        ConcreteValueOrDefault $track_ip.Weight
                        ConcreteValueOrDefault $track_ip.Method
                    }
                    $i_row++
                }
            }
        }

        ########## === Link
        Write-Section $STYLE_HEADING3 'Link' -skip:$($NSRPProfile.SecondaryLink -eq $Null -and $NSRPProfile.HALinkProbe -eq $Null) {
            $range = Insert-TextAtLast $STYLE_BODYTEXT

            $script:table = Add-TableToDoc -Range $range -Rows 1 -Cols 4 `
              -Title @('#','Attribute','Value','memo') `
              -Style @($STYLE_LISTNUMBER,$Null,$Null,$Null)

            $col_list_style_code = @()
            $script:current_row = $table.Rows.Last

            Write-AVRow 'Secondary Link' $NSRPProfile.SecondaryLink
            $col_list_style_code += $table.Rows.Last.Index
            Write-AVRow 'Enable HA Link Probe' $NSRPProfile.HALinkProbe
            if($NSRPProfile.HALinkProbe -is [HALinkProbe]) {
                Write-AVRow 'Interval' $NSRPProfile.HALinkProbe.Interval
                Write-AVRow 'Threshold' $NSRPProfile.HALinkProbe.Threshold
            }

            $col_list_style_code | foreach { $script:table.Cell($_,3).Range.Style = $STYLE_CODE }
        }

        ########## === Synchronization
        Write-Section $STYLE_HEADING3 'Synchronization' {
            $range = Insert-TextAtLast $STYLE_BODYTEXT

            $script:table = Add-TableToDoc -Range $range -Rows 1 -Cols 4 `
              -Title @('#','Attribute','Value','memo') `
              -Style @($STYLE_LISTNUMBER,$Null,$Null,$Null)

            $script:current_row = $table.Rows.Last

            Write-AVRow 'NSRP RTO Synchronization ' ($NSRPProfile.RTOSynchronization -ne $Null)
            if($NSRPProfile.RTOSynchronization -ne $Null) {
                Write-AVRow 'NSRP Session Synchronization' $NSRPProfile.RTOSynchronization.SessionSynchronization
                Write-AVRow 'NSRP Backup Session Timeout Acknowledge' $NSRPProfile.RTOSynchronization.BackupSessionTimeoutAcknowledge
                Write-AVRow 'Non-vsi Session Synchronization' $NSRPProfile.RTOSynchronization.NonVSISessionSynchronization
                if($NSRPProfile.RTOSynchronization.RouteSynchronization -is [RouteSynchronization]) {
                    Write-AVRow 'Route Synchronization' ($(
							     EnabledOrDisabled $NSRPProfile.RTOSynchronization.RouteSynchronization
							     $NSRPProfile.RTOSynchronization.RouteSynchronization.Threshold
							 ) -join "`n")
                }
            }
        }
    }
}

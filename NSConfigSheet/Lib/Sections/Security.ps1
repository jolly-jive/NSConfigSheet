Set-Variable -Scope Script -Option Constant -Name SectionSecurity -Value {
    ########## == Screening
    Write-Section $STYLE_HEADING2 'Screening' -keyword 'screening' {

        ########## === Screen
        Write-Section $STYLE_HEADING3 'Screen' {

            [ScreeningProfile]$screening = $Null
            foreach($screening in $ScreeningDic.values | Sort-Object -Property Zone) {
                $zone_name = $screening.Zone
                ########## === Screening for $zone_name
                $range = Insert-TextAtLast $STYLE_HEADING4 "Screening for $zone_name`n"
                $range = Insert-TextAtLast $STYLE_BODYTEXT

                $script:table = Add-TableToDoc -Range $range -Rows 1 -Cols 4 `
                  -Title @('#','Attribute','Value','memo') `
                  -Style @($STYLE_LISTNUMBER,$Null,$Null,$Null)

                $script:current_row = $table.Rows.Last

                Write-AVRow 'Generate Alarms without Dropping Packet' $screening.AlarmWithoutDrop
                Write-AVRow 'Apply Screen to Tunnel' $screening.OnTunnel
                if($screening.FloodDefense -ne $Null) {
                    Write-AVRow    'Flood Defense' ''
                    Write-SE2AVRow '  ICMP Flood Protection' $screening.FloodDefense.ICMPFlood 'Threshold {0} pps'
                    Write-SE2AVRow '  UDP Flood Protection' $screening.FloodDefense.UDPFlood 'Threshold {0} pps'
                    if($screening.FloodDefense.SYNFlood -ne $Null) {
                        Write-AVRow '  SYN Flood Protection' ($(
								  EnabledOrDisabled $screening.FloodDefense.SYNFlood.Enabled
								  if($screening.FloodDefense.SYNFlood.AttackThreshold -ne $Null) {
								      "Threshold $($screening.FloodDefense.SYNFlood.AttackThreshold) pps"
								  }
								  if($screening.FloodDefense.SYNFlood.AlarmThreshold -ne $Null) {
								      "Alarm Threshold $($screening.FloodDefense.SYNFlood.AlarmThreshold) pps"
								  }
								  if($screening.FloodDefense.SYNFlood.SourceThreshold -ne $Null) {
								      "Source Threshold $($screening.FloodDefense.SYNFlood.SourceThreshold) pps"
								  }
								  if($screening.FloodDefense.SYNFlood.DestinationThreshold -ne $Null) {
								      "Destination Threshold $($screening.FloodDefense.SYNFlood.DestinationThreshold) pps"
								  }
								  if($screening.FloodDefense.SYNFlood.Timeout -ne $Null) {
								      "Timeout Value $($screening.FloodDefense.SYNFlood.Timeout) Seconds"
								  }
								  if($screening.FloodDefense.SYNFlood.QueueSize -ne $Null) {
								      "Queue Size $($screening.FloodDefense.SYNFlood.QueueSize)"
								  }
							      ) -join "`n")
                    }
                }
                if($screening.BlockHTTPComponents -ne $Null) {
                    Write-AVRow 'Block HTTP Components' ''
                    Write-AVRow '  Block Java Component' $screening.BlockHTTPComponents.Java
                    Write-AVRow '  Block ActiveX Component' $screening.BlockHTTPComponents.ActiveX
                    Write-AVRow '  Block ZIP Component' $screening.BlockHTTPComponents.ZIP
                    Write-AVRow '  Block EXE Component' $screening.BlockHTTPComponents.EXE
                }
                if($screening.MSWindowsDefense -ne $Null) {
                    Write-AVRow 'MS-Windows Defense' ''
                    Write-AVRow '  WinNuke Attack Protection' $screening.MSWindowsDefense.WinNuke
                }
                if($screening.ScanSpoofSweepDefense -ne $Null) {
                    Write-AVRow    'Scan/Spoof/Sweep Defense' ''
                    Write-AVRow    '  IP Address Spoof Protection' ($(
									if($screening.ScanSpoofSweepDefense.IPSpoofProtection -ne $Null) {
									    EnabledOrDisabled $screening.ScanSpoofSweepDefense.IPSpoofProtection.Enabled
									    if($screening.ScanSpoofSweepDefense.IPSpoofProtection.DropIfNoReversePathRouteFound) {
										'Drop If No Reverse Path Route Found'
									    }
									    switch($screening.ScanSpoofSweepDefense.IPSpoofProtection.BasedOnZone) {
										$True {'Based On Zone'; break}
										$False {'Based On Interface'; break}
									    }
									}
								    ) -join "`n")
                    Write-SE2AVRow '  IP Address Sweep Protection' $screening.ScanSpoofSweepDefense.IPAddressSweep 'Threshold {0} ms'
                    Write-SE2AVRow '  Port Scan Protection' $screening.ScanSpoofSweepDefense.PortScan 'Threshold {0} ms'
                    Write-SE2AVRow '  TCP Sweep Protection' $screening.ScanSpoofSweepDefense.TCPSweep 'Threshold {0} pps'
                    Write-SE2AVRow '  UDP Sweep Protection' $screening.ScanSpoofSweepDefense.UDPSweep 'Threshold {0} pps'
                }
                if($screening.DenialOfServiceDefense -ne $Null) {
                    Write-AVRow    'Denial of Service Defense' ''
                    Write-AVRow    '  Ping of Death Attack Protection' $screening.DenialOfServiceDefense.PingDeath
                    Write-AVRow    '  Teardrop Attack Protection' $screening.DenialOfServiceDefense.TearDrop

                    Write-AVRow    '  ICMP Fragment Protection' $screening.DenialOfServiceDefense.ICMPFragment
                    Write-SE2AVRow '  ICMP Ping ID Zero Protection' $screening.DenialOfServiceDefense.ICMPPingIDZero
                    Write-AVRow '  Large Size ICMP Packet (Size > 1024) Protection' $screening.DenialOfServiceDefense.LargeSizeICMPPacket
                    Write-AVRow    '  Block Fragment Traffic' $screening.DenialOfServiceDefense.BlockFragmentTraffic

                    Write-AVRow    '  Land Attack Protection' $screening.DenialOfServiceDefense.Land

                    Write-SE2AVRow '  SYN-ACK-ACK Proxy Protection' $screening.DenialOfServiceDefense.SYNACKACKProxy 'Threshold {0} connections '
                    Write-SE2AVRow '  Source IP Based Session Limit' $screening.DenialOfServiceDefense.SourceIPBasedSessionLimit 'Threshold {0} sessions'
                    Write-SE2AVRow '  Destination IP Based Session Limit' $screening.DenialOfServiceDefense.DestinationIPBasedSessionLimit 'Threshold {0} Sessions'

                }
                if($screening.IPOptionAnomalies -ne $Null) {
                    Write-AVRow    'Protocol Anomaly Reports -- IP Option Anomalies' ''
                    Write-AVRow '  Bad IP Option Protection' $screening.IPOptionAnomalies.BadIP
                    Write-AVRow '  IP Timestamp Option Detection' $screening.IPOptionAnomalies.IPTimestamp
                    Write-AVRow '  IP Security Option Detection' $screening.IPOptionAnomalies.IPSecurity
                    Write-AVRow '  IP Stream Option Detection' $screening.IPOptionAnomalies.IPStream
                    Write-AVRow '  IP Record Route Option Detection' $screening.IPOptionAnomalies.IPRecordRoute
                    Write-AVRow '  IP Loose Source Route Option Detection' $screening.IPOptionAnomalies.IPLooseSource
                    Write-AVRow '  IP Strict Source Route Option Detection' $screening.IPOptionAnomalies.IPStrictSourceRoute
                    Write-AVRow '  IP Source Route Option Filter' $screening.IPOptionAnomalies.IPFilterSrc
                }
                if($screening.TCPIPAnomalies -ne $Null) {
                    Write-AVRow 'Protocol Anomaly Reports -- TCP/IP Anomalies' ''
                    Write-AVRow '  SYN Fragment Protection' $screening.TCPIPAnomalies.SYNFragment
                    Write-AVRow '  TCP Packet Without Flag Protection' $screening.TCPIPAnomalies.TCPPacketWithoutFlag
                    Write-AVRow '  SYN and FIN Bits Set Protection' $screening.TCPIPAnomalies.SYNandFINSet
                    Write-AVRow '  FIN Bit With No ACK Bit in Flags Protection' $screening.TCPIPAnomalies.FINwithNoACK
                    Write-AVRow '  Unknown Protocol Protection' $screening.TCPIPAnomalies.UnknownProtocol
                }
            }
        }

        ########## === Malicious URL
        Write-Section $STYLE_HEADING3 'Malicious URL' -keyword 'mul_url' -skip {
        }

        ########## === Flow
        Write-Section $STYLE_HEADING3 'Flow' -keyword 'flow' -skip:($FlowProfile -eq $Null) {
            $range = Insert-TextAtLast $STYLE_BODYTEXT

            $script:table = Add-TableToDoc -Range $range -Rows 1 -Cols 4 `
              -Title @('#','Attribute','Value','memo') `
              -Style @($STYLE_LISTNUMBER,$Null,$Null,$Null)

            $script:current_row = $table.Rows.Last

            if($FlowProfile.AggressiveAging -ne $Null) {
                Write-AVRow    'Aggressive Aging' ''
                Write-AVRow    '  Early Ageout Value' $FlowProfile.AggressiveAging.EarlyAgeout '{0} [10sec]'
                Write-AVRow    '  High Watermark' $FlowProfile.AggressiveAging.HighWatermark '{0} [%]'
                Write-AVRow    '  Low Watermark' $FlowProfile.AggressiveAging.LowWatermark '{0} [%]'
            }

            Write-AVRow    'Allow DNS Reply' $FlowProfile.AllowDNSReply
            Write-SE2AVRow 'All TCP-Maximum Segment Size' $FlowProfile.AllTCPMSS '{0} [byte]'
            Write-AVRow    'Check TCP RST Sequence' $FlowProfile.CheckTCPRSTSequence
            Write-AVRow    'Force IP Reassembly' $FlowProfile.ForceIPReassembly
            Write-SE2AVRow 'Generic Routing Encapsulation In TCP-Maximum Segment Size' $FlowProfile.GREInTCPMSS '{0} [byte]'
            Write-SE2AVRow 'Generic Routing Encapsulation Out TCP-Maximum Segment Size' $FlowProfile.GREOutTCPMSS '{0} [byte]'
            Write-AVRow    'Hub-and-Spoke MIP' $FlowProfile.HubNSpokeMIP
            Write-AVRow    'Initial Timeout' $FlowProfile.InitialTimeout '{0} [min]'
            Write-AVRow    'ICMP Unreachable Message Filter' $FlowProfile.ICMPURMSGFilter
            Write-AVRow    'ICMP Unreachable Message Session Close' $FlowProfile.ICMPURSessionClose
            Write-AVRow    'MAC Cache MGT' $FlowProfile.MACCacheMGT
            Write-AVRow    'MAC Flooding' $FlowProfile.MACFlooding
            Write-AVRow    'Maximum Fragment Packet Size' $FlowProfile.MaxFragPktSize '{0} [byte]'
            Write-AVRow    'Multicast IDP' $FlowProfile.MulticastIDP
            Write-AVRow    'Multicast Install Hardware Session' $FlowProfile.MulticastInstallHWSession
            Write-AVRow    'No TCP Sequence Check' $FlowProfile.NoTCPSeqCheck
            Write-AVRow    'Path MTU' $FlowProfile.PathMTU
            Write-AVRow    'Reverse Route Lookup Behavior for clear text' $(
                switch($FlowProfile.ReverseRouteClearText) {
                    'Prefer' { 'Prefer' }
                    'Always' { 'Always' }
                    'None' { 'Not Peformed' }
                }
            )
            Write-AVRow    'Reverse Route Lookup Behavior for tunnel' $(
                switch($FlowProfile.ReverseRouteTunnel) {
                    'Prefer' { 'Prefer' }
                    'Always' { 'Always' }
                    'None' { 'Not Peformed' }
                }
            )
            Write-AVRow    'Route Cache' $FlowProfile.RouteCache
            Write-AVRow    'Route Change Timeout' $FlowProfile.RouteChangeTimeout '{0} [sec]'

            Write-AVRow    'TCP SYN-proxy SYN-cookie' $FlowProfile.TCPSYNProxySYNCookie

            Write-SE2AVRow 'TCP-Maximum Segment Size' $FlowProfile.TCPMSS '{0} [byte]'
            Write-AVRow    'TCP RST Invalid Session' $FlowProfile.TCPRSTInvalidSession
            Write-AVRow    'TCP SYN Bit Check' $FlowProfile.TCPSYNBitCheck
            Write-AVRow    'TCP SYN Check' $FlowProfile.TCPSYNCheck
            Write-AVRow    'TCP SYN Check In Tunnel' $FlowProfile.TCPSYNCheckInTunnel
            Write-SE2AVRow 'VPN TCP-Maximum Segment Size' $FlowProfile.VPNTCPMSS '{0} [byte]'
        }
    }

    ########## == Web Filtering
    Write-Section $STYLE_HEADING2 'Web Filtering' {

        ########## === Protocol Selection
        Write-Section $STYLE_HEADING3 'Protocol Selection' -keyword 'protocol_selection' -skip {
        }

        ########## === Websense/SurfControl
        Write-Section $STYLE_HEADING3 'Websense/SurfControl' -keyword 'websense' -skip {
        }

        ########## === Categories
        Write-Section $STYLE_HEADING3 'Categories' -keyword 'category' -skip {
        }

        ########## === Profiles
        Write-Section $STYLE_HEADING3 'Profiles' -keyword 'profile' -skip {
        }
    }

    ########## == Deep Inspection
    Write-Section $STYLE_HEADING2 'Deep Inspection' {

        ########## === Attack Signature
        Write-Section $STYLE_HEADING3 'Attack Signature' -keyword 'attack_signature' -skip {
        }

        ########## === Service Limits
        Write-Section $STYLE_HEADING3 'Service Limits' -keyword 'service_limit' -skip {
        }

        ########## === Attacks
        Write-Section $STYLE_HEADING3 'Attacks' -keyword 'attack' -skip {
        }
    }

    ########## == ALG
    Write-Section $STYLE_HEADING2 'ALG' {
    }

}

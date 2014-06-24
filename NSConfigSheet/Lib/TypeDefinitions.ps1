Add-Type -TypeDefinition @"
using System;
using System.Collections;

public class NamedObject {
    public string Name = "";
}

///// CLOCK OBJECTS
public class DSTProfile {}

public class DSTRecurringModeBasedOnWeekday : DSTProfile {
}

public class DSTRecurringModeBasedOnDay : DSTProfile {
}

public class DSTNonRecurringMode : DSTProfile {
}

public enum NTPAuthMode {
    None, Required, Preferred
}

public class NTPProfileElement {
    public string Server = "";
    public string Interface = "";
    public string KeyID = "";
    public string PresharedKey = "";
}

public class NTPProfile {
    public bool? Enabled = null;
    public int? UpdateIntervalMinute = null;
    public int? MaximumTimeAdjustmentSecond = null;
    public NTPAuthMode NTPAuthMode;
    public NTPProfileElement[] List = new NTPProfileElement[3];
}

public class ClockProfile {
    public DSTProfile DST = null;
    public NTPProfile NTP = null;
    public decimal Timezone = 0;
}


///// ADMINISTRATOR OBJECTS
public enum AdminPrivilegeMode {
    ReadOnly, GetExternal, ReadWrite
}

public enum ConfigFileFormat {
    DOS, UNIX
}

public class RemoteServerSetting {
    public bool Primary = false;
    public bool FallbackPermitRoot = true;
    public bool FallbackPermitNonRoot = true;
    public bool Root = false;
}

public enum AdministratorPrivilege {
    All, ReadOnly, Root
}

public enum AdministratorRole {
    Non, Audit, Cryptographic, Security
}

public class AdministratorEntry : NamedObject {
    public AdministratorPrivilege Privilege;
    public bool SSHPasswordAuthEnabled = true;
    public AdministratorRole Role;
    public string EncryptedPassword = "";
}

public class AdminProfile {
    public AdminPrivilegeMode? PrivilegeMode = null;
    public string AdminAuthServer = null;
    public int? AdminAuthTimeout = null;
    public ConfigFileFormat? ConfigFileFormat = null;
    public bool? HttpRecirect = null;
    public RemoteServerSetting RemoteServerSetting = new RemoteServerSetting();
    public Hashtable LocalDB = new Hashtable();
    public string[] PermittedIP = {};
    public int? ConsolePage = null;
}


///// AUTH SERVER OBJECTS
public class AuthServerAccountType {
    public bool? IEEE802dot1X = null;
    public bool? Admin = null;
    public bool? Auth = null;
    public bool? L2TP = null;
    public bool? XAuth = null;

    public string[] GetTypeNames() {
        string[] types = {};
        if(IEEE802dot1X != null && (bool)IEEE802dot1X) {
            Array.Resize(ref types, types.Length + 1);
            types[types.Length - 1] = "802.1X";
        }
        if(Admin != null && (bool)Admin) {
            Array.Resize(ref types, types.Length + 1);
            types[types.Length - 1] = "Admin";
        }
        if(Auth != null && (bool)Auth) {
            Array.Resize(ref types, types.Length + 1);
            types[types.Length - 1] = "Auth";
        }
        if(L2TP != null && (bool)L2TP) {
            Array.Resize(ref types, types.Length + 1);
            types[types.Length - 1] = "L2TP";
        }
        if(XAuth != null && (bool)XAuth) {
            Array.Resize(ref types, types.Length + 1);
            types[types.Length - 1] = "XAuth";
        }
        return types;
    }

    public void SetBool(string type_string, bool value) {
        switch(type_string.ToLower()) {
            case "802.1x": IEEE802dot1X = value; break;
            case "admin": Admin = value; break;
            case "auth": Auth = value; break;
            case "l2tp": L2TP = value; break;
            case "xauth": XAuth = value; break;
            default: throw new ArgumentOutOfRangeException();
        }
    }

    public void Set(string type_string) {
        SetBool(type_string,true);
    }

    public void Unset(string type_string) {
        SetBool(type_string,false);
    }
}

public class AuthServerProfile : NamedObject {
    public AuthServerAccountType AccountType = null;
    public int? Id = null;
    public string Backup1 = "";
    public int? FailOverRevertInterval = null;
    public int? ForcedTimeout = null;
    public string ServerName = "";
    public string SourceInterface = "";
    public int? Timeout = null;
    public string Separator = "";
    public int? Portions = null;
    public string DomainName = "";
    public bool? ZoneVerification = null;

    public AuthServerProfile() {}
    public AuthServerProfile(AuthServerProfile src) {
        Name = src.Name;
        AccountType = src.AccountType;
        Id = src.Id;
        Backup1 = src.Backup1;
        FailOverRevertInterval = src.FailOverRevertInterval;
        ForcedTimeout = src.ForcedTimeout;
        ServerName = src.ServerName;
        SourceInterface = src.SourceInterface;
        Timeout = src.Timeout;
        Separator = src.Separator;
        Portions = src.Portions;
        DomainName = src.DomainName;
        ZoneVerification = src.ZoneVerification;
    }
}

public class AuthServerWithDoubleBackupProfile : AuthServerProfile {
    public string Backup2 = "";

    public AuthServerWithDoubleBackupProfile(): base() {}
    public AuthServerWithDoubleBackupProfile(AuthServerProfile src): base(src) {}
    public AuthServerWithDoubleBackupProfile(AuthServerWithDoubleBackupProfile src): base(src) {
        Backup2 = src.Backup2;
    }
}

public class LDAPAuthServerProfile : AuthServerWithDoubleBackupProfile {
    public string CN = "";
    public string DN = "";
    public int? PortNumber = null;

    public LDAPAuthServerProfile(): base() {}
    public LDAPAuthServerProfile(AuthServerProfile src): base(src) {}
    public LDAPAuthServerProfile(LDAPAuthServerProfile src): base(src) {
        CN = src.CN;
        DN = src.DN;
        PortNumber = src.PortNumber;
    }
}

public class RadiusAuthServerProfile : AuthServerProfile {
    public int? AccountingPortNumber = null;
    public int? AccountSessionIdLength = null;
    public int? CallingStationId = null;
    public bool? CompatibeWithRFC2138 = null;
    public int? PortNumber = null;
    public int? ClientRetries = null;
    public int? ClientTimeout = null;
    public string SharedSecret = "";

    public RadiusAuthServerProfile(): base() {}
    public RadiusAuthServerProfile(AuthServerProfile src): base(src) {}
    public RadiusAuthServerProfile(RadiusAuthServerProfile src): base(src) {
        AccountingPortNumber = src.AccountingPortNumber;
        AccountSessionIdLength = src.AccountSessionIdLength;
        CallingStationId = src.CallingStationId;
        CompatibeWithRFC2138 = src.CompatibeWithRFC2138;
        PortNumber = src.PortNumber;
        ClientRetries = src.ClientRetries;
        ClientTimeout = src.ClientTimeout;
        SharedSecret = src.SharedSecret;
    }
}

public enum SecuIDDuressMode {
    deactivate, activate
}

public enum SecuIDEncryptionMode {
    SDI, DES
}

public class SecuIDAuthServerProfile : AuthServerWithDoubleBackupProfile {
    public int? PortNumber = null;
    public SecuIDDuressMode? DuressMode = null;
    public SecuIDEncryptionMode? EncryptionMode = null;
    public int? ClientRetries = null;
    public int? ClientTimeout = null;

    public SecuIDAuthServerProfile(): base() {}
    public SecuIDAuthServerProfile(AuthServerProfile src): base(src) {}
    public SecuIDAuthServerProfile(SecuIDAuthServerProfile src): base(src) {
        PortNumber = src.PortNumber;
        DuressMode = src.DuressMode;
        EncryptionMode = src.EncryptionMode;
        ClientRetries = src.ClientRetries;
        ClientTimeout = src.ClientTimeout;
    }
}

public class TACACSAuthServerProfile : AuthServerWithDoubleBackupProfile {
    public int? PortNumber = null;
    public string SharedSecret = "";

    public TACACSAuthServerProfile(): base() {}
    public TACACSAuthServerProfile(AuthServerProfile src): base(src) {}
    public TACACSAuthServerProfile(TACACSAuthServerProfile src): base(src) {
        SharedSecret = src.SharedSecret;
        PortNumber = src.PortNumber;
    }
}


///// MANAGEMENT OBJECTS
public class SSHProfile {
    public bool? Enable = null;
    public int? PortNumber = null;
}

public class SSHV1Profile : SSHProfile {
}

public class SSHV2Profile : SSHProfile {
    public bool? SCP = null;
    //public bool? HostIdentity = null;
    //public int? CertDSA = null;
    //public PKADSAProfile PKADSAProfile = null;
}

public class ManagementProfile {
    public SSHProfile SSHProfile = null;
}

///// FIREWALL LOG-SELF OBJECT
public class FirewallLogSelfProfile {
    public bool? Enabled = null;
    public bool? ICMP = null;
    public bool? IKE = null;
    public bool? Multicast = null;
    public bool? SNMP = null;
    public bool? Telnet = null;
    public bool? SSH = null;
    public bool? Web = null;
    public bool? NSM = null;
}

///// SNMP OBJECTS
public enum SNMPVersion {
    v1, v2c, v3, any
}

public enum SNMPTrapVersion {
    v1, v2
}

public class SNMPManagementHost {
    public string IPAddr = "";
    public string SourceInterface = "";
    public SNMPTrapVersion? SNMPTrapVersion = null;
}

public class SNMPCommunity : NamedObject {
    public bool? Write = null;
    public bool? Trap = null;
    public bool? Traffic = null;
    public SNMPVersion? SNMPVersion = null;
    public SNMPManagementHost[] SNMPManagementHost = {};
}

public class MIBFilter : NamedObject {
    public string Type = "";
    public string Action = "";
    public string Entry = "";
}

public class SNMPProfile {
    public string SystemName = "";
    public string SystemContact = "";
    public string Location = "";
    public int? ListenPort = null;
    public int? TrapPort = null;
    public bool? AuthenticationFailTrap = null;
    public Hashtable SNMPCommunity = new Hashtable();
}

///// SYSLOG OBJECT
public enum SyslogFacility {
    auth, authpriv, cron, daemon, kern, lpr, mail, mark, news, syslog, user, uucp,
    local0, local1, local2, local3, local4, local5, local6, local7
}

public class SyslogServer : NamedObject {
    public int? PortNumber = null;
    public SyslogFacility? SecurityFacility = null;
    public SyslogFacility? RegularFacility = null;
    public bool? EventLog = null;
    public bool? TrafficLog = null;
    public bool? TCP = null;
}

public class SyslogProfile {
    public bool? Backup = null;
    public bool? Enabled = null;
    public string SourceInterface = "";
    public Hashtable SyslogServer = new Hashtable();
}

///// VROUTER OBJECTS
public class RouteRecord {
    public string Interface = "";
    public string Description = "";
    public string IPAddr = "";
    public int? Metric = null;
    public bool? Permanent = null;
    public string Gateway = "";
    public int? Preference = null;
    public int? Tag = null;
}

public class SourceInterfaceRouteRecord : RouteRecord {
    public string InInterface = "";
}

public class RoutePreference {
    public int? AutoExported = null;
    public int? Connected = null;
    public int? EBGP = null;
    public int? IBGP = null;
    public int? Imported = null;
    public int? OSPF = null;
    public int? OSPFE2 = null;
    public int? RIP = null;
    public int? Static = null;
}

public class VRouter : NamedObject {
    public string Id = null;
    public bool? AdvInactInterface = false;
    public string AddDefaultRouteVrouter = "";
    public bool? AutoRouteExport = null;
    public bool? DefaultVrouter = null;
    public bool? IgnoreSubnetConflict = null;
    public int? MaxEqualCostMultipathRoutes = null;
    public int? MaxRoutes = null;
    public bool? NSRPConfigSync = null;
    public bool? SourceInterfaceBasedRouting = null;
    public bool? SNMPTrapPrivate = null;
    public bool? SourceRouting = null;
    public bool? Sharable = null;
    public RoutePreference RoutePreference = null;

    public RouteRecord[] DestinationRoute = {};
    public RouteRecord[] SourceRoute = {};
    public SourceInterfaceRouteRecord[] SourceInterfaceRoute = {};
}

///// NSRP OBJECTS
public class VSDGroup {
    public int? Id = null;
    public int? Priority = null;
    public bool? Preempt = null;
    public int? PreemptHoldDownTime = null;
    public string Mode = null;

    public VSDGroup(int id) { Id = id; }
}

public class MonitorElement: NamedObject {
    public int? Weight = null;
}

public class MonitorTrackIP: MonitorElement {
    //public string IPAddr = null;
    public int? Interval = null;
    public int? Threshold = null;
    public string Interface = null;
    public string Method = null;
}

public class HALinkProbe {
    public int? Interval = null;
    public int? Threshold = null;
}

public class RouteSynchronization {
    public int? Threshold = null;
}

public class RTOSynchronization {
    public bool? SessionSynchronization = null;
    public bool? BackupSessionTimeoutAcknowledge = null;
    public bool? NonVSISessionSynchronization = null;
    public RouteSynchronization RouteSynchronization = null;
    public int? Interval = null;
    public int? Threshold = null;
}

public class NSRPProfile: NamedObject {
    public string Version = null;
    public int? Id = null;
    public int? GARPs = null;
    public string AuthenticationPassword = null;
    public string EncryptionPassword = null;

    public bool? VSDMasterAlwaysExist = null;
    public int? VSDInitialStateHoldDownTime = null;
    public int? VSDHeartbeatInterval = null;
    public int? VSDLostHeartbeatThreshold = null;
    public Hashtable VSDGroup = new Hashtable();

    public Hashtable MonitorInterface = new Hashtable();
    public Hashtable MonitorZone = new Hashtable();

    public bool? MonitorTrackIPEnabled = null;
    public int? MonitorTrackThreshold = null;
    public Hashtable MonitorTrackIP = new Hashtable();

    public string SecondaryLink = null;
    public HALinkProbe HALinkProbe = null;

    public RTOSynchronization RTOSynchronization = null;
}

///// SCREENING OBJECTS
public class ScreeningElement {
    public bool Enabled = false;

    public ScreeningElement(bool? e)
    {
        if(e != null) {
            Enabled = (bool)e;
        }
    }
}

public class ScreeningElementWithThreshold : ScreeningElement {
    public int? Threshold = null;

    public ScreeningElementWithThreshold(bool? e, int? t):base(e)
    {
        if(Threshold != null) {
            Threshold = (int)t;
        }
    }
}

public class IPSpoofProtection : ScreeningElement {
    public bool? DropIfNoReversePathRouteFound = null;
    public bool? BasedOnZone = null;

    public IPSpoofProtection(bool? e, bool? d, bool? b):base(e) {
        if(DropIfNoReversePathRouteFound != null) {
            DropIfNoReversePathRouteFound = (bool)d;
        }
        if(BasedOnZone != null) {
            BasedOnZone = (bool)b;
        }
    }
}

public class SYNFlood : ScreeningElement {
    public int? AlarmThreshold = null;
    public int? AttackThreshold = null;
    public int? DestinationThreshold = null;
    public bool? DropUnknownMAC = null;
    public int? QueueSize = null;
    public int? SourceThreshold = null;
    public int? Timeout = null;

    public SYNFlood(bool e):base(e) {}
}

public class FloodDefense {
    public ScreeningElementWithThreshold ICMPFlood = null;
    public ScreeningElementWithThreshold UDPFlood = null;
    public SYNFlood SYNFlood = null;
}

public class BlockHTTPComponents {
    public bool? ActiveX = null;
    public bool? Java = null;
    public bool? ZIP = null;
    public bool? EXE = null;
}

public class MSWindowsDefense {
    public bool? WinNuke = null;
}

public class ScanSpoofSweepDefense {
    public IPSpoofProtection IPSpoofProtection = null;
    public ScreeningElementWithThreshold IPAddressSweep = null;
    public ScreeningElementWithThreshold PortScan = null;
    public ScreeningElementWithThreshold TCPSweep = null;
    public ScreeningElementWithThreshold UDPSweep = null;
}

public class DenialOfServiceDefense {
    public bool? PingDeath = null;
    public bool? TearDrop = null;
    public bool? ICMPFragment = null;

    public bool? ICMPPingIDZero = null;

    public bool? LargeSizeICMPPacket = null;
    public bool? BlockFragmentTraffic = null;
    public bool? Land = null;
    public ScreeningElementWithThreshold SYNACKACKProxy = null;
    public ScreeningElementWithThreshold SourceIPBasedSessionLimit = null;
    public ScreeningElementWithThreshold DestinationIPBasedSessionLimit = null;
}

public class IPOptionAnomalies {
    public bool? BadIP = null;
    public bool? IPTimestamp = null;
    public bool? IPSecurity = null;
    public bool? IPStream = null;
    public bool? IPRecordRoute = null;
    public bool? IPLooseSource = null;
    public bool? IPStrictSourceRoute = null;
    public bool? IPFilterSrc = null;
}

public class TCPIPAnomalies {
    public bool? SYNFragment = null;
    public bool? TCPPacketWithoutFlag = null;
    public bool? SYNandFINSet = null;
    public bool? FINwithNoACK = null;
    public bool? UnknownProtocol = null;
}

public class ScreeningProfile {
    public string Zone;

    public bool? AlarmWithoutDrop = null;
    public bool? OnTunnel = null;
    public FloodDefense FloodDefense = null;
    public BlockHTTPComponents BlockHTTPComponents = null;
    public MSWindowsDefense MSWindowsDefense = null;
    public ScanSpoofSweepDefense ScanSpoofSweepDefense = null;
    public DenialOfServiceDefense DenialOfServiceDefense = null;
    public IPOptionAnomalies IPOptionAnomalies = null;
    public TCPIPAnomalies TCPIPAnomalies = null;

}

///// FLOW OBJECTS
public class AggressiveAging {
    public int? EarlyAgeout = null;
    public int? HighWatermark = null;
    public int? LowWatermark = null;
}

public enum ReverseRouteBehavior {
    Prefer, Always, None
}
public class FlowProfile {
    public AggressiveAging AggressiveAging = null;

    public bool? AllowDNSReply = null;
    public ScreeningElementWithThreshold AllTCPMSS = null;
    public bool? CheckTCPRSTSequence = null;
    public bool? ForceIPReassembly = null;
    public ScreeningElementWithThreshold GREInTCPMSS = null;
    public ScreeningElementWithThreshold GREOutTCPMSS = null;
    public bool? HubNSpokeMIP = null;
    public int? InitialTimeout = null;
    public bool? ICMPURMSGFilter = null;
    public bool? ICMPURSessionClose = null;
    public bool? MACCacheMGT = null;
    public bool? MACFlooding = null;
    public int? MaxFragPktSize = null;
    public bool? MulticastIDP = null;
    public bool? MulticastInstallHWSession = null;
    public bool? NoTCPSeqCheck = null;
    public bool? PathMTU = null;
    public ReverseRouteBehavior? ReverseRouteClearText = null;
    public ReverseRouteBehavior? ReverseRouteTunnel = null;
    public bool? RouteCache = null;
    public int? RouteChangeTimeout = null;
    public bool? TCPSYNProxySYNCookie = null;
    public ScreeningElementWithThreshold TCPMSS = null;
    public bool? TCPRSTInvalidSession = null;
    public bool? TCPSYNBitCheck = null;
    public bool? TCPSYNCheck = null;
    public bool? TCPSYNCheckInTunnel = null;
    public ScreeningElementWithThreshold VPNTCPMSS = null;
}

///// MANAGEMENT SERVICE
public class ManagementService {
    public bool? WebUI = null;
    public bool? Telnet = null;
    public bool? SSH = null;
    public bool? SNMP = null;
    public bool? SSL = null;
    public bool? MTrace = null;

    public bool? Ping = null;
    public bool? PathMTUIPv4 = null;
    public bool? IdentReset = null;

    public string[] GetManagementServiceNames() {
        string[] names = {};
        if(WebUI != null && (bool)WebUI) {
            Array.Resize(ref names, names.Length + 1);
            names[names.Length - 1] = "Web UI";
        }
        if(Telnet != null && (bool)Telnet) {
            Array.Resize(ref names, names.Length + 1);
            names[names.Length - 1] = "Telnet";
        }
        if(SSH != null && (bool)SSH) {
            Array.Resize(ref names, names.Length + 1);
            names[names.Length - 1] = "SSH";
        }
        if(SNMP != null && (bool)SNMP) {
            Array.Resize(ref names, names.Length + 1);
            names[names.Length - 1] = "SNMP";
        }
        if(SSL != null && (bool)SSL) {
            Array.Resize(ref names, names.Length + 1);
            names[names.Length - 1] = "SSL";
        }
        if(MTrace != null && (bool)MTrace) {
            Array.Resize(ref names, names.Length + 1);
            names[names.Length - 1] = "Multicast trace";
        }
        return names;
    }

    public string[] GetOtherServiceNames() {
        string[] names = {};
        if(Ping != null && (bool)Ping) {
            Array.Resize(ref names, names.Length + 1);
            names[names.Length - 1] = "Ping";
        }
        return names;
    }

    public void SetBool(string attribute, bool value) {
        switch(attribute.ToLower()) {
            case "web": WebUI = value; break;
            case "webui": WebUI = value; break;
            case "telnet": Telnet = value; break;
            case "ssh": SSH = value; break;
            case "snmp": SNMP = value; break;
            case "ssl": SSL = value; break;
            case "mtrace": MTrace = value; break;
            case "ping": Ping = value; break;
            case "pathmtuipv4": PathMTUIPv4 = value; break;
            case "identreset": IdentReset = value; break;
            default: throw new ArgumentOutOfRangeException();
        }
    }

    public void Set(string type_string) {
        SetBool(type_string,true);
    }

    public void Unset(string type_string) {
        SetBool(type_string,false);
    }
}

///// ZONE OBJECT
public class ZoneProfile : NamedObject {
    public int? id = null;
    public bool Shared = false;
    public bool TCPRst = false;
    public bool Block = false;
    public string VRouter = "untrust-vr";
    public string VSys = "root";
    public ManagementService ManagementService = null;
}

///// INTERFACE OBJECTS
public class InterfacePhy {
    public string Speed = "auto";
    public string Duplex = "auto";
}

public enum InterfaceMode {
    route, nat, Layer2
}

public class InterfaceIPAddressSetting {
}

public class ObtainFromDHCP: InterfaceIPAddressSetting {
    public bool AutomaticUpdateDHCPServerParameters = false;
}

public class ObtainFromPPPoE: InterfaceIPAddressSetting {
    public string PPPProfile = "";
}

public class SetStaticIP: InterfaceIPAddressSetting {
    public string IPAddr = null;
    public bool? IPManagable = null;
    public string ManageIPAddr = "";
    public bool? Manageable = null;
    public string[] SecondaryIPAddr = {};
}

public class InterfaceWebAuth {
    public bool SSLOnly = false;
    public string IPAddr = "";
}

public class InterfaceTrafficBandwidth {
    public int Egress = 0;
    public int Ingress = 0;
}

public class MappedIP {
    public string MIP;
    public string HostIP;
    public string Netmask;
    public string VRouter;
}

public class VirtualService {
    public int VirtualPort;
    public string MapToService = "";
    public string MapToIPAddr = "";
    public bool? ServerAutoDetection = true;
}

public class VirtualIP {
    public string VirtualIPAddr = "";
    public VirtualService[] VirtualService = {};
}

public class DynamicIPv4 : DynamicIP {
    public string IPAddr1 = "";
    public string IPAddr2 = "";
    public bool? RandomPort = null;
    public int? ScaleSize = null;
}

public class DynamicIPv6 : DynamicIP {
}

public class DynamicIPShift : DynamicIP {
    public string IPAddr = "";
}

public class DynamicIPGroup : DynamicIP {
    public Hashtable DynamicIP = new Hashtable();
}

public class DynamicIP {
    public int DIPID = 0;
}

public class InterfaceProfile : NamedObject {
    public InterfacePhy Phy = new InterfacePhy();
    public string Zone = "";
    public int? Tag = null;
    public InterfaceMode? Mode;
    public InterfaceIPAddressSetting IPAddressSetting;
    public bool? BlockIntraSubnetTraffic = null;
    public ManagementService ManagementService = new ManagementService();
    public int? MTU = null;
    public bool? DNSProxy = null;
    public bool? NTPServer = null;
    public InterfaceWebAuth WebAuth = null;
    public bool? GARP = null;
    public InterfaceTrafficBandwidth Bandwidth = null;
    public bool? VRRP = null;
    public MappedIP[] MappedIP = {};
    public bool? BypassOthersIPSec = null;
    public bool? BypassNonIP = null;
    public bool? BypassNonIPAll = null;
    public Hashtable VirtualIP = new Hashtable();
    public Hashtable DynamicIP = new Hashtable();
}

public class BridgeGroupInterfaceProfile : InterfaceProfile {
    public string[] Port = {};
}

///// POLICY BUILDING BLOCK OBJECT
public class PolicyBuildingBlock : NamedObject {
}


///// SERVICE OBJECTS
public enum IPProtocol {
    ICMP, TCP, UDP
}

public class PortRange {
    public ushort lower;
    public ushort upper;

    public PortRange()
        :this(0,65535)
    {
    }

    public PortRange(ushort l, ushort u)
    {
        lower = l;
        upper = u;
    }
}

public class ServiceRange {
    public IPProtocol Protocol;
    public PortRange SrcPortRange = new PortRange();
    public PortRange DstPortRange = new PortRange();

    public ServiceRange(IPProtocol p, ushort sl, ushort su, ushort dl, ushort du)
    {
        Protocol = p;
        SrcPortRange.lower = sl;
        SrcPortRange.upper = su;
        DstPortRange.lower = dl;
        DstPortRange.upper = du;
    }
}

public class ServiceObject : PolicyBuildingBlock {
    public ServiceRange[] List = {};
}

public class ServiceGroup : PolicyBuildingBlock {
    public Hashtable Member = new Hashtable();
}

///// ADDRESS OBJECTS
public class ZonedObject : PolicyBuildingBlock {
    public string Zone = "";
}

public class AddressObject : ZonedObject {
    public string IPAddr = "";
    public string NetworkMask = "";
    public string FQDN = "";
}

public class AddressGroup : ZonedObject {
    public Hashtable Member = new Hashtable();
}

///// POLICY OBJECTS
public enum PolicyAction {
    deny, permit, reject
}

public class PolicyNat {
    public bool Src = false;
    public int? DIPID = null;
    public string DstIPAddr1 = "";
    public string DstIPAddr2 = "";
    public int? DstPort = null;
}

public class Policy : PolicyBuildingBlock {
    public uint Id;
    public string FromZone;
    public string ToZone;
    public string[] SrcAddrList = {};
    public string[] DstAddrList = {};
    public string[] SvcList = {};
    public PolicyNat Nat = null;
    public PolicyAction Action = PolicyAction.deny;
    public bool Logging = false;
    public bool Count = false;
    public bool Disabled = false;
}

///// VLAN GROUP
public class VLANGroup : NamedObject {
    public int? VSDGroupId;
    public int? VLANLow;
    public int? VLANHigh;
}
"@

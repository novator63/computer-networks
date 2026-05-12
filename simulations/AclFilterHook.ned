package simulations;

import inet.common.SimpleModule;

//
// Minimal IPv4 netfilter-based ACL hook.
// Rules are evaluated in order for the selected hook. The first matching rule
// decides whether the packet is accepted or dropped; non-matching packets are
// accepted by default to avoid disturbing routing protocols such as OSPF.
//
simple AclFilterHook extends SimpleModule
{
    parameters:
        @class(AclFilterHook);
        string networkProtocolModule = default("^.ipv4.ip");
        xml config = default(xml("<acl/>"));
        @display("i=block/filter");

        @signal[aclPacketAccepted](type=inet::Packet);
        @signal[aclPacketDropped](type=inet::Packet);
        @statistic[aclAcceptedPackets](title="ACL accepted packets"; source=aclPacketAccepted; record=count; unit=pk; interpolationmode=none);
        @statistic[aclDroppedPackets](title="ACL dropped packets"; source=aclPacketDropped; record=count; unit=pk; interpolationmode=none);
        @statistic[aclDroppedPacketLengths](title="ACL dropped packet lengths"; source=packetLength(aclPacketDropped); record=sum,histogram,vector; unit=b; interpolationmode=none);
}

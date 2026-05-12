package simulations;

import inet.node.ospfv2.OspfRouter;

//
// OSPF router used for external servers / DMZ.
// It preserves the normal OspfRouter behavior and adds only a small ACL hook
// to the IPv4 layer.
//
module DmzOspfRouter extends OspfRouter
{
    submodules:
        acl: AclFilterHook {
            parameters:
                networkProtocolModule = "^.ipv4.ip";
                config = default(xmldoc("acl_config.xml"));
                @display("p=1125,300");
        }
}

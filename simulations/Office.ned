package simulations;

import inet.node.ethernet.EthernetSwitch;
import inet.node.ethernet.Eth100M;
import inet.node.inet.StandardHost;

network Office
{
    parameters:
        int numClients = default(4);
        @display("i=block/app");
    gates:
        inout ethg[];
    submodules:
        officeSwitch: EthernetSwitch {
            @display("p=100,100");
        }
        client[numClients]: StandardHost {
            @display("p=250,100,row,80");
        }
    connections:
        for i=0..sizeof(ethg)-1 {
            ethg[i] <--> officeSwitch.ethg++;
        }

        for i=0..numClients-1 {
            officeSwitch.ethg++ <--> Eth100M <--> client[i].ethg++;
        }
}
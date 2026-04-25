package simulations;

import inet.node.ethernet.EthernetSwitch;
import inet.node.ethernet.Eth100M;
import inet.node.inet.Router;
import inet.node.inet.StandardHost;

network Branch
{
    parameters:
        int numLocalServers = default(1);
        int office1Clients = default(4);
        int office2Clients = default(4);
        int office3Clients = default(4);
        int office4Clients = default(3);
        @display("i=device/lan-ring");
    gates:
        inout pppg[];
    submodules:
        router: Router {
            @display("p=100,180");
        }

        mainSwitch: EthernetSwitch {
            @display("p=240,180");
        }

        localServer[numLocalServers]: StandardHost {
            @display("p=430,300,row,90;i=device/server");
        }

        office1: Office {
            parameters:
                numClients = parent.office1Clients;
            @display("p=430,60");
        }

        office2: Office {
            parameters:
                numClients = parent.office2Clients;
            @display("p=430,140");
        }

        office3: Office {
            parameters:
                numClients = parent.office3Clients;
            @display("p=430,220");
        }

        office4: Office {
            parameters:
                numClients = parent.office4Clients;
            @display("p=430,390");
        }

    connections:
        for i=0..sizeof(pppg)-1 {
            pppg[i] <--> router.pppg++;
        }

        router.ethg++ <--> Eth100M <--> mainSwitch.ethg++;

        for i=0..numLocalServers-1 {
            mainSwitch.ethg++ <--> Eth100M <--> localServer[i].ethg++;
        }

        office1.ethg++ <--> Eth100M <--> mainSwitch.ethg++;
        office2.ethg++ <--> Eth100M <--> mainSwitch.ethg++;
        office3.ethg++ <--> Eth100M <--> mainSwitch.ethg++;
        office4.ethg++ <--> Eth100M <--> mainSwitch.ethg++;
}
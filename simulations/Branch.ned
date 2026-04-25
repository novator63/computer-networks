package simulations;

import inet.node.ethernet.EthernetSwitch;
import inet.node.ethernet.Eth100M;
import inet.node.inet.Router;
import inet.node.inet.StandardHost;

network Branch
{
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

        localServer: StandardHost {
            @display("p=420,300;i=device/server");
        }

        office1: Office {
            parameters:
                numClients = 4;
            @display("p=430,60");
        }

        office2: Office {
            parameters:
                numClients = 4;
            @display("p=430,140");
        }

        office3: Office {
            parameters:
                numClients = 4;
            @display("p=430,220");
        }

        office4: Office {
            parameters:
                numClients = 3;
            @display("p=430,380");
        }

    connections:
        for i=0..sizeof(pppg)-1 {
            pppg[i] <--> router.pppg++;
        }

        router.ethg++ <--> Eth100M <--> mainSwitch.ethg++;

        mainSwitch.ethg++ <--> Eth100M <--> localServer.ethg++;

        office1.ethg++ <--> Eth100M <--> mainSwitch.ethg++;
        office2.ethg++ <--> Eth100M <--> mainSwitch.ethg++;
        office3.ethg++ <--> Eth100M <--> mainSwitch.ethg++;
        office4.ethg++ <--> Eth100M <--> mainSwitch.ethg++;
}
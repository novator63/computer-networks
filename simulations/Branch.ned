package simulations;

import inet.networklayer.configurator.ipv4.Ipv4NetworkConfigurator;
import inet.node.ethernet.EthernetSwitch;
import inet.node.ethernet.Eth100M;
import inet.node.inet.Router;
import inet.node.inet.StandardHost;

network Branch
{
    parameters:
        int numClients = default(5);   // пока упростим: 5 ПК на филиал
        int numServers = default(1);   // потом будем менять для эксперимента
        @display("i=device/lan-ring");
    gates:
        inout pppg[];
    submodules:
        configurator: Ipv4NetworkConfigurator {
            @display("p=60,50;is=s");
        }
        router: Router {
            @display("p=120,140");
        }
        lanSwitch: EthernetSwitch {
            @display("p=250,140");
        }
        client[numClients]: StandardHost {
            @display("p=380,80,row,90");
        }
        server[numServers]: StandardHost {
            @display("p=380,220,row,90");
        }
    connections:
        for i=0..sizeof(pppg)-1 {
            pppg[i] <--> router.pppg++;
        }

        router.ethg++ <--> Eth100M <--> lanSwitch.ethg++;

        for i=0..numClients-1 {
            lanSwitch.ethg++ <--> Eth100M <--> client[i].ethg++;
        }

        for i=0..numServers-1 {
            lanSwitch.ethg++ <--> Eth100M <--> server[i].ethg++;
        }
}
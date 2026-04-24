package simulations;

import inet.networklayer.configurator.ipv4.Ipv4NetworkConfigurator;
import inet.node.ethernet.Eth100M;
import inet.node.inet.StandardHost;
import inet.node.internetcloud.InternetCloud;

network Global
{
    @display("bgb=1000,500");
    submodules:
        configurator: Ipv4NetworkConfigurator {
            @display("p=80,60;is=s");
        }

        internet: InternetCloud {
            @display("p=500,240;is=vl");
        }

        branch1: Branch {
            parameters:
                numClients = 5;
                numServers = 1;
            @display("p=220,110");
        }

        branch2: Branch {
            parameters:
                numClients = 5;
                numServers = 1;
            @display("p=220,240");
        }

        branch3: Branch {
            parameters:
                numClients = 5;
                numServers = 1;
            @display("p=220,370");
        }

        extServer: StandardHost {
            @display("p=800,240;i=device/server");
        }

    connections:
        branch1.pppg++ <--> { datarate = 15Mbps; delay = 2ms; } <--> internet.pppg++;
        branch2.pppg++ <--> { datarate = 15Mbps; delay = 2ms; } <--> internet.pppg++;
        branch3.pppg++ <--> { datarate = 15Mbps; delay = 2ms; } <--> internet.pppg++;
        extServer.pppg++ <--> { datarate = 15Mbps; delay = 2ms; } <--> internet.pppg++;
}
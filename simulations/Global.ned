package simulations;

import inet.networklayer.configurator.ipv4.Ipv4NetworkConfigurator;
import inet.node.inet.StandardHost;
import inet.node.ospfv2.OspfRouter;
import inet.common.scenario.ScenarioManager;

network Global
{
    parameters:
        @display("bgb=1000,500");

    types:
        channel standardLine extends ned.DatarateChannel {
            datarate = 15Mbps;
            delay = 2ms;
        }

    submodules:
        configurator: Ipv4NetworkConfigurator {
            @display("p=80,60;is=s");
        }

        scenarioManager: ScenarioManager {
            @display("p=80,140;is=s");
        }

        // Проверьте, чтобы имя было именно 'core', а не 'internet'
        core: OspfRouter {
            @display("p=500,240;is=vl");
        }

        // Проверьте имена branch1, branch2, branch3
        branch1: Branch {
            @display("p=220,110");
        }
        branch2: Branch {
            @display("p=220,240");
        }
        branch3: Branch {
            @display("p=220,370");
        }

        extServer: StandardHost {
            @display("p=800,240;i=device/server");
        }

    connections:
        // Используем в точности те же имена, что в submodules
        branch1.pppg++ <--> standardLine <--> core.pppg++;
        branch2.pppg++ <--> standardLine <--> core.pppg++;
        branch3.pppg++ <--> standardLine <--> core.pppg++;

        // Связь ядра с сервером
        core.pppg++ <--> standardLine <--> extServer.pppg++;

        // Резервные каналы между филиалами для отказоустойчивости
        branch1.pppg++ <--> standardLine <--> branch2.pppg++;
        branch2.pppg++ <--> standardLine <--> branch3.pppg++;
        branch3.pppg++ <--> standardLine <--> branch1.pppg++;
}

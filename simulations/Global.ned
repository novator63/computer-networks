package simulations;

import inet.networklayer.configurator.ipv4.Ipv4NetworkConfigurator;
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

        core: OspfRouter {
            @display("p=500,240;is=vl");
        }

        branch1: Branch {
            @display("p=220,110");
        }

        branch2: Branch {
            @display("p=220,240");
        }

        branch3: Branch {
            @display("p=220,370");
        }

        // В OSPF-варианте extServer тоже участвует в OSPF,
        // чтобы он знал обратные маршруты к клиентам.
        extServer: OspfRouter {
            @display("p=800,240;i=device/server");
        }

    connections:
        // Прямые каналы филиалов к ядру
        branch1.pppg++ <--> standardLine <--> core.pppg++;
        branch2.pppg++ <--> standardLine <--> core.pppg++;
        branch3.pppg++ <--> standardLine <--> core.pppg++;

        // Канал ядра к внешнему серверу
        core.pppg++ <--> standardLine <--> extServer.pppg++;

        // Резервное кольцо между филиалами
        branch1.pppg++ <--> standardLine <--> branch2.pppg++;
        branch2.pppg++ <--> standardLine <--> branch3.pppg++;
        branch3.pppg++ <--> standardLine <--> branch1.pppg++;
}
package simulations;

import inet.networklayer.configurator.ipv4.Ipv4NetworkConfigurator;
import inet.node.ospfv2.OspfRouter;
import inet.common.scenario.ScenarioManager;

network Global
{
    parameters:
        @display("bgb=1100,560");

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
            @display("p=540,240;is=vl");
        }

        branch1: Branch {
            @display("p=230,100");
        }

        branch2: Branch {
            @display("p=230,250");
        }

        branch3: Branch {
            @display("p=230,410");
        }

        // Основной внешний сервер
        extServer1: OspfRouter {
            @display("p=850,180;i=device/server");
        }

        // Резервный внешний сервер
        // Подключён не к core, а к branch3, чтобы убрать единую точку отказа по внешнему ресурсу
        extServer2: OspfRouter {
            @display("p=520,470;i=device/server");
        }

    connections:
        // Основные каналы филиалов к ядру
        branch1.pppg++ <--> standardLine <--> core.pppg++;
        branch2.pppg++ <--> standardLine <--> core.pppg++;
        branch3.pppg++ <--> standardLine <--> core.pppg++;

        // Основной внешний сервер через core
        core.pppg++ <--> standardLine <--> extServer1.pppg++;

        // Резервный внешний сервер через branch3
        branch3.pppg++ <--> standardLine <--> extServer2.pppg++;

        // Резервное кольцо между филиалами
        branch1.pppg++ <--> standardLine <--> branch2.pppg++;
        branch2.pppg++ <--> standardLine <--> branch3.pppg++;
        branch3.pppg++ <--> standardLine <--> branch1.pppg++;
}
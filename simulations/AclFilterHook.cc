#include <memory>
#include <vector>

#include "inet/common/ModuleRefByPar.h"
#include "inet/common/SimpleModule.h"
#include "inet/common/packet/Packet.h"
#include "inet/common/packet/PacketFilter.h"
#include "inet/networklayer/contract/INetfilter.h"

using namespace omnetpp;
using namespace inet;

class AclFilterHook : public SimpleModule, public NetfilterBase::HookBase
{
  protected:
    struct Rule {
        INetfilter::IHook::Type hook = LOCALIN;
        bool accept = true;
        PacketFilter filter;
    };

    ModuleRefByPar<INetfilter> networkProtocol;
    std::vector<std::unique_ptr<Rule>> rules;
    simsignal_t aclPacketAcceptedSignal = SIMSIGNAL_NULL;
    simsignal_t aclPacketDroppedSignal = SIMSIGNAL_NULL;

  protected:
    virtual int numInitStages() const override { return NUM_INIT_STAGES; }
    virtual void initialize(int stage) override;
    virtual void handleMessage(cMessage *msg) override;
    virtual void finish() override;

    virtual Result datagramPreRoutingHook(Packet *packet) override { return processPacket(packet, PREROUTING); }
    virtual Result datagramForwardHook(Packet *packet) override { return processPacket(packet, FORWARD); }
    virtual Result datagramPostRoutingHook(Packet *packet) override { return processPacket(packet, POSTROUTING); }
    virtual Result datagramLocalInHook(Packet *packet) override { return processPacket(packet, LOCALIN); }
    virtual Result datagramLocalOutHook(Packet *packet) override { return processPacket(packet, LOCALOUT); }

    void parseConfig();
    Result processPacket(Packet *packet, INetfilter::IHook::Type hook);
    static INetfilter::IHook::Type parseHook(const char *value);
};

Define_Module(AclFilterHook);

void AclFilterHook::initialize(int stage)
{
    SimpleModule::initialize(stage);

    if (stage == INITSTAGE_LOCAL) {
        aclPacketAcceptedSignal = registerSignal("aclPacketAccepted");
        aclPacketDroppedSignal = registerSignal("aclPacketDropped");
        networkProtocol.reference(this, "networkProtocolModule", true);
    }
    else if (stage == INITSTAGE_NETWORK_LAYER) {
        parseConfig();
        if (!rules.empty())
            networkProtocol->registerHook(0, this);
        getDisplayString().setTagArg("t", 0, (std::to_string(rules.size()) + " ACL rules").c_str());
    }
}

void AclFilterHook::handleMessage(cMessage *msg)
{
    throw cRuntimeError("AclFilterHook cannot receive messages");
}

void AclFilterHook::finish()
{
    if (isRegisteredHook(networkProtocol))
        networkProtocol->unregisterHook(this);
}

void AclFilterHook::parseConfig()
{
    auto config = par("config").xmlValue();
    if (config == nullptr)
        return;

    for (auto xmlRule : config->getChildrenByTagName("rule")) {
        auto rule = std::make_unique<Rule>();

        const char *hookAttr = xmlRule->getAttribute("hook");
        rule->hook = parseHook(hookAttr != nullptr ? hookAttr : "localin");

        const char *actionAttr = xmlRule->getAttribute("action");
        if (actionAttr == nullptr || !strcmp(actionAttr, "accept"))
            rule->accept = true;
        else if (!strcmp(actionAttr, "drop"))
            rule->accept = false;
        else
            throw cRuntimeError("Unknown ACL action '%s'", actionAttr);

        const char *packetFilterAttr = xmlRule->getAttribute("packetFilter");
        rule->filter.setExpression(packetFilterAttr != nullptr ? packetFilterAttr : "*");
        rules.push_back(std::move(rule));
    }
}

AclFilterHook::Result AclFilterHook::processPacket(Packet *packet, INetfilter::IHook::Type hook)
{
    Enter_Method("processPacket");

    for (auto& rule : rules) {
        if (rule->hook == hook && rule->filter.matches(packet)) {
            if (rule->accept) {
                emit(aclPacketAcceptedSignal, packet);
                EV_INFO << "ACL ACCEPT " << packet->getName() << endl;
                return ACCEPT;
            }
            else {
                emit(aclPacketDroppedSignal, packet);
                EV_INFO << "ACL DROP " << packet->getName() << endl;
                return DROP;
            }
        }
    }

    return ACCEPT;
}

INetfilter::IHook::Type AclFilterHook::parseHook(const char *value)
{
    if (!strcmp(value, "prerouting"))
        return PREROUTING;
    if (!strcmp(value, "localin"))
        return LOCALIN;
    if (!strcmp(value, "forward"))
        return FORWARD;
    if (!strcmp(value, "postrouting"))
        return POSTROUTING;
    if (!strcmp(value, "localout"))
        return LOCALOUT;
    throw cRuntimeError("Unknown ACL hook '%s'", value);
}

/**
 * @file uwmulti-traffic-rl.cc
 * @author Michele Scapinello
 * @version 1.0.0
*/

#include "uwmulti-traffic-rl.h"
#include "uwmulti-cmn-hdr.h"
#include <mphy_pktheader.h>
#include "mac.h"
#include "ip.h"
#include <mmac-clmsg.h>
#include <uwip-clmsg.h>
#include <algorithm>
#include <clmsg-discovery.h>
#include <uwip-module.h>
#include <clmsg-stats.h>

void 
UwMultiTrafficRl::recv(Packet* p){
    hdr_uwip *uwip = HDR_UWIP(p);
    hdr_cmn *ch = HDR_CMN(p);

    if (ch->direction() == hdr_cmn::DOWN) {
        // Update source node statistics
        q_learning.updateSourceNodeStats();
        // Update destination node statistics
        q_learning.updateDestinationNodeStats();
        // Compute the best phy medium to transmit the packet
        int best_phy_medium = getBestLowerLayer();
        // Send packet to next layer
        sendDown(p);
    }
    else if (ch->direction() == hdr_cmn::UP){
        // compute reward
        // update weigths
        // sendup
    }
}

int 
UwMultiTrafficRl::recvSyncClMsg(ClMessage* msg) {
    // Process packet received
    // Define packets for discovery and for update of statistics
    if (msg->type() == CLMSG_DISCOVERY){}
    else if (msg->type() == CLMSG_STATS) {}
    return UwMultiTrafficControl::recvSyncClMsg(msg);
}


int 
UwMultiTrafficRl::command(int argc, const char*const* argv){

}

void 
UwMultiTrafficRl::discoverLowerLayers() {
    ClMsgDiscovery msg;
    msg.addSenderData((const PlugIn*) this, getLayer(), getId(), getStackId(), name() , getTag());
    sendSyncClMsg(&msg);
    
    // DiscoveryStorage phy_layer_storage = msg.findTag("PHY");
    DiscoveryStorage phys = msg.copyStorage();
    
    if (debug_ >= 2) {
        msg.printReplyData();
    }

    // Scorri attraverso i layer trovati e aggiungi l'id al vettore
    // for each layer
    //      phy_IDs.add(phy_layer[i].id)
    
    for (DBIt it=phys.begin(); it!=phys.end(); it++){
        int id = it->first;
        int layerId = it->second.getId();

        // unwanted layer (current one probably)
        if (id == 0) continue;

        this->phy_IDs.push_back(layerId);
        this->macTclIdLayerId[id] = layerId;

        if (debug_) {
            std::cout << "UwMultiTrafficRl::initialize::tclId(" << id << ")"
            << "::layerId(" << layerId << ")" << std::endl;
        }   
    }
}

void 
UwMultiTrafficRl::initialize(){
    RlAgent* q_learning = new RlAgent();
    // Discover lower layers in init method or via a dedicated function
    // discoverLowerLayers();

}
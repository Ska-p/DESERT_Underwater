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

void UwMultiTrafficRl::recv(Packet* p){
    hdr_uwip *uwip = HDR_UWIP(p);
    hdr_cmn *ch = HDR_CMN(p);

    if (ch->direction() == hdr_cmn::DOWN) {
        // update tx node stats
        // update rx node stats
        // get best lower layer
        // sendDown
    }
    else {
        // compute reward
        // update weigths
        // sendup
    }
}

void::UwMultiTrafficRl::discoverLowerLayers() {
    ClMsgDiscovery msg;
    msg.addSenderData((const PlugIn*) this, getLayer(), getId(), getStackId(), name() , getTag());
    sendSyncClMsg(&msg);
    DiscoveryStorage phy_layer_storage = msg.findTag("PHY");
}

int::UwMultiTrafficRl::recvSyncClMsg(ClMessage* msg) {
    // Process packet received
    // Define packets for discovery and for update of statistics
    
}

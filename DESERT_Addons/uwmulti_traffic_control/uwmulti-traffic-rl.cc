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

/**
 * Class that represents the binding with the tcl configuration script
 */
static class UwMultiTrafficRlClass : public TclClass
{
public:
  /**
   * Constructor of the class
   */
  UwMultiTrafficRlClass() : TclClass("Module/UW/MULTITRAFFIC_RL") {}
  /**
   * Creates the TCL object needed for the tcl language interpretation
   * @return Pointer to an TclObject
   */
  virtual TclObject* create(int, const char*const*)
  {
    return (new UwMultiTrafficRl);
  }
} class_rl_multitraffic;

UwMultiTrafficRl::UwMultiTrafficRl()
  :
  UwMultiTrafficControl(),
  debug_(0)
{
	bind("debug_", &debug_);
}

/*
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
*/

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
  Tcl& tcl = Tcl::instance();

  if(strcasecmp(argv[1], "initialize") == 0) {
    this->initialize();
    return TCL_OK;
  }
  return UwMultiTrafficControl::command(argc, argv);     
}

void 
UwMultiTrafficRl::discoverLowerLayers() {
    ClMsgDiscovery msg;
    msg.addSenderData((const PlugIn*) this, getLayer(), getId(), getStackId(), name() , getTag());
    sendSyncClMsg(&msg);
    
    DiscoveryStorage phy_layer_storage = msg.findTag("PHY1");
    DiscoveryData phy_layer = (*phy_layer_storage.begin()).second;
	  int phy_id = phy_layer.getId();

    std::cout << "UwMultiTrafficRl::initialize::Id(" << phy_layer.getId() << ")" << std::endl
                                                << "TclName: " << phy_layer.getTclName() << " " << std::endl
                                                << "Module Layer Id: " << phy_layer.getLayer() << ")" << std::endl;
    
    phy_layer_storage = msg.findTag("PHY2");
    phy_layer = (*phy_layer_storage.begin()).second;
    std::cout << "UwMultiTrafficRl::initialize::Id(" << phy_layer.getId() << ")" << std::endl
                                                << "TclName: " << phy_layer.getTclName() << " " << std::endl
                                                << "Module Layer Id: " << phy_layer.getLayer() << ")" << std::endl;
    /*
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
    */
}

void 
UwMultiTrafficRl::initialize(){
    // RlAgent* q_learning = new RlAgent();
    // Discover lower layers in init method or via a dedicated function
    discoverLowerLayers();

}
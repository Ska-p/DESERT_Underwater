//
// Copyright (c) 2017 Regents of the SIGNET lab, University of Padova.
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
// 1. Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above copyright
//    notice, this list of conditions and the following disclaimer in the
//    documentation and/or other materials provided with the distribution.
// 3. Neither the name of the University of Padova (SIGNET lab) nor the
//    names of its contributors may be used to endorse or promote products
//    derived from this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
// PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
// CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
// EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
// OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
// WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
// OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
// ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

/**
 * @file   uwoptical.cpp
 * @author Federico Favaro, Federico Guerra, Filippo Campagnaro
 * @version 1.0.0
 *
 * \brief Implementation of UwOptical class.
 *
 */

#include "uwopticalstats-phy.h"
#include "uwoptical-mpropagation.h"
#include "uwphy-clmsg.h"
#include "uwstats-utilities.h"
#include <float.h>


UwOpticalStats::UwOpticalStats()
	:
	Stats(),
	last_rx_power(0),
	last_noise_power(0),
	instant_noise_power(0),
	last_interf_power(0),
	has_error(false)
{
	type_id = (int)StatsEnum::STATS_PHY_LAYER;
}

UwOpticalStats::UwOpticalStats(int mod_id, int stck_id)
	:
	Stats(mod_id,stck_id),
	last_rx_power(0),
	last_noise_power(0),
	instant_noise_power(0),
	last_interf_power(0),
	has_error(false)
{
	type_id = (int)StatsEnum::STATS_PHY_LAYER;
}

void 
UwOpticalStats::updateStats(int mod_id, int stck_id, double rx_pwr, double noise_pwr, double interf_pwr, 
		bool error, ChannelStates channel_state)
{
	module_id = mod_id;
	stack_id = stck_id;
	last_rx_power = rx_pwr;
	last_noise_power = noise_pwr;
	instant_noise_power = noise_pwr;
	last_interf_power = interf_pwr;
	has_error = error;
	channel_state = channel_state;
}

Stats*
UwOpticalStats::clone() const
{
	return new UwOpticalStats( *this );
}


static class UwOpticalStatsPhyClass : public TclClass
{
public:
	UwOpticalStatsPhyClass()
		: TclClass("Module/UW/OPTICAL/STATSPHY")
	{
	}
	TclObject *
	create(int, const char *const *)
	{
		return (new UwOpticalStatsPhy());
	}
} class_module_opticalstats;

UwOpticalStatsPhy::UwOpticalStatsPhy()
	: threshold(0)
{

	UwOpticalPhy();
	bind("Threshold_", &threshold);
	stats_ptr = new UwOpticalStats();
}

int
UwOpticalStatsPhy::command(int argc, const char *const *argv)
{
	if (argc == 1) {
		if (strcasecmp(argv[1], "setThreshold") == 0) {
			int threshold_ = std::stoi(argv[1]);
			setThreshold(threshold_);
			return TCL_OK;
		}
	}
	return UwOpticalPhy::command(argc, argv);
}

// sendSync -> 

void 
UwOpticalStatsPhy::updateInstantaneousStats()
{
	Packet *temp = Packet::alloc();
	hdr_MPhy *ph = HDR_MPHY(temp);
	ph->dstSpectralMask = getRxSpectralMask(temp);
	ph->dstPosition = getPosition();
	ph->dstAntenna = getRxAntenna(temp);
	assert(ph->dstSpectralMask);
	assert(ph->dstPosition);

	ph->srcSpectralMask = getTxSpectralMask(temp);
	ph->srcAntenna = getTxAntenna(temp);
	ph->srcPosition = getPosition();
	assert(ph->srcSpectralMask);

	(dynamic_cast<UwOpticalStats*>(stats_ptr))->instant_noise_power = getNoisePower(temp);
	Packet::free(temp);
}

void
UwOpticalStatsPhy::startRx(Packet *p)
{
	hdr_MPhy *ph = HDR_MPHY(p);
	if ((PktRx == 0) && (txPending == false)) {
		double snr_dB = getSNRdB(p);
		if (snr_dB > MPhy_Bpsk::getAcquisitionThreshold()) {
			if (ph->modulationType == MPhy_Bpsk::modid) {
				PktRx = p;
				Phy2MacStartRx(p);
				return;
			} else {
				if (debug_)
					cout << "UwOpticalPhy::Drop Packet::Wrong modulation"
						 << endl;
			}
		} else {
			if (debug_)
				cout << "UwOpticalPhy::Drop Packet::Below Threshold : snrdb = "
					 << snr_dB
					 << ", threshold = " << MPhy_Bpsk::getAcquisitionThreshold()
					 << endl;
		}
	} else {
		if (debug_)
			cout << "UwOpticalPhy::Drop Packet::Synced onto another packet "
					"PktRx = "
				 << PktRx << ", pending = " << txPending << endl;
	}
}

// Test con TCl per corsslayer communication
int UwOpticalStatsPhy::recvSyncClMsg(ClMessage* m)
{
	if (m->type() == CLMSG_STATS)
	{
		updateInstantaneousStats();
		(dynamic_cast<ClMsgStats*>(m))->setStats(stats_ptr);
		return 0;
	}
	return MPhy_Bpsk::recvSyncClMsg(m);
}

void
UwOpticalStatsPhy::endRx(Packet *p)
{
	hdr_cmn *ch = HDR_CMN(p);
	hdr_MPhy *ph = HDR_MPHY(p);
	// NEW PART
	static int mac_addr = -1;
	ClMsgPhy2MacAddr msg;
	sendSyncClMsg(&msg);
	mac_addr = msg.getAddr();
	// ------
	if (MPhy_Bpsk::PktRx != 0) {
		if (MPhy_Bpsk::PktRx == p) {
			if (interference_) {
				double interference_power = interference_->getInterferencePower(p);
				if (interference_power == 0) {
					// no interference
					ch->error() = 0;
				} else {
					// at least one interferent packet
					ch->error() = 1;
					if (debug_)
						cout << "UwOpticalPhy::endRx interference power = "
							 << interference_power << endl;
				}
				// NEW PART
				// soglia maggiore di un altra soglia settata da tcl
				} else if (UwOpticalStatsPhy::getSNRdB(p) > UwOpticalStatsPhy::getAcquisitionThresholdDb()){
					ch->error() = 0;
				} 
				else {
					// no interference model set
					ch->error() = 1;
				}
			// ----- NEW PART
			dynamic_cast<UwOpticalStats *>(stats_ptr)->updateStats(getId(),
				getStackId(), ph->Pr, ph->Pn, interference_->getInterferencePower(p), ch->error());
			ClMsgTriggerStats m = ClMsgTriggerStats();
			sendSyncClMsg(&m);
			// --------------
			sendUp(p);
			PktRx = 0;
		} else {
			dropPacket(p);
		}
	} else {
		dropPacket(p);
	}
}
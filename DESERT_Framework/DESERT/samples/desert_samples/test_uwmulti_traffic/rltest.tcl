######################################
# Flags to enable or disable options #
######################################
set opt(trace_files)        0
set opt(bash_parameters)    0

#####################
# Library Loading   #
#####################
load libMiracle.so
load libMiracleBasicMovement.so
load libmphy.so
load libmmac.so
load libUwmStd.so
load libuwcsmaaloha.so
load libuwmmac_clmsgs.so
load libuwaloha.so
load libuwip.so
load libuwstaticrouting.so
load libuwmll.so
load libuwudp.so
load libuwcbr.so
load libuwtdma.so
load libuwsmposition.so
load libuwinterference.so
load libUwmStd.so
load libUwmStdPhyBpskTracer.so
load libuwphy_clmsgs.so
load libuwstats_utilities.so
load libuwphysical.so
load libuwposbasedrt.so
load libuwflooding.so
load libuwinterference.so
load libuwphy_clmsgs.so
load libuwstats_utilities.so
load libuwphysical.so
load libuwoptical_propagation.so
load libuwem_channel.so
load libuwoptical_channel.so
load libuwoptical_phy.so
load libuwmulti_traffic_control.so

#############################
# NS-Miracle initialization #
#############################
# You always need the following two lines to use the NS-Miracle simulator
set ns [new Simulator]
$ns use-Miracle

##################
# Tcl variables  #
##################
set opt(nn)             2.0; # Number of Nodes
set opt(starttime)      1
set opt(stoptime)       100000
set opt(txduration)     [expr $opt(stoptime) - $opt(starttime)]

set opt(maxinterval_)   20.0
set opt(freq)           25000.0
set opt(bw)             5000.0
set opt(bitrate)        4800.0
set opt(ack_mode)       "setNoAckMode"

set opt(txpower)        135.0
set opt(rngstream)	        1
set opt(pktsize)            125
set opt(cbr_period)         60

global defaultRNG
for {set k 0} {$k < $opt(rngstream)} {incr k} {
	$defaultRNG next-substream
}

#########################
# Command line options  #
#########################
set channel [new Module/UnderwaterChannel]
set propagation [new MPropagation/Underwater]
set data_mask [new MSpectralMask/Rect]
$data_mask setFreq       $opt(freq)
$data_mask setBandwidth  $opt(bw)

#########################
# Module Configuration  #
#########################
#UW/CBR
Module/UW/CBR set packetSize_          $opt(pktsize)
Module/UW/CBR set period_              $opt(cbr_period)
Module/UW/CBR set PoissonTraffic_      1

# BPSK              
Module/MPhy/BPSK  set BitRate_          $opt(bitrate)
Module/MPhy/BPSK  set TxPower_          $opt(txpower)

# RL
Module/UW/MULTITRAFFIC_RL set debug_    1

################################
# Procedure(s) to create nodes #
################################
proc createNode { id } {

    global channel propagation data_mask ns cbr position node udp portnum ipr ipif rl
    global phy posdb opt rvposx mll mac db_manager
    global node_coordinates
    
    set node($id) [$ns create-M_Node $opt(tracefile) $opt(cltracefile)] 

    set cbr($id)  [new Module/UW/CBR] 
    set udp($id)  [new Module/UW/UDP]
    set rl($id)   [new Module/UW/MULTITRAFFIC_RL]
    set ipr($id)  [new Module/UW/StaticRouting]
    set ipif($id) [new Module/UW/IP]
    set mll($id)  [new Module/UW/MLL]
    set mac($id)  [new Module/UW/CSMA_ALOHA] 
    set phy($id)  [new Module/MPhy/BPSK]
}
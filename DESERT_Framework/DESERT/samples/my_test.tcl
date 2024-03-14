# Stack of the nodes
#                   MASTER                                         SLAVE
#   +------------------------------------------+   +------------------------------------------+
#   |  10. UW/CBR                              |   |  10. UW/CBR                              |
#   +------------------------------------------+   +------------------------------------------+
#   |  9. UW/UDP                               |   |  9. UW/UDP                               |
#   +------------------------------------------+   +------------------------------------------+
#   |  8. UW/STATICROUTING                     |   |  8. UW/STATICROUTING                     |
#   +------------------------------------------+   +------------------------------------------+
#   |  7. UW/IP                                |   |  7. UW/IP                                |
#   +------------------------------------------+   +------------------------------------------+
#   |  6. UW/MLL                               |   |  6. UW/MLL                               |
#   +------------------------------------------+   +------------------------------------------+
#   |  5. UW/CSMA_ALOHA                        |   |  5. UW/CSMA_ALOHA                        |
#   +------------------------------------------+   +------------------------------------------+
#   |  4. UW/MULTI_STACK_CONTROLLER_PHY_MASTER |   |  4. UW/MULTI_STACK_CONTROLLER_PHY_SLAVE  |
#   +--------------+-------------+-------------+   +--------------+-------------+-------------+
#   | 3.UW/PHYSICAL|2.UW/PHYSICAL|1.UW/PHYSICAL|   | 3.UW/PHYSICAL|2.UW/PHYSICAL|1.UW/PHYSICAL|
#   +--------------+-------------+-------------+   +--------------+-------------+-------------+
#           |             |              |                  |             |            |
#   +-----------------------------------------------------------------------------------------+
#   |                                     UnderwaterChannel                                   |
#   +-----------------------------------------------------------------------------------------+

######################################
# Flags to enable or disable options #
######################################
set opt(verbose) 			1
set opt(trace_files)		0
set opt(bash_parameters) 	0

#####################
# Library Loading   #
#####################
load libMiracle.so
load libMiracleBasicMovement.so
load libmphy.so
load libmmac.so
load libUwmStd.so
load libuwip.so
load libuwstaticrouting.so
load libuwmll.so
load libuwudp.so
load libuwcbr.so
load libuwcsmaaloha.so
load libuwaloha.so
load libuwinterference.so
load libuwphy_clmsgs.so
load libuwstats_utilities.so
load libuwphysical.so
load libuwmulti_stack_controller.so
load libuwhermesphy.so
load libuwoptical_propagation.so
load libuwem_channel.so
load libuwoptical_channel.so
load libuwoptical_phy.so
load libuwsmposition.so
load libuwmmac_clmsgs.so

load libuwopticalstatsphy.so

#############################
# NS-Miracle initialization #
#############################
# You always need the following two lines to use the NS-Miracle simulator
set ns [new Simulator]
$ns use-Miracle

##################
# Tcl variables  #
##################

set opt(nn)                 3.0 ;# Number of Nodes
set opt(pktsize)            125  ;# Pkt sike in byte
set opt(starttime)          1
set opt(stoptime)           100
set opt(txduration)         [expr $opt(stoptime) - $opt(starttime)] ;# Duration of the simulation
set opt(txpower)            180.0  ;#Power transmitted in dB re uPa

set opt(time_interval)      12

set opt(maxinterval_)       20.0
set opt(ack_mode)           "setNoAckMode"
set opt(rngstream)	        1

######################
# Hermes/ Acoustic   #
######################

set opt(hermes_freq)        375000.0 ; # Frequency used in Hz
set opt(hermes_bw)          76000.0 ; # Bandwidth used in Hz
set opt(hermes_bitrate)     87768.0 ; #150000; #bitrate in bps
set opt(hermes_txpower)     180.0  ; # Power transmitted in dB re uPa (32 W)

######################
# Optical            #
######################

set opt(optical_freq)              10000000
set opt(optical_bw)                200000
set opt(optical_bitrate)           2000000
set opt(optical_txpower)           100
set opt(opt_acq_db)                10
set opt(temperatura)               293.15 ; # in Kelvin
set opt(txArea)                    0.000010
set opt(rxArea)                    0.0000011 ; # receveing area, it has to be the same for optical physical and propagation
set opt(c)                         0.15 ; # seawater attenation coefficient
set opt(theta)                     1
set opt(id)                        [expr 1.0e-9]
set opt(il)                        [expr 1.0e-6]
set opt(shuntRes)                  [expr 1.49e9]
set opt(sensitivity)               0.26
set opt(LUTpath)                   "../dbs/optical_noise/LUT.txt"
set opt(atten_LUT)                 "../../dbs/optical_attenuation/lut_532nm/lut_532nm_CTD001.csv"
set opt(cbr_period)                0.1
set opt(pktsize)	               125
set opt(rngstream)	               1

###################################################
# Multi stack controller signaling configuaration #
###################################################

set opt(master_signaling_active)   1
set opt(signaling_size)            5

##################################
# Switching thresholds           #
##################################

#set opt(evo2hermes_thresh) 3.846e12;# 119.5 m 48/78
#set opt(evo2hermes_thresh) 9.893e13;# 119.5m HS
#set opt(hermes2evo_thresh) 6.379e13; #120.5m
#set opt(hermes2opt_thresh) 1.81e09
#set opt(opt2hermes_thresh) 1.038e12

if {$opt(bash_parameters)} {
	if {$argc != 3} {
		puts "The script requires three inputs:"
		puts "- the first for the seed"
		puts "- the second one is for the Poisson CBR period"
		puts "- the third one is the cbr packet size (byte);"
		puts "example: ns test_uw_csma_aloha_fully_connected.tcl 1 60 125"
		puts "If you want to leave the default values, please set to 0"
		puts "the value opt(bash_parameters) in the tcl script"
		puts "Please try again."
		return
	} else {
		set opt(rngstream)    [lindex $argv 0]
		set opt(cbr_period)   [lindex $argv 1]
		set opt(pktsize)      [lindex $argv 2]
	}
}

#random generator
global defaultRNG
for {set k 0} {$k < $opt(rngstream)} {incr k} {
	$defaultRNG next-substream
}

MPropagation/Underwater set practicalSpreading_ 1.5
MPropagation/Underwater set debug_              0
MPropagation/Underwater set windspeed_          1

set hermes_data_mask [new MSpectralMask/Rect]
$hermes_data_mask setFreq       $opt(hermes_freq)
$hermes_data_mask setBandwidth  $opt(hermes_bw)

set optical_data_mask [new MSpectralMask/Rect]
$optical_data_mask setFreq       $opt(optical_freq)
$optical_data_mask setBandwidth  $opt(optical_bw)

#########################
# Module Configuration  #
#########################

Module/UW/CBR set packetSize_          $opt(pktsize)
Module/UW/CBR set period_              $opt(cbr_period)
Module/UW/CBR set PoissonTraffic_      1
Module/UW/CBR set debug_               0

Module/UW/HERMES/PHY  set BitRate_                    $opt(hermes_bitrate)
Module/UW/HERMES/PHY  set AcquisitionThreshold_dB_    15.0 
Module/UW/HERMES/PHY  set RxSnrPenalty_dB_            0
Module/UW/HERMES/PHY  set TxSPLMargin_dB_             0
Module/UW/HERMES/PHY  set MaxTxSPL_dB_                $opt(hermes_txpower)
Module/UW/HERMES/PHY  set MinTxSPL_dB_                0
Module/UW/HERMES/PHY  set MaxTxRange_                 200
Module/UW/HERMES/PHY  set PER_target_                 0    
Module/UW/HERMES/PHY  set CentralFreqOptimization_    0
Module/UW/HERMES/PHY  set BandwidthOptimization_      0
Module/UW/HERMES/PHY  set SPLOptimization_            0
Module/UW/HERMES/PHY  set debug_                      0

Module/UW/OPTICAL/STATSPHY   set TxPower_                    $opt(optical_txpower)
Module/UW/OPTICAL/STATSPHY   set BitRate_                    $opt(optical_bitrate)
Module/UW/OPTICAL/STATSPHY   set AcquisitionThreshold_dB_    $opt(opt_acq_db)
Module/UW/OPTICAL/STATSPHY   set Id_                         $opt(id)
Module/UW/OPTICAL/STATSPHY   set Il_                         $opt(il)
Module/UW/OPTICAL/STATSPHY   set R_                          $opt(shuntRes)
Module/UW/OPTICAL/STATSPHY   set S_                          $opt(sensitivity)
Module/UW/OPTICAL/STATSPHY   set T_                          $opt(temperatura)
Module/UW/OPTICAL/STATSPHY   set Ar_                         $opt(rxArea)
Module/UW/OPTICAL/STATSPHY   set debug_                      0

Module/UW/OPTICAL/Propagation set Ar_       $opt(rxArea)
Module/UW/OPTICAL/Propagation set At_       $opt(txArea)
Module/UW/OPTICAL/Propagation set c_        $opt(c)
Module/UW/OPTICAL/Propagation set theta_    $opt(theta)
Module/UW/OPTICAL/Propagation set debug_    0

set optical_propagation [new Module/UW/OPTICAL/Propagation]
$optical_propagation setOmnidirectional

set optical_channel [new Module/UW/Optical/Channel]

Module/UW/MULTI_STACK_CONTROLLER_PHY_SLAVE set debug_      0
Module/UW/MULTI_STACK_CONTROLLER_PHY_MASTER set debug_     0
# Module/UW/MULTI_STACK_CONTROLLER_PHY_MASTER set alpha_     0.5
Module/UW/MULTI_STACK_CONTROLLER_PHY_MASTER set signaling_active_ $opt(master_signaling_active)
Module/UW/MULTI_STACK_CONTROLLER_PHY_MASTER set signaling_period_ 100
Module/UW/MULTI_STACK_CONTROLLER_PHY_SLAVE set min_delay_  [expr 1.79e-4]
################################
# Procedure(s) to create nodes #
################################

set channel [new Module/UnderwaterChannel]
set propagation [new MPropagation/Underwater]

if {$opt(trace_files)} {
	set opt(tracefilename) "./test_uwcsmaaloha.tr"
	set opt(tracefile) [open $opt(tracefilename) w]
	set opt(cltracefilename) "./test_uwcsmaaloha.cltr"
	set opt(cltracefile) [open $opt(tracefilename) w]
} else {
	set opt(tracefilename) "/dev/null"
	set opt(tracefile) [open $opt(tracefilename) w]
	set opt(cltracefilename) "/dev/null"
	set opt(cltracefile) [open $opt(cltracefilename) w]
}

# CSMA_ALOHA parameters
Module/UW/CSMA_ALOHA set listen_time_          [expr 1.0e-12]
Module/UW/CSMA_ALOHA set wait_costant_         [expr 1.0e-12]
Module/UW/CSMA_ALOHA set debug_ 0

proc createNode {id} {

    global channel propagation data_mask data_mask2  ns cbr position node udp portnum ipr ipif channel_estimator
    global phy posdb opt rvposx rvposy rvposz mhrouting mll mac woss_utilities woss_creator db_manager
    global node_coordinates optical_channel optical_propagation hermes_data_mask optical_data_mask

    set node($id) [$ns create-M_Node $opt(tracefile) $opt(cltracefile)]
    for {set cnt 0} {$cnt < $opt(nn)} {incr cnt} {
    if {$id == 0} {
        Module/UW/CBR set period_              [expr $opt(cbr_period)*10]
    } else {
        Module/UW/CBR set period_              $opt(cbr_period)
    }

    set cbr($id,$cnt)  [new Module/UW/CBR]
	}
    
    set udp($id)  [new Module/UW/UDP]
    set ipr($id)  [new Module/UW/StaticRouting]
    set ipif($id) [new Module/UW/IP]
    set mll($id)  [new Module/UW/MLL]
    set mac($id)  [new Module/UW/CSMA_ALOHA]

    if {$id > 0} {
        set ctr($id)  [new Module/UW/MULTI_STACK_CONTROLLER_PHY_SLAVE]
    } else {
        set ctr($id)  [new Module/UW/MULTI_STACK_CONTROLLER_PHY_MASTER]
    }
    set hermes_phy($id)  [new Module/UW/HERMES/PHY]  
    set optical_phy($id)  [new Module/UW/OPTICAL/STATSPHY]  
	
	
  for {set cnt 0} {$cnt < $opt(nn)} {incr cnt} {  
		$node($id) addModule 9 $cbr($id,$cnt)   1  "CBR"
	}
    $node($id) addModule 8 $udp($id)   1  "UDP"
    $node($id) addModule 7 $ipr($id)   1  "IPR"
    $node($id) addModule 6 $ipif($id)  1  "IPF"
    $node($id) addModule 5 $mll($id)   1  "MLL"
    $node($id) addModule 4 $mac($id)   1  "MAC"
    $node($id) addModule 3 $ctr($id)   1  "CTR"
    $node($id) addModule 2 $hermes_phy($id)   1  "PHY1"
    $node($id) addModule 1 $optical_phy($id)   1  "PHY2"

    for {set cnt 0} {$cnt < $opt(nn)} {incr cnt} {
            $node($id) setConnection $cbr($id,$cnt)   $udp($id)   0
            set portnum($id,$cnt) [$udp($id) assignPort $cbr($id,$cnt) ]
        }
    $node($id) setConnection $udp($id)   $ipr($id)   0
    $node($id) setConnection $ipr($id)   $ipif($id)  1
    $node($id) setConnection $ipif($id)  $mll($id)   1
    $node($id) setConnection $mll($id)   $mac($id)   1
    $node($id) setConnection $mac($id)   $ctr($id)   1
    $node($id) setConnection $ctr($id)   $hermes_phy($id)  1
    $node($id) setConnection $ctr($id)   $optical_phy($id)  1
    $node($id) addToChannel  $channel    $hermes_phy($id)   1
    $node($id) addToChannel  $optical_channel    $optical_phy($id)   1

    if {$id > 254} {
        puts "hostnum > 254!!! exiting"
        exit
    }

    #Set the IP address of the node
    set ip_value [expr $id + 1]
    $ipif($id) addr $ip_value
    
    set position($id) [new "Position/BM"]
    $node($id) addPosition $position($id)

    set posdb($id) [new "PlugIn/PositionDB"]
    $node($id) addPlugin $posdb($id) 20 "PDB"
    $posdb($id) addpos [$ipif($id) addr] $position($id)

    #Setup positions
    $position($id) setX_ [expr $id*15]
    $position($id) setY_ [expr $id*0]
    $position($id) setZ_ -100
    
    set interf_data2($id) [new "Module/UW/INTERFERENCE"]
    $interf_data2($id) set maxinterval_ $opt(maxinterval_)
    $interf_data2($id) set debug_       0

    set optical_interf_data($id) [new "MInterference/MIV"]
    $optical_interf_data($id) set maxinterval_ $opt(maxinterval_)
    $optical_interf_data($id) set debug_       0
        
    #Propagation modelpr
    $hermes_phy($id) setPropagation $propagation
    $optical_phy($id) setPropagation $optical_propagation

    $hermes_phy($id) setSpectralMask $hermes_data_mask
    $hermes_phy($id) setInterference $interf_data2($id)
    $hermes_phy($id) setInterferenceModel "MEANPOWER"
    $hermes_phy($id) setLUTFileName "../dbs/hermes/default.csv"
    $hermes_phy($id) initLUT

    $optical_phy($id) setSpectralMask $optical_data_mask
    $optical_phy($id) setInterference $optical_interf_data($id)
    $optical_phy($id) setLUTFileName "$opt(LUTpath)"
    $optical_phy($id) setLUTSeparator " "
    $optical_phy($id) useLUT

    $ctr($id) setManualLowerlId [$optical_phy($id) Id_]
    #$ctr($id) setAutomaticSwitch

    $mac($id) $opt(ack_mode)
    $mac($id) initialize  
    
    if {$id == 0} {
        $ctr($id) addLayer [$hermes_phy($id) Id_] 1
        $ctr($id) addLayer [$optical_phy($id) Id_] 2

        #$ctr($id) addThreshold [$phy($id) Id_] [$hermes_phy($id) Id_] $opt(evo2hermes_thresh)
        #$ctr($id) addThreshold [$hermes_phy($id) Id_] [$phy($id) Id_] $opt(hermes2evo_thresh)
        #$ctr($id) addThreshold [$hermes_phy($id) Id_] [$optical_phy($id) Id_] $opt(hermes2opt_thresh)
        #$ctr($id) addThreshold [$optical_phy($id) Id_] [$hermes_phy($id) Id_] $opt(opt2hermes_thresh)
        #$ctr($id) setManualSwitch
        }
}

#################
# Node Creation #
#################
# Create here all the nodes you want to network together
for {set id 0} {$id < $opt(nn)} {incr id}  {
    createNode $id
}



################################
# Inter-node module connection #
################################
proc connectNodes {id1 des1} {
    global ipif ipr portnum cbr cbr_sink ipif_sink portnum_sink ipr_sink opt

    $cbr($id1,$des1) set destAddr_ [$ipif($des1) addr]
    $cbr($id1,$des1) set destPort_ $portnum($des1,$id1)

    $cbr($des1,$id1) set destAddr_ [$ipif($id1) addr]
    $cbr($des1,$id1) set destPort_ $portnum($id1,$des1)

}

##################
# Setup flows    #
##################
for {set id1 0} {$id1 < $opt(nn)} {incr id1}  {
	for {set id2 0} {$id2 < $opt(nn)} {incr id2}  {
		connectNodes $id1 $id2
	}
}

##################
# ARP tables     #
##################
for {set id1 0} {$id1 < $opt(nn)} {incr id1}  {
    for {set id2 0} {$id2 < $opt(nn)} {incr id2}  {
      $mll($id1) addentry [$ipif($id2) addr] [$mac($id2) addr]
	}
}



##################
# Routing tables #
##################
for {set id1 0} {$id1 < $opt(nn)} {incr id1}  {
	for {set id2 0} {$id2 < $opt(nn)} {incr id2}  {
			$ipr($id1) addRoute [$ipif($id2) addr] [$ipif($id2) addr]
	}
}

#####################
# Start/Stop Timers #
#####################
# Set here the timers to start and/or stop modules (optional)
# e.g.,
for {set id1 1} {$id1 < $opt(nn)} {incr id1}  {
	$ns at $opt(starttime)    "$cbr($id1,0) start"
	$ns at $opt(stoptime)     "$cbr($id1,0) stop"
  $ns at $opt(starttime)    "$cbr(0,$id1) start"
  $ns at $opt(stoptime)     "$cbr(0,$id1) stop"
}

###################
# Final Procedure #
###################
# Define here the procedure to call at the end of the simulation
proc finish {} {
    global ns opt outfile
    global mac propagation cbr_sink mac_sink phy_data phy_data_sink channel db_manager propagation
    global node_coordinates
    global ipr_sink ipr ipif udp cbr phy phy_data_sink
    global node_stats tmp_node_stats sink_stats tmp_sink_stats
    if ($opt(verbose)) {
        puts "---------------------------------------------------------------------"
        puts "Simulation summary"
        puts "number of nodes  : $opt(nn)"
        puts "packet size      : $opt(pktsize) byte"
        puts "cbr period       : $opt(cbr_period) s"
        puts "number of nodes  : $opt(nn)"
        puts "simulation length: $opt(txduration) s"
        puts "tx power         : $opt(txpower) dB"
        puts "tx optical frequency     : $opt(optical_freq) Hz"
        puts "tx bandwidth     : $opt(optical_bw) Hz"
        puts "bitrate          : $opt(optical_bitrate) bps"
        puts "---------------------------------------------------------------------"
    }
    set sum_cbr_throughput     0
    set sum_per                0
    set sum_cbr_sent_pkts      0.0
    set sum_cbr_rcv_pkts       0.0

    for {set i 0} {$i < $opt(nn)} {incr i}  {
  		for {set j 0} {$j < $opt(nn)} {incr j} {
  			set cbr_throughput           [$cbr($i,$j) getthr]
  			if {$i != $j} {
  				set cbr_sent_pkts        [$cbr($i,$j) getsentpkts]
  				set cbr_rcv_pkts         [$cbr($i,$j) getrecvpkts]
          set sum_cbr_throughput [expr $sum_cbr_throughput + $cbr_throughput]
          set sum_cbr_sent_pkts [expr $sum_cbr_sent_pkts + $cbr_sent_pkts]
          set sum_cbr_rcv_pkts  [expr $sum_cbr_rcv_pkts + $cbr_rcv_pkts]
  			}
  			if ($opt(verbose)) {
  				puts "cbr($i,$j) throughput                    : $cbr_throughput"
  			}
  		}
    }

    set ipheadersize        [$ipif(1) getipheadersize]
    set udpheadersize       [$udp(1) getudpheadersize]
    set cbrheadersize       [$cbr(1,0) getcbrheadersize]

    if ($opt(verbose)) {
        puts "Mean Throughput          : [expr ($sum_cbr_throughput/(($opt(nn))*($opt(nn)-1)))]"
        puts "Sent Packets             : $sum_cbr_sent_pkts"
        puts "Received Packets         : $sum_cbr_rcv_pkts"
        puts "Packet Delivery Ratio    : [expr $sum_cbr_rcv_pkts / $sum_cbr_sent_pkts * 100]"
        puts "IP Pkt Header Size       : $ipheadersize"
        puts "UDP Header Size          : $udpheadersize"
        puts "CBR Header Size          : $cbrheadersize"
        puts "done!"
    }

    $ns flush-trace
    close $opt(tracefile)
}


###################
# start simulation
###################
if ($opt(verbose)) {
    puts "\nStarting Simulation\n"
    puts "----------------------------------------------"
}


$ns at [expr $opt(stoptime) + 250.0]  "finish; $ns halt"

$ns run

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
load libuwhermesphy.so
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
set opt(nn)             2.0; # Number of Nodes
set opt(starttime)      1
set opt(stoptime)       100000
set opt(txduration)     [expr $opt(stoptime) - $opt(starttime)]
set opt(txpower)            180.0  ;#Power transmitted in dB re uPa

set opt(time_interval)      12

set opt(maxinterval_)   20.0
set opt(freq)           25000.0
set opt(bw)             5000.0
set opt(bitrate)        4800.0
set opt(ack_mode)       "setNoAckMode"

set opt(rngstream)	        1
set opt(pktsize)            125
set opt(cbr_period)         60

global defaultRNG
for {set k 0} {$k < $opt(rngstream)} {incr k} {
	$defaultRNG next-substream
}

if {$opt(trace_files)} {
    set opt(tracefilename) "./test_uwcbr.tr"
    set opt(tracefile) [open $opt(tracefilename) w]
    set opt(cltracefilename) "./test_uwcbr.cltr"
    set opt(cltracefile) [open $opt(tracefilename) w]
} else {
    set opt(tracefilename) "/dev/null"
    set opt(tracefile) [open $opt(tracefilename) w]
    set opt(cltracefilename) "/dev/null"
    set opt(cltracefile) [open $opt(cltracefilename) w]
}

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
set opt(threshold)                 10

#########################
# Command line options  #
#########################
set channel [new Module/UnderwaterChannel]
set propagation [new MPropagation/Underwater]
set data_mask [new MSpectralMask/Rect]
$data_mask setFreq       $opt(freq)
$data_mask setBandwidth  $opt(bw)

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
#########################
# Module Configuration  #
#########################

# CBR 

Module/UW/CBR set packetSize_          $opt(pktsize)
Module/UW/CBR set period_              $opt(cbr_period)
Module/UW/CBR set PoissonTraffic_      1
Module/UW/CBR set debug_               0

# ACOUSTIC

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

# OPTICAL

Module/UW/OPTICAL/STATSPHY   set TxPower_                    $opt(optical_txpower)
Module/UW/OPTICAL/STATSPHY   set BitRate_                    $opt(optical_bitrate)
Module/UW/OPTICAL/STATSPHY   set AcquisitionThreshold_dB_    $opt(opt_acq_db)
Module/UW/OPTICAL/STATSPHY   set Id_                         $opt(id)
Module/UW/OPTICAL/STATSPHY   set Il_                         $opt(il)
Module/UW/OPTICAL/STATSPHY   set R_                          $opt(shuntRes)
Module/UW/OPTICAL/STATSPHY   set S_                          $opt(sensitivity)
Module/UW/OPTICAL/STATSPHY   set T_                          $opt(temperatura)
Module/UW/OPTICAL/STATSPHY   set Ar_                         $opt(rxArea)
Module/UW/OPTICAL/STATSPHY   set Threshold                   $opt(threshold)
Module/UW/OPTICAL/STATSPHY   set debug_                      0

Module/UW/OPTICAL/Propagation set Ar_       $opt(rxArea)
Module/UW/OPTICAL/Propagation set At_       $opt(txArea)
Module/UW/OPTICAL/Propagation set c_        $opt(c)
Module/UW/OPTICAL/Propagation set theta_    $opt(theta)
Module/UW/OPTICAL/Propagation set debug_    0

set optical_propagation [new Module/UW/OPTICAL/Propagation]
$optical_propagation setOmnidirectional

set optical_channel [new Module/UW/Optical/Channel]

# RL
Module/UW/MULTITRAFFIC_RL set debug_    1

################################
# Procedure(s) to create nodes #
################################
proc createNode { id } {

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
    set rl($id)   [new Module/UW/MULTITRAFFIC_RL]
    set ipr($id)  [new Module/UW/StaticRouting]
    set ipif($id) [new Module/UW/IP]
    set mll($id)  [new Module/UW/MLL]
    set mac($id)  [new Module/UW/CSMA_ALOHA]
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
    $node($id) addModule 3 $rl($id)    0  "RL"  
    $node($id) addModule 2 $hermes_phy($id)   1  "PHY1"
    $node($id) addModule 1 $optical_phy($id)   1  "PHY2"

    for {set cnt 0} {$cnt < $opt(nn)} {incr cnt} {
            $node($id) setConnection $cbr($id,$cnt)   $udp($id)   0
            set portnum($id,$cnt) [$udp($id) assignPort $cbr($id,$cnt) ]
        }
    $node($id) setConnection $udp($id)   $ipr($id)    1
    $node($id) setConnection $ipr($id)   $ipif($id)  1
    $node($id) setConnection $ipif($id)  $mll($id)   1
    $node($id) setConnection $mll($id)   $mac($id)   1
    $node($id) setConnection $mac($id)   $rl($id)   1
    $node($id) setConnection $rl($id)   $hermes_phy($id)  1
    $node($id) setConnection $rl($id)   $optical_phy($id)  1
    $node($id) addToChannel  $channel    $hermes_phy($id)   1
    $node($id) addToChannel  $optical_channel    $optical_phy($id)   1

    puts "Connections done"

    if {$id > 254} {
        puts "hostnum > 254!!! exiting"
        exit
    }

    #Set the IP address of the node
    set ip_value [expr $id + 1]
    $ipif($id) addr $ip_value
    
    puts "ip set"

    set position($id) [new "Position/BM"]
    $node($id) addPosition $position($id)

    set posdb($id) [new "PlugIn/PositionDB"]
    $node($id) addPlugin $posdb($id) 20 "PDB"
    $posdb($id) addpos [$ipif($id) addr] $position($id)

    #Setup positions
    $position($id) setX_ [expr $id*15]
    $position($id) setY_ [expr $id*0]
    $position($id) setZ_ -100
    
    puts "position set"

    set interf_data2($id) [new "Module/UW/INTERFERENCE"]
    $interf_data2($id) set maxinterval_ $opt(maxinterval_)
    $interf_data2($id) set debug_       0

    set optical_interf_data($id) [new "MInterference/MIV"]
    $optical_interf_data($id) set maxinterval_ $opt(maxinterval_)
    $optical_interf_data($id) set debug_       0
        
    puts "interf_data"

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

    puts "spectral mask"

    $mac($id) $opt(ack_mode)
    $mac($id) initialize
    $rl($id)  initialize
        
    puts "node created"
}

#################
# Node Creation #
#################
for {set id 0} {$id < $opt(nn)} {incr id}  {
    createNode $id
}


####################
# Finish procedure #
####################
proc finish {} {
    $ns flush-trace
    close $opt(tracefile)
}

###################
# start simulation
###################
$ns at [expr $opt(stoptime) + 250.0]  "finish; $ns halt" 
$ns run
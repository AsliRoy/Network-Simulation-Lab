#CREATING A WIRELESS NETWORK TOPOLOGY WITH STATIC NODES
# ======================================================================
set val(chan)          Channel/WirelessChannel ;            # channel type
set val(prop)          Propagation/TwoRayGround ;           # radio-propagation model
set val(netif)         Phy/WirelessPhy ;		    # network interface type
set val(mac)           Mac/802_11 ;		    	    # MAC type
set val(ifq)           Queue/DropTail/PriQueue ;	    # interface queue type
set val(ll)            LL ;				    # link layer type
set val(ant)           Antenna/OmniAntenna ;		    # antenna model
set val(ifqlen)        50 ;				    # max packet in ifq
set val(nn)            5 ;				    # number of mobilenodes
set val(rp) 	       WFRP ;				    # routing protocol
set val(x)             100 ; 			   	    # X dimension of topography 
set val(y)             100 ;				    # Y dimension of topography   


set ns_ [new Simulator]

# Creating trace file and nam file
#$ns_ use-newtrace
set tracefd [open a1_AODV.tr w]
$ns_ trace-all $tracefd

set namtrace [open a1_AODV.nam w]
$ns_ namtrace-all-wireless $namtrace $val(x) $val(y)


# set up topography object
set topo [new Topography]
$topo load_flatgrid $val(x) $val(y)

set god_ [create-god $val(nn)]

# configure node
$ns_ node-config -adhocRouting $val(rp) \
-llType $val(ll) \
-macType $val(mac) \
-ifqType $val(ifq) \
-ifqLen $val(ifqlen) \
-antType $val(ant) \
-propType $val(prop) \
-phyType $val(netif) \
-channelType $val(chan) \
-topoInstance $topo \
-agentTrace ON \
-routerTrace ON \
-macTrace OFF \
-movementTrace ON



#Creating node objects
for {set i 0} {$i < $val(nn) } {incr i} {
set node_($i) [$ns_ node]

}


$node_(0) set X_ 30.0
$node_(0) set Y_ 10.0
$node_(1) set X_ 40.0
$node_(1) set Y_ 20.0
$node_(2) set X_ 50.0
$node_(2) set Y_ 30.0
$node_(3) set X_ 60.0
$node_(3) set Y_ 40.0
$node_(4) set X_ 70.0
$node_(4) set Y_ 50.0


for {set i 0} {$i < $val(nn)} { incr i } {
$ns_ initial_node_pos $node_($i) 30
}


for {set i 1} {$i < $val(nn)} { incr i } {
set udp_($i) [new Agent/UDP]
$ns_ attach-agent $node_($i) $udp_($i)
set null [new Agent/Null]
$ns_ attach-agent $node_(0) $null
$ns_ connect $udp_($i) $null


set cbr_($i) [new Application/Traffic/CBR]
$cbr_($i) attach-agent $udp_($i)
$cbr_($i) set type_ CBR
$cbr_($i) set packet_size_ 512
$cbr_($i) set rate_ 0.1mb
$cbr_($i) set random_ false
}





#File Transfer protocol at application layer
for {set i 1} {$i < $val(nn)} { incr i } {
$ns_ at 3.0 "$cbr_($i) start"
}
#
# Tell nodes when the simulation ends
#
for {set i 0} {$i < $val(nn) } {incr i} {
$ns_ at 150.0 "$node_($i) reset";
}
$ns_ at 150.0 "stop"
$ns_ at 150.01 "puts \"NS EXITING...\" ; $ns_ halt"
proc stop {} {
global ns_ tracefd
$ns_ flush-trace
exec awk -f e2ed.awk a1_AODV.tr
close $tracefd
}
puts "Starting Simulation..."
$ns_ run

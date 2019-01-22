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
set val(nn)            10 ;				    # number of mobilenodes
set val(rp) 	       DSR;				    # routing protocol
set val(x)             500 ; 			   	    # X dimension of topography 
set val(y)             500 ;				    # Y dimension of topography   


set ns_ [new Simulator]

# Creating trace file and nam file
set tracefd [open a1_DSR.tr w]
$ns_ trace-all $tracefd

set namtrace [open a1_DSR.nam w]
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


$node_(0) set X_ 25.0
$node_(0) set Y_ 50.0
$node_(1) set X_ 10.0
$node_(1) set Y_ 50.0
$node_(2) set X_ 250.0
$node_(2) set Y_ 150.0
$node_(3) set X_ 210.0
$node_(3) set Y_ 150.0
$node_(4) set X_ 25.0
$node_(4) set Y_ 250.0
$node_(5) set X_ 50.0
$node_(5) set Y_ 250.0
$node_(6) set X_ 25.0
$node_(6) set Y_ 150.0
$node_(7) set X_ 100.0
$node_(7) set Y_ 50.0
$node_(8) set X_ 250.0
$node_(8) set Y_ 100.0
$node_(9) set X_ 80.0
$node_(9) set Y_ 170.0

# Setup traffic flow between nodes
# TCP connections between node_(0) and node_(1)
set tcp [new Agent/TCP]
$tcp set class_ 2
set sink [new Agent/TCPSink]
$ns_ attach-agent $node_(0) $tcp
$ns_ attach-agent $node_(1) $sink
$ns_ connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
# Setup traffic flow between nodes
# TCP connections between node_(2) and node_(3)
set tcp1 [new Agent/TCP]
$tcp1 set class_ 2
set sink1 [new Agent/TCPSink]
$ns_ attach-agent $node_(2) $tcp1
$ns_ attach-agent $node_(3) $sink1
$ns_ connect $tcp1 $sink1
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1
# Setup traffic flow between nodes
# TCP connections between node_(4) and node_(5)
set tcp2 [new Agent/TCP]
$tcp2 set class_ 2
set sink2 [new Agent/TCPSink]
$ns_ attach-agent $node_(4) $tcp2
$ns_ attach-agent $node_(5) $sink2
$ns_ connect $tcp2 $sink2
set ftp2 [new Application/FTP]
$ftp2 attach-agent $tcp2
#File Transfer protocol at application layer
$ns_ at 3.0 "$ftp start"
$ns_ at 3.0 "$ftp1 start"
$ns_ at 3.0 "$ftp2 start"
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
exec awk -f throughput_v4.awk project2.tr
close $tracefd
}
puts "Starting Simulation..."
$ns_ run

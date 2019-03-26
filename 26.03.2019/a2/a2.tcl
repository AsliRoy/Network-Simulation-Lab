# Define options
set val(chan) Channel/WirelessChannel ;# channel type
set val(prop) Propagation/TwoRayGround ;# radio-propagation model
set val(netif) Phy/WirelessPhy ;# network interface type
set val(mac) Mac/802_11 ;# MAC type
set val(ifq) Queue/DropTail/PriQueue ;# interface queue type
set val(ll) LL ;# link layer type
set val(ant) Antenna/OmniAntenna ;# antenna model
set val(ifqlen) 30 ;# max packet in ifq
set val(nn) 37 ;# number of mobilenodes
set val(rp) DSR ;# routing protocol
set val(x) 500 ;# X dimension of topography
set val(y) 500 ;# Y dimension of topography
set val(stop) 50 ;# time of simulation end
set val(energymodel) EnergyModel ;# Energy set up

# Setting the simulator objects
set ns_ [new Simulator]

# Create the nam and trace file
set tracefd [open a2.tr w]
$ns_ trace-all $tracefd
set namtrace [open a2.nam w]
$ns_ namtrace-all-wireless $namtrace  $val(x) $val(y)

$ns_ use-newtrace
# Create topography
set topo [new Topography]
$topo load_flatgrid $val(x) $val(y)
create-god $val(nn)
set chan_1_ [new $val(chan)]


# #  Defining node configuration                       
$ns_ node-config  -adhocRouting $val(rp) \
                  -llType $val(ll) \
                  -macType $val(mac) \
                  -ifqType $val(ifq) \
                  -ifqLen $val(ifqlen) \
                  -antType $val(ant) \
                  -propType $val(prop) \
                  -phyType $val(netif) \
                  -topoInstance $topo \
                  -energyModel $val(energymodel) \
                  -initialEnergy 3 \
                  -rxPower 0.03528 \
                  -txPower 0.03132 \
                  -idlePower 0.000712 \
                  -sleepPower 0.000000144 \
                  -agentTrace ON \
                  -routerTrace ON \
                  -macTrace OFF \
                  -movementTrace ON \
                  -channel $chan_1_

# Creating the wireless nodes
for {set i 0} {$i < $val(nn)} {incr i} {
    set n($i) [$ns_ node]
}


# Setting the initial positions of nodes
for {set i 0} {$i < 6} {incr i} {
    $n($i) set X_ [expr 125 + 50 *  $i ]
    $n($i) set Y_ [expr 250 ]
    $n($i) set Z_ 0.0
}

for {set i 6} {$i < 11} {incr i} {
    $n($i) set X_ [expr 150 + 50 * ($i-6)]
    $n($i) set Y_ [expr 250 + 30]
    $n($i) set Z_ 0.0
}

for {set i 11} {$i < 16} {incr i} {
    $n($i) set X_ [expr 150 + 50 *  ($i-11) ]
    $n($i) set Y_ [expr 250 - 30 ]
    $n($i) set Z_ 0.0
}

for {set i 16} {$i < 20} {incr i} {
    $n($i) set X_ [expr 175 + 50 *  ($i-16) ]
    $n($i) set Y_ [expr 250 + 60]
    $n($i) set Z_ 0.0
}

for {set i 20} {$i < 24} {incr i} {
    $n($i) set X_ [expr 175 + 50 *  ($i-20) ]
    $n($i) set Y_ [expr 250 - 60]
    $n($i) set Z_ 0.0
}

for {set i 24} {$i < 27} {incr i} {
    $n($i) set X_ [expr 200 + 50 *  ($i-24) ]
    $n($i) set Y_ [expr 250 + 90]
    $n($i) set Z_ 0.0
}

for {set i 27} {$i < 30} {incr i} {
    $n($i) set X_ [expr 200 + 50 *  ($i-27) ]
    $n($i) set Y_ [expr 250 - 90]
    $n($i) set Z_ 0.0
}

for {set i 30} {$i < 32} {incr i} {
    $n($i) set X_ [expr 225 + 50 *  ($i-30) ]
    $n($i) set Y_ [expr 250 + 120]
    $n($i) set Z_ 0.0
}

for {set i 32} {$i < 34} {incr i} {
    $n($i) set X_ [expr 225 + 50 *  ($i-32) ]
    $n($i) set Y_ [expr 250 - 120]
    $n($i) set Z_ 0.0
}

#extra two
$n(34) set X_ [expr 250 ]
$n(34) set Y_ [expr 250 + 150]
$n(34) set Z_ 0.0

$n(35) set X_ [expr 250  ]
$n(35) set Y_ [expr 250 - 150]
$n(35) set Z_ 0.0






#Phenomenon
$n(36) set X_ 2.0
$n(36) set Y_ 2.0
$n(36) set Z_ 0.0





$ns_ at 0.2 "$n(36) setdest 299.0 240.0 25.0" 
$ns_ at 49.0 "$n(36) setdest 499.0 2.0 50.0"
# Setting the node size
for {set i 0} {$i < $val(nn)} {incr i} {
    $ns_ initial_node_pos $n($i) 10
}



set dest [new Agent/Null]
$ns_ attach-agent $n(2) $dest
set udp [new Agent/UDP]
$ns_ attach-agent $n(36) $udp
$ns_ connect $udp $dest
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$cbr set packetSize_ 512
  
$ns_ at 0.0 "$cbr start"
    $ns_ at 50.0 "$cbr stop"


# Procedure to stop
proc stop {} {
      global ns_ tracefd
      $ns_ flush-trace
      close $tracefd
      exec nam a2.nam &
      exit 0
}

puts "Starting Simulation..."
$ns_ at $val(stop) "stop"
$ns_ run

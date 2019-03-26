# Define options
set val(chan) Channel/WirelessChannel ;# channel type
set val(prop) Propagation/TwoRayGround ;# radio-propagation model
set val(netif) Phy/WirelessPhy ;# network interface type
set val(mac) Mac/802_11 ;# MAC type
set val(ifq) Queue/DropTail/PriQueue ;# interface queue type
set val(ll) LL ;# link layer type
set val(ant) Antenna/OmniAntenna ;# antenna model
set val(ifqlen) 30 ;# max packet in ifq
set val(nn) 21 ;# number of mobilenodes
set val(rp) DSR ;# routing protocol
set val(x) 500 ;# X dimension of topography
set val(y) 250 ;# Y dimension of topography
set val(stop) 50 ;# time of simulation end
set val(energymodel) EnergyModel ;# Energy set up

# Setting the simulator objects
set ns_ [new Simulator]

# Create the nam and trace file
set tracefd [open a1.tr w]
$ns_ trace-all $tracefd
set namtrace [open a1.nam w]
$ns_ namtrace-all-wireless $namtrace  $val(x) $val(y)

$ns_ use-newtrace
# Create topography
set topo [new Topography]
$topo load_flatgrid $val(x) $val(y)
create-god $val(nn)
set chan_1_ [new $val(chan)]

# Set values for Shadowing
#Propagation/Shadowing set std_db_ 4.0       ;# shadowing deviation (dB)
#Propagation/Shadowing set dist0_ 0.5        ;# reference distance (m)
#Propagation/Shadowing set pathlossExp_ 3.5  ;# path loss exponent

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
for {set i 0} {$i < 4} {incr i} {
    $n($i) set X_ [expr 300 + 40 * cos(0.7853 + $i * 0.785 *2) ]
    $n($i) set Y_ [expr 150 + 40 * sin(0.7853 + $i * 0.785 *2)]
    $n($i) set Z_ 0.0
}

for {set i 4} {$i < 8} {incr i} {
    $n($i) set X_ [expr 300 + 80 * cos(0.7853 + $i * 0.785 *2) ]
    $n($i) set Y_ [expr 150 + 80 * sin(0.7853 + $i * 0.785 *2)]
    $n($i) set Z_ 0.0
}

for {set i 8} {$i < 12} {incr i} {
    $n($i) set X_ [expr 300 + 120 * cos(0.7853 + $i * 0.785 *2) ]
    $n($i) set Y_ [expr 150 + 120 * sin(0.7853 + $i * 0.785 *2)]
    $n($i) set Z_ 0.0
}

for {set i 12} {$i < 16} {incr i} {
    $n($i) set X_ [expr 300 + 160 * cos(0.7853 + $i * 0.785 *2) ]
    $n($i) set Y_ [expr 150 + 160 * sin(0.7853 + $i * 0.785 *2)]
    $n($i) set Z_ 0.0
}

$n(16) set X_ 300.0
    $n(16) set Y_ 150
    $n(16) set Z_ 0.0

$n(17) set X_ 2.0
$n(17) set Y_ 2.0
$n(17) set Z_ 0.0

$n(18) set X_ 250.0
$n(18) set Y_ 150.0
$n(18) set Z_ 0.0

$n(19) set X_ [expr 300 + 160 * cos(0.7853 + 1 * 0.785 *2) - 50]
$n(19) set Y_ [expr 150 + 160 * sin(0.7853 + 1 * 0.785 *2) ]
$n(19) set Z_ 0.0


$n(20) set X_ [expr 300 + 160 * cos(0.7853 + 2 * 0.785 *2) - 50]
$n(20) set Y_ [expr 150 + 160 * sin(0.7853 + 2 * 0.785 *2) ]
$n(20) set Z_ 0.0


$ns_ at 0.2 "$n(17) setdest 299.0 240.0 25.0" 
$ns_ at 49.0 "$n(17) setdest 499.0 2.0 50.0"
# Setting the node size
for {set i 0} {$i < $val(nn)} {incr i} {
    $ns_ initial_node_pos $n($i) 10
}



set dest [new Agent/Null]
$ns_ attach-agent $n(18) $dest
set udp [new Agent/UDP]
$ns_ attach-agent $n(17) $udp
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
      exec nam a1.nam &
      exit 0
}

puts "Starting Simulation..."
$ns_ at $val(stop) "stop"
$ns_ run

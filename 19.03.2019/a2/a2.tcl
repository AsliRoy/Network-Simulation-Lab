# Define options
set val(chan) Channel/WirelessChannel ;# channel type
set val(prop) Propagation/TwoRayGround ;# radio-propagation model
set val(netif) Phy/WirelessPhy ;# network interface type
set val(mac) Mac/802_11 ;# MAC type
set val(ifq) Queue/DropTail/PriQueue ;# interface queue type
set val(ll) LL ;# link layer type
set val(ant) Antenna/OmniAntenna ;# antenna model
set val(ifqlen) 50 ;# max packet in ifq
set val(nn) 20 ;# number of mobilenodes
set val(rp) DSDV ;# routing protocol
set val(x) 500 ;# X dimension of topography
set val(y) 250 ;# Y dimension of topography
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
for {set i 0} {$i < $val(nn)} {incr i} {
    $n($i) set X_ [expr ($i % 10 ) * 50 + 50]
    $n($i) set Y_ [expr ($i / 10 ) * 50 + 50]
    $n($i) set Z_ 0.0
}

# Setting the node size
for {set i 0} {$i < $val(nn)} {incr i} {
    $ns_ initial_node_pos $n($i) 10
}

set n([expr ($i + 1)]) [$ns_ node]
$n([expr ($i + 1)]) set X_ 2.0
$n([expr ($i + 1)]) set Y_ 2.0
$n([expr ($i + 1)]) set Z_ 0.0 


$ns_ at 0.2 "$n([expr ($i + 1)]) setdest 299.0 240.0 25.0" 
$ns_ at 49.0 "$n([expr ($i + 1)]) setdest 499.0 2.0 50.0"

$ns_ initial_node_pos $n([expr ($i + 1)]) 10




# Establishing communication
set dest [new Agent/Null]
#$ns_ attach-agent $n([expr $val(nn) - 1]) $dest
$ns_ attach-agent $n([expr $i / 2]) $dest
#for {set i 0} {$i < [expr $val(nn) - 1]} {incr i} {
    set udp [new Agent/UDP]
    $ns_ attach-agent $n([expr ($i + 1)]) $udp
    $ns_ connect $udp $dest
    set cbr [new Application/Traffic/CBR]
    $cbr attach-agent $udp
    $cbr set packetSize_ 512
    #$ns_ at [expr $i * 2] "$cbr start"
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

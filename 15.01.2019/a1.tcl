#CREATING A NETWORK TOPOLOGY WITH DIFFERENT BANDWIDTHS AND DELAYS BETWEEN NODES

#Creating a Network Simulator Object
set ns [new Simulator]

#Define different colors for data flows (for NAM)
$ns color 1 Blue
$ns color 2 Red

#Creating a Trace File to store Data Flow
set tr [open a1.tr w]
$ns trace-all $tr

#Creating a NAM File to analyze netwrk topology
set namtr [open a1.nam w]
$ns namtrace-all $namtr


#Creating Nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]

#Creating a duplex link between nodes with BW, Delay and QueueType specified
$ns duplex-link $n2 $n3 300Kb 100ms DropTail
$ns duplex-link $n2 $n0 2Mb 10ms DropTail
$ns duplex-link $n2 $n1 2Mb 10ms DropTail
$ns duplex-link $n4 $n3 500Kb 40ms DropTail
$ns duplex-link $n5 $n3 500Kb 30ms DropTail

#Creating the orientation between the different nodes required for visualization
$ns duplex-link-op $n2 $n3 orient right
$ns duplex-link-op $n2 $n0 orient left-up
$ns duplex-link-op $n2 $n1 orient left-down
$ns duplex-link-op $n3 $n4 orient right-up
$ns duplex-link-op $n3 $n5 orient right-down

#Set Queue Size of link  to 10
#$ns queue-limit $n0 $n2 3
#$ns queue-limit $n1 $n2 3
#$ns queue-limit $n2 $n3 3
#$ns queue-limit $n3 $n4 3
#$ns queue-limit $n5 $n3 3

#Setup a TCP connection
set tcp [new Agent/TCP]
$tcp set class_ 2
$ns attach-agent $n0 $tcp
set sink [new Agent/TCPSink]
$ns attach-agent $n4 $sink
$ns connect $tcp $sink
$tcp set fid_ 1

#Setup a FTP over TCP connection
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ftp set type_ FTP


#Setup a UDP connection
set udp [new Agent/UDP]
$ns attach-agent $n1 $udp
set null [new Agent/Null]
$ns attach-agent $n5 $null
$ns connect $udp $null
$udp set fid_ 2

#Setup a CBR over UDP connection
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$cbr set type_ CBR
$cbr set packet_size_ 1000
$cbr set rate_ 1mb
$cbr set random_ false

#Schedule events for the CBR and FTP agents
$ns at 0.1 "$cbr start"
$ns at 0.3 "$ftp start"
$ns at 10.0 "$ftp stop"
$ns at 4.5 "$cbr stop"


#Print CBR packet size and interval
puts "CBR packet size = [$cbr set packet_size_]"
puts "CBR interval = [$cbr set interval_]"

#Running the simulation
$ns at 50.0 "$ns halt"
$ns run


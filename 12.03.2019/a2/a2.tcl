set ns [new Simulator]

$ns multicast

set tr [open a1.tr w]
$ns trace-all $tr
$ns use-newtrace
#Creating a NAM File to analyze netwrk topology
set namtr [open a1.nam w]
$ns namtrace-all $namtr

# allocate a multicast address;
set group1 [Node allocaddr]   
set group2 [Node allocaddr]
                
# nod is the number of nodes
set nod 5                          

# create multicast capable nodes;
for {set i 1} {$i <= $nod} {incr i} {
   set n($i) [$ns node]                      
}
#Create links between the nodes
$ns duplex-link $n(1) $n(2) 0.3Mb 10ms DropTail 
$ns duplex-link $n(2) $n(3) 0.3Mb 10ms DropTail
$ns duplex-link $n(2) $n(4) 0.5Mb 10ms DropTail
$ns duplex-link $n(2) $n(5) 0.3Mb 10ms DropTail

#Give node position
$ns duplex-link-op $n(1) $n(2) orient right
$ns duplex-link-op $n(2) $n(3) orient right
$ns duplex-link-op $n(4) $n(2) orient down
$ns duplex-link-op $n(5) $n(2) orient up

# configure multicast protocol;
DM set CacheMissMode dvmrp
set mproto DM                                

# all nodes will contain multicast protocol agents;
set mrthandle [$ns mrtproto $mproto]         
set udp1 [new Agent/UDP]                     
set udp2 [new Agent/UDP]                    
$ns attach-agent $n(1) $udp1
$ns attach-agent $n(3) $udp2
set src1 [new Application/Traffic/CBR]
$src1 attach-agent $udp1
$udp1 set dst_addr_ $group1
$udp1 set dst_port_ 0
$src1 set random_ false
set src2 [new Application/Traffic/CBR]
$src2 attach-agent $udp2
$udp2 set dst_addr_ $group2
$udp2 set dst_port_ 1
$src2 set random_ false


# create receiver agents
set rcvr [new Agent/LossMonitor]
      
# joining and leaving the group;
$ns at 0.10 "$n(4) join-group $rcvr $group1"
$ns at 0.12 "$n(5) join-group $rcvr $group1"
$ns at 0.5 "$n(4) leave-group $rcvr $group1"
$ns at 0.6 "$n(4) join-group $rcvr $group2"
$ns at 0.05 "$src1 start"
$ns at 0.05 "$src2 start"
$ns at 0.8 "$ns halt"
$ns run

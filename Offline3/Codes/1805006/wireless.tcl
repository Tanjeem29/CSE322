#Random Number Gen
proc rand { excl_limit } {
    expr { int(rand() * $excl_limit) }
}


# set testfile [open test.txt w]



# simulator
set ns [new Simulator]


# ======================================================================
# Define options

set val(chan)         Channel/WirelessChannel  ;# channel type
set val(prop)         Propagation/TwoRayGround ;# radio-propagation model
set val(ant)          Antenna/OmniAntenna      ;# Antenna type
set val(ll)           LL                       ;# Link layer type
set val(ifq)          Queue/DropTail/PriQueue  ;# Interface queue type
set val(ifqlen)       50                       ;# max packet in ifq
set val(netif)        Phy/WirelessPhy          ;# network interface type
set val(mac)          Mac/802_11               ;# MAC type
# set val(netif)        Phy/WirelessPhy/802_15_4          ;# network interface type
# set val(mac)          Mac/802_15_4               ;# MAC type
# =======================================================================

# =======================================================================
#Params
# set val(rp)             DSDV                        ;# ad-hoc routing protocol 
set val(rp)             AODV                        ;# ad-hoc routing protocol 
set val(nn)             [lindex $argv 0]            ;# number of mobilenodes
set val(nf)             [lindex $argv 1]            ;# number of flows
set length              [lindex $argv 2]
set topo                [new Topography]
$topo load_flatgrid $length $length                      ;# length x length area



if { $val(nn) == 20 } {
    set cols 4
} elseif { $val(nn) == 40 } {
    set cols 5 
} elseif { $val(nn) == 60 } {
    set cols 6
} elseif { $val(nn) == 80 } {
    set cols 8
} elseif { $val(nn) == 100 } {
    set cols 10
} else {
    set cols 4
}

set rows [expr $val(nn)/$cols]
# =======================================================================


# trace file
set trace_file [open trace.tr w]
$ns trace-all $trace_file

# nam file
set nam_file [open animation.nam w]
$ns namtrace-all-wireless $nam_file 500 500

# topology: to keep track of node movements



# general operation director for mobilenodes
create-god $val(nn)


# node configs
# ======================================================================

# $ns node-config -addressingType flat or hierarchical or expanded
#                  -adhocRouting   DSDV or DSR or TORA
#                  -llType	   LL
#                  -macType	   Mac/802_11
#                  -propType	   "Propagation/TwoRayGround"
#                  -ifqType	   "Queue/DropTail/PriQueue"
#                  -ifqLen	   50
#                  -phyType	   "Phy/WirelessPhy"
#                  -antType	   "Antenna/OmniAntenna"
#                  -channelType    "Channel/WirelessChannel"
#                  -topoInstance   $topo
#                  -energyModel    "EnergyModel"
#                  -initialEnergy  (in Joules)
#                  -rxPower        (in W)
#                  -txPower        (in W)
#                  -agentTrace     ON or OFF
#                  -routerTrace    ON or OFF
#                  -macTrace       ON or OFF
#                  -movementTrace  ON or OFF

# ======================================================================

$ns node-config -adhocRouting $val(rp) \
                -llType $val(ll) \
                -macType $val(mac) \
                -ifqType $val(ifq) \
                -ifqLen $val(ifqlen) \
                -antType $val(ant) \
                -propType $val(prop) \
                -phyType $val(netif) \
                -topoInstance $topo \
                -channelType $val(chan) \
                -agentTrace ON \
                -routerTrace ON \
                -macTrace OFF \
                -movementTrace OFF


set k 0
for {set i 0} {$i < $cols } {incr i} {

    for {set j 0} {$j < $rows } {incr j} {
        #set l [expr (9 - $k)]
        set l [expr ($k)]
        set node($l) [$ns node]
        $node($l) random-motion 0       ;# disable random motion
        $node($l) set Y_ [expr ($length/$cols * ($i)) ]
        $node($l) set X_ [expr ($length/$rows * ($j)) ]
        $node($l) set Z_ 0
        $ns initial_node_pos $node($l) 50
        set destx [rand $length]
        set desty [rand $length]
        set speed [rand 400]
        set speed [expr ($speed/100.0) + 1]
        $ns at 1.0 "$node($l) setdest $destx $desty $speed"
        # puts $speed
        incr k
    }
}


# Traffic


set dest [rand $val(nn)]
# puts $dest
# puts "---------"

for {set i 0} {$i < $val(nf)} {incr i} {
#    set src $i

    set src [rand $val(nn)]
    while { $dest == $src } {
        set src [rand $val(nn)]
    }
    # puts $src
    # puts $dest
    # puts "----------------------"



    # Traffic config
    # create agent
    set tcp [new Agent/TCP/Reno]
    set tcp_sink [new Agent/TCPSink]
    # attach to nodes
    $ns attach-agent $node($src) $tcp
    $ns attach-agent $node($dest) $tcp_sink
    # connect agents
    $ns connect $tcp $tcp_sink
    $tcp set fid_ $i

    # Traffic generator
    set ftp [new Application/FTP]

    # $ftp set packet_size_ 40
    # attach to agent
    $ftp attach-agent $tcp
    
    # start traffic generation
    $ns at 1.0 "$ftp start"




}


# End Simulation

# Stop nodes
for {set i 0} {$i < $val(nn)} {incr i} {
    $ns at 50.0 "$node($i) reset"
}

# call final function
proc finish {} {
    global ns trace_file nam_file
    $ns flush-trace
    close $trace_file
    close $nam_file
}

proc halt_simulation {} {
    global ns
    puts "Simulation ending"
    $ns halt
}

$ns at 50.0001 "finish"
$ns at 50.0002 "halt_simulation"



# Run simulation
puts "Simulation starting"
$ns run


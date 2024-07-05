expr { srand(1) }
proc rand { excl_limit } {
    expr { int(rand() * $excl_limit) }
}

#Create a simulator object
set ns [new Simulator]

#Define different colors for data flows (for NAM)
$ns color 1 Blue
$ns color 2 Red

proc UniformErr {} {
    # global dropRate
    # set err [new ErrorModel/Uniform $dropRate pkt]
    set err [new ErrorModel/Uniform 0.1 pkt]

    return $err
}
$ns node-config -IncomingErrProc UniformErr  \

set nodes [lindex $argv 0]
set flows [lindex $argv 1]

#Open the NAM file and trace file
set nam_file [open animation.nam w]
set trace_file [open trace.tr w]
$ns namtrace-all $nam_file
$ns trace-all $trace_file

#Define a 'finish' procedure
proc finish {} {
    global ns nam_file trace_file
    $ns flush-trace 
    close $nam_file
    close $trace_file

    exit 0
}

set sender_upper [expr ($nodes / 2) - 1]
set receiver_lower [expr ($nodes / 2) + 1]
set sender_common [expr ($nodes / 2) - 1]
set receiver_common [expr ($nodes / 2)]
puts $sender_common
puts $receiver_common
puts $sender_upper 
puts $receiver_lower
for {set i 0} {$i < $nodes} {incr i} {
    set node($i) [$ns node]
}

for {set i 0} {$i < $sender_upper} {incr i} {
    $ns duplex-link $node($i) $node($sender_common) 2Mb 10ms DropTail
}
for {set i $receiver_lower} {$i < $nodes} {incr i} {

    $ns duplex-link $node($i) $node($receiver_common) 2Mb 10ms DropTail
}
$ns duplex-link $node($sender_common) $node($receiver_common) 2Mb 10ms DropTail


set i $sender_common
set j [expr $sender_common / 2]
set k $receiver_common
set l [expr $receiver_common / 2]


for {set i $receiver_lower} {$i < $nodes} {incr i} {

    $ns duplex-link $node($i) $node($receiver_common) 2Mb 10ms DropTail
}

#Setup a TCP connection
#Setup a flow

for {set k 0} {$k < $flows} {incr k} {

    set i [rand $sender_common]
    set j [rand $sender_common]
    set j [expr $j + $receiver_lower]

    # set tcp1 [new Agent/TCP]
    set tcp1 [new Agent/TCP/Reno]
    # set tcp1 [new Agent/TCP/Tanj]

    $tcp1 set maxseq_ [lindex $argv 2]
    # $tcp1 tracevar nodes
    $ns attach-agent $node($i) $tcp1
    set sink1 [new Agent/TCPSink]
    $ns attach-agent $node($j) $sink1
    $ns connect $tcp1 $sink1
    $tcp1 set fid_ $k
    set ftp1 [new Application/FTP]
    $ftp1 attach-agent $tcp1
    $ftp1 set type_ FTP
    $ns at 1.0 "$ftp1 start"
    $ns at 50.0 "$ftp1 stop"
}


#Call the finish procedure after 5 seconds of simulation time
$ns at 51.0 "finish"


#Run the simulation
$ns run

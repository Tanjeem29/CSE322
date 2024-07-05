#!/bin/bash

# starting by creating file for recording statistics
echo -e "\n------------------ run.sh: starting -----------------\n"
# touch test.csv
# "" > test.csv
# defining baseline parameters
# base_length=500
# base_nodes=40
# base_flows=20
# base_pkts=200
# base_trx=2
base_alt=780
base_incl=90

# generating statistics and plotting graphs 
# by running simulation with varying area size and parsing generated trace files
# echo -e "Network-Throughtput-(kilobits/sec),End-to-End-Avg-Delay-(sec), Packet-Delivery-Ratio-(%) Packet-Drop-Ratio-(%)" > stat.st
echo -e "------------- run.sh: varying area size -------------\n"

for((i=0; i<5; i++)); do
    alt=`expr 580 + $i \* 100`
    # echo -e $length >> test.csv

    echo -e "ns.tcl: running with alt $alt  incl $base_incl\n"
    ns sat.tcl $alt  $base_incl
    echo -e "\nparser.awk: running\n"
    awk -f parseSat.awk out.tr
done

# "" >> test.csv

for((i=0; i<5; i++)); do
    incl=`expr 80 + $i \* 5`
    # echo -e $length >> test.csv

    echo -e "ns.tcl: running with alt $base_alt  incl $incl\n"
    ns sat.tcl $base_alt $incl 
    echo -e "\nparserSat.awk: running\n"
    awk -f parseSat.awk out.tr
done

# "" >> test.csv

# for((i=0; i<5; i++)); do
#     flows=`expr 10 + $i \* 10`
#     # echo -e $length >> test.csv

#     echo -e "ns.tcl: running with $base_nodes $flows $base_pkts $base_trx\n"
#     ns sat.tcl $base_nodes $flows $base_pkts $base_trx 
#     echo -e "\nparser.awk: running\n"
#     awk -f parse.awk trace.tr
# done

# # "" >> test.csv

# for((i=0; i<5; i++)); do
#     pkts=`expr 100 + $i \* 100`
#     # echo -e $length >> test.csv

#     echo -e "ns.tcl: running with $base_nodes $base_flows $pkts $base_trx\n"
#     ns sat.tcl $base_nodes $base_flows $pkts $base_trx 
#     echo -e "\nparser.awk: running\n"
#     awk -f parse.awk trace.tr
# done

# "" >> test.csv

# for((i=0; i<5; i++)); do
#     nodes=`expr 20 + $i \* 20`
#     # echo -e $length >> test.csv

#     echo -e "ns.tcl: running with $nodes $base_flows $base_length\n"
#     ns sat.tcl $nodes $base_flows $base_length 
#     echo -e "\nparser.awk: running\n"
#     awk -f parse.awk trace.tr
# done

# "" >> test.csv

# for((i=0; i<5; i++)); do
#     flows=`expr 10 + $i \* 10`
#     # echo -e $length >> test.csv

#     echo -e "ns.tcl: running with $base_nodes $flows $base_length\n"
#     ns sat.tcl $base_nodes $flows $base_length 
#     echo -e "\nparser.awk: running\n"
#     awk -f parse.awk trace.tr
# done

# for((i=0; i<5; i++)); do
#     nodes=`expr 10 + $i \* 10`
#     # echo -e $length >> test.csv

#     echo -e "ns.tcl: running with $base_nodes $base_flows $length\n"
#     ns sat.tcl $nodes $base_flows $base_length 
#     echo -e "\nparser.awk: running\n"
#     awk -f parse.awk trace.tr
# done

# echo -e "plotter.py: running\n"
# python plotter.py

# # generating statistics and plotting graphs 
# # by running simulation with varying number of nodes and parsing generated trace files
# echo -e "Number-of-Nodes\nNetwork-Throughtput-(kilobits/sec) End-to-End-Avg-Delay-(sec) Packet-Delivery-Ratio-(%) Packet-Drop-Ratio-(%)" > stat.st
# echo -e "---------- run.sh: varying number of nodes ----------\n"

# for((i=0; i<5; i++)); do
#     nodes=`expr 20 + $i \* 20`
#     echo -e $nodes >> stat.st

#     echo -e "ns.tcl: running with $baseline_area_side $nodes $baseline_flows\n"
#     ns ns.tcl $baseline_area_side $nodes $baseline_flows
#     echo -e "\nparser.py: running\n"
#     python parser.py
# done

# echo -e "plotter.py: running\n"
# python plotter.py

# # generating statistics and plotting graphs 
# # by running simulation with varying number of flows and parsing generated trace files
# echo -e "Number-of-Flows\nNetwork-Throughtput-(kilobits/sec) End-to-End-Avg-Delay-(sec) Packet-Delivery-Ratio-(%) Packet-Drop-Ratio-(%)" > stat.st
# echo -e "---------- run.sh: varying number of flows ----------\n"

# for((i=0; i<5; i++)); do
#     flows=`expr 10 + $i \* 10`
#     echo -e $flows >> stat.st

#     echo -e "ns.tcl: running with $baseline_area_side $baseline_nodes $flows\n"
#     ns ns.tcl $baseline_area_side $baseline_nodes $flows
#     echo -e "\nparser.py: running\n"
#     python parser.py
# done

# echo -e "plotter.py: running\n"
# python plotter.py

# # terminating by removing intermediary nam, stat, and trace files
# echo -e "---------------- run.sh: terminating ----------------\n"
# rm animation.nam stat.st trace.tr
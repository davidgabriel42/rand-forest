#!/bin/bash
function run_tstat()
{
        tstat -l -i ens3f0 -s  $1 &
        TSTAT_PID=$!
        echo "TSTAT Started, PID = $TSTAT_PID"
        sleep 1
        for i in {1..120}
                do
                        for j in {1..6}
                                do
                                        echo "Starting iPerf Test #$i.$j"
                                        iperf3 -c 192.168.1.2 -t 10
                                        echo "iPerf Complete"
                                done
                done
        kill -s INT $TSTAT_PID
}

sudo iptables -A INPUT -m statistic --mode random --probability 0.01 -j DROP -p tcp --src 192.168.1.2
run_tstat  OUT_DATA/drop_01_perc
sudo iptables -D INPUT -m statistic --mode random --probability 0.01 -j DROP -p tcp --src 192.168.1.2

sudo iptables -A INPUT -m statistic --mode random --probability 0.001 -j DROP -p tcp --src 192.168.1.2
run_tstat  OUT_DATA/drop_001_perc
sudo iptables -D INPUT -m statistic --mode random --probability 0.001 -j DROP -p tcp --src 192.168.1.2

sudo iptables -A INPUT -m statistic --mode random --probability 0.0005 -j DROP -p tcp --src 192.168.1.2
run_tstat  OUT_DATA/drop_0005_perc
sudo iptables -D INPUT -m statistic --mode random --probability 0.0005 -j DROP -p tcp --src 192.168.1.2

tc qdisc add dev ens3f0 root netem delay 25ms 20ms distribution normal
run_tstat  OUT_DATA/delay_25_var_20
tc qdisc del dev ens3f0 root netem delay 25ms 20ms distribution normal

tc qdisc add dev ens3f0 root netem delay 10ms 5ms distribution normal
run_tstat  OUT_DATA/delay_10_var_5
tc qdisc del dev ens3f0 root netem delay 10ms 5ms distribution normal

tc qdisc add dev ens3f0 root netem delay 5ms 2ms distribution normal
run_tstat  OUT_DATA/delay_5_var_2
tc qdisc del dev ens3f0 root netem delay 5ms 2ms distribution normal

tc qdisc add dev ens3f0 root netem delay 100ms 20ms distribution normal
run_tstat  OUT_DATA/delay_1_var_1
tc qdisc del dev ens3f0 root netem delay 100ms 20ms distribution normal

tc qdisc add dev eth0 root netem duplicate 1%
run_tstat  OUT_DATA/dup_1perc
tc qdisc del dev eth0 root netem duplicate 1%

tc qdisc add dev eth0 root netem duplicate 1%
run_tstat  OUT_DATA/dup_0.1perc
tc qdisc del dev eth0 root netem duplicate 1%

tc qdisc add dev eth0 root netem duplicate 2%
run_tstat  OUT_DATA/dup_2perc
tc qdisc del dev eth0 root netem duplicate 2%

tc qdisc add dev eth0 root netem corrupt 0.1%
run_tstat  OUT_DATA/corrupt_0.1perc
tc qdisc del dev eth0 root netem corrupt 0.1%

tc qdisc add dev eth0 root netem corrupt 0.5%
run_tstat  OUT_DATA/corrupt_0.5perc
tc qdisc del dev eth0 root netem corrupt 0.5%

tc qdisc add dev eth0 root netem corrupt 1.0%
run_tstat  OUT_DATA/corrupt_1.0perc
tc qdisc del dev eth0 root netem corrupt 1.0%
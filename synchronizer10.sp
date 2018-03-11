*synchronizer10

***begin***
.protect
.lib 'putyourlib' tt
.unprotect 
.temp =30
.GLOBAL vdd gnd
.option nomod post acout=0

***Power supply*********
vdd vdd gnd DC=+1.8V


**NAND2**
.subckt NAND2 in1 in2 out vcc vss
m1 vdd in1 out vdd pmos w=2u l=0.18u
m2 vdd in2 out vdd pmos w=2u l=0.18u
m3 out in1 1 gnd nmos w=1u l=0.18u
m4 1 in2 gnd gnd nmos w=1u l=0.18u
.ends NAND2

**AND**
.subckt and in1 in2 out vcc vss
m1 vdd in1 l1 vdd pmos w=2u l=0.18u
m2 vdd in2 l1 vdd pmos w=2u l=0.18u
m3 l1 in1 l2 gnd nmos w=1u l=0.18u
m4 l2 in2 gnd gnd nmos w=1u l=0.18u
m5 vdd l1 out vdd pmos w=2u l=0.18u
m6 out l1 gnd gnd nmos w=1u l=0.18u
.ends and

**XOR**
.subckt XOR A B out
M1 B N20 Out GND nmos w=1u l=0.18u  
M2 N1 A Out GND nmos w=1u l=0.18u  
M3 Gnd B N1 GND nmos w=1u l=0.18u  
M4 GND A N20 GND nmos w=1u l=0.18u  
M5 B A Out VDD pmos w=2u l=0.18u 
M6 N1 N20 Out VDD pmos w=2u l=0.18u 
M7 N1 B VDD VDD pmos w=2u l=0.18u 
M8 N20 A Vdd VDD pmos w=2u l=0.18u
.ends XOR

**NAND3**
.subckt NAND3 in1 in2 in3 out vcc vss
m1 vdd in1 out vdd pmos w=2u l=0.18u
m2 vdd in2 out vdd pmos w=2u l=0.18u
m3 vdd in3 out vdd pmos w=2u l=0.18u
m4 out in1 2 gnd nmos w=1u l=0.18u
m5 2 in2 3 gnd nmos w=1u l=0.18u
m6 3 in3 gnd gnd nmos w=1u l=0.18u
.ends NAND3

****DFFrstX****
.subckt DFFrstX DATA CLK Q reset 
xNAND2_1 1 2 3 vdd gnd NAND2
xNAND2_2 3 CLK 2 vdd gnd NAND2
xNAND3_1 2 CLK 1 4 vdd gnd NAND3
xNAND2_3 4 5 1 vdd gnd NAND2
xAND_1 DATA reset 5 vdd gnd AND
xNAND2_4 2 QP Q vdd gnd NAND2
xNAND2_5 Q 4 QP vdd gnd NAND2
.ends DFFrstX

.subckt synchronizerHandshake l1 l2 l3 l4 l5 l6 l7 l8 ackA ack ackBreqB req reqA clkA clkB 
xDFF_1 dataA clkB ackBreqB reset DFFrstX
xXOR_1 reqA req l1 vdd gnd XOR
xDFF_2 l1 clkA req reset  DFFrstX
xDFF_3 req clkB l2 reset DFFrstX
xDFF_4 l2 clkB l3 reset DFFrstX
xDFF_5 l3 clkB l4 reset DFFrstX
xXOR_2 l4 l3 ackBreqB vdd gnd XOR
xXOR_3 ackBreqB ack l5 vdd gnd XOR
xDFF_6 l5 clkB ack reset DFFrstX
xDFF_7 Ack clkA l6 reset DFFrstX
xDFF_8 l6 clkA l7 reset DFFrstX
xDFF_9 l7 clkA l8 reset DFFrstX
xXOR_4 l7 l8 ackA vdd gnd XORZZ
.ends synchronizerHandshake

*xsynchronizerHandshake l1 l2 l3 l4 l5 l6 l7 l8 ackA ack ackBreqB req reqA clkA clkB vcc vss synchronizerHandshake 


***main***
xDFF_1 dataA clkB dataB ackBreqB DFFrstX
xXOR_1 reqA req l1 XOR
xDFF_2 l1 clkA req reset  DFFrstX
xDFF_3 req clkB l2 reset DFFrstX
xDFF_4 l2 clkB l3 reset DFFrstX
xDFF_5 l3 clkB l4 reset DFFrstX
xXOR_2 l4 l3 ackBreqB XOR
xXOR_3 ackBreqB ack l5 XOR
xDFF_6 l5 clkB ack reset DFFrstX
xDFF_7 Ack clkA l6 reset DFFrstX
xDFF_8 l6 clkA l7 reset DFFrstX
xDFF_9 l7 clkA l8 reset DFFrstX
xXOR_4 l7 l8 ackA XOR

*Cl3 l3 gnd 10pf
RclkA clkA gnd 100G
RclkB clkB gnd 100G
RdataA dataA gnd 100G
RreqA reqA gnd 100G
Rreset reset gnd 100G


***simulate***
vdataA dataA gnd pulse(0V 1.8V 2us 2ns 1ns 3us 8us)
vclkA clkA gnd pulse(0V 1.8V 1us 1ns 1ns 3us 6us)
vclkB clkB gnd pulse(0V 1.8V 2us 1ns 1ns 4.5us 9us)
vreqA reqA gnd pwl(1n 0V 1.5u 0V 1.501u 1.8V 9u 1.8V 9.001u 0V 37.5u 0V 37.501u 1.8V 45u 1.8V 45.001u 0V 59u 0V)
vreset reset gnd pwl(1n 0V 0.5u 0V 0.5001u 1.8V 59u 1.8V)

***analysis***
.op
.probe dc
.tran 0.01us 100us
.end
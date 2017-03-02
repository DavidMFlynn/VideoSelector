EESchema Schematic File Version 2
LIBS:power
LIBS:device
LIBS:transistors
LIBS:conn
LIBS:linear
LIBS:regul
LIBS:74xx
LIBS:cmos4000
LIBS:adc-dac
LIBS:memory
LIBS:xilinx
LIBS:microcontrollers
LIBS:dsp
LIBS:microchip
LIBS:analog_switches
LIBS:motorola
LIBS:texas
LIBS:intel
LIBS:audio
LIBS:interface
LIBS:digital-audio
LIBS:philips
LIBS:display
LIBS:cypress
LIBS:siliconi
LIBS:opto
LIBS:atmel
LIBS:contrib
LIBS:valves
LIBS:Switch16-cache
EELAYER 25 0
EELAYER END
$Descr A 11000 8500
encoding utf-8
Sheet 1 1
Title "Switch 16 pos gray code"
Date "2016-11-19"
Rev "n/c"
Comp "DMFE"
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L CONN_01X05 P1
U 1 1 5830A510
P 5000 3450
F 0 "P1" H 4950 3750 50  0000 L CNN
F 1 "CONN_01X05" H 4900 3100 50  0000 L CNN
F 2 "Pin_Headers:Pin_Header_Straight_1x05" H 5000 3450 50  0001 C CNN
F 3 "" H 5000 3450 50  0000 C CNN
	1    5000 3450
	1    0    0    -1  
$EndComp
$Comp
L RJ45 J1
U 1 1 5830A543
P 3850 1250
F 0 "J1" H 3926 1865 50  0000 C CNN
F 1 "RJ45" H 3926 1774 50  0000 C CNN
F 2 "Connectors:RJ45_8" H 3850 1250 50  0001 C CNN
F 3 "" H 3850 1250 50  0000 C CNN
	1    3850 1250
	1    0    0    -1  
$EndComp
$Comp
L R_Small R1
U 1 1 5830A5D8
P 2500 2400
F 0 "R1" H 2559 2446 50  0000 L CNN
F 1 "10K" H 2559 2355 50  0000 L CNN
F 2 "Resistors_SMD:R_0805_HandSoldering" H 2500 2400 50  0001 C CNN
F 3 "" H 2500 2400 50  0000 C CNN
	1    2500 2400
	1    0    0    -1  
$EndComp
$Comp
L R_Small R2
U 1 1 5830A623
P 2800 2400
F 0 "R2" H 2859 2446 50  0000 L CNN
F 1 "10K" H 2859 2355 50  0000 L CNN
F 2 "Resistors_SMD:R_0805_HandSoldering" H 2800 2400 50  0001 C CNN
F 3 "" H 2800 2400 50  0000 C CNN
	1    2800 2400
	1    0    0    -1  
$EndComp
$Comp
L R_Small R3
U 1 1 5830A645
P 3100 2400
F 0 "R3" H 3159 2446 50  0000 L CNN
F 1 "10K" H 3159 2355 50  0000 L CNN
F 2 "Resistors_SMD:R_0805_HandSoldering" H 3100 2400 50  0001 C CNN
F 3 "" H 3100 2400 50  0000 C CNN
	1    3100 2400
	1    0    0    -1  
$EndComp
$Comp
L R_Small R4
U 1 1 5830A666
P 3400 2400
F 0 "R4" H 3459 2446 50  0000 L CNN
F 1 "10K" H 3459 2355 50  0000 L CNN
F 2 "Resistors_SMD:R_0805_HandSoldering" H 3400 2400 50  0001 C CNN
F 3 "" H 3400 2400 50  0000 C CNN
	1    3400 2400
	1    0    0    -1  
$EndComp
Wire Wire Line
	3600 2200 3600 1700
Wire Wire Line
	2500 2200 3600 2200
Wire Wire Line
	2500 2200 2500 2300
Wire Wire Line
	2800 2300 2800 2200
Connection ~ 2800 2200
Wire Wire Line
	3100 2300 3100 2200
Connection ~ 3100 2200
Wire Wire Line
	3400 2300 3400 2200
Connection ~ 3400 2200
Wire Wire Line
	3500 1700 3500 1800
Wire Wire Line
	3500 1800 3600 1800
Connection ~ 3600 1800
Wire Wire Line
	3700 2600 3400 2600
Wire Wire Line
	3400 2600 3400 2500
Wire Wire Line
	3800 2700 3100 2700
Wire Wire Line
	3100 2700 3100 2500
Wire Wire Line
	3900 2800 2800 2800
Wire Wire Line
	2800 2800 2800 2500
Wire Wire Line
	4000 2900 2500 2900
Wire Wire Line
	2500 2900 2500 2500
Wire Wire Line
	3700 1700 3700 3550
Connection ~ 3700 2600
Wire Wire Line
	3800 1700 3800 3450
Connection ~ 3800 2700
Wire Wire Line
	3900 1700 3900 3350
Connection ~ 3900 2800
Wire Wire Line
	4000 1700 4000 3250
Connection ~ 4000 2900
Wire Wire Line
	4100 1700 4100 3650
Wire Wire Line
	4100 3650 4800 3650
Wire Wire Line
	4200 1700 4200 1800
Wire Wire Line
	4200 1800 4100 1800
Connection ~ 4100 1800
NoConn ~ 4400 900 
Text Notes 5100 3650 0    60   ~ 0
8\n4\n2\n1\nC
Wire Wire Line
	4000 3250 4800 3250
Wire Wire Line
	3900 3350 4800 3350
Wire Wire Line
	3800 3450 4800 3450
Wire Wire Line
	3700 3550 4800 3550
Text Notes 3250 1950 0    60   ~ 0
+5,+5, 1, 2, 4, 8, GND, GND
$EndSCHEMATC

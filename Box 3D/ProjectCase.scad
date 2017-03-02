// **************************************************************
// Project Case (Selector 8 x 16 version)
// Revision: 1.0.0 3/1/2017
// Created: 3/1/2017
// by David M. Flynn
// units: inches
// **************************************************************
// ***** for STL output *****
// scale(25.4) BoxBottom();
// scale(25.4) rotate([180,0,0]) BoxTop();
// **************************************************************
// ***** general routines *****
// RoundRect(X=2.0,Y=1.0,Z=0.5,R=0.1);
// BoxShell(X=2.0,Y=1.0,Z=0.5,R=0.1,Wall=0.04);
// MountingBoss(X=0,Y=0,R=0.2) children;
// **************************************************************

include<CommonStuffSAE.scad>

Overlap=0.005;
IDXtra=0.008;
$fn=90;

module RoundRect(X=2.0,Y=1.0,Z=0.5,R=0.1){
	hull(){
		translate([-X/2+R,-Y/2+R,0]) cylinder(r=R, h=Z);
		translate([X/2-R,-Y/2+R,0]) cylinder(r=R, h=Z);
		translate([-X/2+R,Y/2-R,0]) cylinder(r=R, h=Z);
		translate([X/2-R,Y/2-R,0]) cylinder(r=R, h=Z);
	}// hull
	
} // RoundRect

//RoundRect();

module BoxShell(X=2.0,Y=1.0,Z=0.5,R=0.1,Wall=0.04){
	difference(){
		RoundRect(X=X,Y=Y,Z=Z,R=R);
		translate([0,0,Wall]) RoundRect(X=X-Wall*2,Y=Y-Wall*2,Z=Z,R=R-Wall);
	} // diff
	
	
} // BoxShell

//BoxShell();
PCB_t=0.063;
PCB_x=6.5;
PCB_y=2.6;
MH1=[.2,.2];
MH2=[6.3,.2];
MH3=[-0.075,PCB_y-0.2];
MH4=[PCB_x+0.075,PCB_y-0.2];
BoxWall_t=0.04;
Box_x=PCB_x+0.55;
Box_y=PCB_y+BoxWall_t*4;
BoxBot_h=0.3;
BoxTop_h=0.6;
BoxCorner_r=0.1;

module MountingBoss(X=0,Y=0,R=0.2){
	// from PCB 0,0
	
	difference(){
		translate([-PCB_x/2+X,-PCB_y/2+Y,BoxWall_t-Overlap]) cylinder(r=R,h=BoxBot_h-PCB_t-BoxWall_t);
		translate([-PCB_x/2+X,-PCB_y/2+Y,BoxBot_h-PCB_t]) children();
	} // diff
} // MountingBoss

module PCBRelPos(X=0,Y=0){
	translate([-PCB_x/2+X,-PCB_y/2+Y,0]) children();
} // PCBRelPos

module MountingBossTop(X=0,Y=0,R=0.2){
	// from PCB 0,0
	
	PCBRelPos(X=X,Y=Y)
	difference(){
		cylinder(r=R,h=BoxTop_h-Overlap);
		translate([0,0,BoxTop_h]) children();
	} // diff
} // MountingBossTop

module BoxBottom(){
	BoxShell(X=Box_x,Y=Box_y,Z=BoxBot_h,R=BoxCorner_r,Wall=BoxWall_t);
	MountingBoss(MH1[0],MH1[1],R=0.2) Bolt4Hole();
	MountingBoss(MH2[0],MH2[1],R=0.2) Bolt4Hole();
	MountingBoss(MH3[0],MH3[1],R=0.2) Bolt4Hole();
	MountingBoss(MH4[0],MH4[1],R=0.2) Bolt4Hole();
	
	// pcb
	//translate([-PCB_x/2,-PCB_y/2,BoxBot_h-PCB_t+Overlap]) cube([PCB_x,PCB_y,PCB_t]);
} // BoxBottom

//translate([0,0,-BoxBot_h]) BoxBottom();

RS232=[0.925,2.2,0.5]; // start,end,height
RJ45=[0.45,0.5,0.8,0.5]; // CL first, width, space, height
PowerCord_y=0.8;

module BoxTop(){
	difference(){
		
		translate([0,0,BoxTop_h]) mirror([0,0,1]) BoxShell(X=Box_x,Y=Box_y,Z=BoxTop_h,R=BoxCorner_r,Wall=BoxWall_t);
		
		translate([0,0,BoxTop_h]) {
		PCBRelPos(MH1[0],MH1[1]) Bolt4HeadHole();
		PCBRelPos(MH2[0],MH2[1]) Bolt4HeadHole();
		PCBRelPos(MH3[0],MH3[1]) Bolt4HeadHole();
		PCBRelPos(MH4[0],MH4[1]) Bolt4HeadHole();
		}
		
		translate([-PCB_x/2+RS232[0],-Box_y/2-Overlap,-Overlap]) cube([RS232[1]-RS232[0],BoxWall_t+Overlap*2,RS232[2]]);
		
		translate([-PCB_x/2+RJ45[0]-RJ45[1]/2,Box_y/2-BoxWall_t-Overlap,-Overlap])
			for (j=[0:7]) translate([j*RJ45[2],0,0]) cube([RJ45[1],BoxWall_t+Overlap*2,RJ45[3]]);
				
		translate([Box_x/2-BoxWall_t-Overlap,-PCB_y/2+PowerCord_y-0.1,-Overlap]) cube([BoxWall_t+Overlap*2,0.2,0.2]);
	} // diff
	
	MountingBossTop(MH1[0],MH1[1],R=0.2) Bolt4HeadHole(lDepth=BoxTop_h);
	MountingBossTop(MH2[0],MH2[1],R=0.2) Bolt4HeadHole(lDepth=BoxTop_h);
	MountingBossTop(MH3[0],MH3[1],R=0.2) Bolt4HeadHole(lDepth=BoxTop_h);
	MountingBossTop(MH4[0],MH4[1],R=0.2) Bolt4HeadHole(lDepth=BoxTop_h);

} // BoxTop 

//BoxTop();

























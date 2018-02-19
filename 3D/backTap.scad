$fn = 100;

// Variable declarations
h = 20;
a = 21; //20.8 
a1 = 20.4; // 21.4 (100% pla, base expanse)

aTap = 25;
aIn = 10;
//aBat = 18.2;
aBat = 18.8;
aDim = 3;


/*
hTap = 10; //10x10 of aIn 
hIn = 20; //hTap + extra 10
hBase = 30;
*/
hTap = 5; //10x10 of aIn 
hIn = 10; //hTap + extra 5
hBase = 15;
hBat = 68.5;
hBatBaseConn = 1.5;
hBatBaseWallThick = 1;
hBatBase = hBatBaseWallThick*2+hBatBaseConn;
hChip = 23;
hBat1 = hBat+ hBatBase*2 + hChip;
aBatBaseBot = 7;
aBatBaseTop = 4;

aUSB = 10;
haUSB = 4;
offUSB = 2 + haUSB/2;

xHole = a/2 - 2.5;
yHole = 2;
aHole = 2;


module base(){
    union(){
        difference(){
            union(){
                //cylinder(r1=a1/2,r2=a/2,hBase);
                cylinder(r=a1/2,hBase);
                cylinder(r=aTap/2,h=hTap);
            }
            cylinder(r=aIn/2,h=hIn);
        }
        
        translate([0,aIn/2,aDim/2]){
        rotate([90,0,0])
            cylinder(r=aDim/2,h=aIn);
        }
    }
}

module slot() {
    difference(){
        // Outer Cylinder
        cylinder(r=a/2,h=hBat1);
        // Inner Cylinder
        translate([0,0,hBatBase])
            cylinder(r=aBat/2, h=hBat+hBatBase+hChip-hBatBaseWallThick);
    }
}      


module batteryTopBase() {
    difference() {
        difference() {
            slot();
            // Substract Lower Base connector
            translate([0,0,hBatBaseWallThick]) 
                cylinder(r=aBat/2,h=hBatBaseConn);
        }
        
        // Lower Base Entry
        intersection(){
            translate([-aBatBaseBot/2,-aBat/2,hBatBaseWallThick])
                cube([aBatBaseBot,aBat,hBatBaseConn+hBatBaseWallThick]);
            cylinder(r=aBat/2,h=hBatBase);
        }
    }
}

module batteryBotBase(){
    difference() {
        difference() {
            union() {
                batteryTopBase();
                // Add Upper Base connector
                translate([0,0,hBat1-hBatBase-hChip])
                    cylinder(r=aBat/2,h=hBatBase);
            }
            // Substract Upper Base connector
            translate([0,0,hBat1-hBatBaseWallThick-hBatBaseConn-hChip])
                cylinder(r=aBat/2,h=hBatBaseConn);
        }
        
        // Upper Base Entry
        intersection(){
            translate([-aBatBaseTop/2,-aBat/2,hBat1-hBatBase-hChip])
                cube([aBatBaseTop,aBat,hBatBase]);
            translate([0,0,hBat1-hBatBase-hChip])
                cylinder(r=aBat/2,h=hBatBase);
        }
        
    }
}

module battery() {
    difference(){
        difference() {
            difference() {
                batteryBotBase();
                // Semi Cylinder
                translate([-a/2,0,0])
                    cube([a,a,hBat1]);
            }
            // USB Hole
            translate([0,-offUSB,hBat1-hBatBaseWallThick]) {
                scale([aUSB,haUSB,1]) cylinder(r=0.5, h=hBatBase); 
            }
        }
        // Wire Hole
        translate([xHole,-yHole,hBat1-hBatBaseWallThick]) {
            cylinder(r=aHole/2, h=hBatBase); 
        }
    }
}


translate([0,0,hBase]) battery();
base();











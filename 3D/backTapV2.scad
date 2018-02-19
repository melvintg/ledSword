$fn = 100;

// Variable declarations
h = 20; // ?
a = 21;
a1 = 20.4; // 21.4 (100% pla, base expanse)

aTap = 25;
aIn = 10;
aBat = 18.8;
aDim = 3;

hTap = 5;
hIn = 10;
hBase = 15;
hBat = 65.5;



hBatBaseConn = 1.5;
hBatBaseWallThick = 1;
hBatBase = hBatBaseWallThick*2+hBatBaseConn;


hChip = 46;
aChip = 15.5;
pChip = 6;

hBatOut = hBat+ hBatBase*2 + hChip - hBase;
hBatIn = hBatOut - hBatBaseWallThick;

aBatConnEntry = 4;

hGate = 16;
hGateBot = 5;
aGateGap = 16.5;
pGateGap = 3.5;


module base(){
    difference(){
        union(){
            difference(){
                union(){
                    cylinder(r=a1/2,hBase);
                    cylinder(r=aTap/2,h=hTap);
                }
                cylinder(r=aIn/2,h=hIn);
            }
            /*
            // 1.5 of padding for hole
            translate([-aIn/2,1.5,aDim/2]){
                rotate([90,0,90])
                cylinder(r=aDim/2,h=aIn);
            }
            */
        }
        // 2.2 of padding for hole
        translate([-aChip/2,-aDim/2-pChip+2.2,0])
            cube([aChip,pChip,hChip]);
    }
}
/*
translate([-aChip/2,aDim/2,0])
cube([aChip,pChip,hChip]);
*/
//base();

module slot() {
    difference(){
        // Outer Cylinder
        cylinder(r=a/2,h=hBatOut);
        // Inner Cylinder
        cylinder(r=aBat/2, h=hBatIn);
    }
}

module batteryBotBase(){
    difference() {
        difference() {
            union() {
                slot();
                // Add Bottom Base connector (above chip)
                translate([0,0,hChip-hBase])
                    cylinder(r=aBat/2,h=hBatBase);
            }
            // Substract Base connector
            translate([0,0,hBatBaseWallThick+hChip-hBase])
                cylinder(r=aBat/2,h=hBatBaseConn);
        }

        // Substract Base Entry
        translate([-aBatConnEntry/2,-aBat/2,hChip-hBase])
            cube([aBatConnEntry,aBat,hBatBase]);
    }
}



module batteryTopBase() {
    difference() {
        difference() {
            union() {
                batteryBotBase();
                // Add Top Base connector
                translate([0,0,hBatOut-hBatBase])
                    cylinder(r=aBat/2,h=hBatBase);
            }
            // Substract Base connector
            translate([0,0,hBatOut-hBatBase+hBatBaseWallThick])
                cylinder(r=aBat/2,h=hBatBaseConn);
        }
        // Substract Base Entry
        translate([-aBatConnEntry/2,-aBat/2,hBatOut-hBatBase])
            cube([aBatConnEntry,aBat,hBatBase]);
    }
}

module battery() {
    difference() {
        batteryTopBase();
        // Semi Cylinder
        translate([-a/2,0,0])
            cube([a,a,hBatOut]);
    }
}


module gate() {
    difference(){
        difference(){
            // Outer Cylinder
            cylinder(r=a1/2,h=hGate);
            // Bottom Gate Semi Cylinder
            translate([-a1/2,0,0])
                cube([a1,a1,hGateBot]);
        }
        // Gap
        translate([-aGateGap/2,0,0])
        cube([aGateGap,pGateGap,hGate]);
        
    }
}

translate([0,0,hBase+hBatOut]) gate();
translate([0,0,hBase]) battery();
base();


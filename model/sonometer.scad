//-----------------------------------
// Configuration
//-----------------------------------

// Precission
$fn=100;

// Model size
model_size=100;

// Circle types (count, inner, outer)
circle = [
    [60, 71.5, 79.5],
    [24, 35.5, 43.5]
];

// Size of an individual LED
led_side=6;

// Shift LED circle 
led_shift = 0;

// Holes radius (half of metric: M3, M4...)
hole_size=2; // M4

// Hole distance to edge
hole_distance=5;

// Minkowski radius
chamfer_size=4;

// Gap between pieces
gap = 5;

// Gap between 3d pieces
gap3d = 3;

//-----------------------------------
// DO NOT TOUCH BELOW THIS LINE
//-----------------------------------

//-----------------------------------
// Components
//-----------------------------------

module base() {
    
    difference() {
        
        // Shape
        minkowski() {
            square(model_size-2*chamfer_size, true);
            circle(chamfer_size);
        }

        // Holes
        for(i=[0:3]) {
            rotate(90*i) {
                translate([model_size/2-hole_distance,model_size/2-hole_distance,0]) {
                    circle(hole_size, center=true);
                }
            }
        }

    }
}

module led_circle_negative(type, led_side, shift) {

    count = circle[type][0];
    inner = circle[type][1];
    outer = circle[type][2];
    radius = (inner + outer)/2;

    for (i=[0:count]) {
        rotate(360 * (i+shift) / count)
            translate([0, radius])
                square([led_side, led_side], true);
    }

}
    
module potentiometer_negative(mark=0, body=0) {
    if (body==0) circle(4);
    if (mark) {
        translate([7.5,0,0])
            square([1,2.5], true);
        translate([-7.5,0,0])
            square([1,2.5], true);
    }
    if (body==1) circle(16);
}

module mic_negative(body=0) {
    union() {
        circle(5);
        if (body==1) square([12,3], true);
    }
}

module wall_hole() {
    rotate(180)
        minkowski() {
            square([0.1,15]);
            circle(3);
        }
}

module socket_hole() {
    circle(11.4/2);
}

//-----------------------------------
// Layers
//-----------------------------------

module layer_front() {
    difference() {
        base();
        translate([0, -15]) potentiometer_negative(0);
        translate([0, 15]) mic_negative(0);
    }
}

module layer_grid(mark) {
    difference() {
        base();
        led_circle_negative(1, led_side, led_shift);
        translate([0,-15]) potentiometer_negative(mark,0);
        translate([0,15]) mic_negative(0);
    }
}

module layer_cast(hole) {
    difference() {
        base();
        difference() {
            circle(circle[1][2], center=true);
            circle(circle[1][1], center=true);
        }
        translate([0,-15]) potentiometer_negative(1,hole);
        translate([0,15]) mic_negative(1);
    }
}

module layer_support() {

    difference() {
        
        base();
        
        inner = circle[1][1];
        outer = circle[1][2];
        
        difference() {
            circle(outer, center=true);
            circle(inner, center=true);
            for (i=[0:3]) rotate(90*i) {
                translate([model_size/2, model_size/2 ]) {
                    square(model_size/1.3, true);
                }
            }
        }

        translate([0,-15]) potentiometer_negative(1,1);
        translate([0,15]) mic_negative(1);

    }

}

module layer_hollow() {
    difference() {
        base();
        difference() {
            square(model_size-2*hole_distance,true);
            for(i=[0:3]) 
                rotate(90*i)
                    translate([
                        model_size/2-hole_distance,
                        model_size/2-hole_distance
                    ])
                        circle(5);
        }
    }
}

module layer_hollow_cutout() {
    difference() {
        layer_hollow();
        translate([0,-model_size/2,0]) square([22,10], true);
    }
}

module layer_back_wall() {
    difference() {
        base();
        translate([-model_size/2 + 15, model_size/2 - 25,0]) wall_hole();
        translate([model_size/2 - 15, model_size/2 - 25,0]) wall_hole();
    }
}

//-----------------------------------
// Layers to render
//-----------------------------------

// acrylic-transparent-3mm ----------
//layer_front(); 

// paper-black ----------------------
layer_grid(0);

// paper-white ----------------------
//layer_front(); 

// wood-4mm -------------------------
/*
for(x=[0:1]) for(y=[0:1]) {
    translate([
        (model_size + gap) * x,
        (model_size + gap) * y
    ]) layer_hollow();
}
translate([
    (model_size + gap) * 2,
    (model_size + gap) * 0
]) layer_hollow_cutout();
*/

// wood-2.5mm -----------------------
/*
translate([
    (model_size + gap) * 0,
    (model_size + gap) * 0
]) layer_grid(1);
translate([
    (model_size + gap) * 1,
    (model_size + gap) * 0
]) layer_cast(1);
translate([
    (model_size + gap) * 0,
    (model_size + gap) * 1
]) layer_support();
translate([
    (model_size + gap) * 1,
    (model_size + gap) * 1
]) layer_back_wall();
translate([
    (model_size + gap) * 2,
    (model_size + gap) * 0
]) layer_cast(1);
*/

// 3D ------------------------------
/*
translate([0,0, 0.0]) linear_extrude(2.5) layer_back_wall(); 
translate([0,0, 2.5]) linear_extrude(  4) layer_hollow_cutout(); 
translate([0,0, 6.5]) linear_extrude( 16) layer_hollow(); 
translate([0,0,32.0]) linear_extrude(2.5) layer_support();
translate([0,0,42.0]) linear_extrude(2.5) layer_cast(1);
translate([0,0,52.0]) linear_extrude(2.5) layer_cast(1);
translate([0,0,62.0]) linear_extrude(2.5) layer_grid(1);
*/
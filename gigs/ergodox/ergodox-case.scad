include <kle/ergodox-layout.scad>
include <../../scad-lib/keyboard-case.scad>

function perfect_edge(x) = x + plate_screw_offset + wall_thickness;

case_radius=5.0;
wall_thickness=2;
plate_thickness=1.7;
cherry_clip_recess_depth = 0;
my_screw_rad_offset=1.0;
plate_screw_offset = screw_rad + my_screw_rad_offset + plate_thickness;
$fa = 1;
$fs = $preview ? 1 : 2;
bezier_precision = $preview ? 0.05 : 0.025;
heat_set_insert_diameter = 5.1;
standoff_rad = 5;
bottom_case_height = 15;
micro_usb_stabilizer_pad_bottom=1.2;
micro_usb_hole_yOffset = 0;
micro_usb_pcb_height = 15.8;
micro_usb_screw_y = -2.7;





// Hacky way to select just the left hand keys from split iris/redox layout
left_keys = [ for (i = ergodox_layout) if (key_pos(i).x < 10) i ];

/////////////////////////////////////////
// Rudimentary ergodox case. Untested
/////////////////////////////////////////
ex0 = 88;
ey0 = -104;
ex1 = 0;
ey1 = 0;
ex2 = 144;
ey3 = -70;
ex3 = 183.5;
ey4 = -93;
ex4 = 155.0;
ey5 = -143;
ergodox_reference_points = [
    [ex0, ey0], // Bottom mid
    [ex1, ey0], // Bottom left
    [ex1, ey1], // Top left
    [ex2, ey1], // Top right
    [ex2, ey3], // Mid right
    [ex3, ey4], // Right
    [ex4, ey5], // Bottom
    ];
ergodox_screw_holes = [
    [ex1, ey0], // Bottom left
    [ex1, ey1], // Top left
    [ex2, ey1], // Top right
    [ex3, ey4], // Right
    [ex4, ey5], // Bottom
    ];
ergodox_tent_positions = [
    [[155,-25,0],0,13],
    [[181.3,-120,0],-29.7,13.2]
    ];

module profile(fits_in_walls=false) {
    module offset_() {
        if (fits_in_walls) {
            offset(delta = plate_screw_offset, chamfer = true)
                children();
        } else {
            offset(r = plate_screw_offset + wall_thickness, chamfer = false)
                children();
        }
    }
    fillet(r = case_radius, $fn = 20) {
        offset_()
        polygon(points = ergodox_reference_points, convexity = 3);
    }
}
module ergodox_outer_profile() {
    profile(fits_in_walls=false);
    //fillet(r = case_radius, $fn = 20)
    //    offset(r = plate_screw_offset + wall_thickness, chamfer = false)
    //    polygon(points = ergodox_reference_points, convexity = 3);
}
module plate_profile() {
    profile(fits_in_walls=true);
    //fillet(r = case_radius, $fn = 20)
    //    offset(delta = plate_screw_offset, chamfer = true)
    //    polygon(points = ergodox_reference_points, convexity = 3);
}
module ergodox_top_case() {
    top_case(left_keys, ergodox_screw_holes, raised = true, without_plate=true) {
        ergodox_outer_profile();
        plate_profile();
    }
}
module ergodox_plate() {
    plate(left_keys, ergodox_screw_holes) plate_profile();
}
module ergodox_bottom_case() {
    micro_usb_pos = [ex2 - 20, perfect_edge(ey1 - micro_usb_stickout - wall_thickness), wall_thickness + micro_usb_stabilizer_pad_bottom];
    micro_usb_rot = [0,0,0];
    phone_pos = [ex2, ey1 - 50, wall_thickness + phone_width/2];
    phone_rot = [0,90,-90];

    module micro_usb_position() {
        translate(micro_usb_pos)
            rotate(micro_usb_rot)
            children();
    }
    difference() {
        union() {
            bottom_case(ergodox_screw_holes, ergodox_tent_positions, heat_set_insert=true)
            ergodox_outer_profile();
            micro_usb_position()
                translate([0, 0, -micro_usb_stabilizer_pad_bottom])
                micro_usb_stabilizer(front_wall_thickness=1.3, front_wall_height=10, front_pad=2);
        }
        
        translate([0, 0, bottom_case_height - plate_thickness])
            linear_extrude(height=plate_thickness + 0.1) plate_profile();
        micro_usb_position() {
            micro_usb(hole=true);
            %micro_usb();
        }
        ignore() translate(phone_pos)
            rotate(phone_rot) {
                phone_connector_hole(hole=true);
                //phone_connector_hole(hole=false);
            }
    }
    
}

module partss(part, explode=0, with_extras=true) {
    if (part == "outer") {
        offset(r = -2.5) // Where top of camber would come to
            ergodox_outer_profile();
        for (pos = ergodox_screw_holes) {
            translate(pos) {
                polyhole2d(r = 3.2 / 2);
            }
        }
        #key_holes(left_keys);
        
    } else if (part == "top") {
        ergodox_top_case();
    } else if (part == "plate") {
        ergodox_plate();
    } else if (part == "bottom") {
        ergodox_bottom_case();
    } else {
        if (with_extras) {
            translate([0, 0, plate_thickness + 2 * explode]) key_holes(left_keys, "keycap");
            translate([0, 0, plate_thickness + 2 * explode]) key_holes(left_keys, "switch");
        }
        translate([0, 0, plate_thickness + 1 * explode]) ergodox_top_case();
        translate([0, 0, 0]) ergodox_plate();
        translate([0, 0, plate_thickness -bottom_case_height -1 * explode]) ergodox_bottom_case();
    }
}

module tester(part, pt2, explode=0) {
   if (part == "micro-usb-house-test") {
       intersection() {
           ergodox_bottom_case();
           #translate([124, 0])
               cube([20, 30, 40], center=true);
       }
   } else if (part == "sandwich-test") {
        intersection() {
            if (pt2 == "bottom") {
                ergodox_bottom_case();
            } else if (pt2 == "top") {
                ergodox_top_case();
            } else if (pt2 == "plate") {
                ergodox_plate();
            } else {
                partss("assembly", with_extras=false);
            }
            #translate([0, 0])
                cube([50, 50, 40], center=true);
        }
    } else {
        partss(part, explode=explode);
    }
}

//tester("assembly", explode=20);
//tester("assembly");
//tester("micro-usb-house-test");
//micro_usb_stabilizer(front_pad=2);
tester("bottom");
//switch_hole();

// Requires my utility functions in your OpenSCAD lib or as local submodule
// https://github.com/Lenbok/scad-lenbok-utils.git
use<../../scad-lib/Lenbok_Utils/utils.scad>

include <../../scad-lib/keyboard-case.scad>
include <./led-housing.scad>

key_spacing=19.05;
function key_pos(key) = key[0];
function key_size(key) = key[1];
module position_key(key, unit = key_spacing) {
    translate((key_pos(key) + key_size(key) / 2) * unit) children();
}

plate_thickness=1.5;
plate_screw_margin=5;
bottom_case_height = 14.5;
cherry_clip_recess_width=0;
led_count = 4;
heat_set_insert_diameter=5.0;
case_radius=5;
standoff_rad = 5;


keys_row_count=3.5;
keys_col_count=4;
keys_matrix_positions = [ //order: [col,row]
    [0,0],
    [0,1.5], [1,1.5], [2,1.5], [3,1.5],
    [0,2.5], [1,2.5], [2,2.5], [3,2.5],
];
leds_position = [2,0] * key_spacing;
keys = [ for (p=keys_matrix_positions) [p, [1,1]] ];
screw_x_span = keys_col_count*key_spacing;
screw_y_span = keys_row_count*key_spacing;
plate_width = screw_x_span + 2*plate_screw_margin;
plate_height = screw_y_span + 2*plate_screw_margin;
screws=let (w=screw_x_span, h=screw_y_span) [
    [0,0],
    [screw_x_span,0],
    [w,-h],
    [0, -h],
];

function perfect_edge(x) = x + plate_screw_margin + wall_thickness;

micro_usb_pos = [30, perfect_edge(0 - micro_usb_stickout - wall_thickness), wall_thickness + 0];
micro_usb_rot=[0,0,0];

use<../../scad-lib/Lenbok_Utils/utils.scad>


//takes a shape and cuts out a space for a housing that contains multiple LED bulbs
module add_led_housing() {
    difference() {
        children();
        translate(leds_position) {
            led_housing(hole=true);
            %led_housing(hole=false);
        }
    }
}

module profile(fits_in_walls=false) {
    module offset_() {
        if (fits_in_walls) {
            offset(delta = plate_screw_margin, chamfer = true)
                children();
        } else {
            offset(r = plate_screw_margin + wall_thickness, chamfer = false)
                children();
        }
    }
    fillet(r = case_radius, $fn = 20) {
        offset_()
        polygon(points = screws, convexity = 3);
    }
}
module outer_profile() {
    profile(fits_in_walls=false);
    //fillet(r = case_radius, $fn = 8)
    //    offset(r = plate_screw_margin + wall_thickness, chamfer = false)
    //    polygon(points = screws, convexity = 3);
}
module my_top() {
    add_led_housing()
        top_case(keys, screws, raised=false, without_plate=false)
        outer_profile();
}

module my_plate() {
    add_led_housing()
        plate(keys, screws)
        profile(fits_in_walls=true);
}

module my_bottom() {
    echo(micro_usb_pos);
    module micro_usb_position() {
        translate(micro_usb_pos)
            rotate(micro_usb_rot)
            children();
    }
    difference() {
        bottom_case(screws, heat_set_insert=true)
            outer_profile();
        translate([0,0,bottom_case_height - plate_thickness])
            linear_extrude(height=plate_thickness + 2)
            profile(fits_in_walls=true);
        micro_usb_position()
            translate([0, 0, micro_usb_stabilizer_pad_bottom]) {
                micro_usb_hole(hole=true);
                %micro_usb_hole(hole=false);
            }
    }
    micro_usb_position()
        micro_usb_stabilizer();
}

module my_screen(hole=false) {
    pcb_w = 60;
    pcb_h = 15;
    pcb_d = 2;
    lcd_w = 50;
    lcd_h = 10;
    lcd_d = 4;
    lcd_pos = [0, 0, pcb_d];
    color("green") cube([pcb_w, pcb_h, pcb_d], center=true);
    translate(lcd_pos) color("darkblue") cube([lcd_w, lcd_h, lcd_d], center=true);
    if (hole) {
        %translate([0, 0, (pcb_d + lcd_d)/2]) translate(lcd_pos) cube([lcd_w, lcd_h, lcd_d + 5], center=true);
    }
}

module led_socket(led_r=3, type="hole") {
    k = 1.5;
    led_window_h = 1.5;
    led_h=plate_thickness + led_window_h;
    translate([0,0,-led_h+led_window_h]) difference() {
        cylinder(led_h+k, r=led_r+k, $fn=6);
        if (type == "socket") {
            translate([0,0,led_h - led_window_h]) linear_extrude(height=led_window_h) let (x=2*(led_r+k+1)) {
                polygon([
                    [0,0],
                    [-x,-x],
                    [x,-x],
                ]);
            };
            translate([0,0,-0.1]) cylinder(led_h+0.1, r=led_r);
        } else if (type == "hole") {
        }
    }
}

explode=0;
//%translate([0, 0, plate_thickness + 3 * explode]) key_holes(keys, "keycap");
//%translate([0, 0, plate_thickness + 2 * explode]) key_holes(keys, "switch");

//led_housing();
#translate([0,0,-plate_thickness]) my_plate();
difference() {
    translate([0,0,-bottom_case_height]) my_bottom();
    
    translate([0, 0, plate_thickness + 2 * explode]) key_holes(keys, "switch");
}

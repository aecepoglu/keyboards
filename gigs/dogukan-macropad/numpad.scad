include <../../scad-lib/keyboard-case.scad>
//include <layout.scad>
use<../../scad-lib/Lenbok_Utils/utils.scad>

padding=10;
key_spacing=19.05;
plate_width = 77.152;
plate_height = 77.152;
heat_set_insert_diameter=5.0;
function key_pos(key) = key[0];
function key_size(key) = key[1];
module position_key(key, unit = key_spacing) {
    translate((key_pos(key) + key_size(key) / 2) * unit) children();
}
module pos_correct() {
    translate([-padding/2, padding/2 - plate_height,0])
        children();
}

plate_thickness=1.5;
keys_matrix_positions = [ //order: [col,row]
    [0,0], [1,0], [2,0],
    [0,1], [1,1], [2,1],
    [0,2], [1,2], [2,2]
];
col_count = 3;
row_count = 3;
keys = [ for (p=keys_matrix_positions) [p, [1,1]] ];
plate_screw_margin = 5;
screw_x_span = col_count*key_spacing + padding;
screw_y_span = col_count*key_spacing + padding;
screws=let (w=screw_x_span, h=screw_y_span) [
    [0,0],
    [screw_x_span,0],
    [w,-h],
    [0, -h],
];

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

module generic_plate(filename, thickness) {
    linear_extrude(height=thickness)
        import(file=filename);
}

module switch_plate() {
    //pos_correct()
        color("#555")
        translate([-5,5-plate_width,0])
        generic_plate("macropad_top.dxf", plate_thickness);
}

module my_bottom() {
    difference() {
        bottom_case(screws, heat_set_insert=true)
            outer_profile();
        translate([0,0,bottom_case_height - plate_thickness])
            linear_extrude(height=plate_thickness + 2)
            profile(fits_in_walls=true);
    }
}

explode=0;
rotate([0,0,0]) {
    translate([5, -5, bottom_case_height + 3*explode]) {
         
        key_holes(keys, "keycap");
        key_holes(keys, "switch");
    }
    
    translate([0, 0, bottom_case_height + 2*explode]) switch_plate();
    translate([0, 0, 0]) my_bottom();
    
}
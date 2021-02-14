include <../../scad-lib/keyboard-case.scad>
include <elifcan-layout.scad>
use<../../scad-lib/Lenbok_Utils/utils.scad>

cherry_clip_recess_width=0;
heat_set_insert_diameter=5.0;

padding=10;
width=348.614;
height=115.252;
lid_thickness=3;
lid_meat_thickness=10;
top_plate_thickness=top_case_raised_height;
plate_thickness=1.5;
mid_thickness=8;
bottom_plate_thickness=3.0;
micro_usb_stabilizer_pad_bottom=1.5;
micro_usb_screw_y = -1.7;
micro_usb_hole_width = 8.5;
micro_usb_hole_height = 4;
micro_usb_screw_rad=micro_usb_screw_dia/2;
micro_usb_pcb_height=14.8 + 0.40;
echo("expected width of opening in mid section is ", micro_usb_pcb_width + micro_usb_stabilizer_pad_bottom*2);

//screws=let (w=screw_x_span, h=screw_y_span) [
//    [0,0],
//    [screw_x_span,0],
//    [w,-h],
//    [0, -h],
//];
//function perfect_edge(x) = x + plate_screw_margin + wall_thickness;
//micro_usb_pos = [30, perfect_edge(0 - micro_usb_stickout - wall_thickness), wall_thickness + micro_usb_stabilizer_pad_bottom];
//micro_usb_rot=[0,0,0];

module pos_correct() {
    translate([-padding/2, -height+padding/2,0])
        children();
}

module generic_plate(filename, thickness) {
    linear_extrude(height=thickness)
        import(file=filename);
}

module lid() {
    k=lid_meat_thickness;
    union() {
        translate([0, 0, k + 0])
            pos_correct()
            generic_plate("lid-cover.dxf", lid_thickness);
        pos_correct()
            generic_plate("lid-meat.dxf", k);
    }
}

module top_plate() {
    pos_correct()
        generic_plate("top.dxf", top_plate_thickness);
}

module switch_plate() {
    pos_correct()
        color("#555")
        generic_plate("switch.dxf", plate_thickness);
}

module mid_plate() {
    pos_correct()
        generic_plate("open.dxf", mid_thickness);
}

module bottom_plate() {
    difference() {
        pos_correct()
            color("#555") {
                generic_plate("bottom.dxf", bottom_plate_thickness);
            }
        place_micro_usb() {
            micro_usb_hole(hole=false, screw_hole=true);
        }
    }
}

module place_micro_usb() {
    dx = 119; //offset from center
    translate([0,- micro_usb_stickout,bottom_plate_thickness])
    translate([width/2 + dx - padding/2,padding/2,0]) {
        children();
    }
}

explode=0;
has_lid=true;
has_top=true;
rotate([0,0,0]) {
    translate([padding/2, -padding/2, (3 + (has_top ? 2 : 0))*explode + (plate_thickness + mid_thickness + bottom_plate_thickness)]) {
         
        key_holes(elifcan_keys, "keycap");
        key_holes(elifcan_keys, "switch");
    }
    #if (has_lid) translate([0, 0, 4*explode + (plate_thickness + mid_thickness + bottom_plate_thickness + top_plate_thickness)]) lid();
    if (has_top) translate([0, 0, 3*explode + (plate_thickness + mid_thickness + bottom_plate_thickness)]) top_plate();
    translate([0, 0, 2*explode + (mid_thickness + bottom_plate_thickness)]) switch_plate();
    translate([0, 0, 1*explode + bottom_plate_thickness]) mid_plate();
    translate([0, 0, 0]) bottom_plate();
    translate([0, 0, 0.5*explode]) place_micro_usb() difference() {
        micro_usb_stabilizer(has_protrusions=false, front_wall_height=mid_thickness);
        translate([0, 0, micro_usb_stabilizer_pad_bottom]) {
            micro_usb_hole(hole=true, screw_hole=true);
            %micro_usb_hole(hole=false, screw_hole=explode > 1);
        }
    }
}

ignore() difference() {
    micro_usb_stabilizer(has_protrusions=false, front_wall_height=mid_thickness, front_wall_thickness=1);
    translate([0, 0, micro_usb_stabilizer_pad_bottom]) {
        micro_usb_hole(hole=true, screw_hole=true);
        #translate([0, 0, 0]) micro_usb_hole(hole=false, screw_hole=true);
    }
}
echo("mid layer thickness", mid_thickness);
echo("top layer thickness", top_plate_thickness);
echo("lid thickness", lid_thickness);
echo("lid meat thickness", lid_meat_thickness);

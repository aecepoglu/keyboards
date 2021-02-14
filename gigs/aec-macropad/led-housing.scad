
screen_w = 29.5;
screen_h = 11.4;
led_d = 7;
led_h = 5;
pay=0.1;

module led_housing(count=led_count, d=led_d, h=led_h, margin=1, hole=false) {
    box_h = max(d + 2*margin, screen_h + 2*pay);
    box_w = max(margin + count * (d + margin), screen_w + 2*pay);
    wing_thickness = 1;
    wing = 2;
    stickout = 0;

    color(hole ? "white" : "grey")
        translate([0, -box_h, stickout + plate_thickness-h])
        difference() {
            union() {
                cube([box_w, box_h, h + (hole ? 1 : 0)]);
                translate([-wing, -wing, h - wing_thickness - plate_thickness - stickout])
                    cube([box_w + 2*wing, box_h + 2*wing, wing_thickness]);
            }
            if (!hole)
            let (h_ = h + 1) { //some extra so it can be diff'ed cleanly
                for (i=[0:count-1]) {
                    translate([
                        d/2 + margin + i*(d + margin),
                        d/2 + margin,
                        0.2 + h - h_
                    ])
                        rotate_extrude(angle=360)
                        intersection() {
                            round(r=margin) square([d, 2*h_], center=true);
                            square([d, h_ + 1]);
                        }
                }
            }
        }
}
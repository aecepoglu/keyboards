
// Functions to extract from the raw data structure, not sized to units
function key_pos(key) = key[0];
function key_size(key) = key[1];
function key_rot(key) = key[2];
function key_rot_angle(key) = key_rot(key)[0];
function key_rot_off(key) = key_rot(key)[1];

// Put a child shape at the appropriate position for a key, incorporating unit sizing
module position_key(key, unit = 19.05) {
    pos = (key_pos(key) + key_size(key) / 2) * unit;
    rot_off = key_rot_off(key) * unit;
    translate(rot_off) rotate([0, 0, key_rot_angle(key)]) translate(-rot_off)
        translate(pos)
        children();
}

keys = [
    [[0, 0], [1, 1], [0, [0, 0]]], /*  */
    [[1, 0], [1, 1], [0, [0, 0]]], /*  */
    [[2, 0], [1, 1], [0, [0, 0]]], /*  */
    [[3, 0], [1, 1], [0, [0, 0]]], /*  */
    [[0, 1], [1, 1], [0, [0, 0]]], /*  */
    [[1, 1], [1, 1], [0, [0, 0]]], /*  */
    [[2, 1], [1, 1], [0, [0, 0]]], /*  */
    [[3, 1], [1, 1], [0, [0, 0]]], /*  */
];

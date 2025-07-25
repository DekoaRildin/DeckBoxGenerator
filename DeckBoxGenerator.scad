//
// DeckBoxGenerator v 1.0
//
// Author: Dekoa
//
// A customizable Deck Box Generator for OpenSCAD. 
//
// <<Requirements>>
//  OpenSCAD http://www.openscad.org
//  BOSL2 Library (Included with DeckBoxGenerator) https://github.com/revarbat/BOSL2
//
// <<Licensing>>
//  DeckBoxGenerator and the Included BOSL2 Library are licensed under the BSD 2-Clause License
//
// <<How to Use>>
//  This script will generate a TCG Deck Box based off of the dimensions provided within the
//  Configuration parameters. Size is primarily calculated per Inner Deck Box Measurements, Commander
//  slot Measurements, Thickness of the Walls, and Lid. Caution and proper backups are encouraged if 
//  modifying the original OpenSCAD file. When utilizaing in the OpenSCAD Program itself, the parameters 
//  are listed in the Customizer window. It is recommended to make any modifications to your deck box 
//  here. The default parameters is set up to have a larger than normal commander slot along the lid 
//  being secured by a Dovetail method, 3 magnets help hold the lid in place, while each side has either
//  simple coin depressions for decorations, or a plate depression for custom decoration as well. Please 
//  note that if parameters are non compliant (I.E. various components collide or are too big or too 
//  small), that the script's behavior will try and render it and may error out. Reset to Default 
//  parameters in order to start over.
//
// <<Important Notes!!>>
//  Deck Box Size is rendered based off IDB Parameters, Wall thickness, Commander Slot, and Lid Thickness.
//  If IDB or Commander is Shorter in Z-Axis than the other, Z-Axis Size takes Larger of the two.
//  Shorter Z-Axis Measurement between IDB or Commander will have Infil from the Bottom.
//  Wall thickness between Commander and IDB is Half of the box_wall_thick parameter.
//  Rounding/Clipping applies to Outer Box and Lid Only.
//  Rounding will apply over Clipping if both are Selected.
//  Side 1 is Y-Axis side closest to Origin.
//  Side 2 is X-Axis side furthest from Origin.
//  Side 3 is Y-Axis side furthest from Origin.
//  Side 4 is X-Axis side closest to Origin.
//  If commander Display is needed for slot, Apply Plate to side 4 and use corresponding depth.
//
// <<Minor Version Improvements>>
//  Build in slop tolerance
//  Build in box_lid_cut variable between 10% and 75% to adjust how much the lid cuts into the sides (default: 25%)
//  Able to Imprint Text onto Sides instead of plate
//  Able to Imprint Text onto Lid
//  Able to add Glass Pane slot for Commander Slot
//  Optimize, Function/Modularize, and change Move geometry to Translate Geometry (Highest Priority)
//  Gridfinity base?
//  Separate more Box Lid stuff in Variables
//
// <<Major Version Improvements>>
//  Stackable Box/Lid Concept (requires slop tolerance)
//  Trinket/Die box Add On (Requires Stackable Box/Lid)
//  Commander Slot in Lid Version (requires Optimization)
//  Commander Slot able to be moved to other sides (Requires Optimization)
//  Add ability to imprint images/Logos
//

echo(dbg_version="1.0");
include <BOSL2/std.scad>
include <BOSL2/polyhedra.scad>
echo(bosl_version=bosl_version_str());
bosl_required("2.0.716");
$fa=$preview ? 5 : 2;
$fs=$preview ? 0.5 : 0.2;

//
// Configuration
//

/* [What to Make] */
// Renders the Deck Box. Deselect to prevent rendering.
make_box=true;
// Renders the Box Lid. Deselect to prevent rendering.
make_lid=true;

/* [Inner Box Dimensions] */
// Inner Deck Box length in the X-Axis Direction. Required.
idb_length_x=86;
// Inner Deck Box length in the Y-Axis Direction. Required.
idb_length_y=73;
// Inner Deck Box length in the Z-Axis Direction. Required.
idb_length_z=98;

/* [Deck Box Config] */
// Thickness of the Walls of the Box. Required.
box_wall_thick=5; 
// Adds a commander slot. Wall between IDB and this is Half wall Thickness.
box_commander_slot=true;
// Adds a Card Grab to Sides 1 and 3.
box_cardgrab=true;
// Width of the Card Grab Slot.
box_cardgrab_width=26;
// Depth of the Card Grab Slot.
box_cardgrab_height=40;

/* [Box Lid Config] */
// Thickness of the Box's Lid. Required.
box_lid_thick=9;
// Securing Method of the lid on X-Axis
box_lid_secure="dovetail"; //["none","groove","dovetail"]
// If true, removes back wall for lid slot. Adjust's Lid as well.
box_lid_noback=false;
// How many Magnet slots are in the Lid and Back Wall.
box_lid_magnet_amount=3; //[0,1,2,3,4,5]
// Depth into the wall/Lid for the Magnets.
box_lid_magnet_depth=3;
// Diameter of the Magnet Slots.
box_lid_magnet_diameter=7;
// Depth of the Lid Grab Divot. Set to 0 to Remove.
box_lid_divot_depth=4;
// Selection for Lid Feature.
box_lid_slot="coins"; //["none","coins","plate"]
// If Coins selected, how many showing.
box_lid_coinslots_amount=5; //[1,2,3,4,5,6,7,8]
// If Coins Selected, depth into lid.
box_lid_coinslots_depth=2;
// If Coins Selected, Diameter of coins.
box_lid_coinslots_diameter=21;
// If Coins Selected, Rotation in Degrees of where to render.
box_lid_coinslots_rotate=270; //[0:1:360]
// If Plate Selected, Width of Plate Insert, X-Axis.
box_lid_plateslot_width=81;
// If Plate Selected, Height of Plate Insert, Y-Axis.
box_lid_plateslot_height=68;
// If Plate Selected, Depth of Plate Insert into Lid, Z-Axis.
box_lid_plateslot_depth=2;

/* [Commander Slot Config] */
// Commander length in the X-Axis Direction.
cmd_length_x=76;
// Commander length in the Y-Axis Direction.
cmd_length_y=10;
// Commander length in the Z-Axis Direction.
cmd_length_z=112;

/* [Rounding/Clipping] */
// Rounds the Edges of the Deck box and Lid. Takes Priority.
edge_rounding=0; //[0:0.1:4]
// Clips/Chamfer's the Deck box and Lid.
edge_clipping=1.5; //[0:0.1:4]
// If Selected, will trim corners as well.
trim_corners=true;

/* [Deck Box Sides Config] */
// Selection for Side 1 Feature.
box_side1_slot="coins"; //["none","coins","plate"]
// If Coins selected, how many showing.
box_side1_coinslots_amount=5; //[1,2,3,4,5,6,7,8]
// If Coins Selected, depth into Side.
box_side1_coinslots_depth=2;
// If Coins Selected, Diameter of coins.
box_side1_coinslots_diameter=21;
// If Coins Selected, Rotation in Degrees of where to render.
box_side1_coinslots_rotate=90; //[0:1:360]
// If Plate Selected, Width of Plate Insert, Y-Axis.
box_side1_plateslot_width=65;
// If Plate Selected, Height of Plate Insert, Z-Axis.
box_side1_plateslot_height=90;
// If Plate Selected, Depth of Plate Insert into Side, X-Axis.
box_side1_plateslot_depth=2;
// Selection for Side 2 Feature.
box_side2_slot="plate"; //["none","coins","plate"]
// If Coins selected, how many showing.
box_side2_coinslots_amount=5; //[1,2,3,4,5,6,7,8]
// If Coins Selected, depth into Side.
box_side2_coinslots_depth=2;
// If Coins Selected, Diameter of coins.
box_side2_coinslots_diameter=21;
// If Coins Selected, Rotation in Degrees of where to render.
box_side2_coinslots_rotate=90; //[0:1:360]
// If Plate Selected, Width of Plate Insert, X-Axis.
box_side2_plateslot_width=65;
// If Plate Selected, Height of Plate Insert, Z-Axis.
box_side2_plateslot_height=90;
// If Plate Selected, Depth of Plate Insert into Side, Y-Axis.
box_side2_plateslot_depth=2;
// Selection for Side 3 Feature.
box_side3_slot="coins"; //["none","coins","plate"]
// If Coins selected, how many showing.
box_side3_coinslots_amount=5; //[1,2,3,4,5,6,7,8]
// If Coins Selected, depth into Side.
box_side3_coinslots_depth=2;
// If Coins Selected, Diameter of coins.
box_side3_coinslots_diameter=21;
// If Coins Selected, Rotation in Degrees of where to render.
box_side3_coinslots_rotate=90; //[0:1:360]
// If Plate Selected, Width of Plate Insert, Y-Axis.
box_side3_plateslot_width=65;
// If Plate Selected, Height of Plate Insert, Z-Axis.
box_side3_plateslot_height=90;
// If Plate Selected, Depth of Plate Insert into Side, X-Axis.
box_side3_plateslot_depth=2;
// Selection for Side 4 Feature.
box_side4_slot="plate"; //["none","coins","plate"]
// If Coins selected, how many showing.
box_side4_coinslots_amount=5; //[1,2,3,4,5,6,7,8]
// If Coins Selected, depth into Side.
box_side4_coinslots_depth=2;
// If Coins Selected, Diameter of coins.
box_side4_coinslots_diameter=21;
// If Coins Selected, Rotation in Degrees of where to render.
box_side4_coinslots_rotate=90; //[0:1:360]
// If Plate Selected, Width of Plate Insert, X-Axis.
box_side4_plateslot_width=65;
// If Plate Selected, Height of Plate Insert, Z-Axis.
box_side4_plateslot_height=90;
// If Plate Selected, Depth of Plate Insert into Side, Y-Axis.
box_side4_plateslot_depth=6;

//
// Hidden/Calculated Variables
//

// Spacing for Lid Placement
spacing = (idb_length_x + (box_wall_thick * 2)) * 1.75;
// Determines which Height is Greater
larger_height = idb_length_z > cmd_length_z ? idb_length_z : cmd_length_z;
// Full Box Dimensions X-Axis
box_length_x = idb_length_x + (box_wall_thick * 2);
// Full Box Dimensions Y-Axis, Determines if Commander slot or not
box_length_y = box_commander_slot ? idb_length_y + (cmd_length_y * 1.05) + (box_wall_thick * 2.5) : idb_length_y + (box_wall_thick * 2);
// Full Box Dimensions Z-Axis, Determines if Commander slot or not
box_length_z = box_commander_slot ? larger_height + box_wall_thick + box_lid_thick : idb_length_z + box_wall_thick + box_lid_thick;

//
// Generation
//

if(make_box) drawBox();
if(make_lid) left(spacing) drawLid();

/*
 * Box Generation Module
 * 
 * This module is used to Generate the Deck box.
 * Should not be called outside of this script.
 * TODO:
 *  Optimize and turn into further Modules
 */
module drawBox(){
    //Render Box with Commander Slot
    if (box_commander_slot) {
        //No Edge Rounding, No Edge Clipping
        if(edge_rounding == 0 && edge_clipping==0) {
            difference() {
                cuboid([box_length_x, box_length_y, box_length_z], anchor=FRONT+LEFT+BOT);
                //Calculate if Lid needs a Back or not per box_lid_noback
                box_lid_length_y = box_lid_noback ? box_length_y * 1.2 : box_length_y - box_wall_thick + 1.1;
                
                //If lid secure is Dovetail, Remove Lid
                if(box_lid_secure == "dovetail"){
                    move ([(box_wall_thick * 0.75), -0.1, box_length_z - box_lid_thick + 0.1]) prismoid(size1=[(idb_length_x + (box_wall_thick * 0.5)), box_lid_length_y],size2=[idb_length_x, box_lid_length_y], h=(box_lid_thick + .01), anchor=FRONT+LEFT+BOT);
                }
                //If lid secure is Groove, Remove Lid
                else if(box_lid_secure=="groove"){
                    move ([box_wall_thick, -0.1, box_length_z - box_lid_thick + 0.1]) cube([idb_length_x, box_lid_length_y, (box_lid_thick + .1)], anchor=FRONT+LEFT+BOT);
                    move ([(box_wall_thick * 0.75), -0.1, box_length_z - box_lid_thick + 0.1]) cube([(box_wall_thick * 0.25) + 0.1, box_lid_length_y, (box_lid_thick * 0.5)], anchor=FRONT+LEFT+BOT);
                    move ([(box_length_x - box_wall_thick - 0.1) , -0.1, box_length_z - box_lid_thick + 0.1]) cube([box_wall_thick * .25, box_lid_length_y, (box_lid_thick * 0.5)], anchor=FRONT+LEFT+BOT);
                }
                
                //If lid secure is none, Remove Lid
                else {
                    move ([box_wall_thick, -.1, box_length_z - box_lid_thick + 0.1]) cube([idb_length_x, box_lid_length_y, (box_lid_thick + .1)], anchor=FRONT+LEFT+BOT);
                }
                
                //remove IDB
                move ([box_wall_thick, ((box_wall_thick * 1.5) + cmd_length_y), box_length_z - box_lid_thick + 0.2]) cube([idb_length_x,idb_length_y,(idb_length_z + 0.2)], anchor=FRONT+LEFT+TOP);
                
                //remove Commander Slot
                move ([(((idb_length_x + (box_wall_thick * 2))- cmd_length_x)/2), box_wall_thick, box_length_z - box_lid_thick + 0.2]) cube([cmd_length_x,cmd_length_y,(cmd_length_z + .2)], anchor=FRONT+LEFT+TOP);
                
                //If Card Grab, Remove Card Grab
                if (box_cardgrab){
                    move([-0.1, box_length_y - box_wall_thick - (idb_length_y / 2), box_length_z - box_cardgrab_height]) xcyl(h=(box_length_x+10), r=(box_cardgrab_width/2), anchor=LEFT+BOT);
                    move([-0.1, box_length_y - box_wall_thick - (idb_length_y / 2), box_length_z - (box_cardgrab_height - (box_cardgrab_width / 2))]) cube([(box_length_x+10), box_cardgrab_width, box_length_z], anchor=LEFT+BOT);
                }
                
                //If Magnets, Remove Magnet Slots
                if (box_lid_magnet_amount > 0) {
                    box_lid_magnet_spacing = idb_length_x / box_lid_magnet_amount;
                    for(a = [1 : 1 : box_lid_magnet_amount]) {
                        move([box_wall_thick + ((idb_length_x/(box_lid_magnet_amount + 1)) * a), box_length_y - box_wall_thick - 0.1 + 1, box_length_z - (box_lid_thick / 2)]) ycyl(h=(box_lid_magnet_depth + 0.1), d=(box_lid_magnet_diameter + 0.1), anchor=FRONT);
                    }
                }
                
                //If Side 1 Slot is Plate and no Card Grab
                if (box_side1_slot == "plate" && box_cardgrab == false) {
                    move ([-0.1, (box_length_y/2), box_length_z/2]) cube([box_side1_plateslot_depth + 0.1, box_side1_plateslot_width, box_side1_plateslot_height], anchor=LEFT);
                }
                //If Side 1 Slot is Coins and no Card Grab
                else if (box_side1_slot == "coins" && box_cardgrab == false) {
                    min_length = box_length_y > box_length_z ? box_length_z : box_length_y;
                    coinslot_center_y = box_length_y/2;
                    coinslot_center_z = box_length_z/2;
                    coinslot_radius = (min_length / 2) - (box_side1_coinslots_diameter/2) - box_wall_thick;
                    coinslot_degree = 360 / box_side1_coinslots_amount;
                    //If more than 1 Coin
                    if (box_side1_coinslots_amount > 1) {
                        for(i = [1: 1 : box_side1_coinslots_amount]) {
                            move ([-0.1,coinslot_center_y + (coinslot_radius * cos(coinslot_degree*i+box_side1_coinslots_rotate)),coinslot_center_z + (coinslot_radius * sin(coinslot_degree*i+box_side1_coinslots_rotate))]) xcyl(h=box_side1_coinslots_depth + .1, r=(box_side1_coinslots_diameter/2), anchor=LEFT);
                        }
                    }
                    //If 1 Coin
                    else {
                        move ([-0.1, coinslot_center_y,coinslot_center_z]) xcyl(h=box_side1_coinslots_depth + .1, r=(box_side1_coinslots_diameter/2), anchor=LEFT);
                    }
                }
                //If Side 1 Slot is Plate and Card Grab
                else if (box_side1_slot == "plate" && box_cardgrab == true) {
                    move ([-0.1, box_length_y/2, (box_length_z - box_cardgrab_height)/2]) cube([box_side1_plateslot_depth + 0.1, box_side1_plateslot_width, box_side1_plateslot_height], anchor=LEFT);
                }
                //if Side 1 Slot is Coins and Card Grab
                else if (box_side1_slot == "coins" && box_cardgrab == true) {
                    min_length = box_length_y > (box_length_z - box_cardgrab_height) ? (box_length_z - box_cardgrab_height) : box_length_y;
                    coinslot_center_y = box_length_y/2;
                    coinslot_center_z = (box_length_z - box_cardgrab_height)/2;
                    coinslot_radius = (min_length / 2) - (box_side1_coinslots_diameter/2) - box_wall_thick;
                    coinslot_degree = 360 / box_side1_coinslots_amount;
                    //If more than 1 Coin
                    if (box_side1_coinslots_amount > 1) {
                        for(i = [1: 1 : box_side1_coinslots_amount]) {
                            move ([-0.1, coinslot_center_y + (coinslot_radius * cos(coinslot_degree*i+box_side1_coinslots_rotate)), coinslot_center_z + (coinslot_radius * sin(coinslot_degree*i+box_side1_coinslots_rotate))]) xcyl(h=box_side1_coinslots_depth + .1, r=(box_side1_coinslots_diameter/2), anchor=LEFT);
                        }
                    }
                    //If 1 Coin
                    else {
                        move ([-0.1, coinslot_center_y, coinslot_center_z]) xcyl(h=box_side1_coinslots_depth + 0.1, r=(box_side1_coinslots_diameter/2), anchor=LEFT);
                    }
                }
                
                //If Side 2 slot is Plate
                if (box_side2_slot == "plate") {
                    move ([box_length_x/2, box_length_y + .1, box_length_z/2]) cube([box_side2_plateslot_width, box_side2_plateslot_depth + 0.1, box_side2_plateslot_height], anchor=BACK);
                }
                //If Side 2 Slot is Coins
                else if (box_side2_slot == "coins") {
                    min_length = box_length_x > box_length_z ? box_length_z : box_length_x;
                    coinslot_center_x = box_length_x/2;
                    coinslot_center_z = box_length_z/2;
                    coinslot_radius = (min_length / 2) - (box_side2_coinslots_diameter/2) - box_wall_thick;
                    coinslot_degree = 360 / box_side2_coinslots_amount;
                    //If more than 1 Coin
                    if (box_side2_coinslots_amount > 1) {
                        for(i = [1: 1 : box_side2_coinslots_amount]) {
                            move ([coinslot_center_x + (coinslot_radius * cos(coinslot_degree*i+box_side2_coinslots_rotate)), box_length_y +.1, coinslot_center_z + (coinslot_radius * sin(coinslot_degree*i+box_side2_coinslots_rotate))]) ycyl(h=box_side2_coinslots_depth + 0.1, r=(box_side2_coinslots_diameter/2), anchor=BACK);
                        }
                    }
                    //If 1 Coin
                    else {
                        move ([-0.1, coinslot_center_x, coinslot_center_z]) xcyl(h=box_side2_coinslots_depth + 0.1, r=(box_side2_coinslots_diameter/2), anchor=BACK);
                    }
                }
                
                //If Side 3 Slot is Plate and No Card Grab
                if (box_side3_slot == "plate" && box_cardgrab == false) {
                    move ([box_length_x +.1, box_length_y/2, box_length_z/2]) cube([box_side3_plateslot_depth + 0.1, box_side3_plateslot_width, box_side3_plateslot_height], anchor=RIGHT);
                }
                //If Side 3 Slot is Coins and No Card Grab
                else if (box_side3_slot == "coins" && box_cardgrab == false) {
                    min_length = box_length_y > box_length_z ? box_length_z : box_length_y;
                    coinslot_center_y = box_length_y/2;
                    coinslot_center_z = box_length_z/2;
                    coinslot_radius = (min_length / 2) - (box_side3_coinslots_diameter/2) - box_wall_thick;
                    coinslot_degree = 360 / box_side3_coinslots_amount;
                    //If more than 1 Coin
                    if (box_side3_coinslots_amount > 1) {
                        for(i = [1: 1 : box_side3_coinslots_amount]) {
                            move ([box_length_x + 0.1, coinslot_center_y + (coinslot_radius * cos(coinslot_degree*i+box_side3_coinslots_rotate)), coinslot_center_z + (coinslot_radius * sin(coinslot_degree*i+box_side3_coinslots_rotate))]) xcyl(h=box_side3_coinslots_depth + .1, r=(box_side3_coinslots_diameter/2), anchor=RIGHT);
                        }
                    }
                    //If 1 Coin
                    else {
                        move ([-0.1, coinslot_center_y, coinslot_center_z]) xcyl(h=box_side1_coinslots_depth + .1, r=(box_side1_coinslots_diameter/2), anchor=RIGHT);
                    }
                }
                //if Side 3 slot is Plate and Card Grab
                if (box_side3_slot == "plate" && box_cardgrab == true) {
                    move ([box_length_x +0.1, box_length_y/2, (box_length_z - box_cardgrab_height)/2]) cube([box_side3_plateslot_depth + 0.1, box_side3_plateslot_width, box_side3_plateslot_height], anchor=RIGHT);
                }
                //If Side 3 Slot is Coins and Card Grab
                else if (box_side3_slot == "coins" && box_cardgrab == true) {
                    min_length = box_length_y > (box_length_z - box_cardgrab_height) ? (box_length_z - box_cardgrab_height) : box_length_y;
                    coinslot_center_y = box_length_y/2;
                    coinslot_center_z = (box_length_z - box_cardgrab_height)/2;
                    coinslot_radius = (min_length / 2) - (box_side3_coinslots_diameter/2) - box_wall_thick;
                    coinslot_degree = 360 / box_side3_coinslots_amount;
                    //If more than 1 Coin
                    if (box_side3_coinslots_amount > 1) {
                        for(i = [1: 1 : box_side3_coinslots_amount]) {
                            move ([box_length_x + 0.1, coinslot_center_y + (coinslot_radius * cos(coinslot_degree*i+box_side3_coinslots_rotate)), coinslot_center_z + (coinslot_radius * sin(coinslot_degree*i+box_side3_coinslots_rotate))]) xcyl(h=box_side3_coinslots_depth + .1, r=(box_side3_coinslots_diameter/2), anchor=RIGHT);
                        }
                    }
                    //If 1 Coin
                    else {
                        move ([-0.1, coinslot_center_y, coinslot_center_z]) xcyl(h=box_side1_coinslots_depth + .1, r=(box_side1_coinslots_diameter/2), anchor=RIGHT);
                    }
                }
                                
                //If Side 4 slot is Plate
                if (box_side4_slot == "plate") {
                    move ([box_length_x/2, -0.1, box_length_z/2]) cube([box_side4_plateslot_width, box_side4_plateslot_depth + 0.1, box_side4_plateslot_height], anchor=FRONT);
                }
                //If Side 4 Slot is Coins
                else if (box_side4_slot == "coins") {
                    min_length = box_length_x > box_length_z ? box_length_z : box_length_x;
                    coinslot_center_x = box_length_x/2;
                    coinslot_center_z = box_length_z/2;
                    coinslot_radius = (min_length / 2) - (box_side4_coinslots_diameter/2) - box_wall_thick;
                    coinslot_degree = 360 / box_side4_coinslots_amount;
                    //If more than 1 Coin
                    if (box_side4_coinslots_amount > 1) {
                        for(i = [1: 1 : box_side4_coinslots_amount]) {
                            move ([coinslot_center_x + (coinslot_radius * cos(coinslot_degree*i+box_side4_coinslots_rotate)), -0.1, coinslot_center_z + (coinslot_radius * sin(coinslot_degree*i+box_side4_coinslots_rotate))]) ycyl(h=box_side4_coinslots_depth + .1, r=(box_side4_coinslots_diameter/2), anchor=FRONT);
                        }
                    }
                    //If 1 Coin
                    else {
                        move ([-0.1, coinslot_center_x, coinslot_center_z]) xcyl(h=box_side4_coinslots_depth + .1, r=(box_side4_coinslots_diameter/2), anchor=FRONT);
                    }
                }
            }
        }
        
        //No Edge Rounding, Edge Clipping
        else if(edge_rounding == 0 && edge_clipping>0) {
            difference() {
                cuboid([box_length_x, box_length_y, box_length_z], chamfer=edge_clipping, anchor=FRONT+LEFT+BOT, trimcorners=trim_corners);
                //Calculate if Lid needs a Back or not per box_lid_noback
                box_lid_length_y = box_lid_noback == true ? box_length_y * 1.2 :  box_length_y - box_wall_thick + 1.1;
                //If lid secure is Dovetail, Remove Lid
                if(box_lid_secure == "dovetail"){
                    move ([box_wall_thick * 0.75, -0.1, box_length_z - box_lid_thick + 0.1]) prismoid(size1=[(idb_length_x + (box_wall_thick * 0.5)), box_lid_length_y],size2=[idb_length_x, box_lid_length_y], h=(box_lid_thick + .01), anchor=FRONT+LEFT+BOT);
                }
                //If lid secure is Groove, Remove Lid
                else if(box_lid_secure=="groove"){
                    move ([box_wall_thick, -0.1, box_length_z - box_lid_thick + 0.1]) cube([idb_length_x, box_lid_length_y, (box_lid_thick + 0.1)], anchor=FRONT+LEFT+BOT);
                    move ([box_wall_thick * 0.75, -0.1, box_length_z - box_lid_thick + 0.1]) cube([(box_wall_thick * 0.25) + 0.1, box_lid_length_y, (box_lid_thick * 0.5)], anchor=FRONT+LEFT+BOT);
                    move ([box_length_x - box_wall_thick - 0.1, -0.1, box_length_z - box_lid_thick + 0.1]) cube([box_wall_thick * .25, box_lid_length_y, (box_lid_thick * 0.5)], anchor=FRONT+LEFT+BOT);
                }
                
                //If lid secure is none, Remove Lid
                else {
                    move ([box_wall_thick, -0.1, box_length_z - box_lid_thick + 0.1]) cube([idb_length_x, box_lid_length_y, (box_lid_thick + 0.1)], anchor=FRONT+LEFT+BOT);
                }
                
                //remove IDB
                move ([box_wall_thick, ((box_wall_thick * 1.5) + cmd_length_y), box_length_z - box_lid_thick + 0.2]) cube([idb_length_x,idb_length_y,(idb_length_z + 0.2)], anchor=FRONT+LEFT+TOP);
                
                //remove Commander Slot
                move ([(((idb_length_x + (box_wall_thick * 2))- cmd_length_x)/2), box_wall_thick, box_length_z - box_lid_thick + 0.2]) cube([cmd_length_x,cmd_length_y,(cmd_length_z + .2)], anchor=FRONT+LEFT+TOP);
                
                //If Card Grab, Remove Card Grab
                if (box_cardgrab){
                    move([-0.1, box_length_y - box_wall_thick - (idb_length_y / 2), box_length_z - box_cardgrab_height]) xcyl(h=(box_length_x+10), r=(box_cardgrab_width/2), anchor=LEFT+BOT);
                    move([-0.1, box_length_y - box_wall_thick - (idb_length_y / 2), box_length_z - (box_cardgrab_height - (box_cardgrab_width / 2))]) cube([(box_length_x+10), box_cardgrab_width, box_length_z], anchor=LEFT+BOT);
                }
                
                //If Magnets, Remove Magnet Slots
                if (box_lid_magnet_amount > 0) {
                    box_lid_magnet_spacing = idb_length_x / box_lid_magnet_amount;
                    for(a = [1 : 1 : box_lid_magnet_amount]) {
                        move([box_wall_thick + ((idb_length_x/(box_lid_magnet_amount + 1)) * a), box_length_y - box_wall_thick - 0.1 + 1, box_length_z - (box_lid_thick / 2)]) ycyl(h=(box_lid_magnet_depth + 0.1), d=(box_lid_magnet_diameter + 0.1), anchor=FRONT);
                    }
                }
                
                //If Side 1 Slot is Plate and no Card Grab
                if (box_side1_slot == "plate" && box_cardgrab == false) {
                    move ([-0.1, box_length_y/2, box_length_z/2]) cube([box_side1_plateslot_depth + 0.1, box_side1_plateslot_width, box_side1_plateslot_height], anchor=LEFT);
                }
                //If Side 1 Slot is Coins and no Card Grab
                else if (box_side1_slot == "coins" && box_cardgrab == false) {
                    min_length = box_length_y > box_length_z ? box_length_z : box_length_y;
                    coinslot_center_y = box_length_y/2;
                    coinslot_center_z = box_length_z/2;
                    coinslot_radius = (min_length / 2) - (box_side1_coinslots_diameter/2) - box_wall_thick;
                    coinslot_degree = 360 / box_side1_coinslots_amount;
                    //If more than 1 Coin
                    if (box_side1_coinslots_amount > 1) {
                        for(i = [1: 1 : box_side1_coinslots_amount]) {
                            move ([-0.1, coinslot_center_y + (coinslot_radius * cos(coinslot_degree*i+box_side1_coinslots_rotate)), coinslot_center_z + (coinslot_radius * sin(coinslot_degree*i+box_side1_coinslots_rotate))]) xcyl(h=box_side1_coinslots_depth + .1, r=(box_side1_coinslots_diameter/2), anchor=LEFT);
                        }
                    }
                    //If 1 Coin
                    else {
                        move ([-0.1, coinslot_center_y, coinslot_center_z]) xcyl(h=box_side1_coinslots_depth + .1, r=(box_side1_coinslots_diameter/2), anchor=LEFT);
                    }
                }
                //If Side 1 Slot is Plate and Card Grab
                else if (box_side1_slot == "plate" && box_cardgrab == true) {
                    move ([-0.1, box_length_y/2, (box_length_z - box_cardgrab_height)/2]) cube([box_side1_plateslot_depth + 0.1, box_side1_plateslot_width, box_side1_plateslot_height], anchor=LEFT);
                }
                //if Side 1 Slot is Coins and Card Grab
                else if (box_side1_slot == "coins" && box_cardgrab == true) {
                    min_length = box_length_y > (box_length_z - box_cardgrab_height) ? (box_length_z - box_cardgrab_height) : box_length_y;
                    coinslot_center_y = box_length_y/2;
                    coinslot_center_z = (box_length_z - box_cardgrab_height)/2;
                    coinslot_radius = (min_length / 2) - (box_side1_coinslots_diameter/2) - box_wall_thick;
                    coinslot_degree = 360 / box_side1_coinslots_amount;
                    //If more than 1 Coin
                    if (box_side1_coinslots_amount > 1) {
                        for(i = [1: 1 : box_side1_coinslots_amount]) {
                            move ([-0.1, coinslot_center_y + (coinslot_radius * cos(coinslot_degree*i+box_side1_coinslots_rotate)), coinslot_center_z + (coinslot_radius * sin(coinslot_degree*i+box_side1_coinslots_rotate))]) xcyl(h=box_side1_coinslots_depth + .1, r=(box_side1_coinslots_diameter/2), anchor=LEFT);
                        }
                    }
                    //If 1 Coin
                    else {
                        move ([-0.1, coinslot_center_y, coinslot_center_z]) xcyl(h=box_side1_coinslots_depth + 0.1, r=(box_side1_coinslots_diameter/2), anchor=LEFT);
                    }
                }
                
                //If Side 2 slot is Plate
                if (box_side2_slot == "plate") {
                    move ([box_length_x/2, box_length_y + 0.1, box_length_z/2]) cube([box_side2_plateslot_width, box_side2_plateslot_depth + 0.1, box_side2_plateslot_height], anchor=BACK);
                }
                //If Side 2 Slot is Coins
                else if (box_side2_slot == "coins") {
                    min_length = box_length_x > box_length_z ? box_length_z : box_length_x;
                    coinslot_center_x = box_length_x/2;
                    coinslot_center_z = box_length_z/2;
                    coinslot_radius = (min_length / 2) - (box_side2_coinslots_diameter/2) - box_wall_thick;
                    coinslot_degree = 360 / box_side2_coinslots_amount;
                    //If more than 1 Coin
                    if (box_side2_coinslots_amount > 1) {
                        for(i = [1: 1 : box_side2_coinslots_amount]) {
                            move ([coinslot_center_x + (coinslot_radius * cos(coinslot_degree*i+box_side2_coinslots_rotate)), box_length_y +.1, coinslot_center_z + (coinslot_radius * sin(coinslot_degree*i+box_side2_coinslots_rotate))]) ycyl(h=box_side2_coinslots_depth + 0.1, r=(box_side2_coinslots_diameter/2), anchor=BACK);
                        }
                    }
                    //If 1 Coin
                    else {
                        move ([-0.1, coinslot_center_x, coinslot_center_z]) xcyl(h=box_side2_coinslots_depth + 0.1, r=(box_side2_coinslots_diameter/2), anchor=BACK);
                    }
                }
                
                //If Side 3 Slot is Plate and No Card Grab
                if (box_side3_slot == "plate" && box_cardgrab == false) {
                    move ([box_length_x +0.1, box_length_y/2, box_length_z/2]) cube([box_side3_plateslot_depth + 0.1, box_side3_plateslot_width, box_side3_plateslot_height], anchor=RIGHT);
                }
                //If Side 3 Slot is Coins and No Card Grab
                else if (box_side3_slot == "coins" && box_cardgrab == false) {
                    min_length = box_length_y > box_length_z ? box_length_z : box_length_y;
                    coinslot_center_y = box_length_y/2;
                    coinslot_center_z = box_length_z/2;
                    coinslot_radius = (min_length / 2) - (box_side3_coinslots_diameter/2) - box_wall_thick;
                    coinslot_degree = 360 / box_side3_coinslots_amount;
                    //If more than 1 Coin
                    if (box_side3_coinslots_amount > 1) {
                        for(i = [1: 1 : box_side3_coinslots_amount]) {
                            move ([box_length_x + 0.1, coinslot_center_y + (coinslot_radius * cos(coinslot_degree*i+box_side3_coinslots_rotate)), coinslot_center_z + (coinslot_radius * sin(coinslot_degree*i+box_side3_coinslots_rotate))]) xcyl(h=box_side3_coinslots_depth + .1, r=(box_side3_coinslots_diameter/2), anchor=RIGHT);
                        }
                    }
                    //If 1 Coin
                    else {
                        move ([-0.1, coinslot_center_y, coinslot_center_z]) xcyl(h=box_side1_coinslots_depth + .1, r=(box_side1_coinslots_diameter/2), anchor=RIGHT);
                    }
                }
                //if Side 3 slot is Plate and Card Grab
                if (box_side3_slot == "plate" && box_cardgrab == true) {
                    move ([box_length_x +0.1, box_length_y/2, (box_length_z - box_cardgrab_height)/2]) cube([box_side3_plateslot_depth + 0.1, box_side3_plateslot_width, box_side3_plateslot_height], anchor=RIGHT);
                }
                //If Side 3 Slot is Coins and Card Grab
                else if (box_side3_slot == "coins" && box_cardgrab == true) {
                    min_length = box_length_y > (box_length_z - box_cardgrab_height) ? (box_length_z - box_cardgrab_height) : box_length_y;
                    coinslot_center_y = box_length_y/2;
                    coinslot_center_z = (box_length_z - box_cardgrab_height)/2;
                    coinslot_radius = (min_length / 2) - (box_side3_coinslots_diameter/2) - box_wall_thick;
                    coinslot_degree = 360 / box_side3_coinslots_amount;
                    //If more than 1 Coin
                    if (box_side3_coinslots_amount > 1) {
                        for(i = [1: 1 : box_side3_coinslots_amount]) {
                            move ([box_length_x + .1, coinslot_center_y + (coinslot_radius * cos(coinslot_degree*i+box_side3_coinslots_rotate)), coinslot_center_z + (coinslot_radius * sin(coinslot_degree*i+box_side3_coinslots_rotate))]) xcyl(h=box_side3_coinslots_depth + .1, r=(box_side3_coinslots_diameter/2), anchor=RIGHT);
                        }
                    }
                    //If 1 Coin
                    else {
                        move ([-0.1, coinslot_center_y, coinslot_center_z]) xcyl(h=box_side1_coinslots_depth + 0.1, r=(box_side1_coinslots_diameter/2), anchor=RIGHT);
                    }
                }
                                
                //If Side 4 slot is Plate
                if (box_side4_slot == "plate") {
                    move ([box_length_x/2, -0.1, box_length_z/2]) cube([box_side4_plateslot_width, box_side4_plateslot_depth + 0.1, box_side4_plateslot_height], anchor=FRONT);
                }
                //If Side 4 Slot is Coins
                else if (box_side4_slot == "coins") {
                    min_length = box_length_x > box_length_z ? box_length_z : box_length_x;
                    coinslot_center_x = box_length_x/2;
                    coinslot_center_z = box_length_z/2;
                    coinslot_radius = (min_length / 2) - (box_side4_coinslots_diameter/2) - box_wall_thick;
                    coinslot_degree = 360 / box_side4_coinslots_amount;
                    //If more than 1 Coin
                    if (box_side4_coinslots_amount > 1) {
                        for(i = [1: 1 : box_side4_coinslots_amount]) {
                            move ([coinslot_center_x + (coinslot_radius * cos(coinslot_degree*i+box_side4_coinslots_rotate)), -0.1, coinslot_center_z + (coinslot_radius * sin(coinslot_degree*i+box_side4_coinslots_rotate))]) ycyl(h=box_side4_coinslots_depth + .1, r=(box_side4_coinslots_diameter/2), anchor=FRONT);
                        }
                    }
                    //If 1 Coin
                    else {
                        move ([-0.1, coinslot_center_x, coinslot_center_z]) xcyl(h=box_side4_coinslots_depth + .1, r=(box_side4_coinslots_diameter/2), anchor=FRONT);
                    }
                }
            }
            
        }
        
        //Edge Rounding, Ignores Edge Clipping
        else {
            difference() {
                cuboid([box_length_x, box_length_y, box_length_z], rounding = edge_rounding, anchor=FRONT+LEFT+BOT, trimcorners=trim_corners);
                //Calculate if Lid needs a Back or not per box_lid_noback
                box_lid_length_y = box_lid_noback == true ? box_length_y * 1.2 :  box_length_y - box_wall_thick + 1.1;
                //If lid secure is Dovetail, Remove Lid
                if(box_lid_secure == "dovetail"){
                    move ([box_wall_thick * 0.75, -0.1, box_length_z - box_lid_thick + 0.1]) prismoid(size1=[(idb_length_x + (box_wall_thick * 0.5)), box_lid_length_y],size2=[idb_length_x, box_lid_length_y], h=(box_lid_thick + .01), anchor=FRONT+LEFT+BOT);
                }
                //If lid secure is Groove, Remove Lid
                else if(box_lid_secure=="groove"){
                    move ([box_wall_thick, -0.1, box_length_z - box_lid_thick + 0.1]) cube([idb_length_x, box_lid_length_y, (box_lid_thick + .1)], anchor=FRONT+LEFT+BOT);
                    move ([box_wall_thick * 0.75, -0.1, box_length_z - box_lid_thick + 0.1]) cube([(box_wall_thick * 0.25) + 0.1, box_lid_length_y, (box_lid_thick * 0.5)], anchor=FRONT+LEFT+BOT);
                    move ([box_length_x - box_wall_thick - 0.1 , -0.1, box_length_z - box_lid_thick + 0.1]) cube([box_wall_thick * .25, box_lid_length_y, (box_lid_thick * 0.5)], anchor=FRONT+LEFT+BOT);
                }
                
                //If lid secure is none, Remove Lid
                else {
                    move ([box_wall_thick, -0.1, box_length_z - box_lid_thick + 0.1]) cube([idb_length_x, box_lid_length_y, (box_lid_thick + .1)], anchor=FRONT+LEFT+BOT);
                }
                
                //remove IDB
                move ([box_wall_thick, ((box_wall_thick * 1.5) + cmd_length_y), box_length_z - box_lid_thick + 0.2]) cube([idb_length_x,idb_length_y,(idb_length_z + 0.2)], anchor=FRONT+LEFT+TOP);
                
                //remove Commander Slot
                move ([(((idb_length_x + (box_wall_thick * 2))- cmd_length_x)/2), box_wall_thick, box_length_z - box_lid_thick + 0.2]) cube([cmd_length_x,cmd_length_y,(cmd_length_z + .2)], anchor=FRONT+LEFT+TOP);
                
                //If Card Grab, Remove Card Grab
                if (box_cardgrab){
                    move([-0.1, box_length_y - box_wall_thick - (idb_length_y / 2), box_length_z - box_cardgrab_height]) xcyl(h=(box_length_x+10), r=(box_cardgrab_width/2), anchor=LEFT+BOT);
                    move([-0.1, box_length_y - box_wall_thick - (idb_length_y / 2), box_length_z - (box_cardgrab_height - (box_cardgrab_width / 2))]) cube([(box_length_x+10), box_cardgrab_width, box_length_z], anchor=LEFT+BOT);
                }
                
                //If Magnets, Remove Magnet Slots
                if (box_lid_magnet_amount > 0) {
                    box_lid_magnet_spacing = idb_length_x / box_lid_magnet_amount;
                    for(a = [1 : 1 : box_lid_magnet_amount]) {
                        move([box_wall_thick + ((idb_length_x/(box_lid_magnet_amount + 1)) * a), box_length_y - box_wall_thick - 0.1 + 1, box_length_z - (box_lid_thick / 2)]) ycyl(h=(box_lid_magnet_depth + 0.1), d=(box_lid_magnet_diameter + 0.1), anchor=FRONT);
                    }
                }
                
                //If Side 1 Slot is Plate and no Card Grab
                if (box_side1_slot == "plate" && box_cardgrab == false) {
                    move ([-0.1, box_length_y/2, box_length_z/2]) cube([box_side1_plateslot_depth + 0.1, box_side1_plateslot_width, box_side1_plateslot_height], anchor=LEFT);
                }
                //If Side 1 Slot is Coins and no Card Grab
                else if (box_side1_slot == "coins" && box_cardgrab == false) {
                    min_length = box_length_y > box_length_z ? box_length_z : box_length_y;
                    coinslot_center_y = box_length_y/2;
                    coinslot_center_z = box_length_z/2;
                    coinslot_radius = (min_length / 2) - (box_side1_coinslots_diameter/2) - box_wall_thick;
                    coinslot_degree = 360 / box_side1_coinslots_amount;
                    //If more than 1 Coin
                    if (box_side1_coinslots_amount > 1) {
                        for(i = [1: 1 : box_side1_coinslots_amount]) {
                            move ([-0.1, coinslot_center_y + (coinslot_radius * cos(coinslot_degree*i+box_side1_coinslots_rotate)), coinslot_center_z + (coinslot_radius * sin(coinslot_degree*i+box_side1_coinslots_rotate))]) xcyl(h=box_side1_coinslots_depth + .1, r=(box_side1_coinslots_diameter/2), anchor=LEFT);
                        }
                    }
                    //If 1 Coin
                    else {
                        move ([-0.1, coinslot_center_y, coinslot_center_z]) xcyl(h=box_side1_coinslots_depth + .1, r=(box_side1_coinslots_diameter/2), anchor=LEFT);
                    }
                }
                //If Side 1 Slot is Plate and Card Grab
                else if (box_side1_slot == "plate" && box_cardgrab == true) {
                    move ([-0.1, box_length_y/2, (box_length_z - box_cardgrab_height)/2]) cube([box_side1_plateslot_depth + 0.1, box_side1_plateslot_width, box_side1_plateslot_height], anchor=LEFT);
                }
                //if Side 1 Slot is Coins and Card Grab
                else if (box_side1_slot == "coins" && box_cardgrab == true) {
                    min_length = box_length_y > (box_length_z - box_cardgrab_height) ? (box_length_z - box_cardgrab_height) : box_length_y;
                    coinslot_center_y = box_length_y/2;
                    coinslot_center_z = (box_length_z - box_cardgrab_height)/2;
                    coinslot_radius = (min_length / 2) - (box_side1_coinslots_diameter/2) - box_wall_thick;
                    coinslot_degree = 360 / box_side1_coinslots_amount;
                    //If more than 1 Coin
                    if (box_side1_coinslots_amount > 1) {
                        for(i = [1: 1 : box_side1_coinslots_amount]) {
                            move ([-0.1, coinslot_center_y + (coinslot_radius * cos(coinslot_degree*i+box_side1_coinslots_rotate)), coinslot_center_z + (coinslot_radius * sin(coinslot_degree*i+box_side1_coinslots_rotate))]) xcyl(h=box_side1_coinslots_depth + .1, r=(box_side1_coinslots_diameter/2), anchor=LEFT);
                        }
                    }
                    //If 1 Coin
                    else {
                        move ([-0.1, coinslot_center_y, coinslot_center_z]) xcyl(h=box_side1_coinslots_depth + 0.1, r=(box_side1_coinslots_diameter/2), anchor=LEFT);
                    }
                }
                
                //If Side 2 slot is Plate
                if (box_side2_slot == "plate") {
                    move ([box_length_x/2, box_length_y + .1, box_length_z/2]) cube([box_side2_plateslot_width, box_side2_plateslot_depth + 0.1, box_side2_plateslot_height], anchor=BACK);
                }
                //If Side 2 Slot is Coins
                else if (box_side2_slot == "coins") {
                    min_length = box_length_x > box_length_z ? box_length_z : box_length_x;
                    coinslot_center_x = box_length_x/2;
                    coinslot_center_z = box_length_z/2;
                    coinslot_radius = (min_length / 2) - (box_side2_coinslots_diameter/2) - box_wall_thick;
                    coinslot_degree = 360 / box_side2_coinslots_amount;
                    //If more than 1 Coin
                    if (box_side2_coinslots_amount > 1) {
                        for(i = [1: 1 : box_side2_coinslots_amount]) {
                            move ([coinslot_center_x + (coinslot_radius * cos(coinslot_degree*i+box_side2_coinslots_rotate)), box_length_y +.1, coinslot_center_z + (coinslot_radius * sin(coinslot_degree*i+box_side2_coinslots_rotate))]) ycyl(h=box_side2_coinslots_depth + 0.1, r=(box_side2_coinslots_diameter/2), anchor=BACK);
                        }
                    }
                    //If 1 Coin
                    else {
                        move ([-0.1, coinslot_center_x, coinslot_center_z]) xcyl(h=box_side2_coinslots_depth + 0.1, r=(box_side2_coinslots_diameter/2), anchor=BACK);
                    }
                }
                
                //If Side 3 Slot is Plate and No Card Grab
                if (box_side3_slot == "plate" && box_cardgrab == false) {
                    move ([box_length_x + 0.1, box_length_y/2, box_length_z/2]) cube([box_side3_plateslot_depth + 0.1, box_side3_plateslot_width, box_side3_plateslot_height], anchor=RIGHT);
                }
                //If Side 3 Slot is Coins and No Card Grab
                else if (box_side3_slot == "coins" && box_cardgrab == false) {
                    min_length = box_length_y > box_length_z ? box_length_z : box_length_y;
                    coinslot_center_y = box_length_y/2;
                    coinslot_center_z = box_length_z/2;
                    coinslot_radius = (min_length / 2) - (box_side3_coinslots_diameter/2) - box_wall_thick;
                    coinslot_degree = 360 / box_side3_coinslots_amount;
                    //If more than 1 Coin
                    if (box_side3_coinslots_amount > 1) {
                        for(i = [1: 1 : box_side3_coinslots_amount]) {
                            move ([box_length_x + 0.1, coinslot_center_y + (coinslot_radius * cos(coinslot_degree*i+box_side3_coinslots_rotate)), coinslot_center_z + (coinslot_radius * sin(coinslot_degree*i+box_side3_coinslots_rotate))]) xcyl(h=box_side3_coinslots_depth + .1, r=(box_side3_coinslots_diameter/2), anchor=RIGHT);
                        }
                    }
                    //If 1 Coin
                    else {
                        move ([-0.1, coinslot_center_y, coinslot_center_z]) xcyl(h=box_side1_coinslots_depth + .1, r=(box_side1_coinslots_diameter/2), anchor=RIGHT);
                    }
                }
                //if Side 3 slot is Plate and Card Grab
                if (box_side3_slot == "plate" && box_cardgrab == true) {
                    move ([box_length_x + 0.1, box_length_y/2, (box_length_z - box_cardgrab_height)/2]) cube([box_side3_plateslot_depth + 0.1, box_side3_plateslot_width, box_side3_plateslot_height], anchor=RIGHT);
                }
                //If Side 3 Slot is Coins and Card Grab
                else if (box_side3_slot == "coins" && box_cardgrab == true) {
                    min_length = box_length_y > (box_length_z - box_cardgrab_height) ? (box_length_z - box_cardgrab_height) : box_length_y;
                    coinslot_center_y = box_length_y/2;
                    coinslot_center_z = (box_length_z - box_cardgrab_height)/2;
                    coinslot_radius = (min_length / 2) - (box_side3_coinslots_diameter/2) - box_wall_thick;
                    coinslot_degree = 360 / box_side3_coinslots_amount;
                    //If more than 1 Coin
                    if (box_side3_coinslots_amount > 1) {
                        for(i = [1: 1 : box_side3_coinslots_amount]) {
                            move ([box_length_x + 0.1, coinslot_center_y + (coinslot_radius * cos(coinslot_degree*i+box_side3_coinslots_rotate)), coinslot_center_z + (coinslot_radius * sin(coinslot_degree*i+box_side3_coinslots_rotate))]) xcyl(h=box_side3_coinslots_depth + .1, r=(box_side3_coinslots_diameter/2), anchor=RIGHT);
                        }
                    }
                    //If 1 Coin
                    else {
                        move ([-0.1, coinslot_center_y, coinslot_center_z]) xcyl(h=box_side1_coinslots_depth + .1, r=(box_side1_coinslots_diameter/2), anchor=RIGHT);
                    }
                }
                                
                //If Side 4 slot is Plate
                if (box_side4_slot == "plate") {
                    move ([box_length_x/2, -0.1, box_length_z/2]) cube([box_side4_plateslot_width, box_side4_plateslot_depth + 0.1, box_side4_plateslot_height], anchor=FRONT);
                }
                //If Side 4 Slot is Coins
                else if (box_side4_slot == "coins") {
                    min_length = box_length_x > box_length_z ? box_length_z : box_length_x;
                    coinslot_center_x = box_length_x/2;
                    coinslot_center_z = box_length_z/2;
                    coinslot_radius = (min_length / 2) - (box_side4_coinslots_diameter/2) - box_wall_thick;
                    coinslot_degree = 360 / box_side4_coinslots_amount;
                    //If more than 1 Coin
                    if (box_side4_coinslots_amount > 1) {
                        for(i = [1: 1 : box_side4_coinslots_amount]) {
                            move ([coinslot_center_x + (coinslot_radius * cos(coinslot_degree*i+box_side4_coinslots_rotate)), -0.1, coinslot_center_z + (coinslot_radius * sin(coinslot_degree*i+box_side4_coinslots_rotate))]) ycyl(h=box_side4_coinslots_depth + .1, r=(box_side4_coinslots_diameter/2), anchor=FRONT);
                        }
                    }
                    //If 1 Coin
                    else {
                        move ([-0.1, coinslot_center_x, coinslot_center_z]) xcyl(h=box_side4_coinslots_depth + .1, r=(box_side4_coinslots_diameter/2), anchor=FRONT);
                    }
                }
            }
        }
    }
     
     //Render Box without Commander Slot
     else {
        //No Edge Rounding, No Edge Clipping
        if(edge_rounding == 0 && edge_clipping==0) {
            difference() {
                cuboid([box_length_x, box_length_y, box_length_z], anchor=FRONT+LEFT+BOT);
                
                //Calculate if Lid needs a Back or not per box_lid_noback
                box_lid_length_y = box_lid_noback == true ? box_length_y * 1.2 : box_length_y - box_wall_thick + 1.1;
                
                //If lid secure is Dovetail, Remove Lid
                if(box_lid_secure == "dovetail"){
                    move ([box_wall_thick * 0.75, -0.1, box_length_z - box_lid_thick + 0.1]) prismoid(size1=[(idb_length_x + (box_wall_thick * 0.5)), box_lid_length_y],size2=[idb_length_x, box_lid_length_y], h=(box_lid_thick + .01), anchor=FRONT+LEFT+BOT);
                }
                
                //If lid secure is Groove, Remove Lid
                else if(box_lid_secure=="groove"){
                    move ([box_wall_thick, -0.1, box_length_z - box_lid_thick + 0.1]) cube([idb_length_x, box_lid_length_y, (box_lid_thick + .1)], anchor=FRONT+LEFT+BOT);
                    move ([box_wall_thick * 0.75, -0.1, box_length_z - box_lid_thick + 0.1]) cube([(box_wall_thick * 0.25) + 0.1, box_lid_length_y, (box_lid_thick * 0.5)], anchor=FRONT+LEFT+BOT);
                    move ([box_length_x - box_wall_thick - 0.1, -0.1, box_length_z - box_lid_thick + 0.1]) cube([box_wall_thick * .25, box_lid_length_y, (box_lid_thick * 0.5)], anchor=FRONT+LEFT+BOT);
                }
                
                //If lid secure is none, Remove Lid
                else {
                    move ([box_wall_thick, -0.1, box_length_z - box_lid_thick + 0.1]) cube([idb_length_x, box_lid_length_y, (box_lid_thick + .1)], anchor=FRONT+LEFT+BOT);
                }
                
                //remove IDB
                move ([box_length_x - box_wall_thick, box_length_y - box_wall_thick, box_length_z - box_wall_thick + 0.2]) cube([idb_length_x,idb_length_y,(idb_length_z + .2)], anchor=BACK+RIGHT+TOP);
                
                //If Card Grab, Remove Card Grab
                if (box_cardgrab){
                    move([-0.1, box_length_y - box_wall_thick - (idb_length_y / 2), box_length_z - box_cardgrab_height]) xcyl(h=(box_length_x+10), r=(box_cardgrab_width/2), anchor=LEFT+BOT);
                    move([-.1, box_length_y - box_wall_thick - (idb_length_y / 2), box_length_z - (box_cardgrab_height - (box_cardgrab_width / 2))]) cube([(box_length_x+10), box_cardgrab_width, box_length_z], anchor=LEFT+BOT);
                }
                
                //If Magnets, Remove Magnet Slots
                if (box_lid_magnet_amount > 0) {
                    box_lid_magnet_spacing = idb_length_x / box_lid_magnet_amount;
                    for(a = [1 : 1 : box_lid_magnet_amount]) {
                        move([box_wall_thick + ((idb_length_x/(box_lid_magnet_amount + 1)) * a), box_length_y - box_wall_thick - 0.1 + 1, box_length_z - (box_lid_thick / 2)]) ycyl(h=(box_lid_magnet_depth + 0.1), d=(box_lid_magnet_diameter + 0.1), anchor=FRONT);
                    }
                }
                
                //If Side 1 Slot is Plate and no Card Grab
                if (box_side1_slot == "plate" && box_cardgrab == false) {
                    move ([-0.1, box_length_y/2, box_length_z/2]) cube([box_side1_plateslot_depth + 0.1, box_side1_plateslot_width, box_side1_plateslot_height], anchor=LEFT);
                }
                //If Side 1 Slot is Coins and no Card Grab
                else if (box_side1_slot == "coins" && box_cardgrab == false) {
                    min_length = box_length_y > box_length_z ? box_length_z : box_length_y;
                    coinslot_center_y = box_length_y/2;
                    coinslot_center_z = box_length_z/2;
                    coinslot_radius = (min_length / 2) - (box_side1_coinslots_diameter/2) - box_wall_thick;
                    coinslot_degree = 360 / box_side1_coinslots_amount;
                    //If more than 1 Coin
                    if (box_side1_coinslots_amount > 1) {
                        for(i = [1: 1 : box_side1_coinslots_amount]) {
                            move ([-0.1, coinslot_center_y + (coinslot_radius * cos(coinslot_degree*i+box_side1_coinslots_rotate)), coinslot_center_z + (coinslot_radius * sin(coinslot_degree*i+box_side1_coinslots_rotate))]) xcyl(h=box_side1_coinslots_depth + .1, r=(box_side1_coinslots_diameter/2), anchor=LEFT);
                        }
                    }
                    //If 1 Coin
                    else {
                        move ([-0.1, coinslot_center_y, coinslot_center_z]) xcyl(h=box_side1_coinslots_depth + .1, r=(box_side1_coinslots_diameter/2), anchor=LEFT);
                    }
                }
                //If Side 1 Slot is Plate and Card Grab
                else if (box_side1_slot == "plate" && box_cardgrab == true) {
                    move ([-0.1, box_length_y/2, (box_length_z - box_cardgrab_height)/2]) cube([box_side1_plateslot_depth + 0.1, box_side1_plateslot_width, box_side1_plateslot_height], anchor=LEFT);
                }
                //if Side 1 Slot is Coins and Card Grab
                else if (box_side1_slot == "coins" && box_cardgrab == true) {
                    min_length = box_length_y > (box_length_z - box_cardgrab_height) ? (box_length_z - box_cardgrab_height) : box_length_y;
                    coinslot_center_y = box_length_y/2;
                    coinslot_center_z = (box_length_z - box_cardgrab_height)/2;
                    coinslot_radius = (min_length / 2) - (box_side1_coinslots_diameter/2) - box_wall_thick;
                    coinslot_degree = 360 / box_side1_coinslots_amount;
                    //If more than 1 Coin
                    if (box_side1_coinslots_amount > 1) {
                        for(i = [1: 1 : box_side1_coinslots_amount]) {
                            move ([-0.1, coinslot_center_y + (coinslot_radius * cos(coinslot_degree*i+box_side1_coinslots_rotate)), coinslot_center_z + (coinslot_radius * sin(coinslot_degree*i+box_side1_coinslots_rotate))]) xcyl(h=box_side1_coinslots_depth + 0.1, r=(box_side1_coinslots_diameter/2), anchor=LEFT);
                        }
                    }
                    //If 1 Coin
                    else {
                        move ([-0.1, coinslot_center_y, coinslot_center_z]) xcyl(h=box_side1_coinslots_depth + 0.1, r=(box_side1_coinslots_diameter/2), anchor=LEFT);
                    }
                }
                
                //If Side 2 slot is Plate
                if (box_side2_slot == "plate") {
                    move ([box_length_x/2, box_length_y + 0.1, box_length_z/2]) cube([box_side2_plateslot_width, box_side2_plateslot_depth + 0.1, box_side2_plateslot_height], anchor=BACK);
                }
                //If Side 2 Slot is Coins
                else if (box_side2_slot == "coins") {
                    min_length = box_length_x > box_length_z ? box_length_z : box_length_x;
                    coinslot_center_x = box_length_x/2;
                    coinslot_center_z = box_length_z/2;
                    coinslot_radius = (min_length / 2) - (box_side2_coinslots_diameter/2) - box_wall_thick;
                    coinslot_degree = 360 / box_side2_coinslots_amount;
                    //If more than 1 Coin
                    if (box_side2_coinslots_amount > 1) {
                        for(i = [1: 1 : box_side2_coinslots_amount]) {
                            move ([coinslot_center_x + (coinslot_radius * cos(coinslot_degree*i+box_side2_coinslots_rotate)), box_length_y +0.1, coinslot_center_z + (coinslot_radius * sin(coinslot_degree*i+box_side2_coinslots_rotate))]) ycyl(h=box_side2_coinslots_depth + 0.1, r=(box_side2_coinslots_diameter/2), anchor=BACK);
                        }
                    }
                    //If 1 Coin
                    else {
                        move ([-0.1, coinslot_center_x, coinslot_center_z]) xcyl(h=box_side2_coinslots_depth + 0.1, r=(box_side2_coinslots_diameter/2), anchor=BACK);
                    }
                }
                
                //If Side 3 Slot is Plate and No Card Grab
                if (box_side3_slot == "plate" && box_cardgrab == false) {
                    move ([box_length_x + 0.1, box_length_y/2, box_length_z/2]) cube([box_side3_plateslot_depth + 0.1, box_side3_plateslot_width, box_side3_plateslot_height], anchor=RIGHT);
                }
                //If Side 3 Slot is Coins and No Card Grab
                else if (box_side3_slot == "coins" && box_cardgrab == false) {
                    min_length = box_length_y > box_length_z ? box_length_z : box_length_y;
                    coinslot_center_y = box_length_y/2;
                    coinslot_center_z = box_length_z/2;
                    coinslot_radius = (min_length / 2) - (box_side3_coinslots_diameter/2) - box_wall_thick;
                    coinslot_degree = 360 / box_side3_coinslots_amount;
                    //If more than 1 Coin
                    if (box_side3_coinslots_amount > 1) {
                        for(i = [1: 1 : box_side3_coinslots_amount]) {
                            move ([box_length_x + 0.1, coinslot_center_y + (coinslot_radius * cos(coinslot_degree*i+box_side3_coinslots_rotate)), coinslot_center_z + (coinslot_radius * sin(coinslot_degree*i+box_side3_coinslots_rotate))]) xcyl(h=box_side3_coinslots_depth + .1, r=(box_side3_coinslots_diameter/2), anchor=RIGHT);
                        }
                    }
                    //If 1 Coin
                    else {
                        move ([-0.1, coinslot_center_y, coinslot_center_z]) xcyl(h=box_side1_coinslots_depth + .1, r=(box_side1_coinslots_diameter/2), anchor=RIGHT);
                    }
                }
                //if Side 3 slot is Plate and Card Grab
                if (box_side3_slot == "plate" && box_cardgrab == true) {
                    move ([box_length_x +.1, box_length_y/2, (box_length_z - box_cardgrab_height)/2]) cube([box_side3_plateslot_depth + 0.1, box_side3_plateslot_width, box_side3_plateslot_height], anchor=RIGHT);
                }
                //If Side 3 Slot is Coins and Card Grab
                else if (box_side3_slot == "coins" && box_cardgrab == true) {
                    min_length = box_length_y > (box_length_z - box_cardgrab_height) ? (box_length_z - box_cardgrab_height) : box_length_y;
                    coinslot_center_y = box_length_y/2;
                    coinslot_center_z = (box_length_z - box_cardgrab_height)/2;
                    coinslot_radius = (min_length / 2) - (box_side3_coinslots_diameter/2) - box_wall_thick;
                    coinslot_degree = 360 / box_side3_coinslots_amount;
                    //If more than 1 Coin
                    if (box_side3_coinslots_amount > 1) {
                        for(i = [1: 1 : box_side3_coinslots_amount]) {
                            move ([box_length_x + 0.1, coinslot_center_y + (coinslot_radius * cos(coinslot_degree*i+box_side3_coinslots_rotate)), coinslot_center_z + (coinslot_radius * sin(coinslot_degree*i+box_side3_coinslots_rotate))]) xcyl(h=box_side3_coinslots_depth + .1, r=(box_side3_coinslots_diameter/2), anchor=RIGHT);
                        }
                    }
                    //If 1 Coin
                    else {
                        move ([-0.1, coinslot_center_y, coinslot_center_]) xcyl(h=box_side1_coinslots_depth + .1, r=(box_side1_coinslots_diameter/2), anchor=RIGHT);
                    }
                }
                                
                //If Side 4 slot is Plate
                if (box_side4_slot == "plate") {
                    move ([box_length_x/2, -0.1, box_length_z/2]) cube([box_side4_plateslot_width, box_side4_plateslot_depth + 0.1, box_side4_plateslot_height], anchor=FRONT);
                }
                //If Side 4 Slot is Coins
                else if (box_side4_slot == "coins") {
                    min_length = box_length_x > box_length_z ? box_length_z : box_length_x;
                    coinslot_center_x = box_length_x/2;
                    coinslot_center_z = box_length_z/2;
                    coinslot_radius = (min_length / 2) - (box_side4_coinslots_diameter/2) - box_wall_thick;
                    coinslot_degree = 360 / box_side4_coinslots_amount;
                    //If more than 1 Coin
                    if (box_side4_coinslots_amount > 1) {
                        for(i = [1: 1 : box_side4_coinslots_amount]) {
                            move ([coinslot_center_x + (coinslot_radius * cos(coinslot_degree*i+box_side4_coinslots_rotate)), -0.1, coinslot_center_z + (coinslot_radius * sin(coinslot_degree*i+box_side4_coinslots_rotate))]) ycyl(h=box_side4_coinslots_depth + .1, r=(box_side4_coinslots_diameter/2), anchor=FRONT);
                        }
                    }
                    //If 1 Coin
                    else {
                        move ([-0.1, coinslot_center_x, coinslot_center_z]) xcyl(h=box_side4_coinslots_depth + .1, r=(box_side4_coinslots_diameter/2), anchor=FRONT);
                    }
                }
            }
        }
        
        //No Edge Rounding, Edge Clipping
        else if(edge_rounding == 0 && edge_clipping>0) {
            difference() {
                cuboid([box_length_x, box_length_y, box_length_z], chamfer=edge_clipping, anchor=FRONT+LEFT+BOT, trimcorners=trim_corners);
                
                //Calculate if Lid needs a Back or not per box_lid_noback
                box_lid_length_y = box_lid_noback == true ? box_length_y * 1.2 : box_length_y - box_wall_thick + 1.1;
                
                //If lid secure is Dovetail, Remove Lid
                if(box_lid_secure == "dovetail"){
                    move ([box_wall_thick * 0.75, -0.1, box_length_z - box_lid_thick + 0.1]) prismoid(size1=[(idb_length_x + (box_wall_thick * 0.5)), box_lid_length_y],size2=[idb_length_x, box_lid_length_y], h=(box_lid_thick + .01), anchor=FRONT+LEFT+BOT);
                }
                
                //If lid secure is Groove, Remove Lid
                else if(box_lid_secure=="groove"){
                    move ([box_wall_thick, -0.1, box_length_z - box_lid_thick + 0.1]) cube([idb_length_x, box_lid_length_y, (box_lid_thick + .1)], anchor=FRONT+LEFT+BOT);
                    move ([box_wall_thick * 0.75, -0.1, box_length_z - box_lid_thick + 0.1]) cube([(box_wall_thick * 0.25) + 0.1, box_lid_length_y, (box_lid_thick * 0.5)], anchor=FRONT+LEFT+BOT);
                    move ([box_length_x - box_wall_thick - 0.1, -0.1, box_length_z - box_lid_thick + 0.1]) cube([box_wall_thick * .25, box_lid_length_y, (box_lid_thick * 0.5)], anchor=FRONT+LEFT+BOT);
                }
                
                //If lid secure is none, Remove Lid
                else {
                    move ([box_wall_thick, -.1, box_length_z - box_lid_thick + 0.1]) cube([idb_length_x, box_lid_length_y, (box_lid_thick + .1)], anchor=FRONT+LEFT+BOT);
                }
                
                //remove IDB
                move ([box_length_x - box_wall_thick, box_length_y - box_wall_thick, box_length_z - box_wall_thick + 0.2]) cube([idb_length_x,idb_length_y,(idb_length_z + .2)], anchor=BACK+RIGHT+TOP);
                
                //If Card Grab, Remove Card Grab
                if (box_cardgrab){
                    move([-0.1, box_length_y - box_wall_thick - (idb_length_y / 2), box_length_z - box_cardgrab_height]) xcyl(h=(box_length_x+10), r=(box_cardgrab_width/2), anchor=LEFT+BOT);
                    move([-0.1, box_length_y - box_wall_thick - (idb_length_y / 2), box_length_z - (box_cardgrab_height - (box_cardgrab_width / 2))]) cube([(box_length_x+10), box_cardgrab_width, box_length_z], anchor=LEFT+BOT);
                }
                
                //If Magnets, Remove Magnet Slots
                if (box_lid_magnet_amount > 0) {
                    box_lid_magnet_spacing = idb_length_x / box_lid_magnet_amount;
                    for(a = [1 : 1 : box_lid_magnet_amount]) {
                        move([box_wall_thick + ((idb_length_x/(box_lid_magnet_amount + 1)) * a), box_length_y - box_wall_thick - 0.1 + 1, box_length_z - (box_lid_thick / 2)]) ycyl(h=(box_lid_magnet_depth + 0.1), d=(box_lid_magnet_diameter + 0.1), anchor=FRONT);
                    }
                }
                
                //If Side 1 Slot is Plate and no Card Grab
                if (box_side1_slot == "plate" && box_cardgrab == false) {
                    move ([-0.1, box_length_y/2, box_length_z/2]) cube([box_side1_plateslot_depth + 0.1, box_side1_plateslot_width, box_side1_plateslot_height], anchor=LEFT);
                }
                //If Side 1 Slot is Coins and no Card Grab
                else if (box_side1_slot == "coins" && box_cardgrab == false) {
                    min_length = box_length_y > box_length_z ? box_length_z : box_length_y;
                    coinslot_center_y = box_length_y/2;
                    coinslot_center_z = box_length_z/2;
                    coinslot_radius = (min_length / 2) - (box_side1_coinslots_diameter/2) - box_wall_thick;
                    coinslot_degree = 360 / box_side1_coinslots_amount;
                    //If more than 1 Coin
                    if (box_side1_coinslots_amount > 1) {
                        for(i = [1: 1 : box_side1_coinslots_amount]) {
                            move ([-0.1, coinslot_center_y + (coinslot_radius * cos(coinslot_degree*i+box_side1_coinslots_rotate)), coinslot_center_z + (coinslot_radius * sin(coinslot_degree*i+box_side1_coinslots_rotate))]) xcyl(h=box_side1_coinslots_depth + .1, r=(box_side1_coinslots_diameter/2), anchor=LEFT);
                        }
                    }
                    //If 1 Coin
                    else {
                        move ([-0.1, coinslot_center_y, coinslot_center_z]) xcyl(h=box_side1_coinslots_depth + .1, r=(box_side1_coinslots_diameter/2), anchor=LEFT);
                    }
                }
                //If Side 1 Slot is Plate and Card Grab
                else if (box_side1_slot == "plate" && box_cardgrab == true) {
                    move ([-0.1, box_length_y/2, (box_length_z - box_cardgrab_height)/2]) cube([box_side1_plateslot_depth + 0.1, box_side1_plateslot_width, box_side1_plateslot_height], anchor=LEFT);
                }
                //if Side 1 Slot is Coins and Card Grab
                else if (box_side1_slot == "coins" && box_cardgrab == true) {
                    min_length = box_length_y > (box_length_z - box_cardgrab_height) ? (box_length_z - box_cardgrab_height) : box_length_y;
                    coinslot_center_y = box_length_y/2;
                    coinslot_center_z = (box_length_z - box_cardgrab_height)/2;
                    coinslot_radius = (min_length / 2) - (box_side1_coinslots_diameter/2) - box_wall_thick;
                    coinslot_degree = 360 / box_side1_coinslots_amount;
                    //If more than 1 Coin
                    if (box_side1_coinslots_amount > 1) {
                        for(i = [1: 1 : box_side1_coinslots_amount]) {
                            move ([-0.1, coinslot_center_y + (coinslot_radius * cos(coinslot_degree*i+box_side1_coinslots_rotate)), coinslot_center_z + (coinslot_radius * sin(coinslot_degree*i+box_side1_coinslots_rotate))]) xcyl(h=box_side1_coinslots_depth + .1, r=(box_side1_coinslots_diameter/2), anchor=LEFT);
                        }
                    }
                    //If 1 Coin
                    else {
                        move ([-0.1, coinslot_center_y, coinslot_center_z]) xcyl(h=box_side1_coinslots_depth + 0.1, r=(box_side1_coinslots_diameter/2), anchor=LEFT);
                    }
                }
                
                //If Side 2 slot is Plate
                if (box_side2_slot == "plate") {
                    move ([box_length_x/2, box_length_y + 0.1, box_length_z/2]) cube([box_side2_plateslot_width, box_side2_plateslot_depth + 0.1, box_side2_plateslot_height], anchor=BACK);
                }
                //If Side 2 Slot is Coins
                else if (box_side2_slot == "coins") {
                    min_length = box_length_x > box_length_z ? box_length_z : box_length_x;
                    coinslot_center_x = box_length_x/2;
                    coinslot_center_z = box_length_z/2;
                    coinslot_radius = (min_length / 2) - (box_side2_coinslots_diameter/2) - box_wall_thick;
                    coinslot_degree = 360 / box_side2_coinslots_amount;
                    //If more than 1 Coin
                    if (box_side2_coinslots_amount > 1) {
                        for(i = [1: 1 : box_side2_coinslots_amount]) {
                            move ([coinslot_center_x + (coinslot_radius * cos(coinslot_degree*i+box_side2_coinslots_rotate)), box_length_y +0.1, coinslot_center_z + (coinslot_radius * sin(coinslot_degree*i+box_side2_coinslots_rotate))]) ycyl(h=box_side2_coinslots_depth + 0.1, r=(box_side2_coinslots_diameter/2), anchor=BACK);
                        }
                    }
                    //If 1 Coin
                    else {
                        move ([-0.1, coinslot_center_x, coinslot_center_z]) xcyl(h=box_side2_coinslots_depth + 0.1, r=(box_side2_coinslots_diameter/2), anchor=BACK);
                    }
                }
                
                //If Side 3 Slot is Plate and No Card Grab
                if (box_side3_slot == "plate" && box_cardgrab == false) {
                    move ([box_length_x + 0.1, box_length_y/2, box_length_z/2]) cube([box_side3_plateslot_depth + 0.1, box_side3_plateslot_width, box_side3_plateslot_height], anchor=RIGHT);
                }
                //If Side 3 Slot is Coins and No Card Grab
                else if (box_side3_slot == "coins" && box_cardgrab == false) {
                    min_length = box_length_y > box_length_z ? box_length_z : box_length_y;
                    coinslot_center_y = box_length_y/2;
                    coinslot_center_z = box_length_z/2;
                    coinslot_radius = (min_length / 2) - (box_side3_coinslots_diameter/2) - box_wall_thick;
                    coinslot_degree = 360 / box_side3_coinslots_amount;
                    //If more than 1 Coin
                    if (box_side3_coinslots_amount > 1) {
                        for(i = [1: 1 : box_side3_coinslots_amount]) {
                            move ([box_length_x + 0.1, coinslot_center_y + (coinslot_radius * cos(coinslot_degree*i+box_side3_coinslots_rotate)), coinslot_center_z + (coinslot_radius * sin(coinslot_degree*i+box_side3_coinslots_rotate))]) xcyl(h=box_side3_coinslots_depth + .1, r=(box_side3_coinslots_diameter/2), anchor=RIGHT);
                        }
                    }
                    //If 1 Coin
                    else {
                        move ([-0.1, coinslot_center_y, coinslot_center_z]) xcyl(h=box_side1_coinslots_depth + .1, r=(box_side1_coinslots_diameter/2), anchor=RIGHT);
                    }
                }
                //if Side 3 slot is Plate and Card Grab
                if (box_side3_slot == "plate" && box_cardgrab == true) {
                    move ([box_length_x + 0.1, box_length_y/2, (box_length_z - box_cardgrab_height)/2]) cube([box_side3_plateslot_depth + 0.1, box_side3_plateslot_width, box_side3_plateslot_height], anchor=RIGHT);
                }
                //If Side 3 Slot is Coins and Card Grab
                else if (box_side3_slot == "coins" && box_cardgrab == true) {
                    min_length = box_length_y > (box_length_z - box_cardgrab_height) ? (box_length_z - box_cardgrab_height) : box_length_y;
                    coinslot_center_y = box_length_y/2;
                    coinslot_center_z = (box_length_z - box_cardgrab_height)/2;
                    coinslot_radius = (min_length / 2) - (box_side3_coinslots_diameter/2) - box_wall_thick;
                    coinslot_degree = 360 / box_side3_coinslots_amount;
                    //If more than 1 Coin
                    if (box_side3_coinslots_amount > 1) {
                        for(i = [1: 1 : box_side3_coinslots_amount]) {
                            move ([box_length_x + 0.1, coinslot_center_y + (coinslot_radius * cos(coinslot_degree*i+box_side3_coinslots_rotate)), coinslot_center_z + (coinslot_radius * sin(coinslot_degree*i+box_side3_coinslots_rotate))]) xcyl(h=box_side3_coinslots_depth + .1, r=(box_side3_coinslots_diameter/2), anchor=RIGHT);
                        }
                    }
                    //If 1 Coin
                    else {
                        move ([-0.1, coinslot_center_y, coinslot_center_z]) xcyl(h=box_side1_coinslots_depth + .1, r=(box_side1_coinslots_diameter/2), anchor=RIGHT);
                    }
                }
                                
                //If Side 4 slot is Plate
                if (box_side4_slot == "plate") {
                    move ([box_length_x/2, -0.1, box_length_z/2]) cube([box_side4_plateslot_width, box_side4_plateslot_depth + 0.1, box_side4_plateslot_height], anchor=FRONT);
                }
                //If Side 4 Slot is Coins
                else if (box_side4_slot == "coins") {
                    min_length = box_length_x > box_length_z ? box_length_z : box_length_x;
                    coinslot_center_x = box_length_x/2;
                    coinslot_center_z = box_length_z/2;
                    coinslot_radius = (min_length / 2) - (box_side4_coinslots_diameter/2) - box_wall_thick;
                    coinslot_degree = 360 / box_side4_coinslots_amount;
                    //If more than 1 Coin
                    if (box_side4_coinslots_amount > 1) {
                        for(i = [1: 1 : box_side4_coinslots_amount]) {
                            move ([coinslot_center_x + (coinslot_radius * cos(coinslot_degree*i+box_side4_coinslots_rotate)), -0.1, coinslot_center_z + (coinslot_radius * sin(coinslot_degree*i+box_side4_coinslots_rotate))]) ycyl(h=box_side4_coinslots_depth + .1, r=(box_side4_coinslots_diameter/2), anchor=FRONT);
                        }
                    }
                    //If 1 Coin
                    else {
                        move ([-0.1, coinslot_center_x, coinslot_center_z]) xcyl(h=box_side4_coinslots_depth + .1, r=(box_side4_coinslots_diameter/2), anchor=FRONT);
                    }
                }
            }
            
        }
        
        //Edge Rounding, Ignores Edge Clipping
        else {
            difference() {
                cuboid([box_length_x, box_length_y, box_length_z], rounding = edge_rounding, anchor=FRONT+LEFT+BOT, trimcorners=trim_corners);
                
                //Calculate if Lid needs a Back or not per box_lid_noback
                box_lid_length_y = box_lid_noback == true ? box_length_y * 1.2 : box_length_y - box_wall_thick + 1.1;
                
                //If lid secure is Dovetail, Remove Lid
                if(box_lid_secure == "dovetail"){
                    move ([box_wall_thick * 0.75, -0.1, box_length_z - box_lid_thick + 0.1]) prismoid(size1=[(idb_length_x + (box_wall_thick * 0.5)), box_lid_length_y],size2=[idb_length_x, box_lid_length_y], h=(box_lid_thick + .01), anchor=FRONT+LEFT+BOT);
                }
                
                //If lid secure is Groove, Remove Lid
                else if(box_lid_secure=="groove"){
                    move ([box_wall_thick, -0.1, box_length_z - box_lid_thick + 0.1]) cube([idb_length_x, box_lid_length_y, (box_lid_thick + .1)], anchor=FRONT+LEFT+BOT);
                    move ([box_wall_thick * 0.75, -0.1, box_length_z - box_lid_thick + 0.1]) cube([(box_wall_thick * 0.25) + 0.1, box_lid_length_y, (box_lid_thick * 0.5)], anchor=FRONT+LEFT+BOT);
                    move ([box_length_x - box_wall_thick - 0.1, -0.1, box_length_z - box_lid_thick + 0.1]) cube([box_wall_thick * .25, box_lid_length_y, (box_lid_thick * 0.5)], anchor=FRONT+LEFT+BOT);
                }
                
                //If lid secure is none, Remove Lid
                else {
                    move ([box_wall_thick, -0.1, box_length_z - box_lid_thick + 0.1]) cube([idb_length_x, box_lid_length_y, (box_lid_thick + .1)], anchor=FRONT+LEFT+BOT);
                }
                
                //remove IDB
                move ([box_length_x - box_wall_thick, box_length_y - box_wall_thick, box_length_z - box_wall_thick + 0.2]) cube([idb_length_x,idb_length_y,(idb_length_z + .2)], anchor=BACK+RIGHT+TOP);
                
                //If Card Grab, Remove Card Grab
                if (box_cardgrab){
                    move([-0.1, box_length_y - box_wall_thick - (idb_length_y / 2), box_length_z - box_cardgrab_height]) xcyl(h=(box_length_x+10), r=(box_cardgrab_width/2), anchor=LEFT+BOT);
                    move([-0.1, box_length_y - box_wall_thick - (idb_length_y / 2), box_length_z - (box_cardgrab_height - (box_cardgrab_width / 2))]) cube([(box_length_x+10), box_cardgrab_width, box_length_z], anchor=LEFT+BOT);
                }
                
                //If Magnets, Remove Magnet Slots
                if (box_lid_magnet_amount > 0) {
                    box_lid_magnet_spacing = idb_length_x / box_lid_magnet_amount;
                    for(a = [1 : 1 : box_lid_magnet_amount]) {
                        move([box_wall_thick + ((idb_length_x/(box_lid_magnet_amount + 1)) * a), box_length_y - box_wall_thick - 0.1 + 1, box_length_z - (box_lid_thick / 2)]) ycyl(h=(box_lid_magnet_depth + 0.1), d=(box_lid_magnet_diameter + 0.1), anchor=FRONT);
                    }
                }
                
                //If Side 1 Slot is Plate and no Card Grab
                if (box_side1_slot == "plate" && box_cardgrab == false) {
                    move ([-0.1, box_length_y/2, box_length_z/2]) cube([box_side1_plateslot_depth + 0.1, box_side1_plateslot_width, box_side1_plateslot_height], anchor=LEFT);
                }
                //If Side 1 Slot is Coins and no Card Grab
                else if (box_side1_slot == "coins" && box_cardgrab == false) {
                    min_length = box_length_y > box_length_z ? box_length_z : box_length_y;
                    coinslot_center_y = box_length_y/2;
                    coinslot_center_z = box_length_z/2;
                    coinslot_radius = (min_length / 2) - (box_side1_coinslots_diameter/2) - box_wall_thick;
                    coinslot_degree = 360 / box_side1_coinslots_amount;
                    //If more than 1 Coin
                    if (box_side1_coinslots_amount > 1) {
                        for(i = [1: 1 : box_side1_coinslots_amount]) {
                            move ([-0.1, coinslot_center_y + (coinslot_radius * cos(coinslot_degree*i+box_side1_coinslots_rotate)), coinslot_center_z + (coinslot_radius * sin(coinslot_degree*i+box_side1_coinslots_rotate))]) xcyl(h=box_side1_coinslots_depth + .1, r=(box_side1_coinslots_diameter/2), anchor=LEFT);
                        }
                    }
                    //If 1 Coin
                    else {
                        move ([-0.1, coinslot_center_y, coinslot_center_z]) xcyl(h=box_side1_coinslots_depth + .1, r=(box_side1_coinslots_diameter/2), anchor=LEFT);
                    }
                }
                //If Side 1 Slot is Plate and Card Grab
                else if (box_side1_slot == "plate" && box_cardgrab == true) {
                    move ([-0.1, box_length_y/2, (box_length_z - box_cardgrab_height)/2]) cube([box_side1_plateslot_depth + 0.1, box_side1_plateslot_width, box_side1_plateslot_height], anchor=LEFT);
                }
                //if Side 1 Slot is Coins and Card Grab
                else if (box_side1_slot == "coins" && box_cardgrab == true) {
                    min_length = box_length_y > (box_length_z - box_cardgrab_height) ? (box_length_z - box_cardgrab_height) : box_length_y;
                    coinslot_center_y = box_length_y/2;
                    coinslot_center_z = (box_length_z - box_cardgrab_height)/2;
                    coinslot_radius = (min_length / 2) - (box_side1_coinslots_diameter/2) - box_wall_thick;
                    coinslot_degree = 360 / box_side1_coinslots_amount;
                    //If more than 1 Coin
                    if (box_side1_coinslots_amount > 1) {
                        for(i = [1: 1 : box_side1_coinslots_amount]) {
                            move ([-0.1, coinslot_center_y + (coinslot_radius * cos(coinslot_degree*i+box_side1_coinslots_rotate)), coinslot_center_z + (coinslot_radius * sin(coinslot_degree*i+box_side1_coinslots_rotate))]) xcyl(h=box_side1_coinslots_depth + .1, r=(box_side1_coinslots_diameter/2), anchor=LEFT);
                        }
                    }
                    //If 1 Coin
                    else {
                        move ([-0.1, coinslot_center_y, coinslot_center_z]) xcyl(h=box_side1_coinslots_depth + 0.1, r=(box_side1_coinslots_diameter/2), anchor=LEFT);
                    }
                }
                
                //If Side 2 slot is Plate
                if (box_side2_slot == "plate") {
                    move ([box_length_x/2, box_length_y + 0.1, box_length_z/2]) cube([box_side2_plateslot_width, box_side2_plateslot_depth + 0.1, box_side2_plateslot_height], anchor=BACK);
                }
                //If Side 2 Slot is Coins
                else if (box_side2_slot == "coins") {
                    min_length = box_length_x > box_length_z ? box_length_z : box_length_x;
                    coinslot_center_x = box_length_x/2;
                    coinslot_center_z = box_length_z/2;
                    coinslot_radius = (min_length / 2) - (box_side2_coinslots_diameter/2) - box_wall_thick;
                    coinslot_degree = 360 / box_side2_coinslots_amount;
                    //If more than 1 Coin
                    if (box_side2_coinslots_amount > 1) {
                        for(i = [1: 1 : box_side2_coinslots_amount]) {
                            move ([coinslot_center_x + (coinslot_radius * cos(coinslot_degree*i+box_side2_coinslots_rotate)), box_length_y + 0.1, coinslot_center_z + (coinslot_radius * sin(coinslot_degree*i+box_side2_coinslots_rotate))]) ycyl(h=box_side2_coinslots_depth + 0.1, r=(box_side2_coinslots_diameter/2), anchor=BACK);
                        }
                    }
                    //If 1 Coin
                    else {
                        move ([-0.1, coinslot_center_x, coinslot_center_z]) xcyl(h=box_side2_coinslots_depth + 0.1, r=(box_side2_coinslots_diameter/2), anchor=BACK);
                    }
                }
                
                //If Side 3 Slot is Plate and No Card Grab
                if (box_side3_slot == "plate" && box_cardgrab == false) {
                    move ([box_length_x + 0.1, box_length_y/2, box_length_z/2]) cube([box_side3_plateslot_depth + 0.1, box_side3_plateslot_width, box_side3_plateslot_height], anchor=RIGHT);
                }
                //If Side 3 Slot is Coins and No Card Grab
                else if (box_side3_slot == "coins" && box_cardgrab == false) {
                    min_length = box_length_y > box_length_z ? box_length_z : box_length_y;
                    coinslot_center_y = box_length_y/2;
                    coinslot_center_z = box_length_z/2;
                    coinslot_radius = (min_length / 2) - (box_side3_coinslots_diameter/2) - box_wall_thick;
                    coinslot_degree = 360 / box_side3_coinslots_amount;
                    //If more than 1 Coin
                    if (box_side3_coinslots_amount > 1) {
                        for(i = [1: 1 : box_side3_coinslots_amount]) {
                            move ([box_length_x + 0.1, coinslot_center_y + (coinslot_radius * cos(coinslot_degree*i+box_side3_coinslots_rotate)), coinslot_center_z + (coinslot_radius * sin(coinslot_degree*i+box_side3_coinslots_rotate))]) xcyl(h=box_side3_coinslots_depth + .1, r=(box_side3_coinslots_diameter/2), anchor=RIGHT);
                        }
                    }
                    //If 1 Coin
                    else {
                        move ([-0.1, coinslot_center_y, coinslot_center_z]) xcyl(h=box_side1_coinslots_depth + .1, r=(box_side1_coinslots_diameter/2), anchor=RIGHT);
                    }
                }
                //if Side 3 slot is Plate and Card Grab
                if (box_side3_slot == "plate" && box_cardgrab == true) {
                    move ([box_length_x + 0.1, box_length_y/2, (box_length_z - box_cardgrab_height)/2]) cube([box_side3_plateslot_depth + 0.1, box_side3_plateslot_width, box_side3_plateslot_height], anchor=RIGHT);
                }
                //If Side 3 Slot is Coins and Card Grab
                else if (box_side3_slot == "coins" && box_cardgrab == true) {
                    min_length = box_length_y > (box_length_z - box_cardgrab_height) ? (box_length_z - box_cardgrab_height) : box_length_y;
                    coinslot_center_y = box_length_y/2;
                    coinslot_center_z = (box_length_z - box_cardgrab_height)/2;
                    coinslot_radius = (min_length / 2) - (box_side3_coinslots_diameter/2) - box_wall_thick;
                    coinslot_degree = 360 / box_side3_coinslots_amount;
                    //If more than 1 Coin
                    if (box_side3_coinslots_amount > 1) {
                        for(i = [1: 1 : box_side3_coinslots_amount]) {
                            move ([box_length_x + 0.1, coinslot_center_y + (coinslot_radius * cos(coinslot_degree*i+box_side3_coinslots_rotate)), coinslot_center_z + (coinslot_radius * sin(coinslot_degree*i+box_side3_coinslots_rotate))]) xcyl(h=box_side3_coinslots_depth + .1, r=(box_side3_coinslots_diameter/2), anchor=RIGHT);
                        }
                    }
                    //If 1 Coin
                    else {
                        move ([-0.1, coinslot_center_y, coinslot_center_z]) xcyl(h=box_side1_coinslots_depth + .1, r=(box_side1_coinslots_diameter/2), anchor=RIGHT);
                    }
                }
                                
                //If Side 4 slot is Plate
                if (box_side4_slot == "plate") {
                    move ([box_length_x/2, -0.1, box_length_z/2]) cube([box_side4_plateslot_width, box_side4_plateslot_depth + 0.1, box_side4_plateslot_height], anchor=FRONT);
                }
                //If Side 4 Slot is Coins
                else if (box_side4_slot == "coins") {
                    min_length = box_length_x > box_length_z ? box_length_z : box_length_x;
                    coinslot_center_x = box_length_x/2;
                    coinslot_center_z = box_length_z/2;
                    coinslot_radius = (min_length / 2) - (box_side4_coinslots_diameter/2) - box_wall_thick;
                    coinslot_degree = 360 / box_side4_coinslots_amount;
                    //If more than 1 Coin
                    if (box_side4_coinslots_amount > 1) {
                        for(i = [1: 1 : box_side4_coinslots_amount]) {
                            move ([coinslot_center_x + (coinslot_radius * cos(coinslot_degree*i+box_side4_coinslots_rotate)), -0.1, coinslot_center_z + (coinslot_radius * sin(coinslot_degree*i+box_side4_coinslots_rotate))]) ycyl(h=box_side4_coinslots_depth + .1, r=(box_side4_coinslots_diameter/2), anchor=FRONT);
                        }
                    }
                    //If 1 Coin
                    else {
                        move ([-0.1, coinslot_center_x, coinslot_center_z]) xcyl(h=box_side4_coinslots_depth + .1, r=(box_side4_coinslots_diameter/2), anchor=FRONT);
                    }
                }
            }
        }
     }
}

/*
 * Lid Generation Module
 * 
 * This module is used to Generate the Deck box Lid.
 * Should not be called outside of this script.
 * TODO:
 *  Optimize and turn into further Modules
 */

module drawLid(){
    if (box_commander_slot) {
        //Calculate if Lid needs a Back or not per box_lid_noback
        box_lid_length_y = box_lid_noback == true ? box_length_y : idb_length_y + (box_wall_thick * 1.5) + cmd_length_y + 1.1;

        //If no Edge Rounding or Edge Clipping
        if(edge_rounding == 0 && edge_clipping==0) {
            
            //If lid secure is Dovetail, Remove Lid
            if(box_lid_secure == "dovetail"){
                difference() {
                    union() {
                        //Makes Cube first, then Makes Dovetail bit 75% box_wall_thick back for chamfering/rounding purposes
                        cuboid([idb_length_x, box_lid_length_y, (box_lid_thick + 0.1)], anchor=FRONT+LEFT+BOT);
                        translate([-(box_wall_thick * .25), (box_wall_thick * .75), 0]) prismoid(size1=[(idb_length_x + (box_wall_thick * 0.5)), box_lid_length_y - (box_wall_thick * .75)],size2=[idb_length_x, box_lid_length_y - (box_wall_thick * .75)], h=(box_lid_thick + .01), anchor=FRONT+LEFT+BOT);
                        translate([(box_wall_thick * .25), -(box_wall_thick * .75), 0]);
                    }
                    //Removes Magnet Slots
                    if (box_lid_magnet_amount > 0) {
                        box_lid_magnet_spacing = idb_length_x / box_lid_magnet_amount;
                        for(a = [1: 1: box_lid_magnet_amount]) {
                            translate([((idb_length_x / (box_lid_magnet_amount + 1)) * a), (box_lid_length_y + 0.1), ((box_lid_thick) / 2)]) ycyl(h=(box_lid_magnet_depth + .1), d=(box_lid_magnet_diameter + .1), anchor=BACK);
                            translate([-((idb_length_x / (box_lid_magnet_amount + 1)) * a), -(box_lid_length_y + 0.1), -((box_lid_thick - box_lid_magnet_diameter) / 2)]);
                        }
                    }
                    //Removes Box Lid Divot
                    if (box_lid_divot_depth > 0) {
                        translate([(idb_length_x / 2), box_lid_divot_depth + box_wall_thick, box_lid_thick]) xcyl(r=box_lid_divot_depth, h=idb_length_x - (box_wall_thick * 2));
                    }
                    
                    //If Lid Slot is Plate
                    if (box_lid_slot == "plate") {
                        translate([idb_length_x / 2, box_lid_length_y - ((box_lid_length_y - (box_lid_divot_depth * 2) - (box_wall_thick))/2), box_lid_thick + 0.1]) cuboid([box_lid_plateslot_width, box_lid_plateslot_height, box_lid_plateslot_depth + 0.1]);
                    }
                    
                    //If Lid Slot is Coins
                    else if (box_lid_slot == "coins") {
                        min_length = idb_length_x > (box_lid_length_y - (box_wall_thick * 2) - (box_lid_divot_depth*2)) ? (box_lid_length_y - (box_wall_thick * 2) - (box_lid_divot_depth*2)) : idb_length_x;
                        coinslot_center_x = idb_length_x/2;
                        coinslot_center_y = box_lid_length_y - ((box_lid_length_y - (box_lid_divot_depth * 2) - box_wall_thick)/2);
                        coinslot_radius = (min_length / 2) - (box_lid_coinslots_diameter / 2);
                        coinslot_degree = 360 / box_lid_coinslots_amount; 
                        //If more than 1 Coin
                        if(box_lid_coinslots_amount > 1) {
                            for(i = [1: 1 : box_lid_coinslots_amount]) {
                                translate([coinslot_center_x + (coinslot_radius * cos(coinslot_degree*i+box_lid_coinslots_rotate)), coinslot_center_y + (coinslot_radius * sin(coinslot_degree*i+box_lid_coinslots_rotate)), box_lid_thick + 0.2]) zcyl(h=box_lid_coinslots_depth + 0.2, r=(box_lid_coinslots_diameter/2), anchor=TOP);
                            }
                        }
                        //If 1 Coin
                        else {
                            translate([coinslot_center_x, coinslot_center_y, box_lid_thick + 0.1]) zcyl(h=box_lid_coinslots_depth + 0.2, r=(box_lid_coinslots_diameter/2), anchor=TOP);
                        }
                    }
                }
            }
            //If lid secure is Groove, Remove Lid
            else if(box_lid_secure=="groove"){
                difference() {
                    union() {
                        //Makes Cube for lid first, then adds Grooves to the sides
                        cuboid([idb_length_x, box_lid_length_y, (box_lid_thick + 0.1)], anchor=FRONT+LEFT+BOT, chamfer=edge_rounding, edges=[FRONT+TOP]);
                        cuboid([(box_wall_thick * 0.25), box_lid_length_y, (box_lid_thick * 0.5)], anchor=FRONT+RIGHT+BOT);
                        translate([idb_length_x, 0, 0,]) cube([(box_wall_thick * 0.25), box_lid_length_y, (box_lid_thick * 0.5)], anchor=FRONT+LEFT+BOT);
                        translate([-idb_length_x, 0, 0,]);
                    }
                    //Removes Magnet Slots
                    if (box_lid_magnet_amount > 0) {
                        box_lid_magnet_spacing = idb_length_x / box_lid_magnet_amount;
                        for(a = [1: 1: box_lid_magnet_amount]) {
                            translate([((idb_length_x / (box_lid_magnet_amount + 1)) * a), (box_lid_length_y + 0.1), ((box_lid_thick) / 2)]) ycyl(h=(box_lid_magnet_depth + .1), d=(box_lid_magnet_diameter + .1), anchor=BACK);
                            translate([-((idb_length_x / (box_lid_magnet_amount + 1)) * a), -(box_lid_length_y + 0.1), -((box_lid_thick - box_lid_magnet_diameter) / 2)]);
                        }
                    }
                    //Removes Box Lid Divot
                    if (box_lid_divot_depth > 0) {
                        translate([(idb_length_x / 2), box_lid_divot_depth + box_wall_thick, box_lid_thick]) xcyl(r=box_lid_divot_depth, h=idb_length_x - (box_wall_thick * 2));
                    }
                }
            }
                    
            //If lid secure is none, Remove Lid
            else {
                difference() {
                    cuboid([idb_length_x, box_lid_length_y, (box_lid_thick + .1)], anchor=FRONT+LEFT+BOT);
                    //Removes Magnet Slots
                    if (box_lid_magnet_amount > 0) {
                        box_lid_magnet_spacing = idb_length_x / box_lid_magnet_amount;
                        for(a = [1: 1: box_lid_magnet_amount]) {
                            translate([((idb_length_x / (box_lid_magnet_amount + 1)) * a), (box_lid_length_y + 0.1), ((box_lid_thick) / 2)]) ycyl(h=(box_lid_magnet_depth + .1), d=(box_lid_magnet_diameter + .1), anchor=BACK);
                            translate([-((idb_length_x / (box_lid_magnet_amount + 1)) * a), -(box_lid_length_y + 0.1), -((box_lid_thick - box_lid_magnet_diameter) / 2)]);
                        }
                    }
                    //Removes Box Lid Divot
                    if (box_lid_divot_depth > 0) {
                        translate([(idb_length_x / 2), box_lid_divot_depth + box_wall_thick, box_lid_thick]) xcyl(r=box_lid_divot_depth, h=idb_length_x - (box_wall_thick * 2));
                    }
                    
                    //If Lid Slot is Plate
                    if (box_lid_slot == "plate") {
                        translate([idb_length_x / 2, box_lid_length_y - ((box_lid_length_y - (box_lid_divot_depth * 2) - (box_wall_thick))/2), box_lid_thick + 0.1]) cuboid([box_lid_plateslot_width, box_lid_plateslot_height, box_lid_plateslot_depth + 0.1]);
                    }
                    
                    //If Lid Slot is Coins
                    else if (box_lid_slot == "coins") {
                        min_length = idb_length_x > (box_lid_length_y - (box_wall_thick * 2) - (box_lid_divot_depth*2)) ? (box_lid_length_y - (box_wall_thick * 2) - (box_lid_divot_depth*2)) : idb_length_x;
                        coinslot_center_x = idb_length_x/2;
                        coinslot_center_y = box_lid_length_y - ((box_lid_length_y - (box_lid_divot_depth * 2) - box_wall_thick)/2);
                        coinslot_radius = (min_length / 2) - (box_lid_coinslots_diameter / 2);
                        coinslot_degree = 360 / box_lid_coinslots_amount; 
                        //If more than 1 Coin
                        if(box_lid_coinslots_amount > 1) {
                            for(i = [1: 1 : box_lid_coinslots_amount]) {
                                translate([coinslot_center_x + (coinslot_radius * cos(coinslot_degree*i+box_lid_coinslots_rotate)), coinslot_center_y + (coinslot_radius * sin(coinslot_degree*i+box_lid_coinslots_rotate)), box_lid_thick + 0.2]) zcyl(h=box_lid_coinslots_depth + 0.2, r=(box_lid_coinslots_diameter/2), anchor=TOP);
                            }
                        }
                        //If 1 Coin
                        else {
                            translate([coinslot_center_x, coinslot_center_y, box_lid_thick + 0.1]) zcyl(h=box_lid_coinslots_depth + 0.2, r=(box_lid_coinslots_diameter/2), anchor=TOP);
                        }
                    }
                }
            }
        }
        
        //No Edge Rounding, Edge Clipping
        else if(edge_rounding == 0 && edge_clipping>0) {
            //If lid secure is Dovetail, Remove Lid
            if(box_lid_secure == "dovetail"){
                difference() {
                    union() {
                        //Makes Cube first, then Makes Dovetail bit 75% box_wall_thick back for chamfering/rounding purposes
                        cuboid([idb_length_x, box_lid_length_y, (box_lid_thick + 0.1)], anchor=FRONT+LEFT+BOT, chamfer=edge_clipping, edges=[TOP+FRONT]);
                        translate([-(box_wall_thick * .25), (box_wall_thick * .75), 0]) prismoid(size1=[(idb_length_x + (box_wall_thick * 0.5)), box_lid_length_y - (box_wall_thick * .75)],size2=[idb_length_x, box_lid_length_y - (box_wall_thick * .75)], h=(box_lid_thick + .01), anchor=FRONT+LEFT+BOT);
                        translate([(box_wall_thick * .25), -(box_wall_thick * .75), 0]);
                    }
                    //Removes Magnet Slots
                    if (box_lid_magnet_amount > 0) {
                        box_lid_magnet_spacing = idb_length_x / box_lid_magnet_amount;
                        for(a = [1: 1: box_lid_magnet_amount]) {
                            translate([((idb_length_x / (box_lid_magnet_amount + 1)) * a), (box_lid_length_y + 0.1), ((box_lid_thick) / 2)]) ycyl(h=(box_lid_magnet_depth + .1), d=(box_lid_magnet_diameter + .1), anchor=BACK);
                            translate([-((idb_length_x / (box_lid_magnet_amount + 1)) * a), -(box_lid_length_y + 0.1), -((box_lid_thick - box_lid_magnet_diameter) / 2)]);
                        }
                    }
                    //Removes Box Lid Divot
                    if (box_lid_divot_depth > 0) {
                        translate([(idb_length_x / 2), box_lid_divot_depth + box_wall_thick, box_lid_thick]) xcyl(r=box_lid_divot_depth, h=idb_length_x - (box_wall_thick * 2));
                    }
                    
                    //If Lid Slot is Plate
                    if (box_lid_slot == "plate") {
                        translate([idb_length_x / 2, box_lid_length_y - ((box_lid_length_y - (box_lid_divot_depth * 2) - (box_wall_thick))/2), box_lid_thick + 0.1]) cuboid([box_lid_plateslot_width, box_lid_plateslot_height, box_lid_plateslot_depth + 0.1]);
                    }
                    
                    //If Lid Slot is Coins
                    else if (box_lid_slot == "coins") {
                        min_length = idb_length_x > (box_lid_length_y - (box_wall_thick * 2) - (box_lid_divot_depth*2)) ? (box_lid_length_y - (box_wall_thick * 2) - (box_lid_divot_depth*2)) : idb_length_x;
                        coinslot_center_x = idb_length_x/2;
                        coinslot_center_y = box_lid_length_y - ((box_lid_length_y - (box_lid_divot_depth * 2) - box_wall_thick)/2);
                        coinslot_radius = (min_length / 2) - (box_lid_coinslots_diameter / 2);
                        coinslot_degree = 360 / box_lid_coinslots_amount; 
                        //If more than 1 Coin
                        if(box_lid_coinslots_amount > 1) {
                            for(i = [1: 1 : box_lid_coinslots_amount]) {
                                translate([coinslot_center_x + (coinslot_radius * cos(coinslot_degree*i+box_lid_coinslots_rotate)), coinslot_center_y + (coinslot_radius * sin(coinslot_degree*i+box_lid_coinslots_rotate)), box_lid_thick + 0.2]) zcyl(h=box_lid_coinslots_depth + 0.2, r=(box_lid_coinslots_diameter/2), anchor=TOP);
                            }
                        }
                        //If 1 Coin
                        else {
                            translate([coinslot_center_x, coinslot_center_y, box_lid_thick + 0.1]) zcyl(h=box_lid_coinslots_depth + 0.2, r=(box_lid_coinslots_diameter/2), anchor=TOP);
                        }
                    }
                }
            }
            //If lid secure is Groove, Remove Lid
            else if(box_lid_secure=="groove"){
                difference() {
                    union() {
                        //Makes Cube for lid first, then adds Grooves to the sides
                        cuboid([idb_length_x, box_lid_length_y, (box_lid_thick + 0.1)], anchor=FRONT+LEFT+BOT, , chamfer=edge_clipping, edges=[TOP+FRONT]);
                        cuboid([(box_wall_thick * 0.25), box_lid_length_y, (box_lid_thick * 0.5)], anchor=FRONT+RIGHT+BOT);
                        translate([idb_length_x, 0, 0,]) cube([(box_wall_thick * 0.25), box_lid_length_y, (box_lid_thick * 0.5)], anchor=FRONT+LEFT+BOT);
                        translate([-idb_length_x, 0, 0,]);
                    }
                    //Removes Magnet Slots
                    if (box_lid_magnet_amount > 0) {
                        box_lid_magnet_spacing = idb_length_x / box_lid_magnet_amount;
                        for(a = [1: 1: box_lid_magnet_amount]) {
                            translate([((idb_length_x / (box_lid_magnet_amount + 1)) * a), (box_lid_length_y + 0.1), ((box_lid_thick) / 2)]) ycyl(h=(box_lid_magnet_depth + .1), d=(box_lid_magnet_diameter + .1), anchor=BACK);
                            translate([-((idb_length_x / (box_lid_magnet_amount + 1)) * a), -(box_lid_length_y + 0.1), -((box_lid_thick - box_lid_magnet_diameter) / 2)]);
                        }
                    }
                    //Removes Box Lid Divot
                    if (box_lid_divot_depth > 0) {
                        translate([(idb_length_x / 2), box_lid_divot_depth + box_wall_thick, box_lid_thick]) xcyl(r=box_lid_divot_depth, h=idb_length_x - (box_wall_thick * 2));
                    }
                    
                    //If Lid Slot is Plate
                    if (box_lid_slot == "plate") {
                        translate([idb_length_x / 2, box_lid_length_y - ((box_lid_length_y - (box_lid_divot_depth * 2) - (box_wall_thick))/2), box_lid_thick + 0.1]) cuboid([box_lid_plateslot_width, box_lid_plateslot_height, box_lid_plateslot_depth + 0.1]);
                    }
                    
                    //If Lid Slot is Coins
                    else if (box_lid_slot == "coins") {
                        min_length = idb_length_x > (box_lid_length_y - (box_wall_thick * 2) - (box_lid_divot_depth*2)) ? (box_lid_length_y - (box_wall_thick * 2) - (box_lid_divot_depth*2)) : idb_length_x;
                        coinslot_center_x = idb_length_x/2;
                        coinslot_center_y = box_lid_length_y - ((box_lid_length_y - (box_lid_divot_depth * 2) - box_wall_thick)/2);
                        coinslot_radius = (min_length / 2) - (box_lid_coinslots_diameter / 2);
                        coinslot_degree = 360 / box_lid_coinslots_amount; 
                        //If more than 1 Coin
                        if(box_lid_coinslots_amount > 1) {
                            for(i = [1: 1 : box_lid_coinslots_amount]) {
                                translate([coinslot_center_x + (coinslot_radius * cos(coinslot_degree*i+box_lid_coinslots_rotate)), coinslot_center_y + (coinslot_radius * sin(coinslot_degree*i+box_lid_coinslots_rotate)), box_lid_thick + 0.2]) zcyl(h=box_lid_coinslots_depth + 0.2, r=(box_lid_coinslots_diameter/2), anchor=TOP);
                            }
                        }
                        //If 1 Coin
                        else {
                            translate([coinslot_center_x, coinslot_center_y, box_lid_thick + 0.1]) zcyl(h=box_lid_coinslots_depth + 0.2, r=(box_lid_coinslots_diameter/2), anchor=TOP);
                        }
                    }
                }
            }
                    
            //If lid secure is none, Remove Lid
            else {
                difference() {
                    cuboid([idb_length_x, box_lid_length_y, (box_lid_thick + .1)], anchor=FRONT+LEFT+BOT, chamfer=edge_clipping, edges=[TOP+FRONT]);
                    //Removes Magnet Slots
                    if (box_lid_magnet_amount > 0) {
                        box_lid_magnet_spacing = idb_length_x / box_lid_magnet_amount;
                        for(a = [1: 1: box_lid_magnet_amount]) {
                            translate([((idb_length_x / (box_lid_magnet_amount + 1)) * a), (box_lid_length_y + 0.1), ((box_lid_thick) / 2)]) ycyl(h=(box_lid_magnet_depth + .1), d=(box_lid_magnet_diameter + .1), anchor=BACK);
                            translate([-((idb_length_x / (box_lid_magnet_amount + 1)) * a), -(box_lid_length_y + 0.1), -((box_lid_thick - box_lid_magnet_diameter) / 2)]);
                        }
                    }
                    //Removes Box Lid Divot
                    if (box_lid_divot_depth > 0) {
                        translate([(idb_length_x / 2), box_lid_divot_depth + box_wall_thick, box_lid_thick]) xcyl(r=box_lid_divot_depth, h=idb_length_x - (box_wall_thick * 2));
                    }
                    
                    //If Lid Slot is Plate
                    if (box_lid_slot == "plate") {
                        translate([idb_length_x / 2, box_lid_length_y - ((box_lid_length_y - (box_lid_divot_depth * 2) - (box_wall_thick))/2), box_lid_thick + 0.1]) cuboid([box_lid_plateslot_width, box_lid_plateslot_height, box_lid_plateslot_depth + 0.1]);
                    }
                    
                    //If Lid Slot is Coins
                    else if (box_lid_slot == "coins") {
                        min_length = idb_length_x > (box_lid_length_y - (box_wall_thick * 2) - (box_lid_divot_depth*2)) ? (box_lid_length_y - (box_wall_thick * 2) - (box_lid_divot_depth*2)) : idb_length_x;
                        coinslot_center_x = idb_length_x/2;
                        coinslot_center_y = box_lid_length_y - ((box_lid_length_y - (box_lid_divot_depth * 2) - box_wall_thick)/2);
                        coinslot_radius = (min_length / 2) - (box_lid_coinslots_diameter / 2);
                        coinslot_degree = 360 / box_lid_coinslots_amount; 
                        //If more than 1 Coin
                        if(box_lid_coinslots_amount > 1) {
                            for(i = [1: 1 : box_lid_coinslots_amount]) {
                                translate([coinslot_center_x + (coinslot_radius * cos(coinslot_degree*i+box_lid_coinslots_rotate)), coinslot_center_y + (coinslot_radius * sin(coinslot_degree*i+box_lid_coinslots_rotate)), box_lid_thick + 0.2]) zcyl(h=box_lid_coinslots_depth + 0.2, r=(box_lid_coinslots_diameter/2), anchor=TOP);
                            }
                        }
                        //If 1 Coin
                        else {
                            translate([coinslot_center_x, coinslot_center_y, box_lid_thick + 0.1]) zcyl(h=box_lid_coinslots_depth + 0.2, r=(box_lid_coinslots_diameter/2), anchor=TOP);
                        }
                    }
                }
            }
        }
        
        //Edge Rounding, Ignores Edge Clipping
        else {
            //If lid secure is Dovetail, Remove Lid
            if(box_lid_secure == "dovetail"){
                difference() {
                    union() {
                        //Makes Cube first, then Makes Dovetail bit 75% box_wall_thick back for chamfering/rounding purposes
                        cuboid([idb_length_x, box_lid_length_y, (box_lid_thick + 0.1)], anchor=FRONT+LEFT+BOT, rounding=edge_rounding, edges=[TOP+FRONT]);
                        translate([-(box_wall_thick * .25), (box_wall_thick * .75), 0]) prismoid(size1=[(idb_length_x + (box_wall_thick * 0.5)), box_lid_length_y - (box_wall_thick * .75)],size2=[idb_length_x, box_lid_length_y - (box_wall_thick * .75)], h=(box_lid_thick + .01), anchor=FRONT+LEFT+BOT);
                        translate([(box_wall_thick * .25), -(box_wall_thick * .75), 0]);
                    }
                    //Removes Magnet Slots
                    if (box_lid_magnet_amount > 0) {
                        box_lid_magnet_spacing = idb_length_x / box_lid_magnet_amount;
                        for(a = [1: 1: box_lid_magnet_amount]) {
                            translate([((idb_length_x / (box_lid_magnet_amount + 1)) * a), (box_lid_length_y + 0.1), ((box_lid_thick) / 2)]) ycyl(h=(box_lid_magnet_depth + .1), d=(box_lid_magnet_diameter + .1), anchor=BACK);
                            translate([-((idb_length_x / (box_lid_magnet_amount + 1)) * a), -(box_lid_length_y + 0.1), -((box_lid_thick - box_lid_magnet_diameter) / 2)]);
                        }
                    }
                    //Removes Box Lid Divot
                    if (box_lid_divot_depth > 0) {
                        translate([(idb_length_x / 2), box_lid_divot_depth + box_wall_thick, box_lid_thick]) xcyl(r=box_lid_divot_depth, h=idb_length_x - (box_wall_thick * 2));
                    }
                    
                    //If Lid Slot is Plate
                    if (box_lid_slot == "plate") {
                        translate([idb_length_x / 2, box_lid_length_y - ((box_lid_length_y - (box_lid_divot_depth * 2) - (box_wall_thick))/2), box_lid_thick + 0.1]) cuboid([box_lid_plateslot_width, box_lid_plateslot_height, box_lid_plateslot_depth + 0.1]);
                    }
                    
                    //If Lid Slot is Coins
                    else if (box_lid_slot == "coins") {
                        min_length = idb_length_x > (box_lid_length_y - (box_wall_thick * 2) - (box_lid_divot_depth*2)) ? (box_lid_length_y - (box_wall_thick * 2) - (box_lid_divot_depth*2)) : idb_length_x;
                        coinslot_center_x = idb_length_x/2;
                        coinslot_center_y = box_lid_length_y - ((box_lid_length_y - (box_lid_divot_depth * 2) - box_wall_thick)/2);
                        coinslot_radius = (min_length / 2) - (box_lid_coinslots_diameter / 2);
                        coinslot_degree = 360 / box_lid_coinslots_amount; 
                        //If more than 1 Coin
                        if(box_lid_coinslots_amount > 1) {
                            for(i = [1: 1 : box_lid_coinslots_amount]) {
                                translate([coinslot_center_x + (coinslot_radius * cos(coinslot_degree*i+box_lid_coinslots_rotate)), coinslot_center_y + (coinslot_radius * sin(coinslot_degree*i+box_lid_coinslots_rotate)), box_lid_thick + 0.2]) zcyl(h=box_lid_coinslots_depth + 0.2, r=(box_lid_coinslots_diameter/2), anchor=TOP);
                            }
                        }
                        //If 1 Coin
                        else {
                            translate([coinslot_center_x, coinslot_center_y, box_lid_thick + 0.1]) zcyl(h=box_lid_coinslots_depth + 0.2, r=(box_lid_coinslots_diameter/2), anchor=TOP);
                        }
                    }
                }
            }
            //If lid secure is Groove, Remove Lid
            else if(box_lid_secure=="groove"){
                difference() {
                    union() {
                        //Makes Cube for lid first, then adds Grooves to the sides
                        cuboid([idb_length_x, box_lid_length_y, (box_lid_thick + 0.1)], anchor=FRONT+LEFT+BOT, rounding=edge_rounding, edges=[TOP+FRONT]);
                        cuboid([(box_wall_thick * 0.25), box_lid_length_y, (box_lid_thick * 0.5)], anchor=FRONT+RIGHT+BOT);
                        translate([idb_length_x, 0, 0,]) cube([(box_wall_thick * 0.25), box_lid_length_y, (box_lid_thick * 0.5)], anchor=FRONT+LEFT+BOT);
                        translate([-idb_length_x, 0, 0,]);
                    }
                    //Removes Magnet Slots
                    if (box_lid_magnet_amount > 0) {
                        box_lid_magnet_spacing = idb_length_x / box_lid_magnet_amount;
                        for(a = [1: 1: box_lid_magnet_amount]) {
                            translate([((idb_length_x / (box_lid_magnet_amount + 1)) * a), (box_lid_length_y + 0.1), ((box_lid_thick) / 2)]) ycyl(h=(box_lid_magnet_depth + .1), d=(box_lid_magnet_diameter + .1), anchor=BACK);
                            translate([-((idb_length_x / (box_lid_magnet_amount + 1)) * a), -(box_lid_length_y + 0.1), -((box_lid_thick - box_lid_magnet_diameter) / 2)]);
                        }
                    }
                    //Removes Box Lid Divot
                    if (box_lid_divot_depth > 0) {
                        translate([(idb_length_x / 2), box_lid_divot_depth + box_wall_thick, box_lid_thick]) xcyl(r=box_lid_divot_depth, h=idb_length_x - (box_wall_thick * 2));
                    }
                    
                    //If Lid Slot is Plate
                    if (box_lid_slot == "plate") {
                        translate([idb_length_x / 2, box_lid_length_y - ((box_lid_length_y - (box_lid_divot_depth * 2) - (box_wall_thick))/2), box_lid_thick + 0.1]) cuboid([box_lid_plateslot_width, box_lid_plateslot_height, box_lid_plateslot_depth + 0.1]);
                    }
                    
                    //If Lid Slot is Coins
                    else if (box_lid_slot == "coins") {
                        min_length = idb_length_x > (box_lid_length_y - (box_wall_thick * 2) - (box_lid_divot_depth*2)) ? (box_lid_length_y - (box_wall_thick * 2) - (box_lid_divot_depth*2)) : idb_length_x;
                        coinslot_center_x = idb_length_x/2;
                        coinslot_center_y = box_lid_length_y - ((box_lid_length_y - (box_lid_divot_depth * 2) - box_wall_thick)/2);
                        coinslot_radius = (min_length / 2) - (box_lid_coinslots_diameter / 2);
                        coinslot_degree = 360 / box_lid_coinslots_amount; 
                        //If more than 1 Coin
                        if(box_lid_coinslots_amount > 1) {
                            for(i = [1: 1 : box_lid_coinslots_amount]) {
                                translate([coinslot_center_x + (coinslot_radius * cos(coinslot_degree*i+box_lid_coinslots_rotate)), coinslot_center_y + (coinslot_radius * sin(coinslot_degree*i+box_lid_coinslots_rotate)), box_lid_thick + 0.2]) zcyl(h=box_lid_coinslots_depth + 0.2, r=(box_lid_coinslots_diameter/2), anchor=TOP);
                            }
                        }
                        //If 1 Coin
                        else {
                            translate([coinslot_center_x, coinslot_center_y, box_lid_thick + 0.1]) zcyl(h=box_lid_coinslots_depth + 0.2, r=(box_lid_coinslots_diameter/2), anchor=TOP);
                        }
                    }
                }
            }
                    
            //If lid secure is none, Remove Lid
            else {
                difference() {
                    cuboid([idb_length_x, box_lid_length_y, (box_lid_thick + .1)], anchor=FRONT+LEFT+BOT, rounding=edge_rounding, edges=[TOP+FRONT]);
                    //Removes Magnet Slots
                    if (box_lid_magnet_amount > 0) {
                        box_lid_magnet_spacing = idb_length_x / box_lid_magnet_amount;
                        for(a = [1: 1: box_lid_magnet_amount]) {
                            translate([((idb_length_x / (box_lid_magnet_amount + 1)) * a), (box_lid_length_y + 0.1), ((box_lid_thick) / 2)]) ycyl(h=(box_lid_magnet_depth + .1), d=(box_lid_magnet_diameter + .1), anchor=BACK);
                            translate([-((idb_length_x / (box_lid_magnet_amount + 1)) * a), -(box_lid_length_y + 0.1), -((box_lid_thick - box_lid_magnet_diameter) / 2)]);
                        }
                    }
                    //Removes Box Lid Divot
                    if (box_lid_divot_depth > 0) {
                        translate([(idb_length_x / 2), box_lid_divot_depth + box_wall_thick, box_lid_thick]) xcyl(r=box_lid_divot_depth, h=idb_length_x - (box_wall_thick * 2));
                    }
                    
                    //If Lid Slot is Plate
                    if (box_lid_slot == "plate") {
                        translate([idb_length_x / 2, box_lid_length_y - ((box_lid_length_y - (box_lid_divot_depth * 2) - (box_wall_thick))/2), box_lid_thick + 0.1]) cuboid([box_lid_plateslot_width, box_lid_plateslot_height, box_lid_plateslot_depth + 0.1]);
                    }
                    
                    //If Lid Slot is Coins
                    else if (box_lid_slot == "coins") {
                        min_length = idb_length_x > (box_lid_length_y - (box_wall_thick * 2) - (box_lid_divot_depth*2)) ? (box_lid_length_y - (box_wall_thick * 2) - (box_lid_divot_depth*2)) : idb_length_x;
                        coinslot_center_x = idb_length_x/2;
                        coinslot_center_y = box_lid_length_y - ((box_lid_length_y - (box_lid_divot_depth * 2) - box_wall_thick)/2);
                        coinslot_radius = (min_length / 2) - (box_lid_coinslots_diameter / 2);
                        coinslot_degree = 360 / box_lid_coinslots_amount; 
                        //If more than 1 Coin
                        if(box_lid_coinslots_amount > 1) {
                            for(i = [1: 1 : box_lid_coinslots_amount]) {
                                translate([coinslot_center_x + (coinslot_radius * cos(coinslot_degree*i+box_lid_coinslots_rotate)), coinslot_center_y + (coinslot_radius * sin(coinslot_degree*i+box_lid_coinslots_rotate)), box_lid_thick + 0.2]) zcyl(h=box_lid_coinslots_depth + 0.2, r=(box_lid_coinslots_diameter/2), anchor=TOP);
                            }
                        }
                        //If 1 Coin
                        else {
                            translate([coinslot_center_x, coinslot_center_y, box_lid_thick + 0.1]) zcyl(h=box_lid_coinslots_depth + 0.2, r=(box_lid_coinslots_diameter/2), anchor=TOP);
                        }
                    }
                }
            }
        }
    }
    
    //Render without a Commander Slot
    else {
        //Calculate if Lid needs a Back or not per box_lid_noback
        box_lid_length_y = box_lid_noback == true ? box_length_y : idb_length_y + box_wall_thick + 1.1;
        
        //If no Edge Rounding or Edge Clipping
        if(edge_rounding == 0 && edge_clipping==0) {
            
            //If lid secure is Dovetail, Remove Lid
            if(box_lid_secure == "dovetail"){
                difference() {
                    union() {
                        //Makes Cube first, then Makes Dovetail bit 75% box_wall_thick back for chamfering/rounding purposes
                        cuboid([idb_length_x, box_lid_length_y, (box_lid_thick + 0.1)], anchor=FRONT+LEFT+BOT);
                        translate([-(box_wall_thick * .25), (box_wall_thick * .75), 0]) prismoid(size1=[(idb_length_x + (box_wall_thick * 0.5)), box_lid_length_y - (box_wall_thick * .75)],size2=[idb_length_x, box_lid_length_y - (box_wall_thick * .75)], h=(box_lid_thick + .01), anchor=FRONT+LEFT+BOT);
                        translate([(box_wall_thick * .25), -(box_wall_thick * .75), 0]);
                    }
                    //Removes Magnet Slots
                    if (box_lid_magnet_amount > 0) {
                        box_lid_magnet_spacing = idb_length_x / box_lid_magnet_amount;
                        for(a = [1: 1: box_lid_magnet_amount]) {
                            translate([((idb_length_x / (box_lid_magnet_amount + 1)) * a), (box_lid_length_y + 0.1), ((box_lid_thick) / 2)]) ycyl(h=(box_lid_magnet_depth + .1), d=(box_lid_magnet_diameter + .1), anchor=BACK);
                            translate([-((idb_length_x / (box_lid_magnet_amount + 1)) * a), -(box_lid_length_y + 0.1), -((box_lid_thick - box_lid_magnet_diameter) / 2)]);
                        }
                    }
                    //Removes Box Lid Divot
                    if (box_lid_divot_depth > 0) {
                        translate([(idb_length_x / 2), box_lid_divot_depth + box_wall_thick, box_lid_thick]) xcyl(r=box_lid_divot_depth, h=idb_length_x - (box_wall_thick * 2));
                    }
                    
                    //If Lid Slot is Plate
                    if (box_lid_slot == "plate") {
                        translate([idb_length_x / 2, box_lid_length_y - ((box_lid_length_y - (box_lid_divot_depth * 2) - (box_wall_thick))/2), box_lid_thick + 0.1]) cuboid([box_lid_plateslot_width, box_lid_plateslot_height, box_lid_plateslot_depth + 0.1]);
                    }
                    
                    //If Lid Slot is Coins
                    else if (box_lid_slot == "coins") {
                        min_length = idb_length_x > (box_lid_length_y - (box_wall_thick * 2) - (box_lid_divot_depth*2)) ? (box_lid_length_y - (box_wall_thick * 2) - (box_lid_divot_depth*2)) : idb_length_x;
                        coinslot_center_x = idb_length_x/2;
                        coinslot_center_y = box_lid_length_y - ((box_lid_length_y - (box_lid_divot_depth * 2) - box_wall_thick)/2);
                        coinslot_radius = (min_length / 2) - (box_lid_coinslots_diameter / 2);
                        coinslot_degree = 360 / box_lid_coinslots_amount; 
                        //If more than 1 Coin
                        if(box_lid_coinslots_amount > 1) {
                            for(i = [1: 1 : box_lid_coinslots_amount]) {
                                translate([coinslot_center_x + (coinslot_radius * cos(coinslot_degree*i+box_lid_coinslots_rotate)), coinslot_center_y + (coinslot_radius * sin(coinslot_degree*i+box_lid_coinslots_rotate)), box_lid_thick + 0.2]) zcyl(h=box_lid_coinslots_depth + 0.2, r=(box_lid_coinslots_diameter/2), anchor=TOP);
                            }
                        }
                        //If 1 Coin
                        else {
                            translate([coinslot_center_x, coinslot_center_y, box_lid_thick + 0.1]) zcyl(h=box_lid_coinslots_depth + 0.2, r=(box_lid_coinslots_diameter/2), anchor=TOP);
                        }
                    }
                }
            }
            //If lid secure is Groove, Remove Lid
            else if(box_lid_secure=="groove"){
                difference() {
                    union() {
                        //Makes Cube for lid first, then adds Grooves to the sides
                        cuboid([idb_length_x, box_lid_length_y, (box_lid_thick + 0.1)], anchor=FRONT+LEFT+BOT, chamfer=edge_rounding, edges=[FRONT+TOP]);
                        cuboid([(box_wall_thick * 0.25), box_lid_length_y, (box_lid_thick * 0.5)], anchor=FRONT+RIGHT+BOT);
                        translate([idb_length_x, 0, 0,]) cube([(box_wall_thick * 0.25), box_lid_length_y, (box_lid_thick * 0.5)], anchor=FRONT+LEFT+BOT);
                        translate([-idb_length_x, 0, 0,]);
                    }
                    //Removes Magnet Slots
                    if (box_lid_magnet_amount > 0) {
                        box_lid_magnet_spacing = idb_length_x / box_lid_magnet_amount;
                        for(a = [1: 1: box_lid_magnet_amount]) {
                            translate([((idb_length_x / (box_lid_magnet_amount + 1)) * a), (box_lid_length_y + 0.1), ((box_lid_thick) / 2)]) ycyl(h=(box_lid_magnet_depth + .1), d=(box_lid_magnet_diameter + .1), anchor=BACK);
                            translate([-((idb_length_x / (box_lid_magnet_amount + 1)) * a), -(box_lid_length_y + 0.1), -((box_lid_thick - box_lid_magnet_diameter) / 2)]);
                        }
                    }
                    //Removes Box Lid Divot
                    if (box_lid_divot_depth > 0) {
                        translate([(idb_length_x / 2), box_lid_divot_depth + box_wall_thick, box_lid_thick]) xcyl(r=box_lid_divot_depth, h=idb_length_x - (box_wall_thick * 2));
                    }
                    
                    //If Lid Slot is Plate
                    if (box_lid_slot == "plate") {
                        translate([idb_length_x / 2, box_lid_length_y - ((box_lid_length_y - (box_lid_divot_depth * 2) - (box_wall_thick))/2), box_lid_thick + 0.1]) cuboid([box_lid_plateslot_width, box_lid_plateslot_height, box_lid_plateslot_depth + 0.1]);
                    }
                    
                    //If Lid Slot is Coins
                    else if (box_lid_slot == "coins") {
                        min_length = idb_length_x > (box_lid_length_y - (box_wall_thick * 2) - (box_lid_divot_depth*2)) ? (box_lid_length_y - (box_wall_thick * 2) - (box_lid_divot_depth*2)) : idb_length_x;
                        coinslot_center_x = idb_length_x/2;
                        coinslot_center_y = box_lid_length_y - ((box_lid_length_y - (box_lid_divot_depth * 2) - box_wall_thick)/2);
                        coinslot_radius = (min_length / 2) - (box_lid_coinslots_diameter / 2);
                        coinslot_degree = 360 / box_lid_coinslots_amount; 
                        //If more than 1 Coin
                        if(box_lid_coinslots_amount > 1) {
                            for(i = [1: 1 : box_lid_coinslots_amount]) {
                                translate([coinslot_center_x + (coinslot_radius * cos(coinslot_degree*i+box_lid_coinslots_rotate)), coinslot_center_y + (coinslot_radius * sin(coinslot_degree*i+box_lid_coinslots_rotate)), box_lid_thick + 0.2]) zcyl(h=box_lid_coinslots_depth + 0.2, r=(box_lid_coinslots_diameter/2), anchor=TOP);
                            }
                        }
                        //If 1 Coin
                        else {
                            translate([coinslot_center_x, coinslot_center_y, box_lid_thick + 0.1]) zcyl(h=box_lid_coinslots_depth + 0.2, r=(box_lid_coinslots_diameter/2), anchor=TOP);
                        }
                    }
                }
            }
                    
            //If lid secure is none, Remove Lid
            else {
                difference() {
                    cuboid([idb_length_x, box_lid_length_y, (box_lid_thick + .1)], anchor=FRONT+LEFT+BOT);
                    //Removes Magnet Slots
                    if (box_lid_magnet_amount > 0) {
                        box_lid_magnet_spacing = idb_length_x / box_lid_magnet_amount;
                        for(a = [1: 1: box_lid_magnet_amount]) {
                            translate([((idb_length_x / (box_lid_magnet_amount + 1)) * a), (box_lid_length_y + 0.1), ((box_lid_thick) / 2)]) ycyl(h=(box_lid_magnet_depth + .1), d=(box_lid_magnet_diameter + .1), anchor=BACK);
                            translate([-((idb_length_x / (box_lid_magnet_amount + 1)) * a), -(box_lid_length_y + 0.1), -((box_lid_thick - box_lid_magnet_diameter) / 2)]);
                        }
                    }
                    //Removes Box Lid Divot
                    if (box_lid_divot_depth > 0) {
                        translate([(idb_length_x / 2), box_lid_divot_depth + box_wall_thick, box_lid_thick]) xcyl(r=box_lid_divot_depth, h=idb_length_x - (box_wall_thick * 2));
                    }
                    
                    //If Lid Slot is Plate
                    if (box_lid_slot == "plate") {
                        translate([idb_length_x / 2, box_lid_length_y - ((box_lid_length_y - (box_lid_divot_depth * 2) - (box_wall_thick))/2), box_lid_thick + 0.1]) cuboid([box_lid_plateslot_width, box_lid_plateslot_height, box_lid_plateslot_depth + 0.1]);
                    }
                    
                    //If Lid Slot is Coins
                    else if (box_lid_slot == "coins") {
                        min_length = idb_length_x > (box_lid_length_y - (box_wall_thick * 2) - (box_lid_divot_depth*2)) ? (box_lid_length_y - (box_wall_thick * 2) - (box_lid_divot_depth*2)) : idb_length_x;
                        coinslot_center_x = idb_length_x/2;
                        coinslot_center_y = box_lid_length_y - ((box_lid_length_y - (box_lid_divot_depth * 2) - box_wall_thick)/2);
                        coinslot_radius = (min_length / 2) - (box_lid_coinslots_diameter / 2);
                        coinslot_degree = 360 / box_lid_coinslots_amount; 
                        //If more than 1 Coin
                        if(box_lid_coinslots_amount > 1) {
                            for(i = [1: 1 : box_lid_coinslots_amount]) {
                                translate([coinslot_center_x + (coinslot_radius * cos(coinslot_degree*i+box_lid_coinslots_rotate)), coinslot_center_y + (coinslot_radius * sin(coinslot_degree*i+box_lid_coinslots_rotate)), box_lid_thick + 0.2]) zcyl(h=box_lid_coinslots_depth + 0.2, r=(box_lid_coinslots_diameter/2), anchor=TOP);
                            }
                        }
                        //If 1 Coin
                        else {
                            translate([coinslot_center_x, coinslot_center_y, box_lid_thick + 0.1]) zcyl(h=box_lid_coinslots_depth + 0.2, r=(box_lid_coinslots_diameter/2), anchor=TOP);
                        }
                    }
                }
            }
        }
        
        //No Edge Rounding, Edge Clipping
        else if(edge_rounding == 0 && edge_clipping>0) {
            //If lid secure is Dovetail, Remove Lid
            if(box_lid_secure == "dovetail"){
                difference() {
                    union() {
                        //Makes Cube first, then Makes Dovetail bit 75% box_wall_thick back for chamfering/rounding purposes
                        cuboid([idb_length_x, box_lid_length_y, (box_lid_thick + 0.1)], anchor=FRONT+LEFT+BOT, chamfer=edge_clipping, edges=[TOP+FRONT]);
                        translate([-(box_wall_thick * .25), (box_wall_thick * .75), 0]) prismoid(size1=[(idb_length_x + (box_wall_thick * 0.5)), box_lid_length_y - (box_wall_thick * .75)],size2=[idb_length_x, box_lid_length_y - (box_wall_thick * .75)], h=(box_lid_thick + .01), anchor=FRONT+LEFT+BOT);
                        translate([(box_wall_thick * .25), -(box_wall_thick * .75), 0]);
                    }
                    //Removes Magnet Slots
                    if (box_lid_magnet_amount > 0) {
                        box_lid_magnet_spacing = idb_length_x / box_lid_magnet_amount;
                        for(a = [1: 1: box_lid_magnet_amount]) {
                            translate([((idb_length_x / (box_lid_magnet_amount + 1)) * a), (box_lid_length_y + 0.1), ((box_lid_thick) / 2)]) ycyl(h=(box_lid_magnet_depth + .1), d=(box_lid_magnet_diameter + .1), anchor=BACK);
                            translate([-((idb_length_x / (box_lid_magnet_amount + 1)) * a), -(box_lid_length_y + 0.1), -((box_lid_thick - box_lid_magnet_diameter) / 2)]);
                        }
                    }
                    //Removes Box Lid Divot
                    if (box_lid_divot_depth > 0) {
                        translate([(idb_length_x / 2), box_lid_divot_depth + box_wall_thick, box_lid_thick]) xcyl(r=box_lid_divot_depth, h=idb_length_x - (box_wall_thick * 2));
                    }
                    
                    //If Lid Slot is Plate
                    if (box_lid_slot == "plate") {
                        translate([idb_length_x / 2, box_lid_length_y - ((box_lid_length_y - (box_lid_divot_depth * 2) - (box_wall_thick))/2), box_lid_thick + 0.1]) cuboid([box_lid_plateslot_width, box_lid_plateslot_height, box_lid_plateslot_depth + 0.1]);
                    }
                    
                    //If Lid Slot is Coins
                    else if (box_lid_slot == "coins") {
                        min_length = idb_length_x > (box_lid_length_y - (box_wall_thick * 2) - (box_lid_divot_depth*2)) ? (box_lid_length_y - (box_wall_thick * 2) - (box_lid_divot_depth*2)) : idb_length_x;
                        coinslot_center_x = idb_length_x/2;
                        coinslot_center_y = box_lid_length_y - ((box_lid_length_y - (box_lid_divot_depth * 2) - box_wall_thick)/2);
                        coinslot_radius = (min_length / 2) - (box_lid_coinslots_diameter / 2);
                        coinslot_degree = 360 / box_lid_coinslots_amount; 
                        //If more than 1 Coin
                        if(box_lid_coinslots_amount > 1) {
                            for(i = [1: 1 : box_lid_coinslots_amount]) {
                                translate([coinslot_center_x + (coinslot_radius * cos(coinslot_degree*i+box_lid_coinslots_rotate)), coinslot_center_y + (coinslot_radius * sin(coinslot_degree*i+box_lid_coinslots_rotate)), box_lid_thick + 0.2]) zcyl(h=box_lid_coinslots_depth + 0.2, r=(box_lid_coinslots_diameter/2), anchor=TOP);
                            }
                        }
                        //If 1 Coin
                        else {
                            translate([coinslot_center_x, coinslot_center_y, box_lid_thick + 0.1]) zcyl(h=box_lid_coinslots_depth + 0.2, r=(box_lid_coinslots_diameter/2), anchor=TOP);
                        }
                    }
                }
            }
            //If lid secure is Groove, Remove Lid
            else if(box_lid_secure=="groove"){
                difference() {
                    union() {
                        //Makes Cube for lid first, then adds Grooves to the sides
                        cuboid([idb_length_x, box_lid_length_y, (box_lid_thick + 0.1)], anchor=FRONT+LEFT+BOT, , chamfer=edge_clipping, edges=[TOP+FRONT]);
                        cuboid([(box_wall_thick * 0.25), box_lid_length_y, (box_lid_thick * 0.5)], anchor=FRONT+RIGHT+BOT);
                        translate([idb_length_x, 0, 0,]) cube([(box_wall_thick * 0.25), box_lid_length_y, (box_lid_thick * 0.5)], anchor=FRONT+LEFT+BOT);
                        translate([-idb_length_x, 0, 0,]);
                    }
                    //Removes Magnet Slots
                    if (box_lid_magnet_amount > 0) {
                        box_lid_magnet_spacing = idb_length_x / box_lid_magnet_amount;
                        for(a = [1: 1: box_lid_magnet_amount]) {
                            translate([((idb_length_x / (box_lid_magnet_amount + 1)) * a), (box_lid_length_y + 0.1), ((box_lid_thick) / 2)]) ycyl(h=(box_lid_magnet_depth + .1), d=(box_lid_magnet_diameter + .1), anchor=BACK);
                            translate([-((idb_length_x / (box_lid_magnet_amount + 1)) * a), -(box_lid_length_y + 0.1), -((box_lid_thick - box_lid_magnet_diameter) / 2)]);
                        }
                    }
                    //Removes Box Lid Divot
                    if (box_lid_divot_depth > 0) {
                        translate([(idb_length_x / 2), box_lid_divot_depth + box_wall_thick, box_lid_thick]) xcyl(r=box_lid_divot_depth, h=idb_length_x - (box_wall_thick * 2));
                    }
                    
                    //If Lid Slot is Plate
                    if (box_lid_slot == "plate") {
                        translate([idb_length_x / 2, box_lid_length_y - ((box_lid_length_y - (box_lid_divot_depth * 2) - (box_wall_thick))/2), box_lid_thick + 0.1]) cuboid([box_lid_plateslot_width, box_lid_plateslot_height, box_lid_plateslot_depth + 0.1]);
                    }
                    
                    //If Lid Slot is Coins
                    else if (box_lid_slot == "coins") {
                        min_length = idb_length_x > (box_lid_length_y - (box_wall_thick * 2) - (box_lid_divot_depth*2)) ? (box_lid_length_y - (box_wall_thick * 2) - (box_lid_divot_depth*2)) : idb_length_x;
                        coinslot_center_x = idb_length_x/2;
                        coinslot_center_y = box_lid_length_y - ((box_lid_length_y - (box_lid_divot_depth * 2) - box_wall_thick)/2);
                        coinslot_radius = (min_length / 2) - (box_lid_coinslots_diameter / 2);
                        coinslot_degree = 360 / box_lid_coinslots_amount; 
                        //If more than 1 Coin
                        if(box_lid_coinslots_amount > 1) {
                            for(i = [1: 1 : box_lid_coinslots_amount]) {
                                translate([coinslot_center_x + (coinslot_radius * cos(coinslot_degree*i+box_lid_coinslots_rotate)), coinslot_center_y + (coinslot_radius * sin(coinslot_degree*i+box_lid_coinslots_rotate)), box_lid_thick + 0.2]) zcyl(h=box_lid_coinslots_depth + 0.2, r=(box_lid_coinslots_diameter/2), anchor=TOP);
                            }
                        }
                        //If 1 Coin
                        else {
                            translate([coinslot_center_x, coinslot_center_y, box_lid_thick + 0.1]) zcyl(h=box_lid_coinslots_depth + 0.2, r=(box_lid_coinslots_diameter/2), anchor=TOP);
                        }
                    }
                }
            }
                    
            //If lid secure is none, Remove Lid
            else {
                difference() {
                    cuboid([idb_length_x, box_lid_length_y, (box_lid_thick + .1)], anchor=FRONT+LEFT+BOT, chamfer=edge_clipping, edges=[TOP+FRONT]);
                    //Removes Magnet Slots
                    if (box_lid_magnet_amount > 0) {
                        box_lid_magnet_spacing = idb_length_x / box_lid_magnet_amount;
                        for(a = [1: 1: box_lid_magnet_amount]) {
                            translate([((idb_length_x / (box_lid_magnet_amount + 1)) * a), (box_lid_length_y + 0.1), ((box_lid_thick) / 2)]) ycyl(h=(box_lid_magnet_depth + .1), d=(box_lid_magnet_diameter + .1), anchor=BACK);
                            translate([-((idb_length_x / (box_lid_magnet_amount + 1)) * a), -(box_lid_length_y + 0.1), -((box_lid_thick - box_lid_magnet_diameter) / 2)]);
                        }
                    }
                    //Removes Box Lid Divot
                    if (box_lid_divot_depth > 0) {
                        translate([(idb_length_x / 2), box_lid_divot_depth + box_wall_thick, box_lid_thick]) xcyl(r=box_lid_divot_depth, h=idb_length_x - (box_wall_thick * 2));
                    }
                    
                    //If Lid Slot is Plate
                    if (box_lid_slot == "plate") {
                        translate([idb_length_x / 2, box_lid_length_y - ((box_lid_length_y - (box_lid_divot_depth * 2) - (box_wall_thick))/2), box_lid_thick + 0.1]) cuboid([box_lid_plateslot_width, box_lid_plateslot_height, box_lid_plateslot_depth + 0.1]);
                    }
                    
                    //If Lid Slot is Coins
                    else if (box_lid_slot == "coins") {
                        min_length = idb_length_x > (box_lid_length_y - (box_wall_thick * 2) - (box_lid_divot_depth*2)) ? (box_lid_length_y - (box_wall_thick * 2) - (box_lid_divot_depth*2)) : idb_length_x;
                        coinslot_center_x = idb_length_x/2;
                        coinslot_center_y = box_lid_length_y - ((box_lid_length_y - (box_lid_divot_depth * 2) - box_wall_thick)/2);
                        coinslot_radius = (min_length / 2) - (box_lid_coinslots_diameter / 2);
                        coinslot_degree = 360 / box_lid_coinslots_amount; 
                        //If more than 1 Coin
                        if(box_lid_coinslots_amount > 1) {
                            for(i = [1: 1 : box_lid_coinslots_amount]) {
                                translate([coinslot_center_x + (coinslot_radius * cos(coinslot_degree*i+box_lid_coinslots_rotate)), coinslot_center_y + (coinslot_radius * sin(coinslot_degree*i+box_lid_coinslots_rotate)), box_lid_thick + 0.2]) zcyl(h=box_lid_coinslots_depth + 0.2, r=(box_lid_coinslots_diameter/2), anchor=TOP);
                            }
                        }
                        //If 1 Coin
                        else {
                            translate([coinslot_center_x, coinslot_center_y, box_lid_thick + 0.1]) zcyl(h=box_lid_coinslots_depth + 0.2, r=(box_lid_coinslots_diameter/2), anchor=TOP);
                        }
                    }
                }
            }
        }
        
        //Edge Rounding, Ignores Edge Clipping
        else {
            //If lid secure is Dovetail, Remove Lid
            if(box_lid_secure == "dovetail"){
                difference() {
                    union() {
                        //Makes Cube first, then Makes Dovetail bit 75% box_wall_thick back for chamfering/rounding purposes
                        cuboid([idb_length_x, box_lid_length_y, (box_lid_thick + 0.1)], anchor=FRONT+LEFT+BOT, rounding=edge_rounding, edges=[TOP+FRONT]);
                        translate([-(box_wall_thick * .25), (box_wall_thick * .75), 0]) prismoid(size1=[(idb_length_x + (box_wall_thick * 0.5)), box_lid_length_y - (box_wall_thick * .75)],size2=[idb_length_x, box_lid_length_y - (box_wall_thick * .75)], h=(box_lid_thick + .01), anchor=FRONT+LEFT+BOT);
                        translate([(box_wall_thick * .25), -(box_wall_thick * .75), 0]);
                    }
                    //Removes Magnet Slots
                    if (box_lid_magnet_amount > 0) {
                        box_lid_magnet_spacing = idb_length_x / box_lid_magnet_amount;
                        for(a = [1: 1: box_lid_magnet_amount]) {
                            translate([((idb_length_x / (box_lid_magnet_amount + 1)) * a), (box_lid_length_y + 0.1), ((box_lid_thick) / 2)]) ycyl(h=(box_lid_magnet_depth + .1), d=(box_lid_magnet_diameter + .1), anchor=BACK);
                            translate([-((idb_length_x / (box_lid_magnet_amount + 1)) * a), -(box_lid_length_y + 0.1), -((box_lid_thick - box_lid_magnet_diameter) / 2)]);
                        }
                    }
                    //Removes Box Lid Divot
                    if (box_lid_divot_depth > 0) {
                        translate([(idb_length_x / 2), box_lid_divot_depth + box_wall_thick, box_lid_thick]) xcyl(r=box_lid_divot_depth, h=idb_length_x - (box_wall_thick * 2));
                    }
                    
                    //If Lid Slot is Plate
                    if (box_lid_slot == "plate") {
                        translate([idb_length_x / 2, box_lid_length_y - ((box_lid_length_y - (box_lid_divot_depth * 2) - (box_wall_thick))/2), box_lid_thick + 0.1]) cuboid([box_lid_plateslot_width, box_lid_plateslot_height, box_lid_plateslot_depth + 0.1]);
                    }
                    
                    //If Lid Slot is Coins
                    else if (box_lid_slot == "coins") {
                        min_length = idb_length_x > (box_lid_length_y - (box_wall_thick * 2) - (box_lid_divot_depth*2)) ? (box_lid_length_y - (box_wall_thick * 2) - (box_lid_divot_depth*2)) : idb_length_x;
                        coinslot_center_x = idb_length_x/2;
                        coinslot_center_y = box_lid_length_y - ((box_lid_length_y - (box_lid_divot_depth * 2) - box_wall_thick)/2);
                        coinslot_radius = (min_length / 2) - (box_lid_coinslots_diameter / 2);
                        coinslot_degree = 360 / box_lid_coinslots_amount; 
                        //If more than 1 Coin
                        if(box_lid_coinslots_amount > 1) {
                            for(i = [1: 1 : box_lid_coinslots_amount]) {
                                translate([coinslot_center_x + (coinslot_radius * cos(coinslot_degree*i+box_lid_coinslots_rotate)), coinslot_center_y + (coinslot_radius * sin(coinslot_degree*i+box_lid_coinslots_rotate)), box_lid_thick + 0.2]) zcyl(h=box_lid_coinslots_depth + 0.2, r=(box_lid_coinslots_diameter/2), anchor=TOP);
                            }
                        }
                        //If 1 Coin
                        else {
                            translate([coinslot_center_x, coinslot_center_y, box_lid_thick + 0.1]) zcyl(h=box_lid_coinslots_depth + 0.2, r=(box_lid_coinslots_diameter/2), anchor=TOP);
                        }
                    }
                }
            }
            //If lid secure is Groove, Remove Lid
            else if(box_lid_secure=="groove"){
                difference() {
                    union() {
                        //Makes Cube for lid first, then adds Grooves to the sides
                        cuboid([idb_length_x, box_lid_length_y, (box_lid_thick + 0.1)], anchor=FRONT+LEFT+BOT, rounding=edge_rounding, edges=[TOP+FRONT]);
                        cuboid([(box_wall_thick * 0.25), box_lid_length_y, (box_lid_thick * 0.5)], anchor=FRONT+RIGHT+BOT);
                        translate([idb_length_x, 0, 0,]) cube([(box_wall_thick * 0.25), box_lid_length_y, (box_lid_thick * 0.5)], anchor=FRONT+LEFT+BOT);
                        translate([-idb_length_x, 0, 0,]);
                    }
                    //Removes Magnet Slots
                    if (box_lid_magnet_amount > 0) {
                        box_lid_magnet_spacing = idb_length_x / box_lid_magnet_amount;
                        for(a = [1: 1: box_lid_magnet_amount]) {
                            translate([((idb_length_x / (box_lid_magnet_amount + 1)) * a), (box_lid_length_y + 0.1), ((box_lid_thick) / 2)]) ycyl(h=(box_lid_magnet_depth + .1), d=(box_lid_magnet_diameter + .1), anchor=BACK);
                            translate([-((idb_length_x / (box_lid_magnet_amount + 1)) * a), -(box_lid_length_y + 0.1), -((box_lid_thick - box_lid_magnet_diameter) / 2)]);
                        }
                    }
                    //Removes Box Lid Divot
                    if (box_lid_divot_depth > 0) {
                        translate([(idb_length_x / 2), box_lid_divot_depth + box_wall_thick, box_lid_thick]) xcyl(r=box_lid_divot_depth, h=idb_length_x - (box_wall_thick * 2));
                    }
                    
                    //If Lid Slot is Plate
                    if (box_lid_slot == "plate") {
                        translate([idb_length_x / 2, box_lid_length_y - ((box_lid_length_y - (box_lid_divot_depth * 2) - (box_wall_thick))/2), box_lid_thick + 0.1]) cuboid([box_lid_plateslot_width, box_lid_plateslot_height, box_lid_plateslot_depth + 0.1]);
                    }
                    
                    //If Lid Slot is Coins
                    else if (box_lid_slot == "coins") {
                        min_length = idb_length_x > (box_lid_length_y - (box_wall_thick * 2) - (box_lid_divot_depth*2)) ? (box_lid_length_y - (box_wall_thick * 2) - (box_lid_divot_depth*2)) : idb_length_x;
                        coinslot_center_x = idb_length_x/2;
                        coinslot_center_y = box_lid_length_y - ((box_lid_length_y - (box_lid_divot_depth * 2) - box_wall_thick)/2);
                        coinslot_radius = (min_length / 2) - (box_lid_coinslots_diameter / 2);
                        coinslot_degree = 360 / box_lid_coinslots_amount; 
                        //If more than 1 Coin
                        if(box_lid_coinslots_amount > 1) {
                            for(i = [1: 1 : box_lid_coinslots_amount]) {
                                translate([coinslot_center_x + (coinslot_radius * cos(coinslot_degree*i+box_lid_coinslots_rotate)), coinslot_center_y + (coinslot_radius * sin(coinslot_degree*i+box_lid_coinslots_rotate)), box_lid_thick + 0.2]) zcyl(h=box_lid_coinslots_depth + 0.2, r=(box_lid_coinslots_diameter/2), anchor=TOP);
                            }
                        }
                        //If 1 Coin
                        else {
                            translate([coinslot_center_x, coinslot_center_y, box_lid_thick + 0.1]) zcyl(h=box_lid_coinslots_depth + 0.2, r=(box_lid_coinslots_diameter/2), anchor=TOP);
                        }
                    }
                }
            }
                    
            //If lid secure is none, Remove Lid
            else {
                difference() {
                    cuboid([idb_length_x, box_lid_length_y, (box_lid_thick + .1)], anchor=FRONT+LEFT+BOT, rounding=edge_rounding, edges=[TOP+FRONT]);
                    //Removes Magnet Slots
                    if (box_lid_magnet_amount > 0) {
                        box_lid_magnet_spacing = idb_length_x / box_lid_magnet_amount;
                        for(a = [1: 1: box_lid_magnet_amount]) {
                            translate([((idb_length_x / (box_lid_magnet_amount + 1)) * a), (box_lid_length_y + 0.1), ((box_lid_thick) / 2)]) ycyl(h=(box_lid_magnet_depth + .1), d=(box_lid_magnet_diameter + .1), anchor=BACK);
                            translate([-((idb_length_x / (box_lid_magnet_amount + 1)) * a), -(box_lid_length_y + 0.1), -((box_lid_thick - box_lid_magnet_diameter) / 2)]);
                        }
                    }
                    //Removes Box Lid Divot
                    if (box_lid_divot_depth > 0) {
                        translate([(idb_length_x / 2), box_lid_divot_depth + box_wall_thick, box_lid_thick]) xcyl(r=box_lid_divot_depth, h=idb_length_x - (box_wall_thick * 2));
                    }
                    
                    //If Lid Slot is Plate
                    if (box_lid_slot == "plate") {
                        translate([idb_length_x / 2, box_lid_length_y - ((box_lid_length_y - (box_lid_divot_depth * 2) - (box_wall_thick))/2), box_lid_thick + 0.1]) cuboid([box_lid_plateslot_width, box_lid_plateslot_height, box_lid_plateslot_depth + 0.1]);
                    }
                    
                    //If Lid Slot is Coins
                    else if (box_lid_slot == "coins") {
                        min_length = idb_length_x > (box_lid_length_y - (box_wall_thick * 2) - (box_lid_divot_depth*2)) ? (box_lid_length_y - (box_wall_thick * 2) - (box_lid_divot_depth*2)) : idb_length_x;
                        coinslot_center_x = idb_length_x/2;
                        coinslot_center_y = box_lid_length_y - ((box_lid_length_y - (box_lid_divot_depth * 2) - box_wall_thick)/2);
                        coinslot_radius = (min_length / 2) - (box_lid_coinslots_diameter / 2);
                        coinslot_degree = 360 / box_lid_coinslots_amount; 
                        //If more than 1 Coin
                        if(box_lid_coinslots_amount > 1) {
                            for(i = [1: 1 : box_lid_coinslots_amount]) {
                                translate([coinslot_center_x + (coinslot_radius * cos(coinslot_degree*i+box_lid_coinslots_rotate)), coinslot_center_y + (coinslot_radius * sin(coinslot_degree*i+box_lid_coinslots_rotate)), box_lid_thick + 0.2]) zcyl(h=box_lid_coinslots_depth + 0.2, r=(box_lid_coinslots_diameter/2), anchor=TOP);
                            }
                        }
                        //If 1 Coin
                        else {
                            translate([coinslot_center_x, coinslot_center_y, box_lid_thick + 0.1]) zcyl(h=box_lid_coinslots_depth + 0.2, r=(box_lid_coinslots_diameter/2), anchor=TOP);
                        }
                    }
                }
            }
        }
    }   
}
; HEADER_BLOCK_START
; BambuStudio 02.02.02.56
; model printing time: 1h 10m 18s; total estimated time: 1h 16m 7s
; total layer number: 6
; total filament length [mm] : 5320.00,4077.05,4092.02
; total filament volume [cm^3] : 12796.10,9806.45,9842.45
; total filament weight [g] : 16.12,12.36,12.40
; filament_density: 1.26,1.26,1.26
; filament_diameter: 1.75,1.75,1.75
; max_z_height: 1.05
; filament: 1,2,3
; HEADER_BLOCK_END

; CONFIG_BLOCK_START
; accel_to_decel_enable = 0
; accel_to_decel_factor = 50%
; activate_air_filtration = 0,0,0
; additional_cooling_fan_speed = 70,70,70
; apply_scarf_seam_on_circles = 1
; apply_top_surface_compensation = 0
; auxiliary_fan = 0
; bed_custom_model = /Applications/BambuStudio.app/Contents/Resources/profiles/BBL/bbl-3dp-A1M.stl
; bed_custom_texture = 
; bed_exclude_area = 
; bed_temperature_formula = by_first_filament
; before_layer_change_gcode = 
; best_object_pos = 0.7,0.5
; bottom_color_penetration_layers = 4
; bottom_shell_layers = 4
; bottom_shell_thickness = 0
; bottom_surface_pattern = monotonic
; bridge_angle = 0
; bridge_flow = 1
; bridge_no_support = 0
; bridge_speed = 50
; brim_object_gap = 0.1
; brim_type = auto_brim
; brim_width = 5
; chamber_temperatures = 0,0,0
; change_filament_gcode = ;===== machine: A1 mini =========================\n;===== date: 20231225 =======================\nG392 S0\nM1007 S0\nM620 S[next_extruder]A\nM204 S9000\n{if toolchange_count > 1}\nG17\nG2 Z{max_layer_z + 0.4} I0.86 J0.86 P1 F10000 ; spiral lift a little from second lift\n{endif}\nG1 Z{max_layer_z + 3.0} F1200\n\nM400\nM106 P1 S0\nM106 P2 S0\n{if old_filament_temp > 142 && next_extruder < 255}\nM104 S[old_filament_temp]\n{endif}\n\nG1 X180 F18000\nM620.1 E F[old_filament_e_feedrate] T{nozzle_temperature_range_high[previous_extruder]}\nM620.10 A0 F[old_filament_e_feedrate]\nT[next_extruder]\nM620.1 E F[new_filament_e_feedrate] T{nozzle_temperature_range_high[next_extruder]}\nM620.10 A1 F[new_filament_e_feedrate] L[flush_length] H[nozzle_diameter] T[nozzle_temperature_range_high]\n\nG1 Y90 F9000\n\n{if next_extruder < 255}\nM400\n\nG92 E0\nM628 S0\n\n{if flush_length_1 > 1}\n; FLUSH_START\n; always use highest temperature to flush\nM400\nM1002 set_filament_type:UNKNOWN\nM109 S[nozzle_temperature_range_high]\nM106 P1 S60\n{if flush_length_1 > 23.7}\nG1 E23.7 F{old_filament_e_feedrate} ; do not need pulsatile flushing for start part\nG1 E{(flush_length_1 - 23.7) * 0.02} F50\nG1 E{(flush_length_1 - 23.7) * 0.23} F{old_filament_e_feedrate}\nG1 E{(flush_length_1 - 23.7) * 0.02} F50\nG1 E{(flush_length_1 - 23.7) * 0.23} F{new_filament_e_feedrate}\nG1 E{(flush_length_1 - 23.7) * 0.02} F50\nG1 E{(flush_length_1 - 23.7) * 0.23} F{new_filament_e_feedrate}\nG1 E{(flush_length_1 - 23.7) * 0.02} F50\nG1 E{(flush_length_1 - 23.7) * 0.23} F{new_filament_e_feedrate}\n{else}\nG1 E{flush_length_1} F{old_filament_e_feedrate}\n{endif}\n; FLUSH_END\nG1 E-[old_retract_length_toolchange] F1800\nG1 E[old_retract_length_toolchange] F300\nM400\nM1002 set_filament_type:{filament_type[next_extruder]}\n{endif}\n\n{if flush_length_1 > 45 && flush_length_2 > 1}\n; WIPE\nM400\nM106 P1 S178\nM400 S3\nG1 X-3.5 F18000\nG1 X-13.5 F3000\nG1 X-3.5 F18000\nG1 X-13.5 F3000\nG1 X-3.5 F18000\nG1 X-13.5 F3000\nM400\nM106 P1 S0\n{endif}\n\n{if flush_length_2 > 1}\nM106 P1 S60\n; FLUSH_START\nG1 E{flush_length_2 * 0.18} F{new_filament_e_feedrate}\nG1 E{flush_length_2 * 0.02} F50\nG1 E{flush_length_2 * 0.18} F{new_filament_e_feedrate}\nG1 E{flush_length_2 * 0.02} F50\nG1 E{flush_length_2 * 0.18} F{new_filament_e_feedrate}\nG1 E{flush_length_2 * 0.02} F50\nG1 E{flush_length_2 * 0.18} F{new_filament_e_feedrate}\nG1 E{flush_length_2 * 0.02} F50\nG1 E{flush_length_2 * 0.18} F{new_filament_e_feedrate}\nG1 E{flush_length_2 * 0.02} F50\n; FLUSH_END\nG1 E-[new_retract_length_toolchange] F1800\nG1 E[new_retract_length_toolchange] F300\n{endif}\n\n{if flush_length_2 > 45 && flush_length_3 > 1}\n; WIPE\nM400\nM106 P1 S178\nM400 S3\nG1 X-3.5 F18000\nG1 X-13.5 F3000\nG1 X-3.5 F18000\nG1 X-13.5 F3000\nG1 X-3.5 F18000\nG1 X-13.5 F3000\nM400\nM106 P1 S0\n{endif}\n\n{if flush_length_3 > 1}\nM106 P1 S60\n; FLUSH_START\nG1 E{flush_length_3 * 0.18} F{new_filament_e_feedrate}\nG1 E{flush_length_3 * 0.02} F50\nG1 E{flush_length_3 * 0.18} F{new_filament_e_feedrate}\nG1 E{flush_length_3 * 0.02} F50\nG1 E{flush_length_3 * 0.18} F{new_filament_e_feedrate}\nG1 E{flush_length_3 * 0.02} F50\nG1 E{flush_length_3 * 0.18} F{new_filament_e_feedrate}\nG1 E{flush_length_3 * 0.02} F50\nG1 E{flush_length_3 * 0.18} F{new_filament_e_feedrate}\nG1 E{flush_length_3 * 0.02} F50\n; FLUSH_END\nG1 E-[new_retract_length_toolchange] F1800\nG1 E[new_retract_length_toolchange] F300\n{endif}\n\n{if flush_length_3 > 45 && flush_length_4 > 1}\n; WIPE\nM400\nM106 P1 S178\nM400 S3\nG1 X-3.5 F18000\nG1 X-13.5 F3000\nG1 X-3.5 F18000\nG1 X-13.5 F3000\nG1 X-3.5 F18000\nG1 X-13.5 F3000\nM400\nM106 P1 S0\n{endif}\n\n{if flush_length_4 > 1}\nM106 P1 S60\n; FLUSH_START\nG1 E{flush_length_4 * 0.18} F{new_filament_e_feedrate}\nG1 E{flush_length_4 * 0.02} F50\nG1 E{flush_length_4 * 0.18} F{new_filament_e_feedrate}\nG1 E{flush_length_4 * 0.02} F50\nG1 E{flush_length_4 * 0.18} F{new_filament_e_feedrate}\nG1 E{flush_length_4 * 0.02} F50\nG1 E{flush_length_4 * 0.18} F{new_filament_e_feedrate}\nG1 E{flush_length_4 * 0.02} F50\nG1 E{flush_length_4 * 0.18} F{new_filament_e_feedrate}\nG1 E{flush_length_4 * 0.02} F50\n; FLUSH_END\n{endif}\n\nM629\n\nM400\nM106 P1 S60\nM109 S[new_filament_temp]\nG1 E5 F{new_filament_e_feedrate} ;Compensate for filament spillage during waiting temperature\nM400\nG92 E0\nG1 E-[new_retract_length_toolchange] F1800\nM400\nM106 P1 S178\nM400 S3\nG1 X-3.5 F18000\nG1 X-13.5 F3000\nG1 X-3.5 F18000\nG1 X-13.5 F3000\nG1 X-3.5 F18000\nG1 X-13.5 F3000\nG1 X-3.5 F18000\nM400\nG1 Z{max_layer_z + 3.0} F3000\nM106 P1 S0\n{if layer_z <= (initial_layer_print_height + 0.001)}\nM204 S[initial_layer_acceleration]\n{else}\nM204 S[default_acceleration]\n{endif}\n{else}\nG1 X[x_after_toolchange] Y[y_after_toolchange] Z[z_after_toolchange] F12000\n{endif}\nM621 S[next_extruder]A\n\nM9833 F{outer_wall_volumetric_speed/2.4} A0.3 ; cali dynamic extrusion compensation\nM1002 judge_flag filament_need_cali_flag\nM622 J1\n  M106 P1 S178\n  M400 S7\n  G1 X0 F18000\n  G1 X-13.5 F3000\n  G1 X0 F18000 ;wipe and shake\n  G1 X-13.5 F3000\n  G1 X0 F12000 ;wipe and shake\n  G1 X-13.5 F3000\n  M400\n  M106 P1 S0 \nM623\n\nG392 S0\nM1007 S1\n\n
; circle_compensation_manual_offset = 0
; circle_compensation_speed = 200,200,200
; close_fan_the_first_x_layers = 4,4,4
; complete_print_exhaust_fan_speed = 70,70,70
; cool_plate_temp = 35,35,35
; cool_plate_temp_initial_layer = 35,35,35
; counter_coef_1 = 0,0,0
; counter_coef_2 = 0.008,0.008,0.008
; counter_coef_3 = -0.041,-0.041,-0.041
; counter_limit_max = 0.033,0.033,0.033
; counter_limit_min = -0.035,-0.035,-0.035
; curr_bed_type = High Temp Plate
; default_acceleration = 3000
; default_filament_colour = ;;
; default_filament_profile = "Bambu PLA Basic @BBL A1M"
; default_jerk = 0
; default_nozzle_volume_type = Standard
; default_print_profile = 0.20mm Standard @BBL A1M
; deretraction_speed = 30
; detect_floating_vertical_shell = 1
; detect_narrow_internal_solid_infill = 1
; detect_overhang_wall = 1
; detect_thin_wall = 0
; diameter_limit = 50,50,50
; different_settings_to_system = enable_prime_tower;enable_support;initial_layer_infill_speed;initial_layer_print_height;initial_layer_speed;support_critical_regions_only;close_fan_the_first_x_layers;fan_max_speed;fan_min_speed;hot_plate_temp;hot_plate_temp_initial_layer;nozzle_temperature;nozzle_temperature_initial_layer;close_fan_the_first_x_layers;fan_max_speed;fan_min_speed;hot_plate_temp;hot_plate_temp_initial_layer;nozzle_temperature;nozzle_temperature_initial_layer;close_fan_the_first_x_layers;fan_max_speed;fan_min_speed;hot_plate_temp;hot_plate_temp_initial_layer;nozzle_temperature;nozzle_temperature_initial_layer;bed_custom_model;change_filament_gcode;extruder_clearance_height_to_lid;machine_start_gcode;time_lapse_gcode;upward_compatible_machine
; draft_shield = disabled
; during_print_exhaust_fan_speed = 70,70,70
; elefant_foot_compensation = 0
; enable_arc_fitting = 1
; enable_circle_compensation = 0
; enable_height_slowdown = 0
; enable_long_retraction_when_cut = 2
; enable_overhang_bridge_fan = 1,1,1
; enable_overhang_speed = 1
; enable_pre_heating = 0
; enable_pressure_advance = 0,0,0
; enable_prime_tower = 0
; enable_support = 1
; enable_wrapping_detection = 0
; enforce_support_layers = 0
; eng_plate_temp = 0,0,0
; eng_plate_temp_initial_layer = 0,0,0
; ensure_vertical_shell_thickness = enabled
; exclude_object = 1
; extruder_ams_count = 1#0|4#0;1#0|4#0
; extruder_clearance_dist_to_rod = 56.5
; extruder_clearance_height_to_lid = 90
; extruder_clearance_height_to_rod = 25
; extruder_clearance_max_radius = 73
; extruder_colour = #018001
; extruder_offset = 0x0
; extruder_printable_area = 
; extruder_type = Direct Drive
; extruder_variant_list = "Direct Drive Standard"
; fan_cooling_layer_time = 80,80,80
; fan_max_speed = 100,100,100
; fan_min_speed = 100,100,100
; filament_adaptive_volumetric_speed = 0,0,0
; filament_adhesiveness_category = 100,100,100
; filament_change_length = 5,5,5
; filament_colour = #C2C1C2;#00C8B9;#FF0000
; filament_colour_type = 1;1;1
; filament_cost = 24.99,24.99,24.99
; filament_density = 1.26,1.26,1.26
; filament_diameter = 1.75,1.75,1.75
; filament_end_gcode = "; filament end gcode \n\n";"; filament end gcode \n\n";"; filament end gcode \n\n"
; filament_extruder_variant = "Direct Drive Standard";"Direct Drive Standard";"Direct Drive Standard"
; filament_flow_ratio = 0.98,0.98,0.98
; filament_flush_temp = 0,0,0
; filament_flush_volumetric_speed = 0,0,0
; filament_ids = ;;
; filament_is_support = 0,0,0
; filament_long_retractions_when_cut = 1,1,1
; filament_map = 1,1,1
; filament_map_mode = Auto For Flush
; filament_max_volumetric_speed = 21,21,21
; filament_minimal_purge_on_wipe_tower = 15,15,15
; filament_multi_colour = #C2C1C2;#00C8B9;#FF0000
; filament_notes = 
; filament_pre_cooling_temperature = 0,0,0
; filament_prime_volume = 30,30,30
; filament_printable = 3,3,3
; filament_ramming_travel_time = 0,0,0
; filament_ramming_volumetric_speed = -1,-1,-1
; filament_retraction_distances_when_cut = 18,18,18
; filament_scarf_gap = 0%,0%,0%
; filament_scarf_height = 10%,10%,10%
; filament_scarf_length = 10,10,10
; filament_scarf_seam_type = none,none,none
; filament_self_index = 1,2,3
; filament_settings_id = "Vitacore M123 good";"Vitacore M123 good";"Vitacore M123 good"
; filament_shrink = 100%,100%,100%
; filament_soluble = 0,0,0
; filament_start_gcode = "; filament start gcode\n{if  (bed_temperature[current_extruder] >55)||(bed_temperature_initial_layer[current_extruder] >55)}M106 P3 S200\n{elsif(bed_temperature[current_extruder] >50)||(bed_temperature_initial_layer[current_extruder] >50)}M106 P3 S150\n{elsif(bed_temperature[current_extruder] >45)||(bed_temperature_initial_layer[current_extruder] >45)}M106 P3 S50\n{endif}\n\n{if activate_air_filtration[current_extruder] && support_air_filtration}\nM106 P3 S{during_print_exhaust_fan_speed_num[current_extruder]} \n{endif}";"; filament start gcode\n{if  (bed_temperature[current_extruder] >55)||(bed_temperature_initial_layer[current_extruder] >55)}M106 P3 S200\n{elsif(bed_temperature[current_extruder] >50)||(bed_temperature_initial_layer[current_extruder] >50)}M106 P3 S150\n{elsif(bed_temperature[current_extruder] >45)||(bed_temperature_initial_layer[current_extruder] >45)}M106 P3 S50\n{endif}\n\n{if activate_air_filtration[current_extruder] && support_air_filtration}\nM106 P3 S{during_print_exhaust_fan_speed_num[current_extruder]} \n{endif}";"; filament start gcode\n{if  (bed_temperature[current_extruder] >55)||(bed_temperature_initial_layer[current_extruder] >55)}M106 P3 S200\n{elsif(bed_temperature[current_extruder] >50)||(bed_temperature_initial_layer[current_extruder] >50)}M106 P3 S150\n{elsif(bed_temperature[current_extruder] >45)||(bed_temperature_initial_layer[current_extruder] >45)}M106 P3 S50\n{endif}\n\n{if activate_air_filtration[current_extruder] && support_air_filtration}\nM106 P3 S{during_print_exhaust_fan_speed_num[current_extruder]} \n{endif}"
; filament_type = PLA;PLA;PLA
; filament_velocity_adaptation_factor = 1,1,1
; filament_vendor = "Bambu Lab";"Bambu Lab";"Bambu Lab"
; filename_format = {input_filename_base}_{filament_type[0]}_{print_time}.gcode
; filter_out_gap_fill = 0
; first_layer_print_sequence = 0
; flush_into_infill = 0
; flush_into_objects = 0
; flush_into_support = 1
; flush_multiplier = 1
; flush_volumes_matrix = 0,235,280,370,0,271,530,468,0
; flush_volumes_vector = 140,140,140,140,140,140
; full_fan_speed_layer = 0,0,0
; fuzzy_skin = none
; fuzzy_skin_point_distance = 0.8
; fuzzy_skin_thickness = 0.3
; gap_infill_speed = 250
; gcode_add_line_number = 0
; gcode_flavor = marlin
; grab_length = 17.4
; has_scarf_joint_seam = 0
; head_wrap_detect_zone = 156x152,180x152,180x180,156x180
; hole_coef_1 = 0,0,0
; hole_coef_2 = -0.008,-0.008,-0.008
; hole_coef_3 = 0.23415,0.23415,0.23415
; hole_limit_max = 0.22,0.22,0.22
; hole_limit_min = 0.088,0.088,0.088
; host_type = octoprint
; hot_plate_temp = 65,65,65
; hot_plate_temp_initial_layer = 65,65,65
; hotend_cooling_rate = 2
; hotend_heating_rate = 2
; impact_strength_z = 13.8,13.8,13.8
; independent_support_layer_height = 1
; infill_combination = 0
; infill_direction = 45
; infill_jerk = 9
; infill_lock_depth = 1
; infill_rotate_step = 0
; infill_shift_step = 0.4
; infill_wall_overlap = 15%
; inherits_group = "0.16mm High Quality @BBL A1M";"Bambu PLA Basic @BBL A1M";"Bambu PLA Basic @BBL A1M";"Bambu PLA Basic @BBL A1M";"Bambu Lab A1 mini 0.4 nozzle"
; initial_layer_acceleration = 500
; initial_layer_flow_ratio = 1
; initial_layer_infill_speed = 50
; initial_layer_jerk = 9
; initial_layer_line_width = 0.5
; initial_layer_print_height = 0.25
; initial_layer_speed = 30
; initial_layer_travel_acceleration = 6000
; inner_wall_acceleration = 0
; inner_wall_jerk = 9
; inner_wall_line_width = 0.45
; inner_wall_speed = 150
; interface_shells = 0
; interlocking_beam = 0
; interlocking_beam_layer_count = 2
; interlocking_beam_width = 0.8
; interlocking_boundary_avoidance = 2
; interlocking_depth = 2
; interlocking_orientation = 22.5
; internal_bridge_support_thickness = 0.8
; internal_solid_infill_line_width = 0.42
; internal_solid_infill_pattern = zig-zag
; internal_solid_infill_speed = 200
; ironing_direction = 45
; ironing_flow = 10%
; ironing_inset = 0.21
; ironing_pattern = zig-zag
; ironing_spacing = 0.15
; ironing_speed = 30
; ironing_type = no ironing
; is_infill_first = 0
; layer_change_gcode = ; layer num/total_layer_count: {layer_num+1}/[total_layer_count]\n; update layer progress\nM73 L{layer_num+1}\nM991 S0 P{layer_num} ;notify layer change\n
; layer_height = 0.16
; line_width = 0.42
; locked_skeleton_infill_pattern = zigzag
; locked_skin_infill_pattern = crosszag
; long_retractions_when_cut = 0
; long_retractions_when_ec = 0,0,0
; machine_end_gcode = ;===== date: 20231229 =====================\n;turn off nozzle clog detect\nG392 S0\n\nM400 ; wait for buffer to clear\nG92 E0 ; zero the extruder\nG1 E-0.8 F1800 ; retract\nG1 Z{max_layer_z + 0.5} F900 ; lower z a little\nG1 X0 Y{first_layer_center_no_wipe_tower[1]} F18000 ; move to safe pos\nG1 X-13.0 F3000 ; move to safe pos\n{if !spiral_mode && print_sequence != "by object"}\nM1002 judge_flag timelapse_record_flag\nM622 J1\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM991 S0 P-1 ;end timelapse at safe pos\nM623\n{endif}\n\nM140 S0 ; turn off bed\nM106 S0 ; turn off fan\nM106 P2 S0 ; turn off remote part cooling fan\nM106 P3 S0 ; turn off chamber cooling fan\n\n;G1 X27 F15000 ; wipe\n\n; pull back filament to AMS\nM620 S255\nG1 X181 F12000\nT255\nG1 X0 F18000\nG1 X-13.0 F3000\nG1 X0 F18000 ; wipe\nM621 S255\n\nM104 S0 ; turn off hotend\n\nM400 ; wait all motion done\nM17 S\nM17 Z0.4 ; lower z motor current to reduce impact if there is something in the bottom\n{if (max_layer_z + 100.0) < 180}\n    G1 Z{max_layer_z + 100.0} F600\n    G1 Z{max_layer_z +98.0}\n{else}\n    G1 Z180 F600\n    G1 Z180\n{endif}\nM400 P100\nM17 R ; restore z current\n\nG90\nG1 X-13 Y180 F3600\n\nG91\nG1 Z-1 F600\nG90\nM83\n\nM220 S100  ; Reset feedrate magnitude\nM201.2 K1.0 ; Reset acc magnitude\nM73.2   R1.0 ;Reset left time magnitude\nM1002 set_gcode_claim_speed_level : 0\n\n;=====printer finish  sound=========\nM17\nM400 S1\nM1006 S1\nM1006 A0 B20 L100 C37 D20 M100 E42 F20 N100\nM1006 A0 B10 L100 C44 D10 M100 E44 F10 N100\nM1006 A0 B10 L100 C46 D10 M100 E46 F10 N100\nM1006 A44 B20 L100 C39 D20 M100 E48 F20 N100\nM1006 A0 B10 L100 C44 D10 M100 E44 F10 N100\nM1006 A0 B10 L100 C0 D10 M100 E0 F10 N100\nM1006 A0 B10 L100 C39 D10 M100 E39 F10 N100\nM1006 A0 B10 L100 C0 D10 M100 E0 F10 N100\nM1006 A0 B10 L100 C44 D10 M100 E44 F10 N100\nM1006 A0 B10 L100 C0 D10 M100 E0 F10 N100\nM1006 A0 B10 L100 C39 D10 M100 E39 F10 N100\nM1006 A0 B10 L100 C0 D10 M100 E0 F10 N100\nM1006 A44 B10 L100 C0 D10 M100 E48 F10 N100\nM1006 A0 B10 L100 C0 D10 M100 E0 F10 N100\nM1006 A44 B20 L100 C41 D20 M100 E49 F20 N100\nM1006 A0 B20 L100 C0 D20 M100 E0 F20 N100\nM1006 A0 B20 L100 C37 D20 M100 E37 F20 N100\nM1006 W\n;=====printer finish  sound=========\nM400 S1\nM18 X Y Z\n
; machine_load_filament_time = 28
; machine_max_acceleration_e = 5000,5000
; machine_max_acceleration_extruding = 20000,20000
; machine_max_acceleration_retracting = 5000,5000
; machine_max_acceleration_travel = 9000,9000
; machine_max_acceleration_x = 20000,20000
; machine_max_acceleration_y = 20000,20000
; machine_max_acceleration_z = 1500,1500
; machine_max_jerk_e = 3,3
; machine_max_jerk_x = 9,9
; machine_max_jerk_y = 9,9
; machine_max_jerk_z = 5,5
; machine_max_speed_e = 30,30
; machine_max_speed_x = 500,200
; machine_max_speed_y = 500,200
; machine_max_speed_z = 30,30
; machine_min_extruding_rate = 0,0
; machine_min_travel_rate = 0,0
; machine_pause_gcode = M400 U1
; machine_prepare_compensation_time = 260
; machine_start_gcode = ;===== machine: A1 mini =========================\n;===== date: 20240204 =====================\n\n;===== start to heat heatbead&hotend==========\nM1002 gcode_claim_action : 2\nM1002 set_filament_type:{filament_type[initial_no_support_extruder]}\nM104 S170\nM140 S[bed_temperature_initial_layer_single]\nG392 S0 ;turn off clog detect\nM9833.2\n;=====start printer sound ===================\nM17\nM400 S1\nM1006 S1\nM1006 A0 B0 L100 C37 D10 M100 E37 F10 N100\nM1006 A0 B0 L100 C41 D10 M100 E41 F10 N100\nM1006 A0 B0 L100 C44 D10 M100 E44 F10 N100\nM1006 A0 B10 L100 C0 D10 M100 E0 F10 N100\nM1006 A43 B10 L100 C39 D10 M100 E46 F10 N100\nM1006 A0 B0 L100 C0 D10 M100 E0 F10 N100\nM1006 A0 B0 L100 C39 D10 M100 E43 F10 N100\nM1006 A0 B0 L100 C0 D10 M100 E0 F10 N100\nM1006 A0 B0 L100 C41 D10 M100 E41 F10 N100\nM1006 A0 B0 L100 C44 D10 M100 E44 F10 N100\nM1006 A0 B0 L100 C49 D10 M100 E49 F10 N100\nM1006 A0 B0 L100 C0 D10 M100 E0 F10 N100\nM1006 A44 B10 L100 C39 D10 M100 E48 F10 N100\nM1006 A0 B0 L100 C0 D10 M100 E0 F10 N100\nM1006 A0 B0 L100 C39 D10 M100 E44 F10 N100\nM1006 A0 B0 L100 C0 D10 M100 E0 F10 N100\nM1006 A43 B10 L100 C39 D10 M100 E46 F10 N100\nM1006 W\nM18\n;=====avoid end stop =================\nG91\nG380 S2 Z30 F1200\nG380 S3 Z-20 F1200\nG1 Z5 F1200\nG90\n\n;===== reset machine status =================\nM204 S6000\n\nM630 S0 P0\nG91\nM17 Z0.3 ; lower the z-motor current\n\nG90\nM17 X0.7 Y0.9 Z0.5 ; reset motor current to default\nM960 S5 P1 ; turn on logo lamp\nG90\nM83\nM220 S100 ;Reset Feedrate\nM221 S100 ;Reset Flowrate\nM73.2   R1.0 ;Reset left time magnitude\n;====== cog noise reduction=================\nM982.2 S1 ; turn on cog noise reduction\n\n;===== prepare print temperature and material ==========\nM400\nM18\nM109 S100 H170\nM104 S170\nM400\nM17\nM400\nG28 X\n\nM211 X0 Y0 Z0 ;turn off soft endstop ; turn off soft endstop to prevent protential logic problem\n\nM975 S1 ; turn on\n\nG1 X0.0 F30000\nG1 X-13.5 F3000\n\nM620 M ;enable remap\nM620 S[initial_no_support_extruder]A   ; switch material if AMS exist\n    G392 S0 ;turn on clog detect\n    M1002 gcode_claim_action : 4\n    M400\n    M1002 set_filament_type:UNKNOWN\n    M109 S[nozzle_temperature_initial_layer]\n    M104 S250\n    M400\n    T[initial_no_support_extruder]\n    G1 X-13.5 F3000\n    M400\n    M620.1 E F{filament_max_volumetric_speed[initial_no_support_extruder]/2.4053*60} T{nozzle_temperature_range_high[initial_no_support_extruder]}\n    M109 S250 ;set nozzle to common flush temp\n    M106 P1 S0\n    G92 E0\n    G1 E50 F200\n    M400\n    M1002 set_filament_type:{filament_type[initial_no_support_extruder]}\n    M104 S{nozzle_temperature_range_high[initial_no_support_extruder]}\n    G92 E0\n    G1 E50 F{filament_max_volumetric_speed[initial_no_support_extruder]/2.4053*60}\n    M400\n    M106 P1 S178\n    G92 E0\n    G1 E5 F{filament_max_volumetric_speed[initial_no_support_extruder]/2.4053*60}\n    M109 S{nozzle_temperature_initial_layer[initial_no_support_extruder]-20} ; drop nozzle temp, make filament shink a bit\n    M104 S{nozzle_temperature_initial_layer[initial_no_support_extruder]-40}\n    G92 E0\n    G1 E-0.5 F300\n\n    G1 X0 F30000\n    G1 X-13.5 F3000\n    G1 X0 F30000 ;wipe and shake\n    G1 X-13.5 F3000\n    G1 X0 F12000 ;wipe and shake\n    G1 X0 F30000\n    G1 X-13.5 F3000\n    M109 S{nozzle_temperature_initial_layer[initial_no_support_extruder]-40}\n    G392 S0 ;turn off clog detect\nM621 S[initial_no_support_extruder]A\n\nM400\nM106 P1 S0\n;===== prepare print temperature and material end =====\n\n\n;===== mech mode fast check============================\nM1002 gcode_claim_action : 3\nG0 X25 Y175 F20000 ; find a soft place to home\n;M104 S0\nG28 Z P0 T300; home z with low precision,permit 300deg temperature\nG29.2 S0 ; turn off ABL\nM104 S170\n\n; build plate detect\nM1002 judge_flag build_plate_detect_flag\nM622 S1\n  G39.4\n  M400\nM623\n\nG1 Z5 F3000\nG1 X90 Y-1 F30000\nM400 P200\nM970.3 Q1 A7 K0 O2\nM974 Q1 S2 P0\n\nG1 X90 Y0 Z5 F30000\nM400 P200\nM970 Q0 A10 B50 C90 H15 K0 M20 O3\nM974 Q0 S2 P0\n\nM975 S1\nG1 F30000\nG1 X-1 Y10\nG28 X ; re-home XY\n\n;===== wipe nozzle ===============================\nM1002 gcode_claim_action : 14\nM975 S1\n\nM104 S170 ; set temp down to heatbed acceptable\nM106 S255 ; turn on fan (G28 has turn off fan)\nM211 S; push soft endstop status\nM211 X0 Y0 Z0 ;turn off Z axis endstop\n\nM83\nG1 E-1 F500\nG90\nM83\n\nM109 S170\nM104 S140\nG0 X90 Y-4 F30000\nG380 S3 Z-5 F1200\nG1 Z2 F1200\nG1 X91 F10000\nG380 S3 Z-5 F1200\nG1 Z2 F1200\nG1 X92 F10000\nG380 S3 Z-5 F1200\nG1 Z2 F1200\nG1 X93 F10000\nG380 S3 Z-5 F1200\nG1 Z2 F1200\nG1 X94 F10000\nG380 S3 Z-5 F1200\nG1 Z2 F1200\nG1 X95 F10000\nG380 S3 Z-5 F1200\nG1 Z2 F1200\nG1 X96 F10000\nG380 S3 Z-5 F1200\nG1 Z2 F1200\nG1 X97 F10000\nG380 S3 Z-5 F1200\nG1 Z2 F1200\nG1 X98 F10000\nG380 S3 Z-5 F1200\nG1 Z2 F1200\nG1 X99 F10000\nG380 S3 Z-5 F1200\nG1 Z2 F1200\nG1 X99 F10000\nG380 S3 Z-5 F1200\nG1 Z2 F1200\nG1 X99 F10000\nG380 S3 Z-5 F1200\nG1 Z2 F1200\nG1 X99 F10000\nG380 S3 Z-5 F1200\nG1 Z2 F1200\nG1 X99 F10000\nG380 S3 Z-5 F1200\n\nG1 Z5 F30000\n;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;\nG1 X25 Y175 F30000.1 ;Brush material\nG1 Z0.2 F30000.1\nG1 Y185\nG91\nG1 X-30 F30000\nG1 Y-2\nG1 X27\nG1 Y1.5\nG1 X-28\nG1 Y-2\nG1 X30\nG1 Y1.5\nG1 X-30\nG90\nM83\n\nG1 Z5 F3000\nG0 X50 Y175 F20000 ; find a soft place to home\nG28 Z P0 T300; home z with low precision, permit 300deg temperature\nG29.2 S0 ; turn off ABL\n\nG0 X85 Y185 F10000 ;move to exposed steel surface and stop the nozzle\nG0 Z-1.01 F10000\nG91\n\nG2 I1 J0 X2 Y0 F2000.1\nG2 I-0.75 J0 X-1.5\nG2 I1 J0 X2\nG2 I-0.75 J0 X-1.5\nG2 I1 J0 X2\nG2 I-0.75 J0 X-1.5\nG2 I1 J0 X2\nG2 I-0.75 J0 X-1.5\nG2 I1 J0 X2\nG2 I-0.75 J0 X-1.5\nG2 I1 J0 X2\nG2 I-0.75 J0 X-1.5\nG2 I1 J0 X2\nG2 I-0.75 J0 X-1.5\nG2 I1 J0 X2\nG2 I-0.75 J0 X-1.5\nG2 I1 J0 X2\nG2 I-0.75 J0 X-1.5\nG2 I1 J0 X2\nG2 I-0.75 J0 X-1.5\n\nG90\nG1 Z5 F30000\nG1 X25 Y175 F30000.1 ;Brush material\nG1 Z0.2 F30000.1\nG1 Y185\nG91\nG1 X-30 F30000\nG1 Y-2\nG1 X27\nG1 Y1.5\nG1 X-28\nG1 Y-2\nG1 X30\nG1 Y1.5\nG1 X-30\nG90\nM83\n\nG1 Z5\nG0 X55 Y175 F20000 ; find a soft place to home\nG28 Z P0 T300; home z with low precision, permit 300deg temperature\nG29.2 S0 ; turn off ABL\n\nG1 Z10\nG1 X85 Y185\nG1 Z-1.01\nG1 X95\nG1 X90\n\nM211 R; pop softend status\n\nM106 S0 ; turn off fan , too noisy\n;===== wipe nozzle end ================================\n\n\n;===== wait heatbed  ====================\nM1002 gcode_claim_action : 2\nM104 S0\nM190 S[bed_temperature_initial_layer_single];set bed temp\nM109 S140\n\nG1 Z5 F3000\nG29.2 S1\nG1 X10 Y10 F20000\n\n;===== bed leveling ==================================\n;M1002 set_flag g29_before_print_flag=1\nM1002 judge_flag g29_before_print_flag\nM622 J1\n    M1002 gcode_claim_action : 1\n    G29 A1 X{first_layer_print_min[0]} Y{first_layer_print_min[1]} I{first_layer_print_size[0]} J{first_layer_print_size[1]}\n    M400\n    M500 ; save cali data\nM623\n;===== bed leveling end ================================\n\n;===== home after wipe mouth============================\nM1002 judge_flag g29_before_print_flag\nM622 J0\n\n    M1002 gcode_claim_action : 13\n    G28 T145\n\nM623\n\n;===== home after wipe mouth end =======================\n\nM975 S1 ; turn on vibration supression\n;===== nozzle load line ===============================\nM975 S1\nG90\nM83\nT1000\n\nG1 X-13.5 Y0 Z10 F10000\nG1 E1.2 F500\nM400\nM1002 set_filament_type:UNKNOWN\nM109 S{nozzle_temperature[initial_extruder]}\nM400\n\nM412 S1 ;    ===turn on  filament runout detection===\nM400 P10\n\nG392 S0 ;turn on clog detect\n\nM620.3 W1; === turn on filament tangle detection===\nM400 S2\n\nM1002 set_filament_type:{filament_type[initial_no_support_extruder]}\n;M1002 set_flag extrude_cali_flag=1\nM1002 judge_flag extrude_cali_flag\nM622 J1\n    M1002 gcode_claim_action : 8\n    \n    M400\n    M900 K0.0 L1000.0 M1.0\n    G90\n    M83\n    G0 X68 Y-4 F30000\n    ;G0 Z0.3 F18000 ;Move to start position\n    ;M400\n    ;G0 X88 E10  F{outer_wall_volumetric_speed/(24/20)    * 60}\n    ;G0 X93 E.3742  F{outer_wall_volumetric_speed/(0.3*0.5)/4     * 60}\n    ;G0 X98 E.3742  F{outer_wall_volumetric_speed/(0.3*0.5)     * 60}\n    ;G0 X103 E.3742  F{outer_wall_volumetric_speed/(0.3*0.5)/4     * 60}\n    ;G0 X108 E.3742  F{outer_wall_volumetric_speed/(0.3*0.5)     * 60}\n    ;G0 X113 E.3742  F{outer_wall_volumetric_speed/(0.3*0.5)/4     * 60}\n    ;G0 Y0 Z0 F20000\n    M400\n    \n    G1 X-13.5 Y0 Z10 F10000\n    M400\n    \n    G1 E10 F{outer_wall_volumetric_speed/2.4*60}\n    M983 F{outer_wall_volumetric_speed/2.4} A0.3 H[nozzle_diameter]; cali dynamic extrusion compensation\n    M106 P1 S178\n    M400 S7\n    G1 X0 F18000\n    G1 X-13.5 F3000\n    G1 X0 F18000 ;wipe and shake\n    G1 X-13.5 F3000\n    G1 X0 F12000 ;wipe and shake\n    G1 X-13.5 F3000\n    M400\n    M106 P1 S0\n\n    M1002 judge_last_extrude_cali_success\n    M622 J0\n        M983 F{outer_wall_volumetric_speed/2.4} A0.3 H[nozzle_diameter]; cali dynamic extrusion compensation\n        M106 P1 S178\n        M400 S7\n        G1 X0 F18000\n        G1 X-13.5 F3000\n        G1 X0 F18000 ;wipe and shake\n        G1 X-13.5 F3000\n        G1 X0 F12000 ;wipe and shake\n        M400\n        M106 P1 S0\n    M623\n    \n    ;G1 X-13.5 F3000\n    ;M400\n    ;M984 A0.1 E1 S1 F{outer_wall_volumetric_speed/2.4}\n    ;M106 P1 S178\n    ;M400 S7\n    ;G1 X0 F18000\n    ;G1 X-13.5 F3000\n    ;G1 X0 F18000 ;wipe and shake\n    ;G1 X-13.5 F3000\n    ;G1 X0 F12000 ;wipe and shake\n    ;G1 X-13.5 F3000\n    ;M400\n    ;M106 P1 S0\n\nM623 ; end of "draw extrinsic para cali paint"\n\n;===== extrude cali test ===============================\nM104 S{nozzle_temperature_initial_layer[initial_extruder]}\n;G90\n;M83\n;G0 X68 Y-2.5 F30000\n;G0 Z0.3 F18000 ;Move to start position\n;G0 X88 E10  F{outer_wall_volumetric_speed/(24/20)    * 60}\n;G0 X93 E.3742  F{outer_wall_volumetric_speed/(0.3*0.5)/4     * 60}\n;G0 X98 E.3742  F{outer_wall_volumetric_speed/(0.3*0.5)     * 60}\n;G0 X103 E.3742  F{outer_wall_volumetric_speed/(0.3*0.5)/4     * 60}\n;G0 X108 E.3742  F{outer_wall_volumetric_speed/(0.3*0.5)     * 60}\n;G0 X113 E.3742  F{outer_wall_volumetric_speed/(0.3*0.5)/4     * 60}\n;G0 X115 Z0 F20000\n;G0 Z5\nM400\n\n;========turn off light and wait extrude temperature =============\nM1002 gcode_claim_action : 0\n\nM400 ; wait all motion done before implement the emprical L parameters\n\n;===== for Textured PEI Plate , lower the nozzle as the nozzle was touching topmost of the texture when homing ==\n;curr_bed_type={curr_bed_type}\n{if curr_bed_type=="Textured PEI Plate"}\nG29.1 Z{-0.02} ; for Textured PEI Plate\n{endif}\n\nM960 S1 P0 ; turn off laser\nM960 S2 P0 ; turn off laser\nM106 S0 ; turn off fan\nM106 P2 S0 ; turn off big fan\nM106 P3 S0 ; turn off chamber fan\n\nM975 S1 ; turn on mech mode supression\nG90\nM83\nT1000\n\nM211 X0 Y0 Z0 ;turn off soft endstop\nM1007 S1\n\n\n\n
; machine_switch_extruder_time = 0
; machine_unload_filament_time = 34
; master_extruder_id = 1
; max_bridge_length = 0
; max_layer_height = 0.28
; max_travel_detour_distance = 0
; min_bead_width = 85%
; min_feature_size = 25%
; min_layer_height = 0.08
; minimum_sparse_infill_area = 15
; mmu_segmented_region_interlocking_depth = 0
; mmu_segmented_region_max_width = 0
; nozzle_diameter = 0.4
; nozzle_flush_dataset = 0
; nozzle_height = 4.76
; nozzle_temperature = 215,215,215
; nozzle_temperature_initial_layer = 225,225,225
; nozzle_temperature_range_high = 240,240,240
; nozzle_temperature_range_low = 190,190,190
; nozzle_type = stainless_steel
; nozzle_volume = 92
; nozzle_volume_type = Standard
; only_one_wall_first_layer = 0
; ooze_prevention = 0
; other_layers_print_sequence = 0
; other_layers_print_sequence_nums = 0
; outer_wall_acceleration = 2000
; outer_wall_jerk = 9
; outer_wall_line_width = 0.42
; outer_wall_speed = 60
; overhang_1_4_speed = 60
; overhang_2_4_speed = 30
; overhang_3_4_speed = 10
; overhang_4_4_speed = 10
; overhang_fan_speed = 100,100,100
; overhang_fan_threshold = 50%,50%,50%
; overhang_threshold_participating_cooling = 95%,95%,95%
; overhang_totally_speed = 10
; override_filament_scarf_seam_setting = 0
; physical_extruder_map = 0
; post_process = 
; pre_start_fan_time = 2,2,2
; precise_outer_wall = 0
; precise_z_height = 0
; pressure_advance = 0.02,0.02,0.02
; prime_tower_brim_width = 3
; prime_tower_enable_framework = 0
; prime_tower_extra_rib_length = 0
; prime_tower_fillet_wall = 1
; prime_tower_flat_ironing = 0
; prime_tower_infill_gap = 150%
; prime_tower_lift_height = -1
; prime_tower_lift_speed = 90
; prime_tower_max_speed = 90
; prime_tower_rib_wall = 1
; prime_tower_rib_width = 8
; prime_tower_skip_points = 1
; prime_tower_width = 35
; print_compatible_printers = "Bambu Lab A1 mini 0.4 nozzle"
; print_extruder_id = 1
; print_extruder_variant = "Direct Drive Standard"
; print_flow_ratio = 1
; print_sequence = by layer
; print_settings_id = VITACORE M1+2
; printable_area = 0x0,180x0,180x180,0x180
; printable_height = 180
; printer_extruder_id = 1
; printer_extruder_variant = "Direct Drive Standard"
; printer_model = Bambu Lab A1 mini
; printer_notes = 
; printer_settings_id = AutoFarm3D A1 Mini - Vitacore William
; printer_structure = i3
; printer_technology = FFF
; printer_variant = 0.4
; printhost_authorization_type = key
; printhost_ssl_ignore_revoke = 0
; printing_by_object_gcode = 
; process_notes = 
; raft_contact_distance = 0.1
; raft_expansion = 1.5
; raft_first_layer_density = 90%
; raft_first_layer_expansion = -1
; raft_layers = 0
; reduce_crossing_wall = 0
; reduce_fan_stop_start_freq = 1,1,1
; reduce_infill_retraction = 1
; required_nozzle_HRC = 3,3,3
; resolution = 0.012
; retract_before_wipe = 0%
; retract_length_toolchange = 2
; retract_lift_above = 0
; retract_lift_below = 179
; retract_restart_extra = 0
; retract_restart_extra_toolchange = 0
; retract_when_changing_layer = 1
; retraction_distances_when_cut = 18
; retraction_distances_when_ec = 0,0,0
; retraction_length = 0.8
; retraction_minimum_travel = 1
; retraction_speed = 30
; role_base_wipe_speed = 1
; scan_first_layer = 0
; scarf_angle_threshold = 155
; seam_gap = 15%
; seam_placement_away_from_overhangs = 0
; seam_position = aligned
; seam_slope_conditional = 1
; seam_slope_entire_loop = 0
; seam_slope_gap = 0
; seam_slope_inner_walls = 1
; seam_slope_min_length = 10
; seam_slope_start_height = 10%
; seam_slope_steps = 10
; seam_slope_type = none
; silent_mode = 0
; single_extruder_multi_material = 1
; skeleton_infill_density = 15%
; skeleton_infill_line_width = 0.45
; skin_infill_density = 15%
; skin_infill_depth = 2
; skin_infill_line_width = 0.45
; skirt_distance = 2
; skirt_height = 1
; skirt_loops = 0
; slice_closing_radius = 0.049
; slicing_mode = regular
; slow_down_for_layer_cooling = 1,1,1
; slow_down_layer_time = 6,6,6
; slow_down_min_speed = 20,20,20
; slowdown_end_acc = 100000
; slowdown_end_height = 400
; slowdown_end_speed = 1000
; slowdown_start_acc = 100000
; slowdown_start_height = 0
; slowdown_start_speed = 1000
; small_perimeter_speed = 50%
; small_perimeter_threshold = 0
; smooth_coefficient = 80
; smooth_speed_discontinuity_area = 1
; solid_infill_filament = 1
; sparse_infill_acceleration = 100%
; sparse_infill_anchor = 400%
; sparse_infill_anchor_max = 20
; sparse_infill_density = 15%
; sparse_infill_filament = 1
; sparse_infill_line_width = 0.45
; sparse_infill_pattern = gyroid
; sparse_infill_speed = 200
; spiral_mode = 0
; spiral_mode_max_xy_smoothing = 200%
; spiral_mode_smooth = 0
; standby_temperature_delta = -5
; start_end_points = 30x-3,54x245
; supertack_plate_temp = 45,45,45
; supertack_plate_temp_initial_layer = 45,45,45
; support_air_filtration = 0
; support_angle = 0
; support_base_pattern = default
; support_base_pattern_spacing = 2.5
; support_bottom_interface_spacing = 0.5
; support_bottom_z_distance = 0.16
; support_chamber_temp_control = 0
; support_critical_regions_only = 1
; support_expansion = 0
; support_filament = 0
; support_interface_bottom_layers = 2
; support_interface_filament = 0
; support_interface_loop_pattern = 0
; support_interface_not_for_body = 1
; support_interface_pattern = auto
; support_interface_spacing = 0.5
; support_interface_speed = 80
; support_interface_top_layers = 2
; support_line_width = 0.42
; support_object_first_layer_gap = 0.2
; support_object_xy_distance = 0.35
; support_on_build_plate_only = 0
; support_remove_small_overhang = 1
; support_speed = 150
; support_style = default
; support_threshold_angle = 25
; support_top_z_distance = 0.16
; support_type = tree(auto)
; symmetric_infill_y_axis = 0
; temperature_vitrification = 45,45,45
; template_custom_gcode = 
; textured_plate_temp = 65,65,65
; textured_plate_temp_initial_layer = 65,65,65
; thick_bridges = 0
; thumbnail_size = 50x50
; time_lapse_gcode = ;===================== date: 202312028 =====================\n{if !spiral_mode && print_sequence != "by object"}\n; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer\nM622.1 S1 ; for prev firware, default turned on\nM1002 judge_flag timelapse_record_flag\nM622 J1\nG92 E0\nG17\nG2 Z{layer_z + 0.4} I0.86 J0.86 P1 F20000 ; spiral lift a little\nG1 Z{max_layer_z + 0.4}\nG1 X0 Y{first_layer_center_no_wipe_tower[1]} F18000 ; move to safe pos\nG1 X-13.0 F3000 ; move to safe pos\nM400 P300\nM971 S11 C11 O0\nG92 E0\nG1 X0 F18000\nM623\n\nM622.1 S1\nM1002 judge_flag g39_detection_flag\nM622 J1\n  ; enable nozzle clog detect at 3rd layer\n  {if layer_num == 2}\n    M400\n    G90\n    M83\n    M204 S5000\n    G0 Z2 F4000\n    G0 X-6 Y170 F20000\n    G39 S1 X-6 Y170\n    G0 Z2 F4000\n    G0 X90 Y90 F30000\n  {endif}\n\n\n  {if !in_head_wrap_detect_zone}\n    M622.1 S0\n    M1002 judge_flag g39_mass_exceed_flag\n    M622 J1\n    {if layer_num > 2}\n      G392 S0\n      M400\n      G90\n      M83\n      M204 S5000\n      G0 Z{max_layer_z + 0.4} F4000\n      G39.3 S1\n      G0 Z{max_layer_z + 0.4} F4000\n      G392 S0\n    {endif}\n    M623\n  {endif}\nM623\n{endif}\n
; timelapse_type = 0
; top_area_threshold = 200%
; top_color_penetration_layers = 6
; top_one_wall_type = all top
; top_shell_layers = 6
; top_shell_thickness = 1
; top_solid_infill_flow_ratio = 1
; top_surface_acceleration = 2000
; top_surface_jerk = 9
; top_surface_line_width = 0.42
; top_surface_pattern = monotonicline
; top_surface_speed = 150
; travel_acceleration = 10000
; travel_jerk = 9
; travel_speed = 700
; travel_speed_z = 0
; tree_support_branch_angle = 45
; tree_support_branch_diameter = 2
; tree_support_branch_diameter_angle = 5
; tree_support_branch_distance = 5
; tree_support_wall_count = -1
; upward_compatible_machine = "Bambu Lab P1S 0.4 nozzle";"Bambu Lab P1P 0.4 nozzle";"Bambu Lab X1 0.4 nozzle";"Bambu Lab X1 Carbon 0.4 nozzle";"Bambu Lab X1E 0.4 nozzle";"Bambu Lab A1 0.4 nozzle";"Bambu Lab H2D 0.4 nozzle";"Bambu Lab H2D Pro 0.4 nozzle";"Bambu Lab H2S 0.4 nozzle";"Bambu Lab P2S 0.4 nozzle";"Bambu Lab H2C 0.4 nozzle"
; use_firmware_retraction = 0
; use_relative_e_distances = 1
; vertical_shell_speed = 80%
; volumetric_speed_coefficients = "0 0 0 0 0 0";"0 0 0 0 0 0";"0 0 0 0 0 0"
; wall_distribution_count = 1
; wall_filament = 1
; wall_generator = classic
; wall_loops = 2
; wall_sequence = inner wall/outer wall
; wall_transition_angle = 10
; wall_transition_filter_deviation = 25%
; wall_transition_length = 100%
; wipe = 1
; wipe_distance = 2
; wipe_speed = 80%
; wipe_tower_no_sparse_layers = 0
; wipe_tower_rotation_angle = 0
; wipe_tower_x = 15
; wipe_tower_y = 140.972
; wrapping_detection_gcode = 
; wrapping_detection_layers = 20
; wrapping_exclude_area = 
; xy_contour_compensation = 0
; xy_hole_compensation = 0
; z_direction_outwall_speed_continuous = 0
; z_hop = 0.4
; z_hop_types = Auto Lift
; CONFIG_BLOCK_END

; EXECUTABLE_BLOCK_START
M73 P0 R76
M201 X20000 Y20000 Z1500 E5000
M203 X500 Y500 Z30 E30
M204 P20000 R5000 T20000
M205 X9.00 Y9.00 Z5.00 E3.00
; FEATURE: Custom
;===== machine: A1 mini =========================
;===== date: 20240204 =====================

;===== start to heat heatbead&hotend==========
M1002 gcode_claim_action : 2
M1002 set_filament_type:PLA
M104 S170
M140 S65
G392 S0 ;turn off clog detect
M9833.2
;=====start printer sound ===================
M17
M400 S1
M1006 S1
M1006 A0 B0 L100 C37 D10 M100 E37 F10 N100
M1006 A0 B0 L100 C41 D10 M100 E41 F10 N100
M1006 A0 B0 L100 C44 D10 M100 E44 F10 N100
M1006 A0 B10 L100 C0 D10 M100 E0 F10 N100
M1006 A43 B10 L100 C39 D10 M100 E46 F10 N100
M1006 A0 B0 L100 C0 D10 M100 E0 F10 N100
M1006 A0 B0 L100 C39 D10 M100 E43 F10 N100
M1006 A0 B0 L100 C0 D10 M100 E0 F10 N100
M1006 A0 B0 L100 C41 D10 M100 E41 F10 N100
M1006 A0 B0 L100 C44 D10 M100 E44 F10 N100
M1006 A0 B0 L100 C49 D10 M100 E49 F10 N100
M1006 A0 B0 L100 C0 D10 M100 E0 F10 N100
M1006 A44 B10 L100 C39 D10 M100 E48 F10 N100
M1006 A0 B0 L100 C0 D10 M100 E0 F10 N100
M1006 A0 B0 L100 C39 D10 M100 E44 F10 N100
M1006 A0 B0 L100 C0 D10 M100 E0 F10 N100
M1006 A43 B10 L100 C39 D10 M100 E46 F10 N100
M1006 W
M18
;=====avoid end stop =================
G91
G380 S2 Z30 F1200
G380 S3 Z-20 F1200
G1 Z5 F1200
G90

;===== reset machine status =================
M204 S6000

M630 S0 P0
G91
M17 Z0.3 ; lower the z-motor current

G90
M17 X0.7 Y0.9 Z0.5 ; reset motor current to default
M960 S5 P1 ; turn on logo lamp
G90
M83
M220 S100 ;Reset Feedrate
M221 S100 ;Reset Flowrate
M73.2   R1.0 ;Reset left time magnitude
;====== cog noise reduction=================
M982.2 S1 ; turn on cog noise reduction

;===== prepare print temperature and material ==========
M400
M18
M109 S100 H170
M104 S170
M400
M17
M400
G28 X

M211 X0 Y0 Z0 ;turn off soft endstop ; turn off soft endstop to prevent protential logic problem

M975 S1 ; turn on

G1 X0.0 F30000
G1 X-13.5 F3000

M620 M ;enable remap
M620 S0A   ; switch material if AMS exist
    G392 S0 ;turn on clog detect
    M1002 gcode_claim_action : 4
    M400
    M1002 set_filament_type:UNKNOWN
    M109 S225
    M104 S250
    M400
    T0
    G1 X-13.5 F3000
    M400
    M620.1 E F523.843 T240
    M109 S250 ;set nozzle to common flush temp
    M106 P1 S0
    G92 E0
M73 P0 R75
    G1 E50 F200
    M400
    M1002 set_filament_type:PLA
    M104 S240
    G92 E0
    G1 E50 F523.843
    M400
    M106 P1 S178
    G92 E0
    G1 E5 F523.843
    M109 S205 ; drop nozzle temp, make filament shink a bit
    M104 S185
    G92 E0
M73 P1 R75
    G1 E-0.5 F300

    G1 X0 F30000
    G1 X-13.5 F3000
    G1 X0 F30000 ;wipe and shake
    G1 X-13.5 F3000
    G1 X0 F12000 ;wipe and shake
    G1 X0 F30000
    G1 X-13.5 F3000
    M109 S185
    G392 S0 ;turn off clog detect
M621 S0A

M400
M106 P1 S0
;===== prepare print temperature and material end =====


;===== mech mode fast check============================
M1002 gcode_claim_action : 3
G0 X25 Y175 F20000 ; find a soft place to home
;M104 S0
G28 Z P0 T300; home z with low precision,permit 300deg temperature
G29.2 S0 ; turn off ABL
M104 S170

; build plate detect
M1002 judge_flag build_plate_detect_flag
M622 S1
  G39.4
  M400
M623

G1 Z5 F3000
G1 X90 Y-1 F30000
M400 P200
M970.3 Q1 A7 K0 O2
M974 Q1 S2 P0

G1 X90 Y0 Z5 F30000
M400 P200
M970 Q0 A10 B50 C90 H15 K0 M20 O3
M974 Q0 S2 P0

M975 S1
G1 F30000
G1 X-1 Y10
G28 X ; re-home XY

;===== wipe nozzle ===============================
M1002 gcode_claim_action : 14
M975 S1

M104 S170 ; set temp down to heatbed acceptable
M106 S255 ; turn on fan (G28 has turn off fan)
M211 S; push soft endstop status
M211 X0 Y0 Z0 ;turn off Z axis endstop

M83
G1 E-1 F500
G90
M83

M109 S170
M104 S140
G0 X90 Y-4 F30000
G380 S3 Z-5 F1200
M73 P6 R70
G1 Z2 F1200
G1 X91 F10000
G380 S3 Z-5 F1200
G1 Z2 F1200
G1 X92 F10000
G380 S3 Z-5 F1200
G1 Z2 F1200
G1 X93 F10000
G380 S3 Z-5 F1200
G1 Z2 F1200
G1 X94 F10000
G380 S3 Z-5 F1200
G1 Z2 F1200
G1 X95 F10000
G380 S3 Z-5 F1200
G1 Z2 F1200
G1 X96 F10000
G380 S3 Z-5 F1200
G1 Z2 F1200
G1 X97 F10000
G380 S3 Z-5 F1200
G1 Z2 F1200
G1 X98 F10000
G380 S3 Z-5 F1200
G1 Z2 F1200
G1 X99 F10000
G380 S3 Z-5 F1200
G1 Z2 F1200
G1 X99 F10000
G380 S3 Z-5 F1200
G1 Z2 F1200
G1 X99 F10000
G380 S3 Z-5 F1200
G1 Z2 F1200
G1 X99 F10000
G380 S3 Z-5 F1200
G1 Z2 F1200
G1 X99 F10000
G380 S3 Z-5 F1200

G1 Z5 F30000
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
G1 X25 Y175 F30000.1 ;Brush material
G1 Z0.2 F30000.1
G1 Y185
G91
G1 X-30 F30000
G1 Y-2
G1 X27
G1 Y1.5
G1 X-28
G1 Y-2
G1 X30
G1 Y1.5
G1 X-30
G90
M83

G1 Z5 F3000
G0 X50 Y175 F20000 ; find a soft place to home
G28 Z P0 T300; home z with low precision, permit 300deg temperature
G29.2 S0 ; turn off ABL

G0 X85 Y185 F10000 ;move to exposed steel surface and stop the nozzle
G0 Z-1.01 F10000
G91

G2 I1 J0 X2 Y0 F2000.1
G2 I-0.75 J0 X-1.5
G2 I1 J0 X2
G2 I-0.75 J0 X-1.5
G2 I1 J0 X2
G2 I-0.75 J0 X-1.5
G2 I1 J0 X2
G2 I-0.75 J0 X-1.5
G2 I1 J0 X2
G2 I-0.75 J0 X-1.5
G2 I1 J0 X2
G2 I-0.75 J0 X-1.5
G2 I1 J0 X2
G2 I-0.75 J0 X-1.5
G2 I1 J0 X2
G2 I-0.75 J0 X-1.5
G2 I1 J0 X2
G2 I-0.75 J0 X-1.5
G2 I1 J0 X2
G2 I-0.75 J0 X-1.5

G90
G1 Z5 F30000
G1 X25 Y175 F30000.1 ;Brush material
G1 Z0.2 F30000.1
G1 Y185
G91
G1 X-30 F30000
G1 Y-2
G1 X27
G1 Y1.5
G1 X-28
G1 Y-2
G1 X30
G1 Y1.5
G1 X-30
G90
M83

G1 Z5
G0 X55 Y175 F20000 ; find a soft place to home
G28 Z P0 T300; home z with low precision, permit 300deg temperature
G29.2 S0 ; turn off ABL

M73 P7 R70
G1 Z10
G1 X85 Y185
G1 Z-1.01
G1 X95
G1 X90

M211 R; pop softend status

M106 S0 ; turn off fan , too noisy
;===== wipe nozzle end ================================


;===== wait heatbed  ====================
M1002 gcode_claim_action : 2
M104 S0
M190 S65;set bed temp
M109 S140

G1 Z5 F3000
G29.2 S1
G1 X10 Y10 F20000

;===== bed leveling ==================================
;M1002 set_flag g29_before_print_flag=1
M1002 judge_flag g29_before_print_flag
M622 J1
    M1002 gcode_claim_action : 1
    G29 A1 X2.5 Y2.5 I175 J175
    M400
    M500 ; save cali data
M623
;===== bed leveling end ================================

;===== home after wipe mouth============================
M1002 judge_flag g29_before_print_flag
M622 J0

    M1002 gcode_claim_action : 13
    G28 T145

M623

;===== home after wipe mouth end =======================

M975 S1 ; turn on vibration supression
;===== nozzle load line ===============================
M975 S1
G90
M83
T1000

G1 X-13.5 Y0 Z10 F10000
G1 E1.2 F500
M400
M1002 set_filament_type:UNKNOWN
M109 S215
M400

M412 S1 ;    ===turn on  filament runout detection===
M400 P10

G392 S0 ;turn on clog detect

M620.3 W1; === turn on filament tangle detection===
M400 S2

M1002 set_filament_type:PLA
;M1002 set_flag extrude_cali_flag=1
M1002 judge_flag extrude_cali_flag
M622 J1
    M1002 gcode_claim_action : 8
    
    M400
    M900 K0.0 L1000.0 M1.0
    G90
    M83
    G0 X68 Y-4 F30000
    ;G0 Z0.3 F18000 ;Move to start position
    ;M400
    ;G0 X88 E10  F271.497
    ;G0 X93 E.3742  F452.496
    ;G0 X98 E.3742  F1809.98
    ;G0 X103 E.3742  F452.496
    ;G0 X108 E.3742  F1809.98
    ;G0 X113 E.3742  F452.496
    ;G0 Y0 Z0 F20000
    M400
    
    G1 X-13.5 Y0 Z10 F10000
    M400
    
    G1 E10 F113.124
    M983 F1.8854 A0.3 H0.4; cali dynamic extrusion compensation
    M106 P1 S178
    M400 S7
    G1 X0 F18000
    G1 X-13.5 F3000
    G1 X0 F18000 ;wipe and shake
    G1 X-13.5 F3000
    G1 X0 F12000 ;wipe and shake
    G1 X-13.5 F3000
    M400
    M106 P1 S0

    M1002 judge_last_extrude_cali_success
    M622 J0
        M983 F1.8854 A0.3 H0.4; cali dynamic extrusion compensation
        M106 P1 S178
        M400 S7
        G1 X0 F18000
        G1 X-13.5 F3000
        G1 X0 F18000 ;wipe and shake
        G1 X-13.5 F3000
        G1 X0 F12000 ;wipe and shake
        M400
        M106 P1 S0
    M623
    
    ;G1 X-13.5 F3000
    ;M400
    ;M984 A0.1 E1 S1 F1.8854
    ;M106 P1 S178
    ;M400 S7
    ;G1 X0 F18000
    ;G1 X-13.5 F3000
    ;G1 X0 F18000 ;wipe and shake
    ;G1 X-13.5 F3000
    ;G1 X0 F12000 ;wipe and shake
    ;G1 X-13.5 F3000
    ;M400
    ;M106 P1 S0

M623 ; end of "draw extrinsic para cali paint"

;===== extrude cali test ===============================
M104 S225
;G90
;M83
;G0 X68 Y-2.5 F30000
;G0 Z0.3 F18000 ;Move to start position
;G0 X88 E10  F271.497
;G0 X93 E.3742  F452.496
;G0 X98 E.3742  F1809.98
;G0 X103 E.3742  F452.496
;G0 X108 E.3742  F1809.98
;G0 X113 E.3742  F452.496
;G0 X115 Z0 F20000
;G0 Z5
M400

;========turn off light and wait extrude temperature =============
M1002 gcode_claim_action : 0

M400 ; wait all motion done before implement the emprical L parameters

;===== for Textured PEI Plate , lower the nozzle as the nozzle was touching topmost of the texture when homing ==
;curr_bed_type=High Temp Plate


M960 S1 P0 ; turn off laser
M960 S2 P0 ; turn off laser
M106 S0 ; turn off fan
M106 P2 S0 ; turn off big fan
M106 P3 S0 ; turn off chamber fan

M975 S1 ; turn on mech mode supression
G90
M83
T1000

M211 X0 Y0 Z0 ;turn off soft endstop
M1007 S1



; MACHINE_START_GCODE_END
; filament start gcode
M106 P3 S200


;VT0
G90
G21
M83 ; use relative distances for extrusion
M981 S1 P20000 ;open spaghetti detector
; CHANGE_LAYER
; Z_HEIGHT: 0.25
; LAYER_HEIGHT: 0.25
G1 E-.8 F1800
; layer num/total_layer_count: 1/6
; update layer progress
M73 L1
M991 S0 P0 ;notify layer change

M106 S0
; OBJECT_ID: 53
G1 X176.804 Y176.804 F42000
M204 S6000
G1 Z.4
G1 Z.25
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.5
M204 S500
G1 X3.196 Y176.804 E7.89302
G1 X3.196 Y3.196 E7.89302
G1 X176.804 Y3.196 E7.89302
G1 X176.804 Y176.744 E7.89029
M204 S6000
G1 X177.25 Y177.25 F42000
; FEATURE: Outer wall
G1 F1800
M204 S500
G1 X2.75 Y177.25 E7.93361
G1 X2.75 Y2.75 E7.93361
G1 X177.25 Y2.75 E7.93361
G1 X177.25 Y177.19 E7.93088
; WIPE_START
G1 X175.25 Y177.191 E-.76
; WIPE_END
G1 E-.04
M204 S6000
G17
G3 Z.65 I1.217 J0 P1  F42000
;===================== date: 202312028 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
M622.1 S1 ; for prev firware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G17
G2 Z0.65 I0.86 J0.86 P1 F20000 ; spiral lift a little
G1 Z0.65
G1 X0 Y90 F18000 ; move to safe pos
M73 P8 R70
G1 X-13.0 F3000 ; move to safe pos
M400 P300
M971 S11 C11 O0
G92 E0
M73 P8 R69
G1 X0 F18000
M623

M622.1 S1
M1002 judge_flag g39_detection_flag
M622 J1
  ; enable nozzle clog detect at 3rd layer
  


  
M623


G1 X175.723 Y3.375 F42000
G1 Z.25
G1 E.8 F1800
; FEATURE: Bottom surface
; LINE_WIDTH: 0.50005
G1 F3000
M204 S500
G1 X176.424 Y4.076 E.04511
G1 X176.424 Y4.708 E.02871
G1 X175.292 Y3.576 E.07279
G1 X174.661 Y3.576 E.02871
G1 X176.424 Y5.339 E.11339
G1 X176.424 Y5.97 E.02871
G1 X174.03 Y3.576 E.15398
G1 X173.398 Y3.576 E.02871
G1 X176.424 Y6.602 E.19458
G1 X176.424 Y7.233 E.02871
G1 X172.767 Y3.576 E.23517
G1 X172.136 Y3.576 E.02871
G1 X176.424 Y7.864 E.27577
G1 X176.424 Y8.496 E.02871
G1 X171.504 Y3.576 E.31636
G1 X170.873 Y3.576 E.02871
G1 X176.424 Y9.127 E.35696
G1 X176.424 Y9.758 E.02871
G1 X170.242 Y3.576 E.39756
G1 X169.611 Y3.576 E.02871
G1 X176.424 Y10.389 E.43815
G1 X176.424 Y11.021 E.02871
G1 X168.979 Y3.576 E.47875
G1 X168.348 Y3.576 E.02871
G1 X176.424 Y11.652 E.51934
G1 X176.424 Y12.283 E.02871
G1 X167.717 Y3.576 E.55994
G1 X167.085 Y3.576 E.02871
G1 X176.424 Y12.915 E.60053
G1 X176.424 Y13.546 E.02871
G1 X166.454 Y3.576 E.64113
G1 X165.823 Y3.576 E.02871
G1 X176.424 Y14.177 E.68172
G1 X176.424 Y14.809 E.02871
G1 X165.191 Y3.576 E.72232
G1 X164.56 Y3.576 E.02871
G1 X176.424 Y15.44 E.76292
G1 X176.424 Y16.071 E.02871
G1 X163.929 Y3.576 E.80351
G1 X163.298 Y3.576 E.02871
G1 X176.424 Y16.703 E.84411
G1 X176.424 Y17.334 E.02871
G1 X162.666 Y3.576 E.8847
G1 X162.035 Y3.576 E.02871
G1 X176.424 Y17.965 E.9253
G1 X176.424 Y18.596 E.02871
G1 X161.404 Y3.576 E.96589
G1 X160.772 Y3.576 E.02871
G1 X176.424 Y19.228 E1.00649
G1 X176.424 Y19.859 E.02871
G1 X160.141 Y3.576 E1.04708
G1 X159.51 Y3.576 E.02871
G1 X176.424 Y20.49 E1.08768
G1 X176.424 Y21.122 E.02871
G1 X158.878 Y3.576 E1.12827
G1 X158.247 Y3.576 E.02871
G1 X176.424 Y21.753 E1.16887
G1 X176.424 Y22.384 E.02871
G1 X157.616 Y3.576 E1.20947
G1 X156.984 Y3.576 E.02871
G1 X176.424 Y23.016 E1.25006
G1 X176.424 Y23.647 E.02871
G1 X156.353 Y3.576 E1.29066
G1 X155.722 Y3.576 E.02871
G1 X176.424 Y24.278 E1.33125
G1 X176.424 Y24.909 E.02871
G1 X155.091 Y3.576 E1.37185
G1 X154.459 Y3.576 E.02871
G1 X176.424 Y25.541 E1.41244
G1 X176.424 Y26.172 E.02871
G1 X153.828 Y3.576 E1.45304
G1 X153.197 Y3.576 E.02871
G1 X176.424 Y26.803 E1.49364
G1 X176.424 Y27.435 E.02871
G1 X152.565 Y3.576 E1.53423
G1 X151.934 Y3.576 E.02871
G1 X176.424 Y28.066 E1.57483
G1 X176.424 Y28.697 E.02871
G1 X151.303 Y3.576 E1.61542
G1 X150.671 Y3.576 E.02871
G1 X176.424 Y29.329 E1.65602
M73 P9 R69
G1 X176.424 Y29.96 E.02871
G1 X150.04 Y3.576 E1.69661
G1 X149.409 Y3.576 E.02871
G1 X176.424 Y30.591 E1.73721
G1 X176.424 Y31.223 E.02871
G1 X148.777 Y3.576 E1.7778
G1 X148.146 Y3.576 E.02871
G1 X176.424 Y31.854 E1.8184
G1 X176.424 Y32.485 E.02871
G1 X147.515 Y3.576 E1.85899
G1 X146.884 Y3.576 E.02871
G1 X176.424 Y33.116 E1.89959
G1 X176.424 Y33.748 E.02871
G1 X146.252 Y3.576 E1.94019
G1 X145.621 Y3.576 E.02871
G1 X176.424 Y34.379 E1.98078
G1 X176.424 Y35.01 E.02871
G1 X144.99 Y3.576 E2.02138
G1 X144.358 Y3.576 E.02871
G1 X176.424 Y35.642 E2.06197
G1 X176.424 Y36.273 E.02871
G1 X143.727 Y3.576 E2.10257
G1 X143.096 Y3.576 E.02871
G1 X176.424 Y36.904 E2.14316
G1 X176.424 Y37.536 E.02871
G1 X142.464 Y3.576 E2.18376
G1 X141.833 Y3.576 E.02871
G1 X176.424 Y38.167 E2.22436
G1 X176.424 Y38.798 E.02871
G1 X141.202 Y3.576 E2.26495
G1 X140.571 Y3.576 E.02871
G1 X176.424 Y39.429 E2.30555
G1 X176.424 Y40.061 E.02871
G1 X139.939 Y3.576 E2.34614
G1 X139.308 Y3.576 E.02871
G1 X176.424 Y40.692 E2.38674
G1 X176.424 Y41.323 E.02871
G1 X138.677 Y3.576 E2.42733
G1 X138.045 Y3.576 E.02871
M73 P9 R68
G1 X176.424 Y41.955 E2.46793
G1 X176.424 Y42.586 E.02871
G1 X137.414 Y3.576 E2.50852
G1 X136.783 Y3.576 E.02871
G1 X176.424 Y43.217 E2.54912
G1 X176.424 Y43.849 E.02871
G1 X136.151 Y3.576 E2.58971
G1 X135.52 Y3.576 E.02871
G1 X176.424 Y44.48 E2.63031
G1 X176.424 Y45.111 E.02871
G1 X134.889 Y3.576 E2.67091
G1 X134.257 Y3.576 E.02871
G1 X176.424 Y45.743 E2.7115
G1 X176.424 Y46.374 E.02871
G1 X133.626 Y3.576 E2.7521
G1 X132.995 Y3.576 E.02871
G1 X176.424 Y47.005 E2.79269
G1 X176.424 Y47.636 E.02871
G1 X132.364 Y3.576 E2.83329
G1 X131.732 Y3.576 E.02871
G1 X176.424 Y48.268 E2.87388
G1 X176.424 Y48.899 E.02871
G1 X131.101 Y3.576 E2.91448
G1 X130.47 Y3.576 E.02871
G1 X176.424 Y49.53 E2.95508
G1 X176.424 Y50.162 E.02871
G1 X129.838 Y3.576 E2.99567
G1 X129.207 Y3.576 E.02871
G1 X176.424 Y50.793 E3.03627
G1 X176.424 Y51.424 E.02871
G1 X128.576 Y3.576 E3.07686
G1 X127.944 Y3.576 E.02871
G1 X176.424 Y52.056 E3.11746
G1 X176.424 Y52.687 E.02871
G1 X127.313 Y3.576 E3.15805
G1 X126.682 Y3.576 E.02871
G1 X176.424 Y53.318 E3.19865
G1 X176.424 Y53.949 E.02871
G1 X126.051 Y3.576 E3.23924
G1 X125.419 Y3.576 E.02871
G1 X176.424 Y54.581 E3.27984
G1 X176.424 Y55.212 E.02871
G1 X124.788 Y3.576 E3.32043
G1 X124.157 Y3.576 E.02871
M73 P10 R68
G1 X176.424 Y55.843 E3.36103
G1 X176.424 Y56.475 E.02871
G1 X123.525 Y3.576 E3.40163
G1 X122.894 Y3.576 E.02871
G1 X176.424 Y57.106 E3.44222
G1 X176.424 Y57.737 E.02871
G1 X122.263 Y3.576 E3.48282
G1 X121.631 Y3.576 E.02871
G1 X176.424 Y58.369 E3.52341
G1 X176.424 Y59 E.02871
G1 X121 Y3.576 E3.56401
G1 X120.369 Y3.576 E.02871
G1 X176.424 Y59.631 E3.6046
G1 X176.424 Y60.263 E.02871
G1 X119.737 Y3.576 E3.6452
G1 X119.106 Y3.576 E.02871
G1 X176.424 Y60.894 E3.68579
G1 X176.424 Y61.525 E.02871
G1 X118.475 Y3.576 E3.72639
G1 X117.844 Y3.576 E.02871
G1 X176.424 Y62.156 E3.76699
G1 X176.424 Y62.788 E.02871
G1 X117.212 Y3.576 E3.80758
G1 X116.581 Y3.576 E.02871
G1 X176.424 Y63.419 E3.84818
G1 X176.424 Y64.05 E.02871
G1 X115.95 Y3.576 E3.88877
G1 X115.318 Y3.576 E.02871
G1 X176.424 Y64.682 E3.92937
G1 X176.424 Y65.313 E.02871
G1 X114.687 Y3.576 E3.96996
G1 X114.056 Y3.576 E.02871
G1 X176.424 Y65.944 E4.01056
G1 X176.424 Y66.576 E.02871
G1 X113.424 Y3.576 E4.05115
G1 X112.793 Y3.576 E.02871
G1 X176.424 Y67.207 E4.09175
G1 X176.424 Y67.838 E.02871
G1 X112.162 Y3.576 E4.13235
G1 X111.531 Y3.576 E.02871
M73 P10 R67
G1 X176.424 Y68.47 E4.17294
G1 X176.424 Y69.101 E.02871
G1 X110.899 Y3.576 E4.21354
G1 X110.268 Y3.576 E.02871
G1 X176.424 Y69.732 E4.25413
G1 X176.424 Y70.363 E.02871
G1 X109.637 Y3.576 E4.29473
G1 X109.005 Y3.576 E.02871
G1 X176.424 Y70.995 E4.33532
G1 X176.424 Y71.626 E.02871
G1 X108.374 Y3.576 E4.37592
G1 X107.743 Y3.576 E.02871
G1 X176.424 Y72.257 E4.41651
G1 X176.424 Y72.889 E.02871
M73 P11 R67
G1 X107.111 Y3.576 E4.45711
G1 X106.48 Y3.576 E.02871
G1 X176.424 Y73.52 E4.49771
G1 X176.424 Y74.151 E.02871
G1 X105.849 Y3.576 E4.5383
G1 X105.217 Y3.576 E.02871
G1 X176.424 Y74.783 E4.5789
G1 X176.424 Y75.414 E.02871
G1 X104.586 Y3.576 E4.61949
G1 X103.955 Y3.576 E.02871
G1 X176.424 Y76.045 E4.66009
G1 X176.424 Y76.676 E.02871
G1 X103.324 Y3.576 E4.70068
G1 X102.692 Y3.576 E.02871
G1 X176.424 Y77.308 E4.74128
G1 X176.424 Y77.939 E.02871
G1 X102.061 Y3.576 E4.78187
G1 X101.43 Y3.576 E.02871
G1 X176.424 Y78.57 E4.82247
G1 X176.424 Y79.202 E.02871
G1 X100.798 Y3.576 E4.86307
G1 X100.167 Y3.576 E.02871
G1 X176.424 Y79.833 E4.90366
G1 X176.424 Y80.464 E.02871
G1 X99.536 Y3.576 E4.94426
G1 X98.904 Y3.576 E.02871
G1 X176.424 Y81.096 E4.98485
G1 X176.424 Y81.727 E.02871
G1 X98.273 Y3.576 E5.02545
G1 X97.642 Y3.576 E.02871
G1 X176.424 Y82.358 E5.06604
G1 X176.424 Y82.99 E.02871
G1 X97.01 Y3.576 E5.10664
G1 X96.379 Y3.576 E.02871
G1 X176.424 Y83.621 E5.14723
G1 X176.424 Y84.252 E.02871
G1 X95.748 Y3.576 E5.18783
G1 X95.117 Y3.576 E.02871
G1 X176.424 Y84.883 E5.22843
G1 X176.424 Y85.515 E.02871
G1 X94.485 Y3.576 E5.26902
G1 X93.854 Y3.576 E.02871
G1 X176.424 Y86.146 E5.30962
G1 X176.424 Y86.777 E.02871
M73 P12 R66
G1 X93.223 Y3.576 E5.35021
G1 X92.591 Y3.576 E.02871
G1 X176.424 Y87.409 E5.39081
G1 X176.424 Y88.04 E.02871
G1 X91.96 Y3.576 E5.4314
G1 X91.329 Y3.576 E.02871
G1 X176.424 Y88.671 E5.472
G1 X176.424 Y89.303 E.02871
G1 X90.697 Y3.576 E5.51259
G1 X90.066 Y3.576 E.02871
G1 X176.424 Y89.934 E5.55319
G1 X176.424 Y90.565 E.02871
G1 X89.435 Y3.576 E5.59379
G1 X88.804 Y3.576 E.02871
G1 X176.424 Y91.196 E5.63438
G1 X176.424 Y91.828 E.02871
G1 X88.172 Y3.576 E5.67498
G1 X87.541 Y3.576 E.02871
G1 X176.424 Y92.459 E5.71557
G1 X176.424 Y93.09 E.02871
G1 X86.91 Y3.576 E5.75617
G1 X86.278 Y3.576 E.02871
G1 X176.424 Y93.722 E5.79676
G1 X176.424 Y94.353 E.02871
G1 X85.647 Y3.576 E5.83736
G1 X85.016 Y3.576 E.02871
G1 X176.424 Y94.984 E5.87795
G1 X176.424 Y95.616 E.02871
G1 X84.384 Y3.576 E5.91855
G1 X83.753 Y3.576 E.02871
G1 X176.424 Y96.247 E5.95915
G1 X176.424 Y96.878 E.02871
G1 X83.122 Y3.576 E5.99974
G1 X82.49 Y3.576 E.02871
G1 X176.424 Y97.51 E6.04034
G1 X176.424 Y98.141 E.02871
M73 P13 R66
G1 X81.859 Y3.576 E6.08093
G1 X81.228 Y3.576 E.02871
G1 X176.424 Y98.772 E6.12153
G1 X176.424 Y99.403 E.02871
G1 X80.597 Y3.576 E6.16212
G1 X79.965 Y3.576 E.02871
G1 X176.424 Y100.035 E6.20272
G1 X176.424 Y100.666 E.02871
G1 X79.334 Y3.576 E6.24331
G1 X78.703 Y3.576 E.02871
M73 P13 R65
G1 X176.424 Y101.297 E6.28391
G1 X176.424 Y101.929 E.02871
G1 X78.071 Y3.576 E6.32451
G1 X77.44 Y3.576 E.02871
G1 X176.424 Y102.56 E6.3651
G1 X176.424 Y103.191 E.02871
G1 X76.809 Y3.576 E6.4057
G1 X76.177 Y3.576 E.02871
G1 X176.424 Y103.823 E6.44629
G1 X176.424 Y104.454 E.02871
G1 X75.546 Y3.576 E6.48689
G1 X74.915 Y3.576 E.02871
G1 X176.424 Y105.085 E6.52748
G1 X176.424 Y105.717 E.02871
G1 X74.284 Y3.576 E6.56808
G1 X73.652 Y3.576 E.02871
G1 X176.424 Y106.348 E6.60867
G1 X176.424 Y106.979 E.02871
G1 X73.021 Y3.576 E6.64927
G1 X72.39 Y3.576 E.02871
G1 X176.424 Y107.61 E6.68987
G1 X176.424 Y108.242 E.02871
M73 P14 R65
G1 X71.758 Y3.576 E6.73046
G1 X71.127 Y3.576 E.02871
G1 X176.424 Y108.873 E6.77106
G1 X176.424 Y109.504 E.02871
G1 X70.496 Y3.576 E6.81165
G1 X69.864 Y3.576 E.02871
G1 X176.424 Y110.136 E6.85225
G1 X176.424 Y110.767 E.02871
G1 X69.233 Y3.576 E6.89284
G1 X68.602 Y3.576 E.02871
G1 X176.424 Y111.398 E6.93344
G1 X176.424 Y112.03 E.02871
G1 X67.97 Y3.576 E6.97403
G1 X67.339 Y3.576 E.02871
G1 X176.424 Y112.661 E7.01463
G1 X176.424 Y113.292 E.02871
G1 X66.708 Y3.576 E7.05523
G1 X66.077 Y3.576 E.02871
G1 X176.424 Y113.923 E7.09582
G1 X176.424 Y114.555 E.02871
M73 P14 R64
G1 X65.445 Y3.576 E7.13642
G1 X64.814 Y3.576 E.02871
G1 X176.424 Y115.186 E7.17701
G1 X176.424 Y115.817 E.02871
G1 X64.183 Y3.576 E7.21761
G1 X63.551 Y3.576 E.02871
G1 X176.424 Y116.449 E7.2582
G1 X176.424 Y117.08 E.02871
G1 X62.92 Y3.576 E7.2988
G1 X62.289 Y3.576 E.02871
M73 P15 R64
G1 X176.424 Y117.711 E7.33939
G1 X176.424 Y118.343 E.02871
G1 X61.657 Y3.576 E7.37999
G1 X61.026 Y3.576 E.02871
G1 X176.424 Y118.974 E7.42059
G1 X176.424 Y119.605 E.02871
G1 X60.395 Y3.576 E7.46118
G1 X59.763 Y3.576 E.02871
G1 X176.424 Y120.237 E7.50178
G1 X176.424 Y120.868 E.02871
G1 X59.132 Y3.576 E7.54237
G1 X58.501 Y3.576 E.02871
G1 X176.424 Y121.499 E7.58297
G1 X176.424 Y122.13 E.02871
G1 X57.87 Y3.576 E7.62356
G1 X57.238 Y3.576 E.02871
G1 X176.424 Y122.762 E7.66416
G1 X176.424 Y123.393 E.02871
G1 X56.607 Y3.576 E7.70475
G1 X55.976 Y3.576 E.02871
G1 X176.424 Y124.024 E7.74535
G1 X176.424 Y124.656 E.02871
G1 X55.344 Y3.576 E7.78595
G1 X54.713 Y3.576 E.02871
G1 X176.424 Y125.287 E7.82654
G1 X176.424 Y125.918 E.02871
M73 P15 R63
G1 X54.082 Y3.576 E7.86714
G1 X53.45 Y3.576 E.02871
M73 P16 R63
G1 X176.424 Y126.55 E7.90773
G1 X176.424 Y127.181 E.02871
G1 X52.819 Y3.576 E7.94833
G1 X52.188 Y3.576 E.02871
G1 X176.424 Y127.812 E7.98892
G1 X176.424 Y128.443 E.02871
G1 X51.557 Y3.576 E8.02952
G1 X50.925 Y3.576 E.02871
G1 X176.424 Y129.075 E8.07011
G1 X176.424 Y129.706 E.02871
G1 X50.294 Y3.576 E8.11071
G1 X49.663 Y3.576 E.02871
G1 X176.424 Y130.337 E8.15131
G1 X176.424 Y130.969 E.02871
G1 X49.031 Y3.576 E8.1919
G1 X48.4 Y3.576 E.02871
G1 X176.424 Y131.6 E8.2325
G1 X176.424 Y132.231 E.02871
G1 X47.769 Y3.576 E8.27309
G1 X47.137 Y3.576 E.02871
G1 X176.424 Y132.863 E8.31369
G1 X176.424 Y133.494 E.02871
G1 X46.506 Y3.576 E8.35428
G1 X45.875 Y3.576 E.02871
G1 X176.424 Y134.125 E8.39488
G1 X176.424 Y134.757 E.02871
M73 P17 R63
G1 X45.243 Y3.576 E8.43547
G1 X44.612 Y3.576 E.02871
G1 X176.424 Y135.388 E8.47607
G1 X176.424 Y136.019 E.02871
G1 X43.981 Y3.576 E8.51667
G1 X43.35 Y3.576 E.02871
M73 P17 R62
G1 X176.424 Y136.65 E8.55726
G1 X176.424 Y137.282 E.02871
G1 X42.718 Y3.576 E8.59786
G1 X42.087 Y3.576 E.02871
G1 X176.424 Y137.913 E8.63845
G1 X176.424 Y138.544 E.02871
G1 X41.456 Y3.576 E8.67905
G1 X40.824 Y3.576 E.02871
G1 X176.424 Y139.176 E8.71964
G1 X176.424 Y139.807 E.02871
G1 X40.193 Y3.576 E8.76024
G1 X39.562 Y3.576 E.02871
G1 X176.424 Y140.438 E8.80083
G1 X176.424 Y141.07 E.02871
G1 X38.93 Y3.576 E8.84143
G1 X38.299 Y3.576 E.02871
G1 X176.424 Y141.701 E8.88203
G1 X176.424 Y142.332 E.02871
M73 P18 R62
G1 X37.668 Y3.576 E8.92262
G1 X37.037 Y3.576 E.02871
G1 X176.424 Y142.963 E8.96322
G1 X176.424 Y143.595 E.02871
G1 X36.405 Y3.576 E9.00381
G1 X35.774 Y3.576 E.02871
G1 X176.424 Y144.226 E9.04441
G1 X176.424 Y144.857 E.02871
G1 X35.143 Y3.576 E9.085
G1 X34.511 Y3.576 E.02871
G1 X176.424 Y145.489 E9.1256
G1 X176.424 Y146.12 E.02871
M73 P18 R61
G1 X33.88 Y3.576 E9.16619
G1 X33.249 Y3.576 E.02871
G1 X176.424 Y146.751 E9.20679
G1 X176.424 Y147.383 E.02871
G1 X32.617 Y3.576 E9.24739
G1 X31.986 Y3.576 E.02871
G1 X176.424 Y148.014 E9.28798
G1 X176.424 Y148.645 E.02871
G1 X31.355 Y3.576 E9.32858
G1 X30.723 Y3.576 E.02871
M73 P19 R61
G1 X176.424 Y149.277 E9.36917
G1 X176.424 Y149.908 E.02871
G1 X30.092 Y3.576 E9.40977
G1 X29.461 Y3.576 E.02871
G1 X176.424 Y150.539 E9.45036
G1 X176.424 Y151.17 E.02871
G1 X28.83 Y3.576 E9.49096
G1 X28.198 Y3.576 E.02871
G1 X176.424 Y151.802 E9.53155
G1 X176.424 Y152.433 E.02871
G1 X27.567 Y3.576 E9.57215
G1 X26.936 Y3.576 E.02871
G1 X176.424 Y153.064 E9.61275
G1 X176.424 Y153.696 E.02871
G1 X26.304 Y3.576 E9.65334
G1 X25.673 Y3.576 E.02871
G1 X176.424 Y154.327 E9.69394
G1 X176.424 Y154.958 E.02871
G1 X25.042 Y3.576 E9.73453
G1 X24.41 Y3.576 E.02871
M73 P19 R60
G1 X176.424 Y155.59 E9.77513
G1 X176.424 Y156.221 E.02871
M73 P20 R60
G1 X23.779 Y3.576 E9.81572
G1 X23.148 Y3.576 E.02871
G1 X176.424 Y156.852 E9.85632
G1 X176.424 Y157.484 E.02871
G1 X22.517 Y3.576 E9.89691
G1 X21.885 Y3.576 E.02871
G1 X176.424 Y158.115 E9.93751
G1 X176.424 Y158.746 E.02871
G1 X21.254 Y3.576 E9.97811
G1 X20.623 Y3.576 E.02871
G1 X176.424 Y159.377 E10.0187
G1 X176.424 Y160.009 E.02871
G1 X19.991 Y3.576 E10.0593
G1 X19.36 Y3.576 E.02871
G1 X176.424 Y160.64 E10.09989
G1 X176.424 Y161.271 E.02871
G1 X18.729 Y3.576 E10.14049
G1 X18.097 Y3.576 E.02871
G1 X176.424 Y161.903 E10.18108
G1 X176.424 Y162.534 E.02871
M73 P21 R60
G1 X17.466 Y3.576 E10.22168
G1 X16.835 Y3.576 E.02871
G1 X176.424 Y163.165 E10.26227
G1 X176.424 Y163.797 E.02871
M73 P21 R59
G1 X16.203 Y3.576 E10.30287
G1 X15.572 Y3.576 E.02871
G1 X176.424 Y164.428 E10.34346
G1 X176.424 Y165.059 E.02871
G1 X14.941 Y3.576 E10.38406
G1 X14.31 Y3.576 E.02871
G1 X176.424 Y165.69 E10.42466
G1 X176.424 Y166.322 E.02871
G1 X13.678 Y3.576 E10.46525
G1 X13.047 Y3.576 E.02871
G1 X176.424 Y166.953 E10.50585
G1 X176.424 Y167.584 E.02871
G1 X12.416 Y3.576 E10.54644
G1 X11.784 Y3.576 E.02871
G1 X176.424 Y168.216 E10.58704
G1 X176.424 Y168.847 E.02871
M73 P22 R59
G1 X11.153 Y3.576 E10.62763
G1 X10.522 Y3.576 E.02871
G1 X176.424 Y169.478 E10.66823
G1 X176.424 Y170.11 E.02871
G1 X9.89 Y3.576 E10.70883
G1 X9.259 Y3.576 E.02871
G1 X176.424 Y170.741 E10.74942
G1 X176.424 Y171.372 E.02871
G1 X8.628 Y3.576 E10.79002
G1 X7.996 Y3.576 E.02871
M73 P22 R58
G1 X176.424 Y172.004 E10.83061
G1 X176.424 Y172.635 E.02871
G1 X7.365 Y3.576 E10.87121
G1 X6.734 Y3.576 E.02871
G1 X176.424 Y173.266 E10.9118
G1 X176.424 Y173.897 E.02871
G1 X6.103 Y3.576 E10.9524
G1 X5.471 Y3.576 E.02871
G1 X176.424 Y174.529 E10.99299
G1 X176.424 Y175.16 E.02871
M73 P23 R58
G1 X4.84 Y3.576 E11.03359
G1 X4.209 Y3.576 E.02871
G1 X176.424 Y175.791 E11.07418
G1 X176.424 Y176.423 E.02871
G1 X3.576 Y3.576 E11.11483
G1 X3.576 Y4.205 E.02863
G1 X175.795 Y176.424 E11.07439
G1 X175.163 Y176.424 E.02871
G1 X3.576 Y4.837 E11.0338
G1 X3.576 Y5.468 E.02871
G1 X174.532 Y176.424 E10.9932
G1 X173.901 Y176.424 E.02871
G1 X3.576 Y6.099 E10.95261
G1 X3.576 Y6.731 E.02871
G1 X173.269 Y176.424 E10.91201
G1 X172.638 Y176.424 E.02871
M73 P23 R57
G1 X3.576 Y7.362 E10.87142
G1 X3.576 Y7.993 E.02871
M73 P24 R57
G1 X172.007 Y176.424 E10.83082
G1 X171.375 Y176.424 E.02871
G1 X3.576 Y8.625 E10.79023
G1 X3.576 Y9.256 E.02871
G1 X170.744 Y176.424 E10.74963
G1 X170.113 Y176.424 E.02871
G1 X3.576 Y9.887 E10.70903
G1 X3.576 Y10.518 E.02871
G1 X169.482 Y176.424 E10.66844
G1 X168.85 Y176.424 E.02871
G1 X3.576 Y11.15 E10.62784
G1 X3.576 Y11.781 E.02871
G1 X168.219 Y176.424 E10.58725
G1 X167.588 Y176.424 E.02871
G1 X3.576 Y12.412 E10.54665
G1 X3.576 Y13.044 E.02871
G1 X166.956 Y176.424 E10.50606
G1 X166.325 Y176.424 E.02871
G1 X3.576 Y13.675 E10.46546
G1 X3.576 Y14.306 E.02871
M73 P25 R57
G1 X165.694 Y176.424 E10.42487
G1 X165.062 Y176.424 E.02871
M73 P25 R56
G1 X3.576 Y14.938 E10.38427
G1 X3.576 Y15.569 E.02871
G1 X164.431 Y176.424 E10.34367
G1 X163.8 Y176.424 E.02871
G1 X3.576 Y16.2 E10.30308
G1 X3.576 Y16.832 E.02871
G1 X163.169 Y176.424 E10.26248
G1 X162.537 Y176.424 E.02871
G1 X3.576 Y17.463 E10.22189
G1 X3.576 Y18.094 E.02871
G1 X161.906 Y176.424 E10.18129
G1 X161.275 Y176.424 E.02871
G1 X3.576 Y18.725 E10.1407
G1 X3.576 Y19.357 E.02871
G1 X160.643 Y176.424 E10.1001
G1 X160.012 Y176.424 E.02871
M73 P26 R56
G1 X3.576 Y19.988 E10.05951
G1 X3.576 Y20.619 E.02871
G1 X159.381 Y176.424 E10.01891
G1 X158.749 Y176.424 E.02871
G1 X3.576 Y21.251 E9.97831
G1 X3.576 Y21.882 E.02871
G1 X158.118 Y176.424 E9.93772
G1 X157.487 Y176.424 E.02871
G1 X3.576 Y22.513 E9.89712
G1 X3.576 Y23.145 E.02871
M73 P26 R55
G1 X156.855 Y176.424 E9.85653
G1 X156.224 Y176.424 E.02871
G1 X3.576 Y23.776 E9.81593
G1 X3.576 Y24.407 E.02871
G1 X155.593 Y176.424 E9.77534
G1 X154.962 Y176.424 E.02871
G1 X3.576 Y25.038 E9.73474
G1 X3.576 Y25.67 E.02871
G1 X154.33 Y176.424 E9.69415
G1 X153.699 Y176.424 E.02871
M73 P27 R55
G1 X3.576 Y26.301 E9.65355
G1 X3.576 Y26.932 E.02871
G1 X153.068 Y176.424 E9.61295
G1 X152.436 Y176.424 E.02871
G1 X3.576 Y27.564 E9.57236
G1 X3.576 Y28.195 E.02871
G1 X151.805 Y176.424 E9.53176
G1 X151.174 Y176.424 E.02871
G1 X3.576 Y28.826 E9.49117
G1 X3.576 Y29.458 E.02871
G1 X150.542 Y176.424 E9.45057
G1 X149.911 Y176.424 E.02871
G1 X3.576 Y30.089 E9.40998
G1 X3.576 Y30.72 E.02871
G1 X149.28 Y176.424 E9.36938
G1 X148.648 Y176.424 E.02871
M73 P27 R54
G1 X3.576 Y31.352 E9.32879
G1 X3.576 Y31.983 E.02871
G1 X148.017 Y176.424 E9.28819
G1 X147.386 Y176.424 E.02871
G1 X3.576 Y32.614 E9.24759
G1 X3.576 Y33.245 E.02871
M73 P28 R54
G1 X146.755 Y176.424 E9.207
G1 X146.123 Y176.424 E.02871
G1 X3.576 Y33.877 E9.1664
G1 X3.576 Y34.508 E.02871
G1 X145.492 Y176.424 E9.12581
G1 X144.861 Y176.424 E.02871
G1 X3.576 Y35.139 E9.08521
G1 X3.576 Y35.771 E.02871
G1 X144.229 Y176.424 E9.04462
G1 X143.598 Y176.424 E.02871
G1 X3.576 Y36.402 E9.00402
G1 X3.576 Y37.033 E.02871
G1 X142.967 Y176.424 E8.96343
G1 X142.335 Y176.424 E.02871
G1 X3.576 Y37.665 E8.92283
G1 X3.576 Y38.296 E.02871
G1 X141.704 Y176.424 E8.88223
G1 X141.073 Y176.424 E.02871
G1 X3.576 Y38.927 E8.84164
G1 X3.576 Y39.558 E.02871
G1 X140.442 Y176.424 E8.80104
G1 X139.81 Y176.424 E.02871
M73 P29 R54
G1 X3.576 Y40.19 E8.76045
G1 X3.576 Y40.821 E.02871
M73 P29 R53
G1 X139.179 Y176.424 E8.71985
G1 X138.548 Y176.424 E.02871
G1 X3.576 Y41.452 E8.67926
G1 X3.576 Y42.084 E.02871
G1 X137.916 Y176.424 E8.63866
G1 X137.285 Y176.424 E.02871
G1 X3.576 Y42.715 E8.59807
G1 X3.576 Y43.346 E.02871
G1 X136.654 Y176.424 E8.55747
G1 X136.022 Y176.424 E.02871
G1 X3.576 Y43.978 E8.51687
G1 X3.576 Y44.609 E.02871
G1 X135.391 Y176.424 E8.47628
G1 X134.76 Y176.424 E.02871
G1 X3.576 Y45.24 E8.43568
G1 X3.576 Y45.872 E.02871
G1 X134.128 Y176.424 E8.39509
G1 X133.497 Y176.424 E.02871
G1 X3.576 Y46.503 E8.35449
G1 X3.576 Y47.134 E.02871
M73 P30 R53
G1 X132.866 Y176.424 E8.3139
G1 X132.235 Y176.424 E.02871
G1 X3.576 Y47.765 E8.2733
G1 X3.576 Y48.397 E.02871
G1 X131.603 Y176.424 E8.23271
G1 X130.972 Y176.424 E.02871
G1 X3.576 Y49.028 E8.19211
G1 X3.576 Y49.659 E.02871
G1 X130.341 Y176.424 E8.15151
G1 X129.709 Y176.424 E.02871
M73 P30 R52
G1 X3.576 Y50.291 E8.11092
G1 X3.576 Y50.922 E.02871
G1 X129.078 Y176.424 E8.07032
G1 X128.447 Y176.424 E.02871
G1 X3.576 Y51.553 E8.02973
G1 X3.576 Y52.185 E.02871
G1 X127.815 Y176.424 E7.98913
G1 X127.184 Y176.424 E.02871
G1 X3.576 Y52.816 E7.94854
G1 X3.576 Y53.447 E.02871
G1 X126.553 Y176.424 E7.90794
G1 X125.922 Y176.424 E.02871
G1 X3.576 Y54.078 E7.86735
G1 X3.576 Y54.71 E.02871
M73 P31 R52
G1 X125.29 Y176.424 E7.82675
G1 X124.659 Y176.424 E.02871
G1 X3.576 Y55.341 E7.78615
G1 X3.576 Y55.972 E.02871
G1 X124.028 Y176.424 E7.74556
G1 X123.396 Y176.424 E.02871
G1 X3.576 Y56.604 E7.70496
G1 X3.576 Y57.235 E.02871
G1 X122.765 Y176.424 E7.66437
G1 X122.134 Y176.424 E.02871
G1 X3.576 Y57.866 E7.62377
G1 X3.576 Y58.498 E.02871
G1 X121.502 Y176.424 E7.58318
G1 X120.871 Y176.424 E.02871
G1 X3.576 Y59.129 E7.54258
G1 X3.576 Y59.76 E.02871
G1 X120.24 Y176.424 E7.50199
G1 X119.608 Y176.424 E.02871
M73 P31 R51
G1 X3.576 Y60.392 E7.46139
G1 X3.576 Y61.023 E.02871
G1 X118.977 Y176.424 E7.42079
G1 X118.346 Y176.424 E.02871
G1 X3.576 Y61.654 E7.3802
G1 X3.576 Y62.285 E.02871
G1 X117.715 Y176.424 E7.3396
G1 X117.083 Y176.424 E.02871
M73 P32 R51
G1 X3.576 Y62.917 E7.29901
G1 X3.576 Y63.548 E.02871
G1 X116.452 Y176.424 E7.25841
G1 X115.821 Y176.424 E.02871
G1 X3.576 Y64.179 E7.21782
G1 X3.576 Y64.811 E.02871
G1 X115.189 Y176.424 E7.17722
G1 X114.558 Y176.424 E.02871
G1 X3.576 Y65.442 E7.13663
G1 X3.576 Y66.073 E.02871
G1 X113.927 Y176.424 E7.09603
G1 X113.295 Y176.424 E.02871
G1 X3.576 Y66.705 E7.05543
G1 X3.576 Y67.336 E.02871
G1 X112.664 Y176.424 E7.01484
G1 X112.033 Y176.424 E.02871
G1 X3.576 Y67.967 E6.97424
G1 X3.576 Y68.599 E.02871
G1 X111.401 Y176.424 E6.93365
G1 X110.77 Y176.424 E.02871
G1 X3.576 Y69.23 E6.89305
G1 X3.576 Y69.861 E.02871
G1 X110.139 Y176.424 E6.85246
G1 X109.508 Y176.424 E.02871
G1 X3.576 Y70.492 E6.81186
G1 X3.576 Y71.124 E.02871
G1 X108.876 Y176.424 E6.77127
G1 X108.245 Y176.424 E.02871
M73 P33 R50
G1 X3.576 Y71.755 E6.73067
G1 X3.576 Y72.386 E.02871
G1 X107.614 Y176.424 E6.69007
G1 X106.982 Y176.424 E.02871
G1 X3.576 Y73.018 E6.64948
G1 X3.576 Y73.649 E.02871
G1 X106.351 Y176.424 E6.60888
G1 X105.72 Y176.424 E.02871
G1 X3.576 Y74.28 E6.56829
G1 X3.576 Y74.912 E.02871
G1 X105.088 Y176.424 E6.52769
G1 X104.457 Y176.424 E.02871
G1 X3.576 Y75.543 E6.4871
G1 X3.576 Y76.174 E.02871
G1 X103.826 Y176.424 E6.4465
G1 X103.195 Y176.424 E.02871
G1 X3.576 Y76.805 E6.40591
G1 X3.576 Y77.437 E.02871
G1 X102.563 Y176.424 E6.36531
G1 X101.932 Y176.424 E.02871
G1 X3.576 Y78.068 E6.32471
G1 X3.576 Y78.699 E.02871
G1 X101.301 Y176.424 E6.28412
G1 X100.669 Y176.424 E.02871
G1 X3.576 Y79.331 E6.24352
G1 X3.576 Y79.962 E.02871
G1 X100.038 Y176.424 E6.20293
G1 X99.407 Y176.424 E.02871
G1 X3.576 Y80.593 E6.16233
G1 X3.576 Y81.225 E.02871
M73 P34 R50
G1 X98.775 Y176.424 E6.12174
G1 X98.144 Y176.424 E.02871
G1 X3.576 Y81.856 E6.08114
G1 X3.576 Y82.487 E.02871
G1 X97.513 Y176.424 E6.04055
G1 X96.881 Y176.424 E.02871
G1 X3.576 Y83.119 E5.99995
G1 X3.576 Y83.75 E.02871
G1 X96.25 Y176.424 E5.95935
G1 X95.619 Y176.424 E.02871
M73 P34 R49
G1 X3.576 Y84.381 E5.91876
G1 X3.576 Y85.012 E.02871
G1 X94.988 Y176.424 E5.87816
G1 X94.356 Y176.424 E.02871
G1 X3.576 Y85.644 E5.83757
G1 X3.576 Y86.275 E.02871
G1 X93.725 Y176.424 E5.79697
G1 X93.094 Y176.424 E.02871
G1 X3.576 Y86.906 E5.75638
G1 X3.576 Y87.538 E.02871
G1 X92.462 Y176.424 E5.71578
G1 X91.831 Y176.424 E.02871
G1 X3.576 Y88.169 E5.67519
G1 X3.576 Y88.8 E.02871
G1 X91.2 Y176.424 E5.63459
G1 X90.568 Y176.424 E.02871
G1 X3.576 Y89.432 E5.59399
G1 X3.576 Y90.063 E.02871
G1 X89.937 Y176.424 E5.5534
G1 X89.306 Y176.424 E.02871
G1 X3.576 Y90.694 E5.5128
G1 X3.576 Y91.325 E.02871
M73 P35 R49
G1 X88.675 Y176.424 E5.47221
G1 X88.043 Y176.424 E.02871
G1 X3.576 Y91.957 E5.43161
G1 X3.576 Y92.588 E.02871
G1 X87.412 Y176.424 E5.39102
G1 X86.781 Y176.424 E.02871
G1 X3.576 Y93.219 E5.35042
G1 X3.576 Y93.851 E.02871
G1 X86.149 Y176.424 E5.30983
G1 X85.518 Y176.424 E.02871
G1 X3.576 Y94.482 E5.26923
G1 X3.576 Y95.113 E.02871
G1 X84.887 Y176.424 E5.22863
G1 X84.255 Y176.424 E.02871
G1 X3.576 Y95.745 E5.18804
G1 X3.576 Y96.376 E.02871
G1 X83.624 Y176.424 E5.14744
G1 X82.993 Y176.424 E.02871
G1 X3.576 Y97.007 E5.10685
G1 X3.576 Y97.639 E.02871
G1 X82.361 Y176.424 E5.06625
G1 X81.73 Y176.424 E.02871
G1 X3.576 Y98.27 E5.02566
G1 X3.576 Y98.901 E.02871
M73 P35 R48
G1 X81.099 Y176.424 E4.98506
G1 X80.468 Y176.424 E.02871
G1 X3.576 Y99.532 E4.94447
G1 X3.576 Y100.164 E.02871
G1 X79.836 Y176.424 E4.90387
G1 X79.205 Y176.424 E.02871
G1 X3.576 Y100.795 E4.86327
G1 X3.576 Y101.426 E.02871
G1 X78.574 Y176.424 E4.82268
G1 X77.942 Y176.424 E.02871
G1 X3.576 Y102.058 E4.78208
G1 X3.576 Y102.689 E.02871
G1 X77.311 Y176.424 E4.74149
G1 X76.68 Y176.424 E.02871
M73 P36 R48
G1 X3.576 Y103.32 E4.70089
G1 X3.576 Y103.952 E.02871
G1 X76.048 Y176.424 E4.6603
G1 X75.417 Y176.424 E.02871
G1 X3.576 Y104.583 E4.6197
G1 X3.576 Y105.214 E.02871
G1 X74.786 Y176.424 E4.57911
G1 X74.155 Y176.424 E.02871
G1 X3.576 Y105.846 E4.53851
G1 X3.576 Y106.477 E.02871
G1 X73.523 Y176.424 E4.49792
G1 X72.892 Y176.424 E.02871
G1 X3.576 Y107.108 E4.45732
G1 X3.576 Y107.739 E.02871
G1 X72.261 Y176.424 E4.41672
G1 X71.629 Y176.424 E.02871
G1 X3.576 Y108.371 E4.37613
G1 X3.576 Y109.002 E.02871
G1 X70.998 Y176.424 E4.33553
G1 X70.367 Y176.424 E.02871
G1 X3.576 Y109.633 E4.29494
G1 X3.576 Y110.265 E.02871
G1 X69.735 Y176.424 E4.25434
G1 X69.104 Y176.424 E.02871
G1 X3.576 Y110.896 E4.21375
G1 X3.576 Y111.527 E.02871
G1 X68.473 Y176.424 E4.17315
G1 X67.841 Y176.424 E.02871
G1 X3.576 Y112.159 E4.13255
G1 X3.576 Y112.79 E.02871
G1 X67.21 Y176.424 E4.09196
G1 X66.579 Y176.424 E.02871
G1 X3.576 Y113.421 E4.05136
G1 X3.576 Y114.052 E.02871
G1 X65.948 Y176.424 E4.01077
G1 X65.316 Y176.424 E.02871
G1 X3.576 Y114.684 E3.97017
G1 X3.576 Y115.315 E.02871
G1 X64.685 Y176.424 E3.92958
G1 X64.054 Y176.424 E.02871
G1 X3.576 Y115.946 E3.88898
G1 X3.576 Y116.578 E.02871
M73 P36 R47
G1 X63.422 Y176.424 E3.84839
G1 X62.791 Y176.424 E.02871
M73 P37 R47
G1 X3.576 Y117.209 E3.80779
G1 X3.576 Y117.84 E.02871
G1 X62.16 Y176.424 E3.7672
G1 X61.528 Y176.424 E.02871
G1 X3.576 Y118.472 E3.7266
G1 X3.576 Y119.103 E.02871
G1 X60.897 Y176.424 E3.686
G1 X60.266 Y176.424 E.02871
G1 X3.576 Y119.734 E3.64541
G1 X3.576 Y120.366 E.02871
G1 X59.634 Y176.424 E3.60481
G1 X59.003 Y176.424 E.02871
G1 X3.576 Y120.997 E3.56422
G1 X3.576 Y121.628 E.02871
G1 X58.372 Y176.424 E3.52362
G1 X57.741 Y176.424 E.02871
G1 X3.576 Y122.259 E3.48303
G1 X3.576 Y122.891 E.02871
G1 X57.109 Y176.424 E3.44243
G1 X56.478 Y176.424 E.02871
G1 X3.576 Y123.522 E3.40183
G1 X3.576 Y124.153 E.02871
G1 X55.847 Y176.424 E3.36124
G1 X55.215 Y176.424 E.02871
G1 X3.576 Y124.785 E3.32064
G1 X3.576 Y125.416 E.02871
G1 X54.584 Y176.424 E3.28005
G1 X53.953 Y176.424 E.02871
G1 X3.576 Y126.047 E3.23945
G1 X3.576 Y126.679 E.02871
G1 X53.321 Y176.424 E3.19886
G1 X52.69 Y176.424 E.02871
G1 X3.576 Y127.31 E3.15826
G1 X3.576 Y127.941 E.02871
G1 X52.059 Y176.424 E3.11767
G1 X51.428 Y176.424 E.02871
G1 X3.576 Y128.572 E3.07707
G1 X3.576 Y129.204 E.02871
G1 X50.796 Y176.424 E3.03648
G1 X50.165 Y176.424 E.02871
G1 X3.576 Y129.835 E2.99588
G1 X3.576 Y130.466 E.02871
G1 X49.534 Y176.424 E2.95528
G1 X48.902 Y176.424 E.02871
G1 X3.576 Y131.098 E2.91469
G1 X3.576 Y131.729 E.02871
G1 X48.271 Y176.424 E2.87409
G1 X47.64 Y176.424 E.02871
G1 X3.576 Y132.36 E2.8335
G1 X3.576 Y132.992 E.02871
G1 X47.008 Y176.424 E2.7929
G1 X46.377 Y176.424 E.02871
G1 X3.576 Y133.623 E2.75231
G1 X3.576 Y134.254 E.02871
M73 P38 R47
G1 X45.746 Y176.424 E2.71171
G1 X45.114 Y176.424 E.02871
G1 X3.576 Y134.886 E2.67111
G1 X3.576 Y135.517 E.02871
G1 X44.483 Y176.424 E2.63052
G1 X43.852 Y176.424 E.02871
G1 X3.576 Y136.148 E2.58992
G1 X3.576 Y136.779 E.02871
G1 X43.221 Y176.424 E2.54933
G1 X42.589 Y176.424 E.02871
G1 X3.576 Y137.411 E2.50873
G1 X3.576 Y138.042 E.02871
G1 X41.958 Y176.424 E2.46814
G1 X41.327 Y176.424 E.02871
G1 X3.576 Y138.673 E2.42754
G1 X3.576 Y139.305 E.02871
G1 X40.695 Y176.424 E2.38695
G1 X40.064 Y176.424 E.02871
G1 X3.576 Y139.936 E2.34635
G1 X3.576 Y140.567 E.02871
M73 P38 R46
G1 X39.433 Y176.424 E2.30576
G1 X38.801 Y176.424 E.02871
G1 X3.576 Y141.199 E2.26516
G1 X3.576 Y141.83 E.02871
G1 X38.17 Y176.424 E2.22456
G1 X37.539 Y176.424 E.02871
G1 X3.576 Y142.461 E2.18397
G1 X3.576 Y143.092 E.02871
G1 X36.908 Y176.424 E2.14337
G1 X36.276 Y176.424 E.02871
G1 X3.576 Y143.724 E2.10278
G1 X3.576 Y144.355 E.02871
G1 X35.645 Y176.424 E2.06218
G1 X35.014 Y176.424 E.02871
G1 X3.576 Y144.986 E2.02159
G1 X3.576 Y145.618 E.02871
G1 X34.382 Y176.424 E1.98099
G1 X33.751 Y176.424 E.02871
G1 X3.576 Y146.249 E1.9404
G1 X3.576 Y146.88 E.02871
G1 X33.12 Y176.424 E1.8998
G1 X32.488 Y176.424 E.02871
G1 X3.576 Y147.512 E1.8592
G1 X3.576 Y148.143 E.02871
G1 X31.857 Y176.424 E1.81861
G1 X31.226 Y176.424 E.02871
G1 X3.576 Y148.774 E1.77801
G1 X3.576 Y149.406 E.02871
G1 X30.594 Y176.424 E1.73742
G1 X29.963 Y176.424 E.02871
G1 X3.576 Y150.037 E1.69682
G1 X3.576 Y150.668 E.02871
G1 X29.332 Y176.424 E1.65623
G1 X28.701 Y176.424 E.02871
G1 X3.576 Y151.299 E1.61563
G1 X3.576 Y151.931 E.02871
G1 X28.069 Y176.424 E1.57504
G1 X27.438 Y176.424 E.02871
G1 X3.576 Y152.562 E1.53444
G1 X3.576 Y153.193 E.02871
G1 X26.807 Y176.424 E1.49384
G1 X26.175 Y176.424 E.02871
G1 X3.576 Y153.825 E1.45325
G1 X3.576 Y154.456 E.02871
G1 X25.544 Y176.424 E1.41265
G1 X24.913 Y176.424 E.02871
G1 X3.576 Y155.087 E1.37206
G1 X3.576 Y155.719 E.02871
G1 X24.281 Y176.424 E1.33146
G1 X23.65 Y176.424 E.02871
G1 X3.576 Y156.35 E1.29087
G1 X3.576 Y156.981 E.02871
G1 X23.019 Y176.424 E1.25027
G1 X22.388 Y176.424 E.02871
G1 X3.576 Y157.613 E1.20968
G1 X3.576 Y158.244 E.02871
G1 X21.756 Y176.424 E1.16908
G1 X21.125 Y176.424 E.02871
G1 X3.576 Y158.875 E1.12848
G1 X3.576 Y159.506 E.02871
G1 X20.494 Y176.424 E1.08789
G1 X19.862 Y176.424 E.02871
G1 X3.576 Y160.138 E1.04729
G1 X3.576 Y160.769 E.02871
G1 X19.231 Y176.424 E1.0067
G1 X18.6 Y176.424 E.02871
G1 X3.576 Y161.4 E.9661
G1 X3.576 Y162.032 E.02871
G1 X17.968 Y176.424 E.92551
G1 X17.337 Y176.424 E.02871
G1 X3.576 Y162.663 E.88491
G1 X3.576 Y163.294 E.02871
M73 P39 R46
G1 X16.706 Y176.424 E.84432
G1 X16.074 Y176.424 E.02871
G1 X3.576 Y163.926 E.80372
G1 X3.576 Y164.557 E.02871
G1 X15.443 Y176.424 E.76312
G1 X14.812 Y176.424 E.02871
G1 X3.576 Y165.188 E.72253
G1 X3.576 Y165.819 E.02871
G1 X14.181 Y176.424 E.68193
G1 X13.549 Y176.424 E.02871
G1 X3.576 Y166.451 E.64134
G1 X3.576 Y167.082 E.02871
G1 X12.918 Y176.424 E.60074
G1 X12.287 Y176.424 E.02871
G1 X3.576 Y167.713 E.56015
G1 X3.576 Y168.345 E.02871
G1 X11.655 Y176.424 E.51955
G1 X11.024 Y176.424 E.02871
G1 X3.576 Y168.976 E.47896
G1 X3.576 Y169.607 E.02871
G1 X10.393 Y176.424 E.43836
G1 X9.761 Y176.424 E.02871
G1 X3.576 Y170.239 E.39776
G1 X3.576 Y170.87 E.02871
G1 X9.13 Y176.424 E.35717
G1 X8.499 Y176.424 E.02871
G1 X3.576 Y171.501 E.31657
G1 X3.576 Y172.133 E.02871
G1 X7.867 Y176.424 E.27598
G1 X7.236 Y176.424 E.02871
G1 X3.576 Y172.764 E.23538
G1 X3.576 Y173.395 E.02871
G1 X6.605 Y176.424 E.19479
G1 X5.974 Y176.424 E.02871
G1 X3.576 Y174.026 E.15419
G1 X3.576 Y174.658 E.02871
G1 X5.342 Y176.424 E.1136
G1 X4.711 Y176.424 E.02871
G1 X3.576 Y175.289 E.073
G1 X3.576 Y175.92 E.02871
G1 X4.281 Y176.625 E.04532
; CHANGE_LAYER
; Z_HEIGHT: 0.41
; LAYER_HEIGHT: 0.16
; WIPE_START
G1 F3000
G1 X3.576 Y175.92 E-.37875
G1 X3.576 Y175.289 E-.2399
G1 X3.839 Y175.552 E-.14135
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 2/6
; update layer progress
M73 L2
M991 S0 P1 ;notify layer change

; open powerlost recovery
M1003 S1
M104 S215 ; set nozzle temperature
G1 E-1.2
; filament end gcode 

M204 S10000
G17
G3 Z.65 I1.217 J0 P1  F42000
;===== machine: A1 mini =========================
;===== date: 20231225 =======================
G392 S0
M1007 S0
M620 S1A
M204 S9000

G1 Z3.41 F1200

M400
M106 P1 S0
M106 P2 S0

M104 S215


G1 X180 F18000
M620.1 E F523 T240
M620.10 A0 F523
T1
M73 E2
M620.1 E F523 T240
M620.10 A1 F523 L80.3399 H0.4 T240

G1 Y90 F9000


M400

G92 E0
M628 S0


; FLUSH_START
; always use highest temperature to flush
M400
M1002 set_filament_type:UNKNOWN
M109 S240
M106 P1 S60

G1 E23.7 F523 ; do not need pulsatile flushing for start part
G1 E1.1328 F50
G1 E13.0272 F523
G1 E1.1328 F50
G1 E13.0272 F523
G1 E1.1328 F50
G1 E13.0272 F523
G1 E1.1328 F50
G1 E13.0272 F523

; FLUSH_END
G1 E-2 F1800
G1 E2 F300
M400
M1002 set_filament_type:PLA














M629

M400
M106 P1 S60
M109 S215
G1 E5 F523 ;Compensate for filament spillage during waiting temperature
M400
G92 E0
M73 P40 R45
G1 E-2 F1800
M400
M106 P1 S178
M400 S3
G1 X-3.5 F18000
G1 X-13.5 F3000
G1 X-3.5 F18000
G1 X-13.5 F3000
G1 X-3.5 F18000
G1 X-13.5 F3000
G1 X-3.5 F18000
M400
M73 P40 R44
G1 Z3.41 F3000
M106 P1 S0

M204 S3000


M621 S1A

M9833 F1.54265 A0.3 ; cali dynamic extrusion compensation
M1002 judge_flag filament_need_cali_flag
M622 J1
  M106 P1 S178
  M400 S7
  G1 X0 F18000
  G1 X-13.5 F3000
  G1 X0 F18000 ;wipe and shake
  G1 X-13.5 F3000
M73 P41 R44
  G1 X0 F12000 ;wipe and shake
  G1 X-13.5 F3000
  M400
  M106 P1 S0 
M623

G392 S0
M1007 S1

M106 S0
M104 S215 ; set nozzle temperature
; filament start gcode
M106 P3 S200


; OBJECT_ID: 53
G1 X176.889 Y176.889 F42000
G1 Z.41
G1 E2 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F9000
M204 S3000
G1 X3.111 Y176.889 E4.70889
G1 X3.111 Y3.111 E4.70889
G1 X176.889 Y3.111 E4.70889
G1 X176.889 Y176.829 E4.70727
M204 S10000
G1 X177.29 Y177.29 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3600
M204 S2000
G1 X2.71 Y177.29 E4.38918
G1 X2.71 Y2.71 E4.38918
G1 X177.29 Y2.71 E4.38918
G1 X177.29 Y177.23 E4.38767
; WIPE_START
M204 S3000
G1 X175.29 Y177.231 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z.81 I1.217 J0 P1  F42000
;===================== date: 202312028 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
M622.1 S1 ; for prev firware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G17
G2 Z0.81 I0.86 J0.86 P1 F20000 ; spiral lift a little
G1 Z0.81
G1 X0 Y90 F18000 ; move to safe pos
G1 X-13.0 F3000 ; move to safe pos
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

M622.1 S1
M1002 judge_flag g39_detection_flag
M622 J1
  ; enable nozzle clog detect at 3rd layer
  


  
M623


G1 X175.943 Y176.722 F42000
G1 Z.41
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.420086
G1 F12000
M204 S3000
G1 X176.549 Y176.116 E.02156
G1 X176.549 Y175.571 E.01372
G1 X175.571 Y176.549 E.03479
G1 X175.025 Y176.549 E.01372
G1 X176.549 Y175.025 E.05419
G1 X176.549 Y174.48 E.01372
G1 X174.48 Y176.549 E.07359
G1 X173.934 Y176.549 E.01372
G1 X176.549 Y173.934 E.09299
G1 X176.549 Y173.388 E.01372
G1 X173.388 Y176.549 E.11239
G1 X172.843 Y176.549 E.01372
G1 X176.549 Y172.843 E.13179
G1 X176.549 Y172.297 E.01372
G1 X172.297 Y176.549 E.15119
G1 X171.752 Y176.549 E.01372
G1 X176.549 Y171.752 E.1706
G1 X176.549 Y171.206 E.01372
G1 X171.206 Y176.549 E.19
G1 X170.661 Y176.549 E.01372
G1 X176.549 Y170.661 E.2094
G1 X176.549 Y170.115 E.01372
G1 X170.115 Y176.549 E.2288
G1 X169.57 Y176.549 E.01372
G1 X176.549 Y169.57 E.2482
G1 X176.549 Y169.024 E.01372
G1 X169.024 Y176.549 E.2676
G1 X168.479 Y176.549 E.01372
G1 X176.549 Y168.479 E.287
G1 X176.549 Y167.933 E.01372
G1 X167.933 Y176.549 E.3064
G1 X167.388 Y176.549 E.01372
G1 X176.549 Y167.388 E.3258
G1 X176.549 Y166.842 E.01372
G1 X166.842 Y176.549 E.3452
G1 X166.297 Y176.549 E.01372
G1 X176.549 Y166.297 E.3646
G1 X176.549 Y165.751 E.01372
G1 X165.751 Y176.549 E.38401
G1 X165.205 Y176.549 E.01372
G1 X176.549 Y165.205 E.40341
G1 X176.549 Y164.66 E.01372
G1 X164.66 Y176.549 E.42281
G1 X164.114 Y176.549 E.01372
G1 X176.549 Y164.114 E.44221
G1 X176.549 Y163.569 E.01372
G1 X163.569 Y176.549 E.46161
G1 X163.023 Y176.549 E.01372
G1 X176.549 Y163.023 E.48101
G1 X176.549 Y162.478 E.01372
G1 X162.478 Y176.549 E.50041
G1 X161.932 Y176.549 E.01372
G1 X176.549 Y161.932 E.51981
G1 X176.549 Y161.387 E.01372
G1 X161.387 Y176.549 E.53921
G1 X160.841 Y176.549 E.01372
G1 X176.549 Y160.841 E.55861
G1 X176.549 Y160.296 E.01372
G1 X160.296 Y176.549 E.57801
G1 X159.75 Y176.549 E.01372
G1 X176.549 Y159.75 E.59742
G1 X176.549 Y159.205 E.01372
G1 X159.205 Y176.549 E.61682
G1 X158.659 Y176.549 E.01372
G1 X176.549 Y158.659 E.63622
G1 X176.549 Y158.114 E.01372
G1 X158.114 Y176.549 E.65562
G1 X157.568 Y176.549 E.01372
G1 X176.549 Y157.568 E.67502
G1 X176.549 Y157.022 E.01372
G1 X157.022 Y176.549 E.69442
G1 X156.477 Y176.549 E.01372
G1 X176.549 Y156.477 E.71382
G1 X176.549 Y155.931 E.01372
G1 X155.931 Y176.549 E.73322
G1 X155.386 Y176.549 E.01372
G1 X176.549 Y155.386 E.75262
G1 X176.549 Y154.84 E.01372
G1 X154.84 Y176.549 E.77202
G1 X154.295 Y176.549 E.01372
G1 X176.549 Y154.295 E.79142
G1 X176.549 Y153.749 E.01372
G1 X153.749 Y176.549 E.81083
G1 X153.204 Y176.549 E.01372
G1 X176.549 Y153.204 E.83023
G1 X176.549 Y152.658 E.01372
G1 X152.658 Y176.549 E.84963
G1 X152.113 Y176.549 E.01372
G1 X176.549 Y152.113 E.86903
G1 X176.549 Y151.567 E.01372
G1 X151.567 Y176.549 E.88843
G1 X151.022 Y176.549 E.01372
G1 X176.549 Y151.022 E.90783
G1 X176.549 Y150.476 E.01372
G1 X150.476 Y176.549 E.92723
G1 X149.931 Y176.549 E.01372
G1 X176.549 Y149.931 E.94663
G1 X176.549 Y149.385 E.01372
G1 X149.385 Y176.549 E.96603
G1 X148.839 Y176.549 E.01372
G1 X176.549 Y148.839 E.98543
G1 X176.549 Y148.294 E.01372
G1 X148.294 Y176.549 E1.00483
G1 X147.748 Y176.549 E.01372
G1 X176.549 Y147.748 E1.02424
G1 X176.549 Y147.203 E.01372
G1 X147.203 Y176.549 E1.04364
G1 X146.657 Y176.549 E.01372
G1 X176.549 Y146.657 E1.06304
G1 X176.549 Y146.112 E.01372
G1 X146.112 Y176.549 E1.08244
G1 X145.566 Y176.549 E.01372
G1 X176.549 Y145.566 E1.10184
G1 X176.549 Y145.021 E.01372
G1 X145.021 Y176.549 E1.12124
G1 X144.475 Y176.549 E.01372
G1 X176.549 Y144.475 E1.14064
G1 X176.549 Y143.93 E.01372
G1 X143.93 Y176.549 E1.16004
G1 X143.384 Y176.549 E.01372
G1 X176.549 Y143.384 E1.17944
G1 X176.549 Y142.839 E.01372
G1 X142.839 Y176.549 E1.19884
G1 X142.293 Y176.549 E.01372
G1 X176.549 Y142.293 E1.21824
G1 X176.549 Y141.748 E.01372
G1 X141.748 Y176.549 E1.23765
G1 X141.202 Y176.549 E.01372
G1 X176.549 Y141.202 E1.25705
G1 X176.549 Y140.656 E.01372
G1 X140.656 Y176.549 E1.27645
G1 X140.111 Y176.549 E.01372
G1 X176.549 Y140.111 E1.29585
G1 X176.549 Y139.565 E.01372
G1 X139.565 Y176.549 E1.31525
G1 X139.02 Y176.549 E.01372
G1 X176.549 Y139.02 E1.33465
G1 X176.549 Y138.474 E.01372
G1 X138.474 Y176.549 E1.35405
G1 X137.929 Y176.549 E.01372
G1 X176.549 Y137.929 E1.37345
G1 X176.549 Y137.383 E.01372
G1 X137.383 Y176.549 E1.39285
G1 X136.838 Y176.549 E.01372
G1 X176.549 Y136.838 E1.41225
G1 X176.549 Y136.292 E.01372
G1 X136.292 Y176.549 E1.43165
G1 X135.747 Y176.549 E.01372
G1 X176.549 Y135.747 E1.45106
G1 X176.549 Y135.201 E.01372
G1 X135.201 Y176.549 E1.47046
G1 X134.656 Y176.549 E.01372
G1 X176.549 Y134.656 E1.48986
G1 X176.549 Y134.11 E.01372
G1 X134.11 Y176.549 E1.50926
G1 X133.565 Y176.549 E.01372
G1 X176.549 Y133.565 E1.52866
G1 X176.549 Y133.019 E.01372
G1 X133.019 Y176.549 E1.54806
G1 X132.473 Y176.549 E.01372
M73 P42 R44
G1 X176.549 Y132.473 E1.56746
G1 X176.549 Y131.928 E.01372
G1 X131.928 Y176.549 E1.58686
G1 X131.382 Y176.549 E.01372
G1 X176.549 Y131.382 E1.60626
G1 X176.549 Y130.837 E.01372
G1 X130.837 Y176.549 E1.62566
G1 X130.291 Y176.549 E.01372
G1 X176.549 Y130.291 E1.64506
G1 X176.549 Y129.746 E.01372
G1 X129.746 Y176.549 E1.66447
G1 X129.2 Y176.549 E.01372
G1 X176.549 Y129.2 E1.68387
G1 X176.549 Y128.655 E.01372
G1 X128.655 Y176.549 E1.70327
G1 X128.109 Y176.549 E.01372
G1 X176.549 Y128.109 E1.72267
G1 X176.549 Y127.564 E.01372
G1 X127.564 Y176.549 E1.74207
G1 X127.018 Y176.549 E.01372
G1 X176.549 Y127.018 E1.76147
G1 X176.549 Y126.473 E.01372
G1 X126.473 Y176.549 E1.78087
G1 X125.927 Y176.549 E.01372
G1 X176.549 Y125.927 E1.80027
G1 X176.549 Y125.382 E.01372
G1 X125.382 Y176.549 E1.81967
G1 X124.836 Y176.549 E.01372
G1 X176.549 Y124.836 E1.83907
G1 X176.549 Y124.29 E.01372
G1 X124.29 Y176.549 E1.85847
G1 X123.745 Y176.549 E.01372
G1 X176.549 Y123.745 E1.87787
G1 X176.549 Y123.199 E.01372
G1 X123.199 Y176.549 E1.89728
G1 X122.654 Y176.549 E.01372
G1 X176.549 Y122.654 E1.91668
G1 X176.549 Y122.108 E.01372
G1 X122.108 Y176.549 E1.93608
G1 X121.563 Y176.549 E.01372
G1 X176.549 Y121.563 E1.95548
G1 X176.549 Y121.017 E.01372
G1 X121.017 Y176.549 E1.97488
G1 X120.472 Y176.549 E.01372
G1 X176.549 Y120.472 E1.99428
G1 X176.549 Y119.926 E.01372
G1 X119.926 Y176.549 E2.01368
G1 X119.381 Y176.549 E.01372
M73 P42 R43
G1 X176.549 Y119.381 E2.03308
G1 X176.549 Y118.835 E.01372
G1 X118.835 Y176.549 E2.05248
G1 X118.29 Y176.549 E.01372
G1 X176.549 Y118.29 E2.07188
G1 X176.549 Y117.744 E.01372
G1 X117.744 Y176.549 E2.09129
G1 X117.199 Y176.549 E.01372
G1 X176.549 Y117.199 E2.11069
G1 X176.549 Y116.653 E.01372
G1 X116.653 Y176.549 E2.13009
G1 X116.107 Y176.549 E.01372
G1 X176.549 Y116.107 E2.14949
G1 X176.549 Y115.562 E.01372
G1 X115.562 Y176.549 E2.16889
G1 X115.016 Y176.549 E.01372
G1 X176.549 Y115.016 E2.18829
G1 X176.549 Y114.471 E.01372
G1 X114.471 Y176.549 E2.20769
G1 X113.925 Y176.549 E.01372
G1 X176.549 Y113.925 E2.22709
G1 X176.549 Y113.38 E.01372
G1 X113.38 Y176.549 E2.24649
G1 X112.834 Y176.549 E.01372
G1 X176.549 Y112.834 E2.26589
G1 X176.549 Y112.289 E.01372
G1 X112.289 Y176.549 E2.28529
G1 X111.743 Y176.549 E.01372
G1 X176.549 Y111.743 E2.3047
G1 X176.549 Y111.198 E.01372
G1 X111.198 Y176.549 E2.3241
G1 X110.652 Y176.549 E.01372
G1 X176.549 Y110.652 E2.3435
G1 X176.549 Y110.107 E.01372
G1 X110.107 Y176.549 E2.3629
G1 X109.561 Y176.549 E.01372
G1 X176.549 Y109.561 E2.3823
G1 X176.549 Y109.016 E.01372
G1 X109.016 Y176.549 E2.4017
G1 X108.47 Y176.549 E.01372
G1 X176.549 Y108.47 E2.4211
G1 X176.549 Y107.925 E.01372
G1 X107.924 Y176.549 E2.4405
G1 X107.379 Y176.549 E.01372
G1 X176.549 Y107.379 E2.4599
G1 X176.549 Y106.833 E.01372
G1 X106.833 Y176.549 E2.4793
G1 X106.288 Y176.549 E.01372
G1 X176.549 Y106.288 E2.4987
G1 X176.549 Y105.742 E.01372
G1 X105.742 Y176.549 E2.5181
G1 X105.197 Y176.549 E.01372
G1 X176.549 Y105.197 E2.53751
G1 X176.549 Y104.651 E.01372
G1 X104.651 Y176.549 E2.55691
G1 X104.106 Y176.549 E.01372
G1 X176.549 Y104.106 E2.57631
G1 X176.549 Y103.56 E.01372
G1 X103.56 Y176.549 E2.59571
G1 X103.015 Y176.549 E.01372
G1 X176.549 Y103.015 E2.61511
G1 X176.549 Y102.469 E.01372
G1 X102.469 Y176.549 E2.63451
G1 X101.924 Y176.549 E.01372
G1 X176.549 Y101.924 E2.65391
G1 X176.549 Y101.378 E.01372
G1 X101.378 Y176.549 E2.67331
G1 X100.833 Y176.549 E.01372
G1 X176.549 Y100.833 E2.69271
G1 X176.549 Y100.287 E.01372
G1 X100.287 Y176.549 E2.71211
G1 X99.741 Y176.549 E.01372
G1 X176.549 Y99.742 E2.73151
G1 X176.549 Y99.196 E.01372
G1 X99.196 Y176.549 E2.75092
G1 X98.65 Y176.549 E.01372
G1 X176.549 Y98.65 E2.77032
G1 X176.549 Y98.105 E.01372
G1 X98.105 Y176.549 E2.78972
G1 X97.559 Y176.549 E.01372
G1 X176.549 Y97.559 E2.80912
G1 X176.549 Y97.014 E.01372
G1 X97.014 Y176.549 E2.82852
G1 X96.468 Y176.549 E.01372
G1 X176.549 Y96.468 E2.84792
G1 X176.549 Y95.923 E.01372
G1 X95.923 Y176.549 E2.86732
G1 X95.377 Y176.549 E.01372
G1 X176.549 Y95.377 E2.88672
G1 X176.549 Y94.832 E.01372
G1 X94.832 Y176.549 E2.90612
G1 X94.286 Y176.549 E.01372
G1 X176.549 Y94.286 E2.92552
G1 X176.549 Y93.741 E.01372
G1 X93.741 Y176.549 E2.94492
G1 X93.195 Y176.549 E.01372
G1 X176.549 Y93.195 E2.96433
G1 X176.549 Y92.65 E.01372
G1 X92.65 Y176.549 E2.98373
G1 X92.104 Y176.549 E.01372
G1 X176.549 Y92.104 E3.00313
G1 X176.549 Y91.559 E.01372
G1 X91.558 Y176.549 E3.02253
G1 X91.013 Y176.549 E.01372
G1 X176.549 Y91.013 E3.04193
G1 X176.549 Y90.467 E.01372
G1 X90.467 Y176.549 E3.06133
G1 X89.922 Y176.549 E.01372
G1 X176.549 Y89.922 E3.08073
G1 X176.549 Y89.376 E.01372
G1 X89.376 Y176.549 E3.10013
G1 X88.831 Y176.549 E.01372
G1 X176.549 Y88.831 E3.11953
G1 X176.549 Y88.285 E.01372
G1 X88.285 Y176.549 E3.13893
G1 X87.74 Y176.549 E.01372
G1 X176.549 Y87.74 E3.15833
G1 X176.549 Y87.194 E.01372
G1 X87.194 Y176.549 E3.17774
G1 X86.649 Y176.549 E.01372
G1 X176.549 Y86.649 E3.19714
G1 X176.549 Y86.103 E.01372
G1 X86.103 Y176.549 E3.21654
G1 X85.558 Y176.549 E.01372
M73 P43 R43
G1 X176.549 Y85.558 E3.23594
G1 X176.549 Y85.012 E.01372
G1 X85.012 Y176.549 E3.25534
G1 X84.467 Y176.549 E.01372
G1 X176.549 Y84.467 E3.27474
G1 X176.549 Y83.921 E.01372
G1 X83.921 Y176.549 E3.29414
G1 X83.375 Y176.549 E.01372
G1 X176.549 Y83.376 E3.31354
G1 X176.549 Y82.83 E.01372
G1 X82.83 Y176.549 E3.33294
G1 X82.284 Y176.549 E.01372
G1 X176.549 Y82.284 E3.35234
G1 X176.549 Y81.739 E.01372
G1 X81.739 Y176.549 E3.37174
G1 X81.193 Y176.549 E.01372
G1 X176.549 Y81.193 E3.39115
G1 X176.549 Y80.648 E.01372
G1 X80.648 Y176.549 E3.41055
G1 X80.102 Y176.549 E.01372
G1 X176.549 Y80.102 E3.42995
G1 X176.549 Y79.557 E.01372
G1 X79.557 Y176.549 E3.44935
G1 X79.011 Y176.549 E.01372
G1 X176.549 Y79.011 E3.46875
G1 X176.549 Y78.466 E.01372
G1 X78.466 Y176.549 E3.48815
G1 X77.92 Y176.549 E.01372
G1 X176.549 Y77.92 E3.50755
G1 X176.549 Y77.375 E.01372
G1 X77.375 Y176.549 E3.52695
G1 X76.829 Y176.549 E.01372
G1 X176.549 Y76.829 E3.54635
G1 X176.549 Y76.284 E.01372
G1 X76.284 Y176.549 E3.56575
G1 X75.738 Y176.549 E.01372
G1 X176.549 Y75.738 E3.58515
G1 X176.549 Y75.193 E.01372
G1 X75.193 Y176.549 E3.60456
G1 X74.647 Y176.549 E.01372
G1 X176.549 Y74.647 E3.62396
G1 X176.549 Y74.101 E.01372
G1 X74.101 Y176.549 E3.64336
G1 X73.556 Y176.549 E.01372
G1 X176.549 Y73.556 E3.66276
G1 X176.549 Y73.01 E.01372
G1 X73.01 Y176.549 E3.68216
G1 X72.465 Y176.549 E.01372
G1 X176.549 Y72.465 E3.70156
G1 X176.549 Y71.919 E.01372
G1 X71.919 Y176.549 E3.72096
G1 X71.374 Y176.549 E.01372
G1 X176.549 Y71.374 E3.74036
G1 X176.549 Y70.828 E.01372
G1 X70.828 Y176.549 E3.75976
G1 X70.283 Y176.549 E.01372
G1 X176.549 Y70.283 E3.77916
G1 X176.549 Y69.737 E.01372
G1 X69.737 Y176.549 E3.79856
G1 X69.192 Y176.549 E.01372
G1 X176.549 Y69.192 E3.81797
G1 X176.549 Y68.646 E.01372
M73 P43 R42
G1 X68.646 Y176.549 E3.83737
G1 X68.101 Y176.549 E.01372
G1 X176.549 Y68.101 E3.85677
G1 X176.549 Y67.555 E.01372
G1 X67.555 Y176.549 E3.87617
G1 X67.01 Y176.549 E.01372
G1 X176.549 Y67.01 E3.89557
G1 X176.549 Y66.464 E.01372
G1 X66.464 Y176.549 E3.91497
G1 X65.918 Y176.549 E.01372
G1 X176.549 Y65.918 E3.93437
G1 X176.549 Y65.373 E.01372
G1 X65.373 Y176.549 E3.95377
G1 X64.827 Y176.549 E.01372
G1 X176.549 Y64.827 E3.97317
G1 X176.549 Y64.282 E.01372
G1 X64.282 Y176.549 E3.99257
G1 X63.736 Y176.549 E.01372
G1 X176.549 Y63.736 E4.01197
G1 X176.549 Y63.191 E.01372
G1 X63.191 Y176.549 E4.03138
G1 X62.645 Y176.549 E.01372
G1 X176.549 Y62.645 E4.05078
G1 X176.549 Y62.1 E.01372
G1 X62.1 Y176.549 E4.07018
G1 X61.554 Y176.549 E.01372
G1 X176.549 Y61.554 E4.08958
G1 X176.549 Y61.009 E.01372
G1 X61.009 Y176.549 E4.10898
G1 X60.463 Y176.549 E.01372
G1 X176.549 Y60.463 E4.12838
G1 X176.549 Y59.918 E.01372
G1 X59.918 Y176.549 E4.14778
G1 X59.372 Y176.549 E.01372
G1 X176.549 Y59.372 E4.16718
G1 X176.549 Y58.827 E.01372
G1 X58.827 Y176.549 E4.18658
G1 X58.281 Y176.549 E.01372
G1 X176.549 Y58.281 E4.20598
G1 X176.549 Y57.735 E.01372
G1 X57.735 Y176.549 E4.22538
G1 X57.19 Y176.549 E.01372
G1 X176.549 Y57.19 E4.24479
G1 X176.549 Y56.644 E.01372
G1 X56.644 Y176.549 E4.26419
G1 X56.099 Y176.549 E.01372
G1 X176.549 Y56.099 E4.28359
G1 X176.549 Y55.553 E.01372
G1 X55.553 Y176.549 E4.30299
G1 X55.008 Y176.549 E.01372
M73 P44 R42
G1 X176.549 Y55.008 E4.32239
G1 X176.549 Y54.462 E.01372
G1 X54.462 Y176.549 E4.34179
G1 X53.917 Y176.549 E.01372
G1 X176.549 Y53.917 E4.36119
G1 X176.549 Y53.371 E.01372
G1 X53.371 Y176.549 E4.38059
G1 X52.826 Y176.549 E.01372
G1 X176.549 Y52.826 E4.39999
G1 X176.549 Y52.28 E.01372
G1 X52.28 Y176.549 E4.41939
G1 X51.735 Y176.549 E.01372
G1 X176.549 Y51.735 E4.43879
G1 X176.549 Y51.189 E.01372
G1 X51.189 Y176.549 E4.4582
G1 X50.644 Y176.549 E.01372
G1 X176.549 Y50.644 E4.4776
G1 X176.549 Y50.098 E.01372
G1 X50.098 Y176.549 E4.497
G1 X49.552 Y176.549 E.01372
G1 X176.549 Y49.552 E4.5164
G1 X176.549 Y49.007 E.01372
G1 X49.007 Y176.549 E4.5358
G1 X48.461 Y176.549 E.01372
G1 X176.549 Y48.461 E4.5552
G1 X176.549 Y47.916 E.01372
G1 X47.916 Y176.549 E4.5746
G1 X47.37 Y176.549 E.01372
G1 X176.549 Y47.37 E4.594
G1 X176.549 Y46.825 E.01372
G1 X46.825 Y176.549 E4.6134
G1 X46.279 Y176.549 E.01372
G1 X176.549 Y46.279 E4.6328
G1 X176.549 Y45.734 E.01372
G1 X45.734 Y176.549 E4.6522
G1 X45.188 Y176.549 E.01372
G1 X176.549 Y45.188 E4.6716
G1 X176.549 Y44.643 E.01372
G1 X44.643 Y176.549 E4.69101
G1 X44.097 Y176.549 E.01372
G1 X176.549 Y44.097 E4.71041
G1 X176.549 Y43.552 E.01372
G1 X43.552 Y176.549 E4.72981
G1 X43.006 Y176.549 E.01372
G1 X176.549 Y43.006 E4.74921
G1 X176.549 Y42.461 E.01372
G1 X42.461 Y176.549 E4.76861
G1 X41.915 Y176.549 E.01372
G1 X176.549 Y41.915 E4.78801
G1 X176.549 Y41.37 E.01372
G1 X41.369 Y176.549 E4.80741
G1 X40.824 Y176.549 E.01372
G1 X176.549 Y40.824 E4.82681
G1 X176.549 Y40.278 E.01372
G1 X40.278 Y176.549 E4.84621
G1 X39.733 Y176.549 E.01372
G1 X176.549 Y39.733 E4.86561
G1 X176.549 Y39.187 E.01372
G1 X39.187 Y176.549 E4.88501
G1 X38.642 Y176.549 E.01372
G1 X176.549 Y38.642 E4.90442
G1 X176.549 Y38.096 E.01372
G1 X38.096 Y176.549 E4.92382
G1 X37.551 Y176.549 E.01372
G1 X176.549 Y37.551 E4.94322
G1 X176.549 Y37.005 E.01372
G1 X37.005 Y176.549 E4.96262
G1 X36.46 Y176.549 E.01372
G1 X176.549 Y36.46 E4.98202
G1 X176.549 Y35.914 E.01372
G1 X35.914 Y176.549 E5.00142
G1 X35.369 Y176.549 E.01372
G1 X176.549 Y35.369 E5.02082
G1 X176.549 Y34.823 E.01372
G1 X34.823 Y176.549 E5.04022
G1 X34.278 Y176.549 E.01372
G1 X176.549 Y34.278 E5.05962
G1 X176.549 Y33.732 E.01372
M73 P44 R41
G1 X33.732 Y176.549 E5.07902
G1 X33.186 Y176.549 E.01372
G1 X176.549 Y33.187 E5.09842
G1 X176.549 Y32.641 E.01372
G1 X32.641 Y176.549 E5.11783
G1 X32.095 Y176.549 E.01372
G1 X176.549 Y32.095 E5.13723
G1 X176.549 Y31.55 E.01372
G1 X31.55 Y176.549 E5.15663
G1 X31.004 Y176.549 E.01372
G1 X176.549 Y31.004 E5.17603
G1 X176.549 Y30.459 E.01372
G1 X30.459 Y176.549 E5.19543
G1 X29.913 Y176.549 E.01372
M73 P45 R41
G1 X176.549 Y29.913 E5.21483
G1 X176.549 Y29.368 E.01372
G1 X29.368 Y176.549 E5.23423
G1 X28.822 Y176.549 E.01372
G1 X176.549 Y28.822 E5.25363
G1 X176.549 Y28.277 E.01372
G1 X28.277 Y176.549 E5.27303
G1 X27.731 Y176.549 E.01372
G1 X176.549 Y27.731 E5.29243
G1 X176.549 Y27.186 E.01372
G1 X27.186 Y176.549 E5.31183
G1 X26.64 Y176.549 E.01372
G1 X176.549 Y26.64 E5.33124
G1 X176.549 Y26.095 E.01372
G1 X26.095 Y176.549 E5.35064
G1 X25.549 Y176.549 E.01372
G1 X176.549 Y25.549 E5.37004
G1 X176.549 Y25.004 E.01372
G1 X25.003 Y176.549 E5.38944
G1 X24.458 Y176.549 E.01372
G1 X176.549 Y24.458 E5.40884
G1 X176.549 Y23.912 E.01372
G1 X23.912 Y176.549 E5.42824
G1 X23.367 Y176.549 E.01372
G1 X176.549 Y23.367 E5.44764
G1 X176.549 Y22.821 E.01372
G1 X22.821 Y176.549 E5.46704
G1 X22.276 Y176.549 E.01372
G1 X176.549 Y22.276 E5.48644
G1 X176.549 Y21.73 E.01372
G1 X21.73 Y176.549 E5.50584
G1 X21.185 Y176.549 E.01372
G1 X176.549 Y21.185 E5.52524
G1 X176.549 Y20.639 E.01372
G1 X20.639 Y176.549 E5.54465
G1 X20.094 Y176.549 E.01372
G1 X176.549 Y20.094 E5.56405
G1 X176.549 Y19.548 E.01372
G1 X19.548 Y176.549 E5.58345
G1 X19.003 Y176.549 E.01372
G1 X176.549 Y19.003 E5.60285
G1 X176.549 Y18.457 E.01372
G1 X18.457 Y176.549 E5.62225
G1 X17.912 Y176.549 E.01372
G1 X176.549 Y17.912 E5.64165
G1 X176.549 Y17.366 E.01372
G1 X17.366 Y176.549 E5.66105
G1 X16.82 Y176.549 E.01372
G1 X176.549 Y16.821 E5.68045
G1 X176.549 Y16.275 E.01372
G1 X16.275 Y176.549 E5.69985
G1 X15.729 Y176.549 E.01372
G1 X176.549 Y15.729 E5.71925
G1 X176.549 Y15.184 E.01372
G1 X15.184 Y176.549 E5.73865
G1 X14.638 Y176.549 E.01372
G1 X176.549 Y14.638 E5.75806
G1 X176.549 Y14.093 E.01372
G1 X14.093 Y176.549 E5.77746
G1 X13.547 Y176.549 E.01372
G1 X176.549 Y13.547 E5.79686
G1 X176.549 Y13.002 E.01372
G1 X13.002 Y176.549 E5.81626
G1 X12.456 Y176.549 E.01372
G1 X176.549 Y12.456 E5.83566
G1 X176.549 Y11.911 E.01372
G1 X11.911 Y176.549 E5.85506
G1 X11.365 Y176.549 E.01372
G1 X176.549 Y11.365 E5.87446
G1 X176.549 Y10.82 E.01372
G1 X10.82 Y176.549 E5.89386
G1 X10.274 Y176.549 E.01372
G1 X176.549 Y10.274 E5.91326
G1 X176.549 Y9.729 E.01372
G1 X9.729 Y176.549 E5.93266
G1 X9.183 Y176.549 E.01372
G1 X176.549 Y9.183 E5.95206
G1 X176.549 Y8.638 E.01372
M73 P46 R41
G1 X8.637 Y176.549 E5.97147
G1 X8.092 Y176.549 E.01372
G1 X176.549 Y8.092 E5.99087
G1 X176.549 Y7.546 E.01372
G1 X7.546 Y176.549 E6.01027
G1 X7.001 Y176.549 E.01372
G1 X176.549 Y7.001 E6.02967
G1 X176.549 Y6.455 E.01372
G1 X6.455 Y176.549 E6.04907
G1 X5.91 Y176.549 E.01372
G1 X176.549 Y5.91 E6.06847
G1 X176.549 Y5.364 E.01372
M73 P46 R40
G1 X5.364 Y176.549 E6.08787
G1 X4.819 Y176.549 E.01372
G1 X176.549 Y4.819 E6.10727
G1 X176.549 Y4.273 E.01372
G1 X4.273 Y176.549 E6.12667
G1 X3.728 Y176.549 E.01372
G1 X176.549 Y3.728 E6.14607
G1 X176.549 Y3.451 E.00695
G1 X176.28 Y3.451 E.00676
G1 X3.451 Y176.28 E6.14634
G1 X3.451 Y175.734 E.01372
G1 X175.734 Y3.451 E6.12694
G1 X175.189 Y3.451 E.01372
G1 X3.451 Y175.189 E6.10754
G1 X3.451 Y174.643 E.01372
G1 X174.643 Y3.451 E6.08814
G1 X174.098 Y3.451 E.01372
G1 X3.451 Y174.098 E6.06874
G1 X3.451 Y173.552 E.01372
G1 X173.552 Y3.451 E6.04934
G1 X173.007 Y3.451 E.01372
G1 X3.451 Y173.007 E6.02993
G1 X3.451 Y172.461 E.01372
G1 X172.461 Y3.451 E6.01053
G1 X171.916 Y3.451 E.01372
G1 X3.451 Y171.915 E5.99113
G1 X3.451 Y171.37 E.01372
G1 X171.37 Y3.451 E5.97173
G1 X170.824 Y3.451 E.01372
G1 X3.451 Y170.824 E5.95233
G1 X3.451 Y170.279 E.01372
G1 X170.279 Y3.451 E5.93293
G1 X169.733 Y3.451 E.01372
G1 X3.451 Y169.733 E5.91353
G1 X3.451 Y169.188 E.01372
G1 X169.188 Y3.451 E5.89413
G1 X168.642 Y3.451 E.01372
G1 X3.451 Y168.642 E5.87473
G1 X3.451 Y168.097 E.01372
G1 X168.097 Y3.451 E5.85533
G1 X167.551 Y3.451 E.01372
G1 X3.451 Y167.551 E5.83593
G1 X3.451 Y167.006 E.01372
G1 X167.006 Y3.451 E5.81652
G1 X166.46 Y3.451 E.01372
G1 X3.451 Y166.46 E5.79712
G1 X3.451 Y165.915 E.01372
G1 X165.915 Y3.451 E5.77772
G1 X165.369 Y3.451 E.01372
G1 X3.451 Y165.369 E5.75832
G1 X3.451 Y164.824 E.01372
G1 X164.824 Y3.451 E5.73892
G1 X164.278 Y3.451 E.01372
G1 X3.451 Y164.278 E5.71952
G1 X3.451 Y163.732 E.01372
G1 X163.733 Y3.451 E5.70012
G1 X163.187 Y3.451 E.01372
G1 X3.451 Y163.187 E5.68072
G1 X3.451 Y162.641 E.01372
G1 X162.641 Y3.451 E5.66132
G1 X162.096 Y3.451 E.01372
M73 P47 R40
G1 X3.451 Y162.096 E5.64192
G1 X3.451 Y161.55 E.01372
G1 X161.55 Y3.451 E5.62252
G1 X161.005 Y3.451 E.01372
G1 X3.451 Y161.005 E5.60311
G1 X3.451 Y160.459 E.01372
G1 X160.459 Y3.451 E5.58371
G1 X159.914 Y3.451 E.01372
G1 X3.451 Y159.914 E5.56431
G1 X3.451 Y159.368 E.01372
G1 X159.368 Y3.451 E5.54491
G1 X158.823 Y3.451 E.01372
G1 X3.451 Y158.823 E5.52551
G1 X3.451 Y158.277 E.01372
G1 X158.277 Y3.451 E5.50611
G1 X157.732 Y3.451 E.01372
G1 X3.451 Y157.732 E5.48671
G1 X3.451 Y157.186 E.01372
G1 X157.186 Y3.451 E5.46731
G1 X156.641 Y3.451 E.01372
G1 X3.451 Y156.641 E5.44791
G1 X3.451 Y156.095 E.01372
G1 X156.095 Y3.451 E5.42851
G1 X155.55 Y3.451 E.01372
G1 X3.451 Y155.55 E5.40911
G1 X3.451 Y155.004 E.01372
G1 X155.004 Y3.451 E5.3897
G1 X154.458 Y3.451 E.01372
G1 X3.451 Y154.458 E5.3703
G1 X3.451 Y153.913 E.01372
G1 X153.913 Y3.451 E5.3509
G1 X153.367 Y3.451 E.01372
G1 X3.451 Y153.367 E5.3315
G1 X3.451 Y152.822 E.01372
G1 X152.822 Y3.451 E5.3121
G1 X152.276 Y3.451 E.01372
M73 P47 R39
G1 X3.451 Y152.276 E5.2927
G1 X3.451 Y151.731 E.01372
G1 X151.731 Y3.451 E5.2733
G1 X151.185 Y3.451 E.01372
G1 X3.451 Y151.185 E5.2539
G1 X3.451 Y150.64 E.01372
G1 X150.64 Y3.451 E5.2345
G1 X150.094 Y3.451 E.01372
G1 X3.451 Y150.094 E5.2151
G1 X3.451 Y149.549 E.01372
G1 X149.549 Y3.451 E5.1957
G1 X149.003 Y3.451 E.01372
G1 X3.451 Y149.003 E5.17629
G1 X3.451 Y148.458 E.01372
G1 X148.458 Y3.451 E5.15689
G1 X147.912 Y3.451 E.01372
G1 X3.451 Y147.912 E5.13749
G1 X3.451 Y147.367 E.01372
G1 X147.367 Y3.451 E5.11809
G1 X146.821 Y3.451 E.01372
G1 X3.451 Y146.821 E5.09869
G1 X3.451 Y146.275 E.01372
G1 X146.275 Y3.451 E5.07929
G1 X145.73 Y3.451 E.01372
G1 X3.451 Y145.73 E5.05989
G1 X3.451 Y145.184 E.01372
G1 X145.184 Y3.451 E5.04049
G1 X144.639 Y3.451 E.01372
G1 X3.451 Y144.639 E5.02109
G1 X3.451 Y144.093 E.01372
G1 X144.093 Y3.451 E5.00169
G1 X143.548 Y3.451 E.01372
G1 X3.451 Y143.548 E4.98229
G1 X3.451 Y143.002 E.01372
G1 X143.002 Y3.451 E4.96288
G1 X142.457 Y3.451 E.01372
G1 X3.451 Y142.457 E4.94348
G1 X3.451 Y141.911 E.01372
G1 X141.911 Y3.451 E4.92408
G1 X141.366 Y3.451 E.01372
G1 X3.451 Y141.366 E4.90468
G1 X3.451 Y140.82 E.01372
M73 P48 R39
G1 X140.82 Y3.451 E4.88528
G1 X140.275 Y3.451 E.01372
G1 X3.451 Y140.275 E4.86588
G1 X3.451 Y139.729 E.01372
G1 X139.729 Y3.451 E4.84648
G1 X139.184 Y3.451 E.01372
G1 X3.451 Y139.184 E4.82708
G1 X3.451 Y138.638 E.01372
G1 X138.638 Y3.451 E4.80768
G1 X138.093 Y3.451 E.01372
G1 X3.451 Y138.092 E4.78828
G1 X3.451 Y137.547 E.01372
G1 X137.547 Y3.451 E4.76888
G1 X137.001 Y3.451 E.01372
G1 X3.451 Y137.001 E4.74947
G1 X3.451 Y136.456 E.01372
G1 X136.456 Y3.451 E4.73007
G1 X135.91 Y3.451 E.01372
G1 X3.451 Y135.91 E4.71067
G1 X3.451 Y135.365 E.01372
G1 X135.365 Y3.451 E4.69127
G1 X134.819 Y3.451 E.01372
G1 X3.451 Y134.819 E4.67187
G1 X3.451 Y134.274 E.01372
G1 X134.274 Y3.451 E4.65247
G1 X133.728 Y3.451 E.01372
G1 X3.451 Y133.728 E4.63307
G1 X3.451 Y133.183 E.01372
G1 X133.183 Y3.451 E4.61367
G1 X132.637 Y3.451 E.01372
G1 X3.451 Y132.637 E4.59427
G1 X3.451 Y132.092 E.01372
G1 X132.092 Y3.451 E4.57487
G1 X131.546 Y3.451 E.01372
G1 X3.451 Y131.546 E4.55547
G1 X3.451 Y131.001 E.01372
G1 X131.001 Y3.451 E4.53606
G1 X130.455 Y3.451 E.01372
G1 X3.451 Y130.455 E4.51666
G1 X3.451 Y129.909 E.01372
G1 X129.91 Y3.451 E4.49726
G1 X129.364 Y3.451 E.01372
G1 X3.451 Y129.364 E4.47786
G1 X3.451 Y128.818 E.01372
G1 X128.818 Y3.451 E4.45846
G1 X128.273 Y3.451 E.01372
G1 X3.451 Y128.273 E4.43906
G1 X3.451 Y127.727 E.01372
G1 X127.727 Y3.451 E4.41966
G1 X127.182 Y3.451 E.01372
G1 X3.451 Y127.182 E4.40026
G1 X3.451 Y126.636 E.01372
G1 X126.636 Y3.451 E4.38086
G1 X126.091 Y3.451 E.01372
G1 X3.451 Y126.091 E4.36146
G1 X3.451 Y125.545 E.01372
G1 X125.545 Y3.451 E4.34206
G1 X125 Y3.451 E.01372
G1 X3.451 Y125 E4.32265
G1 X3.451 Y124.454 E.01372
G1 X124.454 Y3.451 E4.30325
G1 X123.909 Y3.451 E.01372
G1 X3.451 Y123.909 E4.28385
G1 X3.451 Y123.363 E.01372
G1 X123.363 Y3.451 E4.26445
G1 X122.818 Y3.451 E.01372
G1 X3.451 Y122.818 E4.24505
G1 X3.451 Y122.272 E.01372
G1 X122.272 Y3.451 E4.22565
G1 X121.727 Y3.451 E.01372
G1 X3.451 Y121.726 E4.20625
G1 X3.451 Y121.181 E.01372
M73 P48 R38
G1 X121.181 Y3.451 E4.18685
G1 X120.635 Y3.451 E.01372
G1 X3.451 Y120.635 E4.16745
G1 X3.451 Y120.09 E.01372
G1 X120.09 Y3.451 E4.14805
G1 X119.544 Y3.451 E.01372
G1 X3.451 Y119.544 E4.12865
G1 X3.451 Y118.999 E.01372
G1 X118.999 Y3.451 E4.10924
G1 X118.453 Y3.451 E.01372
G1 X3.451 Y118.453 E4.08984
G1 X3.451 Y117.908 E.01372
G1 X117.908 Y3.451 E4.07044
G1 X117.362 Y3.451 E.01372
G1 X3.451 Y117.362 E4.05104
G1 X3.451 Y116.817 E.01372
G1 X116.817 Y3.451 E4.03164
G1 X116.271 Y3.451 E.01372
G1 X3.451 Y116.271 E4.01224
G1 X3.451 Y115.726 E.01372
G1 X115.726 Y3.451 E3.99284
G1 X115.18 Y3.451 E.01372
M73 P49 R38
G1 X3.451 Y115.18 E3.97344
G1 X3.451 Y114.635 E.01372
G1 X114.635 Y3.451 E3.95404
G1 X114.089 Y3.451 E.01372
G1 X3.451 Y114.089 E3.93464
G1 X3.451 Y113.543 E.01372
G1 X113.544 Y3.451 E3.91524
G1 X112.998 Y3.451 E.01372
G1 X3.451 Y112.998 E3.89584
G1 X3.451 Y112.452 E.01372
G1 X112.452 Y3.451 E3.87643
G1 X111.907 Y3.451 E.01372
G1 X3.451 Y111.907 E3.85703
G1 X3.451 Y111.361 E.01372
G1 X111.361 Y3.451 E3.83763
G1 X110.816 Y3.451 E.01372
G1 X3.451 Y110.816 E3.81823
G1 X3.451 Y110.27 E.01372
G1 X110.27 Y3.451 E3.79883
G1 X109.725 Y3.451 E.01372
G1 X3.451 Y109.725 E3.77943
G1 X3.451 Y109.179 E.01372
G1 X109.179 Y3.451 E3.76003
G1 X108.634 Y3.451 E.01372
G1 X3.451 Y108.634 E3.74063
G1 X3.451 Y108.088 E.01372
G1 X108.088 Y3.451 E3.72123
G1 X107.543 Y3.451 E.01372
G1 X3.451 Y107.543 E3.70183
G1 X3.451 Y106.997 E.01372
G1 X106.997 Y3.451 E3.68243
G1 X106.452 Y3.451 E.01372
G1 X3.451 Y106.452 E3.66302
G1 X3.451 Y105.906 E.01372
G1 X105.906 Y3.451 E3.64362
G1 X105.361 Y3.451 E.01372
G1 X3.451 Y105.36 E3.62422
G1 X3.451 Y104.815 E.01372
G1 X104.815 Y3.451 E3.60482
G1 X104.269 Y3.451 E.01372
G1 X3.451 Y104.269 E3.58542
G1 X3.451 Y103.724 E.01372
G1 X103.724 Y3.451 E3.56602
G1 X103.178 Y3.451 E.01372
G1 X3.451 Y103.178 E3.54662
G1 X3.451 Y102.633 E.01372
G1 X102.633 Y3.451 E3.52722
G1 X102.087 Y3.451 E.01372
G1 X3.451 Y102.087 E3.50782
G1 X3.451 Y101.542 E.01372
G1 X101.542 Y3.451 E3.48842
G1 X100.996 Y3.451 E.01372
G1 X3.451 Y100.996 E3.46901
G1 X3.451 Y100.451 E.01372
G1 X100.451 Y3.451 E3.44961
G1 X99.905 Y3.451 E.01372
G1 X3.451 Y99.905 E3.43021
G1 X3.451 Y99.36 E.01372
G1 X99.36 Y3.451 E3.41081
G1 X98.814 Y3.451 E.01372
G1 X3.451 Y98.814 E3.39141
G1 X3.451 Y98.269 E.01372
G1 X98.269 Y3.451 E3.37201
G1 X97.723 Y3.451 E.01372
G1 X3.451 Y97.723 E3.35261
G1 X3.451 Y97.177 E.01372
G1 X97.178 Y3.451 E3.33321
G1 X96.632 Y3.451 E.01372
G1 X3.451 Y96.632 E3.31381
G1 X3.451 Y96.086 E.01372
G1 X96.086 Y3.451 E3.29441
G1 X95.541 Y3.451 E.01372
G1 X3.451 Y95.541 E3.27501
G1 X3.451 Y94.995 E.01372
G1 X94.995 Y3.451 E3.25561
G1 X94.45 Y3.451 E.01372
G1 X3.451 Y94.45 E3.2362
G1 X3.451 Y93.904 E.01372
G1 X93.904 Y3.451 E3.2168
G1 X93.359 Y3.451 E.01372
G1 X3.451 Y93.359 E3.1974
G1 X3.451 Y92.813 E.01372
G1 X92.813 Y3.451 E3.178
G1 X92.268 Y3.451 E.01372
G1 X3.451 Y92.268 E3.1586
G1 X3.451 Y91.722 E.01372
G1 X91.722 Y3.451 E3.1392
G1 X91.177 Y3.451 E.01372
G1 X3.451 Y91.177 E3.1198
G1 X3.451 Y90.631 E.01372
G1 X90.631 Y3.451 E3.1004
G1 X90.086 Y3.451 E.01372
G1 X3.451 Y90.086 E3.081
G1 X3.451 Y89.54 E.01372
G1 X89.54 Y3.451 E3.0616
G1 X88.995 Y3.451 E.01372
G1 X3.451 Y88.995 E3.0422
G1 X3.451 Y88.449 E.01372
G1 X88.449 Y3.451 E3.02279
G1 X87.903 Y3.451 E.01372
G1 X3.451 Y87.903 E3.00339
G1 X3.451 Y87.358 E.01372
G1 X87.358 Y3.451 E2.98399
G1 X86.812 Y3.451 E.01372
G1 X3.451 Y86.812 E2.96459
G1 X3.451 Y86.267 E.01372
G1 X86.267 Y3.451 E2.94519
G1 X85.721 Y3.451 E.01372
G1 X3.451 Y85.721 E2.92579
G1 X3.451 Y85.176 E.01372
G1 X85.176 Y3.451 E2.90639
G1 X84.63 Y3.451 E.01372
G1 X3.451 Y84.63 E2.88699
G1 X3.451 Y84.085 E.01372
M73 P50 R38
G1 X84.085 Y3.451 E2.86759
G1 X83.539 Y3.451 E.01372
G1 X3.451 Y83.539 E2.84819
G1 X3.451 Y82.994 E.01372
G1 X82.994 Y3.451 E2.82879
G1 X82.448 Y3.451 E.01372
G1 X3.451 Y82.448 E2.80938
G1 X3.451 Y81.903 E.01372
G1 X81.903 Y3.451 E2.78998
G1 X81.357 Y3.451 E.01372
G1 X3.451 Y81.357 E2.77058
G1 X3.451 Y80.812 E.01372
G1 X80.812 Y3.451 E2.75118
G1 X80.266 Y3.451 E.01372
M73 P50 R37
G1 X3.451 Y80.266 E2.73178
G1 X3.451 Y79.72 E.01372
G1 X79.72 Y3.451 E2.71238
G1 X79.175 Y3.451 E.01372
G1 X3.451 Y79.175 E2.69298
G1 X3.451 Y78.629 E.01372
G1 X78.629 Y3.451 E2.67358
G1 X78.084 Y3.451 E.01372
G1 X3.451 Y78.084 E2.65418
G1 X3.451 Y77.538 E.01372
G1 X77.538 Y3.451 E2.63478
G1 X76.993 Y3.451 E.01372
G1 X3.451 Y76.993 E2.61538
G1 X3.451 Y76.447 E.01372
G1 X76.447 Y3.451 E2.59597
G1 X75.902 Y3.451 E.01372
G1 X3.451 Y75.902 E2.57657
G1 X3.451 Y75.356 E.01372
G1 X75.356 Y3.451 E2.55717
G1 X74.811 Y3.451 E.01372
G1 X3.451 Y74.811 E2.53777
G1 X3.451 Y74.265 E.01372
G1 X74.265 Y3.451 E2.51837
G1 X73.72 Y3.451 E.01372
G1 X3.451 Y73.72 E2.49897
G1 X3.451 Y73.174 E.01372
G1 X73.174 Y3.451 E2.47957
G1 X72.629 Y3.451 E.01372
G1 X3.451 Y72.629 E2.46017
G1 X3.451 Y72.083 E.01372
G1 X72.083 Y3.451 E2.44077
G1 X71.537 Y3.451 E.01372
G1 X3.451 Y71.537 E2.42137
G1 X3.451 Y70.992 E.01372
G1 X70.992 Y3.451 E2.40197
G1 X70.446 Y3.451 E.01372
G1 X3.451 Y70.446 E2.38256
G1 X3.451 Y69.901 E.01372
G1 X69.901 Y3.451 E2.36316
G1 X69.355 Y3.451 E.01372
G1 X3.451 Y69.355 E2.34376
G1 X3.451 Y68.81 E.01372
G1 X68.81 Y3.451 E2.32436
G1 X68.264 Y3.451 E.01372
G1 X3.451 Y68.264 E2.30496
G1 X3.451 Y67.719 E.01372
G1 X67.719 Y3.451 E2.28556
G1 X67.173 Y3.451 E.01372
G1 X3.451 Y67.173 E2.26616
G1 X3.451 Y66.628 E.01372
G1 X66.628 Y3.451 E2.24676
G1 X66.082 Y3.451 E.01372
G1 X3.451 Y66.082 E2.22736
G1 X3.451 Y65.537 E.01372
G1 X65.537 Y3.451 E2.20796
G1 X64.991 Y3.451 E.01372
G1 X3.451 Y64.991 E2.18856
G1 X3.451 Y64.446 E.01372
G1 X64.446 Y3.451 E2.16915
G1 X63.9 Y3.451 E.01372
G1 X3.451 Y63.9 E2.14975
G1 X3.451 Y63.354 E.01372
G1 X63.354 Y3.451 E2.13035
G1 X62.809 Y3.451 E.01372
G1 X3.451 Y62.809 E2.11095
G1 X3.451 Y62.263 E.01372
G1 X62.263 Y3.451 E2.09155
G1 X61.718 Y3.451 E.01372
G1 X3.451 Y61.718 E2.07215
G1 X3.451 Y61.172 E.01372
G1 X61.172 Y3.451 E2.05275
G1 X60.627 Y3.451 E.01372
G1 X3.451 Y60.627 E2.03335
G1 X3.451 Y60.081 E.01372
G1 X60.081 Y3.451 E2.01395
G1 X59.536 Y3.451 E.01372
G1 X3.451 Y59.536 E1.99455
G1 X3.451 Y58.99 E.01372
G1 X58.99 Y3.451 E1.97515
G1 X58.445 Y3.451 E.01372
G1 X3.451 Y58.445 E1.95574
G1 X3.451 Y57.899 E.01372
G1 X57.899 Y3.451 E1.93634
G1 X57.354 Y3.451 E.01372
G1 X3.451 Y57.354 E1.91694
G1 X3.451 Y56.808 E.01372
G1 X56.808 Y3.451 E1.89754
G1 X56.263 Y3.451 E.01372
G1 X3.451 Y56.263 E1.87814
G1 X3.451 Y55.717 E.01372
G1 X55.717 Y3.451 E1.85874
G1 X55.171 Y3.451 E.01372
G1 X3.451 Y55.171 E1.83934
G1 X3.451 Y54.626 E.01372
G1 X54.626 Y3.451 E1.81994
G1 X54.08 Y3.451 E.01372
G1 X3.451 Y54.08 E1.80054
G1 X3.451 Y53.535 E.01372
G1 X53.535 Y3.451 E1.78114
G1 X52.989 Y3.451 E.01372
G1 X3.451 Y52.989 E1.76174
G1 X3.451 Y52.444 E.01372
G1 X52.444 Y3.451 E1.74233
G1 X51.898 Y3.451 E.01372
G1 X3.451 Y51.898 E1.72293
G1 X3.451 Y51.353 E.01372
G1 X51.353 Y3.451 E1.70353
G1 X50.807 Y3.451 E.01372
G1 X3.451 Y50.807 E1.68413
G1 X3.451 Y50.262 E.01372
G1 X50.262 Y3.451 E1.66473
G1 X49.716 Y3.451 E.01372
G1 X3.451 Y49.716 E1.64533
G1 X3.451 Y49.171 E.01372
G1 X49.171 Y3.451 E1.62593
G1 X48.625 Y3.451 E.01372
G1 X3.451 Y48.625 E1.60653
G1 X3.451 Y48.08 E.01372
G1 X48.08 Y3.451 E1.58713
G1 X47.534 Y3.451 E.01372
G1 X3.451 Y47.534 E1.56773
G1 X3.451 Y46.988 E.01372
G1 X46.988 Y3.451 E1.54833
G1 X46.443 Y3.451 E.01372
G1 X3.451 Y46.443 E1.52892
G1 X3.451 Y45.897 E.01372
G1 X45.897 Y3.451 E1.50952
G1 X45.352 Y3.451 E.01372
G1 X3.451 Y45.352 E1.49012
G1 X3.451 Y44.806 E.01372
G1 X44.806 Y3.451 E1.47072
G1 X44.261 Y3.451 E.01372
G1 X3.451 Y44.261 E1.45132
G1 X3.451 Y43.715 E.01372
G1 X43.715 Y3.451 E1.43192
G1 X43.17 Y3.451 E.01372
G1 X3.451 Y43.17 E1.41252
G1 X3.451 Y42.624 E.01372
G1 X42.624 Y3.451 E1.39312
G1 X42.079 Y3.451 E.01372
G1 X3.451 Y42.079 E1.37372
G1 X3.451 Y41.533 E.01372
G1 X41.533 Y3.451 E1.35432
G1 X40.988 Y3.451 E.01372
G1 X3.451 Y40.988 E1.33492
G1 X3.451 Y40.442 E.01372
G1 X40.442 Y3.451 E1.31551
G1 X39.897 Y3.451 E.01372
G1 X3.451 Y39.897 E1.29611
G1 X3.451 Y39.351 E.01372
G1 X39.351 Y3.451 E1.27671
G1 X38.806 Y3.451 E.01372
G1 X3.451 Y38.805 E1.25731
G1 X3.451 Y38.26 E.01372
G1 X38.26 Y3.451 E1.23791
G1 X37.714 Y3.451 E.01372
G1 X3.451 Y37.714 E1.21851
G1 X3.451 Y37.169 E.01372
G1 X37.169 Y3.451 E1.19911
G1 X36.623 Y3.451 E.01372
G1 X3.451 Y36.623 E1.17971
G1 X3.451 Y36.078 E.01372
G1 X36.078 Y3.451 E1.16031
G1 X35.532 Y3.451 E.01372
G1 X3.451 Y35.532 E1.14091
G1 X3.451 Y34.987 E.01372
G1 X34.987 Y3.451 E1.12151
G1 X34.441 Y3.451 E.01372
M73 P51 R37
G1 X3.451 Y34.441 E1.1021
G1 X3.451 Y33.896 E.01372
G1 X33.896 Y3.451 E1.0827
G1 X33.35 Y3.451 E.01372
G1 X3.451 Y33.35 E1.0633
G1 X3.451 Y32.805 E.01372
G1 X32.805 Y3.451 E1.0439
G1 X32.259 Y3.451 E.01372
G1 X3.451 Y32.259 E1.0245
G1 X3.451 Y31.714 E.01372
G1 X31.714 Y3.451 E1.0051
G1 X31.168 Y3.451 E.01372
G1 X3.451 Y31.168 E.9857
G1 X3.451 Y30.622 E.01372
G1 X30.623 Y3.451 E.9663
G1 X30.077 Y3.451 E.01372
G1 X3.451 Y30.077 E.9469
G1 X3.451 Y29.531 E.01372
G1 X29.531 Y3.451 E.9275
G1 X28.986 Y3.451 E.01372
G1 X3.451 Y28.986 E.9081
G1 X3.451 Y28.44 E.01372
G1 X28.44 Y3.451 E.8887
G1 X27.895 Y3.451 E.01372
G1 X3.451 Y27.895 E.86929
G1 X3.451 Y27.349 E.01372
G1 X27.349 Y3.451 E.84989
G1 X26.804 Y3.451 E.01372
G1 X3.451 Y26.804 E.83049
G1 X3.451 Y26.258 E.01372
G1 X26.258 Y3.451 E.81109
G1 X25.713 Y3.451 E.01372
G1 X3.451 Y25.713 E.79169
G1 X3.451 Y25.167 E.01372
G1 X25.167 Y3.451 E.77229
G1 X24.622 Y3.451 E.01372
G1 X3.451 Y24.622 E.75289
G1 X3.451 Y24.076 E.01372
G1 X24.076 Y3.451 E.73349
G1 X23.531 Y3.451 E.01372
G1 X3.451 Y23.531 E.71409
G1 X3.451 Y22.985 E.01372
G1 X22.985 Y3.451 E.69469
G1 X22.44 Y3.451 E.01372
G1 X3.451 Y22.44 E.67529
G1 X3.451 Y21.894 E.01372
G1 X21.894 Y3.451 E.65588
G1 X21.348 Y3.451 E.01372
G1 X3.451 Y21.348 E.63648
G1 X3.451 Y20.803 E.01372
G1 X20.803 Y3.451 E.61708
G1 X20.257 Y3.451 E.01372
G1 X3.451 Y20.257 E.59768
G1 X3.451 Y19.712 E.01372
G1 X19.712 Y3.451 E.57828
G1 X19.166 Y3.451 E.01372
G1 X3.451 Y19.166 E.55888
G1 X3.451 Y18.621 E.01372
G1 X18.621 Y3.451 E.53948
G1 X18.075 Y3.451 E.01372
G1 X3.451 Y18.075 E.52008
G1 X3.451 Y17.53 E.01372
G1 X17.53 Y3.451 E.50068
G1 X16.984 Y3.451 E.01372
G1 X3.451 Y16.984 E.48128
G1 X3.451 Y16.439 E.01372
G1 X16.439 Y3.451 E.46188
G1 X15.893 Y3.451 E.01372
G1 X3.451 Y15.893 E.44247
G1 X3.451 Y15.348 E.01372
G1 X15.348 Y3.451 E.42307
G1 X14.802 Y3.451 E.01372
G1 X3.451 Y14.802 E.40367
G1 X3.451 Y14.257 E.01372
G1 X14.257 Y3.451 E.38427
G1 X13.711 Y3.451 E.01372
G1 X3.451 Y13.711 E.36487
G1 X3.451 Y13.165 E.01372
G1 X13.165 Y3.451 E.34547
G1 X12.62 Y3.451 E.01372
G1 X3.451 Y12.62 E.32607
G1 X3.451 Y12.074 E.01372
G1 X12.074 Y3.451 E.30667
G1 X11.529 Y3.451 E.01372
G1 X3.451 Y11.529 E.28727
G1 X3.451 Y10.983 E.01372
G1 X10.983 Y3.451 E.26787
G1 X10.438 Y3.451 E.01372
G1 X3.451 Y10.438 E.24847
G1 X3.451 Y9.892 E.01372
G1 X9.892 Y3.451 E.22906
G1 X9.347 Y3.451 E.01372
G1 X3.451 Y9.347 E.20966
G1 X3.451 Y8.801 E.01372
G1 X8.801 Y3.451 E.19026
G1 X8.256 Y3.451 E.01372
G1 X3.451 Y8.256 E.17086
G1 X3.451 Y7.71 E.01372
G1 X7.71 Y3.451 E.15146
G1 X7.165 Y3.451 E.01372
G1 X3.451 Y7.165 E.13206
G1 X3.451 Y6.619 E.01372
G1 X6.619 Y3.451 E.11266
G1 X6.074 Y3.451 E.01372
G1 X3.451 Y6.074 E.09326
G1 X3.451 Y5.528 E.01372
G1 X5.528 Y3.451 E.07386
G1 X4.982 Y3.451 E.01372
G1 X3.451 Y4.982 E.05446
G1 X3.451 Y4.437 E.01372
G1 X4.437 Y3.451 E.03506
G1 X3.891 Y3.451 E.01372
G1 X3.278 Y4.065 E.02183
; CHANGE_LAYER
; Z_HEIGHT: 0.57
; LAYER_HEIGHT: 0.16
; WIPE_START
G1 F12000
G1 X3.891 Y3.451 E-.32982
G1 X4.437 Y3.451 E-.2073
G1 X4.022 Y3.866 E-.22287
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 3/6
; update layer progress
M73 L3
M991 S0 P2 ;notify layer change

; OBJECT_ID: 53
M204 S10000
G17
G3 Z.81 I-.861 J.86 P1  F42000
G1 X176.889 Y176.889 Z.81
G1 Z.57
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F9000
M204 S3000
G1 X3.111 Y176.889 E4.70889
G1 X3.111 Y3.111 E4.70889
G1 X176.889 Y3.111 E4.70889
G1 X176.889 Y176.829 E4.70727
M204 S10000
G1 X177.29 Y177.29 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3600
M204 S2000
G1 X2.71 Y177.29 E4.38918
G1 X2.71 Y2.71 E4.38918
G1 X177.29 Y2.71 E4.38918
G1 X177.29 Y177.23 E4.38767
; WIPE_START
M204 S3000
G1 X175.29 Y177.231 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z.97 I1.217 J0 P1  F42000
;===================== date: 202312028 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
M622.1 S1 ; for prev firware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G17
G2 Z0.97 I0.86 J0.86 P1 F20000 ; spiral lift a little
G1 Z0.97
G1 X0 Y90 F18000 ; move to safe pos
G1 X-13.0 F3000 ; move to safe pos
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

M622.1 S1
M1002 judge_flag g39_detection_flag
M622 J1
  ; enable nozzle clog detect at 3rd layer
  
    M400
    G90
    M83
    M204 S5000
    G0 Z2 F4000
    G0 X-6 Y170 F20000
    G39 S1 X-6 Y170
    G0 Z2 F4000
    G0 X90 Y90 F30000
  


  
M623


G1 X4.065 Y176.722 F42000
G1 Z.57
M73 P51 R36
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.420086
G1 F12000
M204 S3000
G1 X3.451 Y176.109 E.02183
G1 X3.451 Y175.563 E.01372
G1 X4.437 Y176.549 E.03506
G1 X4.982 Y176.549 E.01372
G1 X3.451 Y175.018 E.05446
G1 X3.451 Y174.472 E.01372
G1 X5.528 Y176.549 E.07386
G1 X6.074 Y176.549 E.01372
G1 X3.451 Y173.926 E.09326
G1 X3.451 Y173.381 E.01372
G1 X6.619 Y176.549 E.11266
G1 X7.165 Y176.549 E.01372
G1 X3.451 Y172.835 E.13206
G1 X3.451 Y172.29 E.01372
G1 X7.71 Y176.549 E.15146
G1 X8.256 Y176.549 E.01372
G1 X3.451 Y171.744 E.17086
G1 X3.451 Y171.199 E.01372
G1 X8.801 Y176.549 E.19026
G1 X9.347 Y176.549 E.01372
G1 X3.451 Y170.653 E.20966
G1 X3.451 Y170.108 E.01372
G1 X9.892 Y176.549 E.22906
G1 X10.438 Y176.549 E.01372
G1 X3.451 Y169.562 E.24847
G1 X3.451 Y169.017 E.01372
G1 X10.983 Y176.549 E.26787
G1 X11.529 Y176.549 E.01372
G1 X3.451 Y168.471 E.28727
G1 X3.451 Y167.926 E.01372
G1 X12.074 Y176.549 E.30667
G1 X12.62 Y176.549 E.01372
G1 X3.451 Y167.38 E.32607
G1 X3.451 Y166.835 E.01372
G1 X13.165 Y176.549 E.34547
G1 X13.711 Y176.549 E.01372
G1 X3.451 Y166.289 E.36487
G1 X3.451 Y165.743 E.01372
G1 X14.257 Y176.549 E.38427
G1 X14.802 Y176.549 E.01372
G1 X3.451 Y165.198 E.40367
G1 X3.451 Y164.652 E.01372
G1 X15.348 Y176.549 E.42307
G1 X15.893 Y176.549 E.01372
G1 X3.451 Y164.107 E.44247
G1 X3.451 Y163.561 E.01372
G1 X16.439 Y176.549 E.46188
G1 X16.984 Y176.549 E.01372
G1 X3.451 Y163.016 E.48128
G1 X3.451 Y162.47 E.01372
G1 X17.53 Y176.549 E.50068
G1 X18.075 Y176.549 E.01372
G1 X3.451 Y161.925 E.52008
G1 X3.451 Y161.379 E.01372
G1 X18.621 Y176.549 E.53948
G1 X19.166 Y176.549 E.01372
G1 X3.451 Y160.834 E.55888
G1 X3.451 Y160.288 E.01372
G1 X19.712 Y176.549 E.57828
G1 X20.257 Y176.549 E.01372
G1 X3.451 Y159.743 E.59768
G1 X3.451 Y159.197 E.01372
G1 X20.803 Y176.549 E.61708
G1 X21.348 Y176.549 E.01372
G1 X3.451 Y158.652 E.63648
G1 X3.451 Y158.106 E.01372
G1 X21.894 Y176.549 E.65588
G1 X22.44 Y176.549 E.01372
G1 X3.451 Y157.561 E.67528
G1 X3.451 Y157.015 E.01372
G1 X22.985 Y176.549 E.69469
G1 X23.531 Y176.549 E.01372
G1 X3.451 Y156.469 E.71409
G1 X3.451 Y155.924 E.01372
G1 X24.076 Y176.549 E.73349
G1 X24.622 Y176.549 E.01372
G1 X3.451 Y155.378 E.75289
G1 X3.451 Y154.833 E.01372
G1 X25.167 Y176.549 E.77229
G1 X25.713 Y176.549 E.01372
G1 X3.451 Y154.287 E.79169
G1 X3.451 Y153.742 E.01372
G1 X26.258 Y176.549 E.81109
G1 X26.804 Y176.549 E.01372
G1 X3.451 Y153.196 E.83049
G1 X3.451 Y152.651 E.01372
G1 X27.349 Y176.549 E.84989
G1 X27.895 Y176.549 E.01372
G1 X3.451 Y152.105 E.86929
G1 X3.451 Y151.56 E.01372
G1 X28.44 Y176.549 E.8887
G1 X28.986 Y176.549 E.01372
G1 X3.451 Y151.014 E.9081
G1 X3.451 Y150.469 E.01372
G1 X29.531 Y176.549 E.9275
G1 X30.077 Y176.549 E.01372
G1 X3.451 Y149.923 E.9469
G1 X3.451 Y149.378 E.01372
G1 X30.623 Y176.549 E.9663
G1 X31.168 Y176.549 E.01372
G1 X3.451 Y148.832 E.9857
G1 X3.451 Y148.286 E.01372
G1 X31.714 Y176.549 E1.0051
G1 X32.259 Y176.549 E.01372
G1 X3.451 Y147.741 E1.0245
G1 X3.451 Y147.195 E.01372
G1 X32.805 Y176.549 E1.0439
G1 X33.35 Y176.549 E.01372
G1 X3.451 Y146.65 E1.0633
G1 X3.451 Y146.104 E.01372
G1 X33.896 Y176.549 E1.0827
G1 X34.441 Y176.549 E.01372
G1 X3.451 Y145.559 E1.10211
G1 X3.451 Y145.013 E.01372
G1 X34.987 Y176.549 E1.12151
G1 X35.532 Y176.549 E.01372
G1 X3.451 Y144.468 E1.14091
G1 X3.451 Y143.922 E.01372
G1 X36.078 Y176.549 E1.16031
G1 X36.623 Y176.549 E.01372
G1 X3.451 Y143.377 E1.17971
G1 X3.451 Y142.831 E.01372
G1 X37.169 Y176.549 E1.19911
G1 X37.714 Y176.549 E.01372
G1 X3.451 Y142.286 E1.21851
G1 X3.451 Y141.74 E.01372
G1 X38.26 Y176.549 E1.23791
G1 X38.805 Y176.549 E.01372
G1 X3.451 Y141.195 E1.25731
G1 X3.451 Y140.649 E.01372
G1 X39.351 Y176.549 E1.27671
G1 X39.897 Y176.549 E.01372
G1 X3.451 Y140.103 E1.29611
G1 X3.451 Y139.558 E.01372
G1 X40.442 Y176.549 E1.31551
G1 X40.988 Y176.549 E.01372
G1 X3.451 Y139.012 E1.33492
G1 X3.451 Y138.467 E.01372
G1 X41.533 Y176.549 E1.35432
G1 X42.079 Y176.549 E.01372
G1 X3.451 Y137.921 E1.37372
G1 X3.451 Y137.376 E.01372
G1 X42.624 Y176.549 E1.39312
G1 X43.17 Y176.549 E.01372
G1 X3.451 Y136.83 E1.41252
G1 X3.451 Y136.285 E.01372
M73 P52 R36
G1 X43.715 Y176.549 E1.43192
G1 X44.261 Y176.549 E.01372
G1 X3.451 Y135.739 E1.45132
G1 X3.451 Y135.194 E.01372
G1 X44.806 Y176.549 E1.47072
G1 X45.352 Y176.549 E.01372
G1 X3.451 Y134.648 E1.49012
G1 X3.451 Y134.103 E.01372
G1 X45.897 Y176.549 E1.50952
G1 X46.443 Y176.549 E.01372
G1 X3.451 Y133.557 E1.52892
G1 X3.451 Y133.012 E.01372
G1 X46.988 Y176.549 E1.54833
G1 X47.534 Y176.549 E.01372
G1 X3.451 Y132.466 E1.56773
G1 X3.451 Y131.92 E.01372
G1 X48.08 Y176.549 E1.58713
G1 X48.625 Y176.549 E.01372
G1 X3.451 Y131.375 E1.60653
G1 X3.451 Y130.829 E.01372
G1 X49.171 Y176.549 E1.62593
G1 X49.716 Y176.549 E.01372
G1 X3.451 Y130.284 E1.64533
G1 X3.451 Y129.738 E.01372
G1 X50.262 Y176.549 E1.66473
G1 X50.807 Y176.549 E.01372
G1 X3.451 Y129.193 E1.68413
G1 X3.451 Y128.647 E.01372
G1 X51.353 Y176.549 E1.70353
G1 X51.898 Y176.549 E.01372
G1 X3.451 Y128.102 E1.72293
G1 X3.451 Y127.556 E.01372
G1 X52.444 Y176.549 E1.74233
G1 X52.989 Y176.549 E.01372
G1 X3.451 Y127.011 E1.76174
G1 X3.451 Y126.465 E.01372
G1 X53.535 Y176.549 E1.78114
G1 X54.08 Y176.549 E.01372
G1 X3.451 Y125.92 E1.80054
G1 X3.451 Y125.374 E.01372
G1 X54.626 Y176.549 E1.81994
G1 X55.171 Y176.549 E.01372
G1 X3.451 Y124.829 E1.83934
G1 X3.451 Y124.283 E.01372
G1 X55.717 Y176.549 E1.85874
G1 X56.263 Y176.549 E.01372
G1 X3.451 Y123.737 E1.87814
G1 X3.451 Y123.192 E.01372
G1 X56.808 Y176.549 E1.89754
G1 X57.354 Y176.549 E.01372
G1 X3.451 Y122.646 E1.91694
G1 X3.451 Y122.101 E.01372
G1 X57.899 Y176.549 E1.93634
G1 X58.445 Y176.549 E.01372
G1 X3.451 Y121.555 E1.95574
G1 X3.451 Y121.01 E.01372
G1 X58.99 Y176.549 E1.97515
G1 X59.536 Y176.549 E.01372
G1 X3.451 Y120.464 E1.99455
G1 X3.451 Y119.919 E.01372
G1 X60.081 Y176.549 E2.01395
G1 X60.627 Y176.549 E.01372
G1 X3.451 Y119.373 E2.03335
G1 X3.451 Y118.828 E.01372
G1 X61.172 Y176.549 E2.05275
G1 X61.718 Y176.549 E.01372
G1 X3.451 Y118.282 E2.07215
G1 X3.451 Y117.737 E.01372
G1 X62.263 Y176.549 E2.09155
G1 X62.809 Y176.549 E.01372
G1 X3.451 Y117.191 E2.11095
G1 X3.451 Y116.646 E.01372
G1 X63.354 Y176.549 E2.13035
G1 X63.9 Y176.549 E.01372
G1 X3.451 Y116.1 E2.14975
G1 X3.451 Y115.554 E.01372
G1 X64.446 Y176.549 E2.16915
G1 X64.991 Y176.549 E.01372
G1 X3.451 Y115.009 E2.18856
G1 X3.451 Y114.463 E.01372
G1 X65.537 Y176.549 E2.20796
G1 X66.082 Y176.549 E.01372
G1 X3.451 Y113.918 E2.22736
G1 X3.451 Y113.372 E.01372
G1 X66.628 Y176.549 E2.24676
G1 X67.173 Y176.549 E.01372
G1 X3.451 Y112.827 E2.26616
G1 X3.451 Y112.281 E.01372
G1 X67.719 Y176.549 E2.28556
G1 X68.264 Y176.549 E.01372
G1 X3.451 Y111.736 E2.30496
G1 X3.451 Y111.19 E.01372
G1 X68.81 Y176.549 E2.32436
G1 X69.355 Y176.549 E.01372
G1 X3.451 Y110.645 E2.34376
G1 X3.451 Y110.099 E.01372
G1 X69.901 Y176.549 E2.36316
G1 X70.446 Y176.549 E.01372
G1 X3.451 Y109.554 E2.38256
G1 X3.451 Y109.008 E.01372
G1 X70.992 Y176.549 E2.40197
G1 X71.537 Y176.549 E.01372
G1 X3.451 Y108.463 E2.42137
G1 X3.451 Y107.917 E.01372
G1 X72.083 Y176.549 E2.44077
G1 X72.629 Y176.549 E.01372
G1 X3.451 Y107.371 E2.46017
G1 X3.451 Y106.826 E.01372
G1 X73.174 Y176.549 E2.47957
G1 X73.72 Y176.549 E.01372
G1 X3.451 Y106.28 E2.49897
G1 X3.451 Y105.735 E.01372
G1 X74.265 Y176.549 E2.51837
G1 X74.811 Y176.549 E.01372
G1 X3.451 Y105.189 E2.53777
G1 X3.451 Y104.644 E.01372
G1 X75.356 Y176.549 E2.55717
G1 X75.902 Y176.549 E.01372
G1 X3.451 Y104.098 E2.57657
G1 X3.451 Y103.553 E.01372
G1 X76.447 Y176.549 E2.59597
G1 X76.993 Y176.549 E.01372
G1 X3.451 Y103.007 E2.61538
G1 X3.451 Y102.462 E.01372
G1 X77.538 Y176.549 E2.63478
G1 X78.084 Y176.549 E.01372
G1 X3.451 Y101.916 E2.65418
G1 X3.451 Y101.371 E.01372
G1 X78.629 Y176.549 E2.67358
G1 X79.175 Y176.549 E.01372
G1 X3.451 Y100.825 E2.69298
G1 X3.451 Y100.28 E.01372
G1 X79.72 Y176.549 E2.71238
G1 X80.266 Y176.549 E.01372
G1 X3.451 Y99.734 E2.73178
G1 X3.451 Y99.188 E.01372
G1 X80.812 Y176.549 E2.75118
G1 X81.357 Y176.549 E.01372
G1 X3.451 Y98.643 E2.77058
G1 X3.451 Y98.097 E.01372
M73 P52 R35
G1 X81.903 Y176.549 E2.78998
G1 X82.448 Y176.549 E.01372
G1 X3.451 Y97.552 E2.80938
G1 X3.451 Y97.006 E.01372
G1 X82.994 Y176.549 E2.82879
G1 X83.539 Y176.549 E.01372
G1 X3.451 Y96.461 E2.84819
G1 X3.451 Y95.915 E.01372
G1 X84.085 Y176.549 E2.86759
G1 X84.63 Y176.549 E.01372
G1 X3.451 Y95.37 E2.88699
G1 X3.451 Y94.824 E.01372
G1 X85.176 Y176.549 E2.90639
G1 X85.721 Y176.549 E.01372
G1 X3.451 Y94.279 E2.92579
G1 X3.451 Y93.733 E.01372
G1 X86.267 Y176.549 E2.94519
G1 X86.812 Y176.549 E.01372
G1 X3.451 Y93.188 E2.96459
G1 X3.451 Y92.642 E.01372
G1 X87.358 Y176.549 E2.98399
G1 X87.903 Y176.549 E.01372
G1 X3.451 Y92.097 E3.00339
G1 X3.451 Y91.551 E.01372
G1 X88.449 Y176.549 E3.02279
G1 X88.995 Y176.549 E.01372
G1 X3.451 Y91.005 E3.0422
G1 X3.451 Y90.46 E.01372
G1 X89.54 Y176.549 E3.0616
G1 X90.086 Y176.549 E.01372
G1 X3.451 Y89.914 E3.081
G1 X3.451 Y89.369 E.01372
G1 X90.631 Y176.549 E3.1004
G1 X91.177 Y176.549 E.01372
G1 X3.451 Y88.823 E3.1198
G1 X3.451 Y88.278 E.01372
G1 X91.722 Y176.549 E3.1392
G1 X92.268 Y176.549 E.01372
G1 X3.451 Y87.732 E3.1586
G1 X3.451 Y87.187 E.01372
M73 P53 R35
G1 X92.813 Y176.549 E3.178
G1 X93.359 Y176.549 E.01372
G1 X3.451 Y86.641 E3.1974
G1 X3.451 Y86.096 E.01372
G1 X93.904 Y176.549 E3.2168
G1 X94.45 Y176.549 E.01372
G1 X3.451 Y85.55 E3.2362
G1 X3.451 Y85.005 E.01372
G1 X94.995 Y176.549 E3.25561
G1 X95.541 Y176.549 E.01372
G1 X3.451 Y84.459 E3.27501
G1 X3.451 Y83.914 E.01372
G1 X96.086 Y176.549 E3.29441
G1 X96.632 Y176.549 E.01372
G1 X3.451 Y83.368 E3.31381
G1 X3.451 Y82.822 E.01372
G1 X97.178 Y176.549 E3.33321
G1 X97.723 Y176.549 E.01372
G1 X3.451 Y82.277 E3.35261
G1 X3.451 Y81.731 E.01372
G1 X98.269 Y176.549 E3.37201
G1 X98.814 Y176.549 E.01372
G1 X3.451 Y81.186 E3.39141
G1 X3.451 Y80.64 E.01372
G1 X99.36 Y176.549 E3.41081
G1 X99.905 Y176.549 E.01372
G1 X3.451 Y80.095 E3.43021
G1 X3.451 Y79.549 E.01372
G1 X100.451 Y176.549 E3.44961
G1 X100.996 Y176.549 E.01372
G1 X3.451 Y79.004 E3.46902
G1 X3.451 Y78.458 E.01372
G1 X101.542 Y176.549 E3.48842
G1 X102.087 Y176.549 E.01372
G1 X3.451 Y77.913 E3.50782
G1 X3.451 Y77.367 E.01372
G1 X102.633 Y176.549 E3.52722
G1 X103.178 Y176.549 E.01372
G1 X3.451 Y76.822 E3.54662
G1 X3.451 Y76.276 E.01372
G1 X103.724 Y176.549 E3.56602
G1 X104.269 Y176.549 E.01372
G1 X3.451 Y75.731 E3.58542
G1 X3.451 Y75.185 E.01372
G1 X104.815 Y176.549 E3.60482
G1 X105.361 Y176.549 E.01372
G1 X3.451 Y74.64 E3.62422
G1 X3.451 Y74.094 E.01372
G1 X105.906 Y176.549 E3.64362
G1 X106.452 Y176.549 E.01372
G1 X3.451 Y73.548 E3.66302
G1 X3.451 Y73.003 E.01372
G1 X106.997 Y176.549 E3.68243
G1 X107.543 Y176.549 E.01372
G1 X3.451 Y72.457 E3.70183
G1 X3.451 Y71.912 E.01372
G1 X108.088 Y176.549 E3.72123
G1 X108.634 Y176.549 E.01372
G1 X3.451 Y71.366 E3.74063
G1 X3.451 Y70.821 E.01372
G1 X109.179 Y176.549 E3.76003
G1 X109.725 Y176.549 E.01372
G1 X3.451 Y70.275 E3.77943
G1 X3.451 Y69.73 E.01372
G1 X110.27 Y176.549 E3.79883
G1 X110.816 Y176.549 E.01372
G1 X3.451 Y69.184 E3.81823
G1 X3.451 Y68.639 E.01372
G1 X111.361 Y176.549 E3.83763
G1 X111.907 Y176.549 E.01372
G1 X3.451 Y68.093 E3.85703
G1 X3.451 Y67.548 E.01372
G1 X112.452 Y176.549 E3.87643
G1 X112.998 Y176.549 E.01372
G1 X3.451 Y67.002 E3.89583
G1 X3.451 Y66.457 E.01372
G1 X113.543 Y176.549 E3.91524
G1 X114.089 Y176.549 E.01372
G1 X3.451 Y65.911 E3.93464
G1 X3.451 Y65.365 E.01372
G1 X114.635 Y176.549 E3.95404
G1 X115.18 Y176.549 E.01372
G1 X3.451 Y64.82 E3.97344
G1 X3.451 Y64.274 E.01372
G1 X115.726 Y176.549 E3.99284
G1 X116.271 Y176.549 E.01372
G1 X3.451 Y63.729 E4.01224
G1 X3.451 Y63.183 E.01372
G1 X116.817 Y176.549 E4.03164
G1 X117.362 Y176.549 E.01372
G1 X3.451 Y62.638 E4.05104
G1 X3.451 Y62.092 E.01372
G1 X117.908 Y176.549 E4.07044
G1 X118.453 Y176.549 E.01372
G1 X3.451 Y61.547 E4.08984
G1 X3.451 Y61.001 E.01372
G1 X118.999 Y176.549 E4.10924
G1 X119.544 Y176.549 E.01372
G1 X3.451 Y60.456 E4.12865
G1 X3.451 Y59.91 E.01372
G1 X120.09 Y176.549 E4.14805
G1 X120.635 Y176.549 E.01372
G1 X3.451 Y59.365 E4.16745
G1 X3.451 Y58.819 E.01372
G1 X121.181 Y176.549 E4.18685
G1 X121.726 Y176.549 E.01372
G1 X3.451 Y58.274 E4.20625
G1 X3.451 Y57.728 E.01372
G1 X122.272 Y176.549 E4.22565
G1 X122.818 Y176.549 E.01372
G1 X3.451 Y57.182 E4.24505
G1 X3.451 Y56.637 E.01372
G1 X123.363 Y176.549 E4.26445
G1 X123.909 Y176.549 E.01372
G1 X3.451 Y56.091 E4.28385
G1 X3.451 Y55.546 E.01372
M73 P54 R35
G1 X124.454 Y176.549 E4.30325
G1 X125 Y176.549 E.01372
M73 P54 R34
G1 X3.451 Y55 E4.32265
G1 X3.451 Y54.455 E.01372
G1 X125.545 Y176.549 E4.34206
G1 X126.091 Y176.549 E.01372
G1 X3.451 Y53.909 E4.36146
G1 X3.451 Y53.364 E.01372
G1 X126.636 Y176.549 E4.38086
G1 X127.182 Y176.549 E.01372
G1 X3.451 Y52.818 E4.40026
G1 X3.451 Y52.273 E.01372
G1 X127.727 Y176.549 E4.41966
G1 X128.273 Y176.549 E.01372
G1 X3.451 Y51.727 E4.43906
G1 X3.451 Y51.182 E.01372
G1 X128.818 Y176.549 E4.45846
G1 X129.364 Y176.549 E.01372
G1 X3.451 Y50.636 E4.47786
G1 X3.451 Y50.091 E.01372
G1 X129.909 Y176.549 E4.49726
G1 X130.455 Y176.549 E.01372
G1 X3.451 Y49.545 E4.51666
G1 X3.451 Y48.999 E.01372
G1 X131.001 Y176.549 E4.53606
G1 X131.546 Y176.549 E.01372
G1 X3.451 Y48.454 E4.55547
G1 X3.451 Y47.908 E.01372
G1 X132.092 Y176.549 E4.57487
G1 X132.637 Y176.549 E.01372
G1 X3.451 Y47.363 E4.59427
G1 X3.451 Y46.817 E.01372
G1 X133.183 Y176.549 E4.61367
G1 X133.728 Y176.549 E.01372
G1 X3.451 Y46.272 E4.63307
G1 X3.451 Y45.726 E.01372
G1 X134.274 Y176.549 E4.65247
G1 X134.819 Y176.549 E.01372
G1 X3.451 Y45.181 E4.67187
G1 X3.451 Y44.635 E.01372
G1 X135.365 Y176.549 E4.69127
G1 X135.91 Y176.549 E.01372
G1 X3.451 Y44.09 E4.71067
G1 X3.451 Y43.544 E.01372
G1 X136.456 Y176.549 E4.73007
G1 X137.001 Y176.549 E.01372
G1 X3.451 Y42.999 E4.74947
G1 X3.451 Y42.453 E.01372
G1 X137.547 Y176.549 E4.76888
G1 X138.092 Y176.549 E.01372
G1 X3.451 Y41.908 E4.78828
G1 X3.451 Y41.362 E.01372
G1 X138.638 Y176.549 E4.80768
G1 X139.184 Y176.549 E.01372
G1 X3.451 Y40.816 E4.82708
G1 X3.451 Y40.271 E.01372
G1 X139.729 Y176.549 E4.84648
G1 X140.275 Y176.549 E.01372
G1 X3.451 Y39.725 E4.86588
G1 X3.451 Y39.18 E.01372
G1 X140.82 Y176.549 E4.88528
G1 X141.366 Y176.549 E.01372
G1 X3.451 Y38.634 E4.90468
G1 X3.451 Y38.089 E.01372
G1 X141.911 Y176.549 E4.92408
G1 X142.457 Y176.549 E.01372
G1 X3.451 Y37.543 E4.94348
G1 X3.451 Y36.998 E.01372
G1 X143.002 Y176.549 E4.96288
G1 X143.548 Y176.549 E.01372
G1 X3.451 Y36.452 E4.98229
G1 X3.451 Y35.907 E.01372
G1 X144.093 Y176.549 E5.00169
G1 X144.639 Y176.549 E.01372
G1 X3.451 Y35.361 E5.02109
G1 X3.451 Y34.816 E.01372
G1 X145.184 Y176.549 E5.04049
G1 X145.73 Y176.549 E.01372
G1 X3.451 Y34.27 E5.05989
G1 X3.451 Y33.725 E.01372
G1 X146.275 Y176.549 E5.07929
G1 X146.821 Y176.549 E.01372
G1 X3.451 Y33.179 E5.09869
G1 X3.451 Y32.633 E.01372
G1 X147.367 Y176.549 E5.11809
G1 X147.912 Y176.549 E.01372
G1 X3.451 Y32.088 E5.13749
G1 X3.451 Y31.542 E.01372
G1 X148.458 Y176.549 E5.15689
G1 X149.003 Y176.549 E.01372
G1 X3.451 Y30.997 E5.17629
G1 X3.451 Y30.451 E.01372
M73 P55 R34
G1 X149.549 Y176.549 E5.1957
G1 X150.094 Y176.549 E.01372
G1 X3.451 Y29.906 E5.2151
G1 X3.451 Y29.36 E.01372
G1 X150.64 Y176.549 E5.2345
G1 X151.185 Y176.549 E.01372
G1 X3.451 Y28.815 E5.2539
G1 X3.451 Y28.269 E.01372
G1 X151.731 Y176.549 E5.2733
G1 X152.276 Y176.549 E.01372
G1 X3.451 Y27.724 E5.2927
G1 X3.451 Y27.178 E.01372
G1 X152.822 Y176.549 E5.3121
G1 X153.367 Y176.549 E.01372
G1 X3.451 Y26.633 E5.3315
G1 X3.451 Y26.087 E.01372
G1 X153.913 Y176.549 E5.3509
G1 X154.458 Y176.549 E.01372
G1 X3.451 Y25.542 E5.3703
G1 X3.451 Y24.996 E.01372
G1 X155.004 Y176.549 E5.3897
G1 X155.55 Y176.549 E.01372
G1 X3.451 Y24.45 E5.40911
G1 X3.451 Y23.905 E.01372
G1 X156.095 Y176.549 E5.42851
G1 X156.641 Y176.549 E.01372
G1 X3.451 Y23.359 E5.44791
G1 X3.451 Y22.814 E.01372
M73 P55 R33
G1 X157.186 Y176.549 E5.46731
G1 X157.732 Y176.549 E.01372
G1 X3.451 Y22.268 E5.48671
G1 X3.451 Y21.723 E.01372
G1 X158.277 Y176.549 E5.50611
G1 X158.823 Y176.549 E.01372
G1 X3.451 Y21.177 E5.52551
G1 X3.451 Y20.632 E.01372
G1 X159.368 Y176.549 E5.54491
G1 X159.914 Y176.549 E.01372
G1 X3.451 Y20.086 E5.56431
G1 X3.451 Y19.541 E.01372
G1 X160.459 Y176.549 E5.58371
G1 X161.005 Y176.549 E.01372
G1 X3.451 Y18.995 E5.60311
G1 X3.451 Y18.45 E.01372
G1 X161.55 Y176.549 E5.62252
G1 X162.096 Y176.549 E.01372
G1 X3.451 Y17.904 E5.64192
G1 X3.451 Y17.359 E.01372
G1 X162.641 Y176.549 E5.66132
G1 X163.187 Y176.549 E.01372
G1 X3.451 Y16.813 E5.68072
G1 X3.451 Y16.267 E.01372
G1 X163.733 Y176.549 E5.70012
G1 X164.278 Y176.549 E.01372
G1 X3.451 Y15.722 E5.71952
G1 X3.451 Y15.176 E.01372
G1 X164.824 Y176.549 E5.73892
G1 X165.369 Y176.549 E.01372
G1 X3.451 Y14.631 E5.75832
G1 X3.451 Y14.085 E.01372
G1 X165.915 Y176.549 E5.77772
G1 X166.46 Y176.549 E.01372
G1 X3.451 Y13.54 E5.79712
G1 X3.451 Y12.994 E.01372
G1 X167.006 Y176.549 E5.81652
G1 X167.551 Y176.549 E.01372
G1 X3.451 Y12.449 E5.83593
G1 X3.451 Y11.903 E.01372
G1 X168.097 Y176.549 E5.85533
G1 X168.642 Y176.549 E.01372
G1 X3.451 Y11.358 E5.87473
G1 X3.451 Y10.812 E.01372
G1 X169.188 Y176.549 E5.89413
G1 X169.733 Y176.549 E.01372
G1 X3.451 Y10.267 E5.91353
G1 X3.451 Y9.721 E.01372
G1 X170.279 Y176.549 E5.93293
G1 X170.824 Y176.549 E.01372
M73 P56 R33
G1 X3.451 Y9.176 E5.95233
G1 X3.451 Y8.63 E.01372
G1 X171.37 Y176.549 E5.97173
G1 X171.916 Y176.549 E.01372
G1 X3.451 Y8.084 E5.99113
G1 X3.451 Y7.539 E.01372
G1 X172.461 Y176.549 E6.01053
G1 X173.007 Y176.549 E.01372
G1 X3.451 Y6.993 E6.02993
G1 X3.451 Y6.448 E.01372
G1 X173.552 Y176.549 E6.04934
G1 X174.098 Y176.549 E.01372
G1 X3.451 Y5.902 E6.06874
G1 X3.451 Y5.357 E.01372
G1 X174.643 Y176.549 E6.08814
G1 X175.189 Y176.549 E.01372
G1 X3.451 Y4.811 E6.10754
G1 X3.451 Y4.266 E.01372
G1 X175.734 Y176.549 E6.12694
G1 X176.28 Y176.549 E.01372
G1 X3.451 Y3.72 E6.14634
G1 X3.451 Y3.451 E.00677
G1 X3.728 Y3.451 E.00695
G1 X176.549 Y176.272 E6.14607
G1 X176.549 Y175.727 E.01372
G1 X4.273 Y3.451 E6.12667
G1 X4.819 Y3.451 E.01372
G1 X176.549 Y175.181 E6.10727
G1 X176.549 Y174.636 E.01372
G1 X5.364 Y3.451 E6.08787
G1 X5.91 Y3.451 E.01372
G1 X176.549 Y174.09 E6.06847
G1 X176.549 Y173.545 E.01372
G1 X6.455 Y3.451 E6.04907
G1 X7.001 Y3.451 E.01372
G1 X176.549 Y172.999 E6.02967
G1 X176.549 Y172.454 E.01372
G1 X7.546 Y3.451 E6.01027
G1 X8.092 Y3.451 E.01372
G1 X176.549 Y171.908 E5.99087
G1 X176.549 Y171.363 E.01372
G1 X8.638 Y3.451 E5.97147
G1 X9.183 Y3.451 E.01372
G1 X176.549 Y170.817 E5.95206
G1 X176.549 Y170.271 E.01372
G1 X9.729 Y3.451 E5.93266
G1 X10.274 Y3.451 E.01372
G1 X176.549 Y169.726 E5.91326
G1 X176.549 Y169.18 E.01372
M73 P56 R32
G1 X10.82 Y3.451 E5.89386
G1 X11.365 Y3.451 E.01372
G1 X176.549 Y168.635 E5.87446
G1 X176.549 Y168.089 E.01372
G1 X11.911 Y3.451 E5.85506
G1 X12.456 Y3.451 E.01372
G1 X176.549 Y167.544 E5.83566
G1 X176.549 Y166.998 E.01372
G1 X13.002 Y3.451 E5.81626
G1 X13.547 Y3.451 E.01372
G1 X176.549 Y166.453 E5.79686
G1 X176.549 Y165.907 E.01372
G1 X14.093 Y3.451 E5.77746
G1 X14.638 Y3.451 E.01372
G1 X176.549 Y165.362 E5.75806
G1 X176.549 Y164.816 E.01372
G1 X15.184 Y3.451 E5.73865
G1 X15.729 Y3.451 E.01372
G1 X176.549 Y164.271 E5.71925
G1 X176.549 Y163.725 E.01372
G1 X16.275 Y3.451 E5.69985
G1 X16.82 Y3.451 E.01372
G1 X176.549 Y163.18 E5.68045
G1 X176.549 Y162.634 E.01372
M73 P57 R32
G1 X17.366 Y3.451 E5.66105
G1 X17.912 Y3.451 E.01372
G1 X176.549 Y162.088 E5.64165
G1 X176.549 Y161.543 E.01372
G1 X18.457 Y3.451 E5.62225
G1 X19.003 Y3.451 E.01372
G1 X176.549 Y160.997 E5.60285
G1 X176.549 Y160.452 E.01372
G1 X19.548 Y3.451 E5.58345
G1 X20.094 Y3.451 E.01372
G1 X176.549 Y159.906 E5.56405
G1 X176.549 Y159.361 E.01372
G1 X20.639 Y3.451 E5.54465
G1 X21.185 Y3.451 E.01372
G1 X176.549 Y158.815 E5.52524
G1 X176.549 Y158.27 E.01372
G1 X21.73 Y3.451 E5.50584
G1 X22.276 Y3.451 E.01372
G1 X176.549 Y157.724 E5.48644
G1 X176.549 Y157.179 E.01372
G1 X22.821 Y3.451 E5.46704
G1 X23.367 Y3.451 E.01372
G1 X176.549 Y156.633 E5.44764
G1 X176.549 Y156.088 E.01372
G1 X23.912 Y3.451 E5.42824
G1 X24.458 Y3.451 E.01372
G1 X176.549 Y155.542 E5.40884
G1 X176.549 Y154.997 E.01372
G1 X25.003 Y3.451 E5.38944
G1 X25.549 Y3.451 E.01372
G1 X176.549 Y154.451 E5.37004
G1 X176.549 Y153.905 E.01372
G1 X26.095 Y3.451 E5.35064
G1 X26.64 Y3.451 E.01372
G1 X176.549 Y153.36 E5.33124
G1 X176.549 Y152.814 E.01372
G1 X27.186 Y3.451 E5.31183
G1 X27.731 Y3.451 E.01372
G1 X176.549 Y152.269 E5.29243
G1 X176.549 Y151.723 E.01372
G1 X28.277 Y3.451 E5.27303
G1 X28.822 Y3.451 E.01372
G1 X176.549 Y151.178 E5.25363
G1 X176.549 Y150.632 E.01372
G1 X29.368 Y3.451 E5.23423
G1 X29.913 Y3.451 E.01372
G1 X176.549 Y150.087 E5.21483
G1 X176.549 Y149.541 E.01372
G1 X30.459 Y3.451 E5.19543
G1 X31.004 Y3.451 E.01372
G1 X176.549 Y148.996 E5.17603
G1 X176.549 Y148.45 E.01372
G1 X31.55 Y3.451 E5.15663
G1 X32.095 Y3.451 E.01372
G1 X176.549 Y147.905 E5.13723
G1 X176.549 Y147.359 E.01372
G1 X32.641 Y3.451 E5.11783
G1 X33.186 Y3.451 E.01372
G1 X176.549 Y146.814 E5.09842
G1 X176.549 Y146.268 E.01372
G1 X33.732 Y3.451 E5.07902
G1 X34.278 Y3.451 E.01372
G1 X176.549 Y145.722 E5.05962
G1 X176.549 Y145.177 E.01372
G1 X34.823 Y3.451 E5.04022
G1 X35.369 Y3.451 E.01372
G1 X176.549 Y144.631 E5.02082
G1 X176.549 Y144.086 E.01372
G1 X35.914 Y3.451 E5.00142
G1 X36.46 Y3.451 E.01372
G1 X176.549 Y143.54 E4.98202
G1 X176.549 Y142.995 E.01372
G1 X37.005 Y3.451 E4.96262
G1 X37.551 Y3.451 E.01372
G1 X176.549 Y142.449 E4.94322
G1 X176.549 Y141.904 E.01372
M73 P57 R31
G1 X38.096 Y3.451 E4.92382
G1 X38.642 Y3.451 E.01372
M73 P58 R31
G1 X176.549 Y141.358 E4.90442
G1 X176.549 Y140.813 E.01372
G1 X39.187 Y3.451 E4.88501
G1 X39.733 Y3.451 E.01372
G1 X176.549 Y140.267 E4.86561
G1 X176.549 Y139.722 E.01372
G1 X40.278 Y3.451 E4.84621
G1 X40.824 Y3.451 E.01372
G1 X176.549 Y139.176 E4.82681
G1 X176.549 Y138.631 E.01372
G1 X41.369 Y3.451 E4.80741
G1 X41.915 Y3.451 E.01372
G1 X176.549 Y138.085 E4.78801
G1 X176.549 Y137.539 E.01372
G1 X42.461 Y3.451 E4.76861
G1 X43.006 Y3.451 E.01372
G1 X176.549 Y136.994 E4.74921
G1 X176.549 Y136.448 E.01372
G1 X43.552 Y3.451 E4.72981
G1 X44.097 Y3.451 E.01372
G1 X176.549 Y135.903 E4.71041
G1 X176.549 Y135.357 E.01372
G1 X44.643 Y3.451 E4.69101
G1 X45.188 Y3.451 E.01372
G1 X176.549 Y134.812 E4.67161
G1 X176.549 Y134.266 E.01372
G1 X45.734 Y3.451 E4.6522
G1 X46.279 Y3.451 E.01372
G1 X176.549 Y133.721 E4.6328
G1 X176.549 Y133.175 E.01372
G1 X46.825 Y3.451 E4.6134
G1 X47.37 Y3.451 E.01372
G1 X176.549 Y132.63 E4.594
G1 X176.549 Y132.084 E.01372
G1 X47.916 Y3.451 E4.5746
G1 X48.461 Y3.451 E.01372
G1 X176.549 Y131.539 E4.5552
G1 X176.549 Y130.993 E.01372
G1 X49.007 Y3.451 E4.5358
G1 X49.552 Y3.451 E.01372
G1 X176.549 Y130.448 E4.5164
G1 X176.549 Y129.902 E.01372
G1 X50.098 Y3.451 E4.497
G1 X50.644 Y3.451 E.01372
G1 X176.549 Y129.356 E4.4776
G1 X176.549 Y128.811 E.01372
G1 X51.189 Y3.451 E4.4582
G1 X51.735 Y3.451 E.01372
G1 X176.549 Y128.265 E4.43879
G1 X176.549 Y127.72 E.01372
G1 X52.28 Y3.451 E4.41939
G1 X52.826 Y3.451 E.01372
G1 X176.549 Y127.174 E4.39999
G1 X176.549 Y126.629 E.01372
G1 X53.371 Y3.451 E4.38059
G1 X53.917 Y3.451 E.01372
G1 X176.549 Y126.083 E4.36119
G1 X176.549 Y125.538 E.01372
G1 X54.462 Y3.451 E4.34179
G1 X55.008 Y3.451 E.01372
G1 X176.549 Y124.992 E4.32239
G1 X176.549 Y124.447 E.01372
G1 X55.553 Y3.451 E4.30299
G1 X56.099 Y3.451 E.01372
G1 X176.549 Y123.901 E4.28359
G1 X176.549 Y123.356 E.01372
G1 X56.644 Y3.451 E4.26419
G1 X57.19 Y3.451 E.01372
G1 X176.549 Y122.81 E4.24479
G1 X176.549 Y122.265 E.01372
G1 X57.735 Y3.451 E4.22538
G1 X58.281 Y3.451 E.01372
G1 X176.549 Y121.719 E4.20598
G1 X176.549 Y121.173 E.01372
G1 X58.827 Y3.451 E4.18658
G1 X59.372 Y3.451 E.01372
G1 X176.549 Y120.628 E4.16718
G1 X176.549 Y120.082 E.01372
G1 X59.918 Y3.451 E4.14778
G1 X60.463 Y3.451 E.01372
G1 X176.549 Y119.537 E4.12838
G1 X176.549 Y118.991 E.01372
G1 X61.009 Y3.451 E4.10898
G1 X61.554 Y3.451 E.01372
G1 X176.549 Y118.446 E4.08958
G1 X176.549 Y117.9 E.01372
G1 X62.1 Y3.451 E4.07018
G1 X62.645 Y3.451 E.01372
G1 X176.549 Y117.355 E4.05078
G1 X176.549 Y116.809 E.01372
G1 X63.191 Y3.451 E4.03138
G1 X63.736 Y3.451 E.01372
M73 P59 R31
G1 X176.549 Y116.264 E4.01197
G1 X176.549 Y115.718 E.01372
G1 X64.282 Y3.451 E3.99257
G1 X64.827 Y3.451 E.01372
G1 X176.549 Y115.173 E3.97317
G1 X176.549 Y114.627 E.01372
G1 X65.373 Y3.451 E3.95377
G1 X65.918 Y3.451 E.01372
G1 X176.549 Y114.082 E3.93437
G1 X176.549 Y113.536 E.01372
G1 X66.464 Y3.451 E3.91497
G1 X67.01 Y3.451 E.01372
G1 X176.549 Y112.99 E3.89557
G1 X176.549 Y112.445 E.01372
G1 X67.555 Y3.451 E3.87617
G1 X68.101 Y3.451 E.01372
G1 X176.549 Y111.899 E3.85677
G1 X176.549 Y111.354 E.01372
G1 X68.646 Y3.451 E3.83737
G1 X69.192 Y3.451 E.01372
G1 X176.549 Y110.808 E3.81797
G1 X176.549 Y110.263 E.01372
G1 X69.737 Y3.451 E3.79856
G1 X70.283 Y3.451 E.01372
G1 X176.549 Y109.717 E3.77916
G1 X176.549 Y109.172 E.01372
G1 X70.828 Y3.451 E3.75976
G1 X71.374 Y3.451 E.01372
G1 X176.549 Y108.626 E3.74036
G1 X176.549 Y108.081 E.01372
M73 P59 R30
G1 X71.919 Y3.451 E3.72096
G1 X72.465 Y3.451 E.01372
G1 X176.549 Y107.535 E3.70156
G1 X176.549 Y106.99 E.01372
G1 X73.01 Y3.451 E3.68216
G1 X73.556 Y3.451 E.01372
G1 X176.549 Y106.444 E3.66276
G1 X176.549 Y105.899 E.01372
G1 X74.101 Y3.451 E3.64336
G1 X74.647 Y3.451 E.01372
G1 X176.549 Y105.353 E3.62396
G1 X176.549 Y104.807 E.01372
G1 X75.193 Y3.451 E3.60456
G1 X75.738 Y3.451 E.01372
G1 X176.549 Y104.262 E3.58515
G1 X176.549 Y103.716 E.01372
G1 X76.284 Y3.451 E3.56575
G1 X76.829 Y3.451 E.01372
G1 X176.549 Y103.171 E3.54635
G1 X176.549 Y102.625 E.01372
G1 X77.375 Y3.451 E3.52695
G1 X77.92 Y3.451 E.01372
G1 X176.549 Y102.08 E3.50755
G1 X176.549 Y101.534 E.01372
G1 X78.466 Y3.451 E3.48815
G1 X79.011 Y3.451 E.01372
G1 X176.549 Y100.989 E3.46875
G1 X176.549 Y100.443 E.01372
G1 X79.557 Y3.451 E3.44935
G1 X80.102 Y3.451 E.01372
G1 X176.549 Y99.898 E3.42995
G1 X176.549 Y99.352 E.01372
G1 X80.648 Y3.451 E3.41055
G1 X81.193 Y3.451 E.01372
G1 X176.549 Y98.807 E3.39115
G1 X176.549 Y98.261 E.01372
G1 X81.739 Y3.451 E3.37174
G1 X82.284 Y3.451 E.01372
G1 X176.549 Y97.716 E3.35234
G1 X176.549 Y97.17 E.01372
G1 X82.83 Y3.451 E3.33294
G1 X83.376 Y3.451 E.01372
G1 X176.549 Y96.625 E3.31354
G1 X176.549 Y96.079 E.01372
G1 X83.921 Y3.451 E3.29414
G1 X84.467 Y3.451 E.01372
G1 X176.549 Y95.533 E3.27474
G1 X176.549 Y94.988 E.01372
G1 X85.012 Y3.451 E3.25534
G1 X85.558 Y3.451 E.01372
G1 X176.549 Y94.442 E3.23594
G1 X176.549 Y93.897 E.01372
G1 X86.103 Y3.451 E3.21654
G1 X86.649 Y3.451 E.01372
G1 X176.549 Y93.351 E3.19714
G1 X176.549 Y92.806 E.01372
G1 X87.194 Y3.451 E3.17774
G1 X87.74 Y3.451 E.01372
G1 X176.549 Y92.26 E3.15833
G1 X176.549 Y91.715 E.01372
G1 X88.285 Y3.451 E3.13893
G1 X88.831 Y3.451 E.01372
G1 X176.549 Y91.169 E3.11953
G1 X176.549 Y90.624 E.01372
G1 X89.376 Y3.451 E3.10013
G1 X89.922 Y3.451 E.01372
G1 X176.549 Y90.078 E3.08073
G1 X176.549 Y89.533 E.01372
G1 X90.467 Y3.451 E3.06133
G1 X91.013 Y3.451 E.01372
G1 X176.549 Y88.987 E3.04193
G1 X176.549 Y88.442 E.01372
G1 X91.559 Y3.451 E3.02253
G1 X92.104 Y3.451 E.01372
G1 X176.549 Y87.896 E3.00313
G1 X176.549 Y87.35 E.01372
G1 X92.65 Y3.451 E2.98373
G1 X93.195 Y3.451 E.01372
G1 X176.549 Y86.805 E2.96433
G1 X176.549 Y86.259 E.01372
G1 X93.741 Y3.451 E2.94492
G1 X94.286 Y3.451 E.01372
G1 X176.549 Y85.714 E2.92552
G1 X176.549 Y85.168 E.01372
M73 P60 R30
G1 X94.832 Y3.451 E2.90612
G1 X95.377 Y3.451 E.01372
G1 X176.549 Y84.623 E2.88672
G1 X176.549 Y84.077 E.01372
G1 X95.923 Y3.451 E2.86732
G1 X96.468 Y3.451 E.01372
G1 X176.549 Y83.532 E2.84792
G1 X176.549 Y82.986 E.01372
G1 X97.014 Y3.451 E2.82852
G1 X97.559 Y3.451 E.01372
G1 X176.549 Y82.441 E2.80912
G1 X176.549 Y81.895 E.01372
G1 X98.105 Y3.451 E2.78972
G1 X98.65 Y3.451 E.01372
G1 X176.549 Y81.35 E2.77032
G1 X176.549 Y80.804 E.01372
G1 X99.196 Y3.451 E2.75092
G1 X99.741 Y3.451 E.01372
G1 X176.549 Y80.259 E2.73151
G1 X176.549 Y79.713 E.01372
G1 X100.287 Y3.451 E2.71211
G1 X100.833 Y3.451 E.01372
G1 X176.549 Y79.167 E2.69271
G1 X176.549 Y78.622 E.01372
G1 X101.378 Y3.451 E2.67331
G1 X101.924 Y3.451 E.01372
G1 X176.549 Y78.076 E2.65391
G1 X176.549 Y77.531 E.01372
G1 X102.469 Y3.451 E2.63451
G1 X103.015 Y3.451 E.01372
G1 X176.549 Y76.985 E2.61511
G1 X176.549 Y76.44 E.01372
G1 X103.56 Y3.451 E2.59571
G1 X104.106 Y3.451 E.01372
G1 X176.549 Y75.894 E2.57631
G1 X176.549 Y75.349 E.01372
G1 X104.651 Y3.451 E2.55691
G1 X105.197 Y3.451 E.01372
G1 X176.549 Y74.803 E2.53751
G1 X176.549 Y74.258 E.01372
G1 X105.742 Y3.451 E2.5181
G1 X106.288 Y3.451 E.01372
G1 X176.549 Y73.712 E2.4987
G1 X176.549 Y73.167 E.01372
G1 X106.833 Y3.451 E2.4793
G1 X107.379 Y3.451 E.01372
G1 X176.549 Y72.621 E2.4599
G1 X176.549 Y72.076 E.01372
G1 X107.924 Y3.451 E2.4405
G1 X108.47 Y3.451 E.01372
G1 X176.549 Y71.53 E2.4211
G1 X176.549 Y70.984 E.01372
G1 X109.016 Y3.451 E2.4017
G1 X109.561 Y3.451 E.01372
G1 X176.549 Y70.439 E2.3823
G1 X176.549 Y69.893 E.01372
G1 X110.107 Y3.451 E2.3629
G1 X110.652 Y3.451 E.01372
G1 X176.549 Y69.348 E2.3435
G1 X176.549 Y68.802 E.01372
G1 X111.198 Y3.451 E2.3241
G1 X111.743 Y3.451 E.01372
G1 X176.549 Y68.257 E2.30469
G1 X176.549 Y67.711 E.01372
G1 X112.289 Y3.451 E2.28529
G1 X112.834 Y3.451 E.01372
G1 X176.549 Y67.166 E2.26589
G1 X176.549 Y66.62 E.01372
G1 X113.38 Y3.451 E2.24649
G1 X113.925 Y3.451 E.01372
G1 X176.549 Y66.075 E2.22709
G1 X176.549 Y65.529 E.01372
G1 X114.471 Y3.451 E2.20769
G1 X115.016 Y3.451 E.01372
G1 X176.549 Y64.984 E2.18829
G1 X176.549 Y64.438 E.01372
G1 X115.562 Y3.451 E2.16889
G1 X116.107 Y3.451 E.01372
G1 X176.549 Y63.893 E2.14949
G1 X176.549 Y63.347 E.01372
G1 X116.653 Y3.451 E2.13009
G1 X117.199 Y3.451 E.01372
G1 X176.549 Y62.801 E2.11069
G1 X176.549 Y62.256 E.01372
G1 X117.744 Y3.451 E2.09128
G1 X118.29 Y3.451 E.01372
G1 X176.549 Y61.71 E2.07188
G1 X176.549 Y61.165 E.01372
G1 X118.835 Y3.451 E2.05248
G1 X119.381 Y3.451 E.01372
M73 P60 R29
G1 X176.549 Y60.619 E2.03308
G1 X176.549 Y60.074 E.01372
G1 X119.926 Y3.451 E2.01368
G1 X120.472 Y3.451 E.01372
G1 X176.549 Y59.528 E1.99428
G1 X176.549 Y58.983 E.01372
G1 X121.017 Y3.451 E1.97488
G1 X121.563 Y3.451 E.01372
G1 X176.549 Y58.437 E1.95548
G1 X176.549 Y57.892 E.01372
G1 X122.108 Y3.451 E1.93608
G1 X122.654 Y3.451 E.01372
G1 X176.549 Y57.346 E1.91668
G1 X176.549 Y56.801 E.01372
G1 X123.199 Y3.451 E1.89728
G1 X123.745 Y3.451 E.01372
G1 X176.549 Y56.255 E1.87787
G1 X176.549 Y55.71 E.01372
G1 X124.29 Y3.451 E1.85847
G1 X124.836 Y3.451 E.01372
G1 X176.549 Y55.164 E1.83907
G1 X176.549 Y54.618 E.01372
G1 X125.382 Y3.451 E1.81967
G1 X125.927 Y3.451 E.01372
G1 X176.549 Y54.073 E1.80027
G1 X176.549 Y53.527 E.01372
G1 X126.473 Y3.451 E1.78087
G1 X127.018 Y3.451 E.01372
G1 X176.549 Y52.982 E1.76147
G1 X176.549 Y52.436 E.01372
G1 X127.564 Y3.451 E1.74207
G1 X128.109 Y3.451 E.01372
G1 X176.549 Y51.891 E1.72267
G1 X176.549 Y51.345 E.01372
G1 X128.655 Y3.451 E1.70327
G1 X129.2 Y3.451 E.01372
G1 X176.549 Y50.8 E1.68387
G1 X176.549 Y50.254 E.01372
G1 X129.746 Y3.451 E1.66447
G1 X130.291 Y3.451 E.01372
G1 X176.549 Y49.709 E1.64506
G1 X176.549 Y49.163 E.01372
G1 X130.837 Y3.451 E1.62566
G1 X131.382 Y3.451 E.01372
G1 X176.549 Y48.618 E1.60626
G1 X176.549 Y48.072 E.01372
G1 X131.928 Y3.451 E1.58686
G1 X132.473 Y3.451 E.01372
G1 X176.549 Y47.527 E1.56746
G1 X176.549 Y46.981 E.01372
G1 X133.019 Y3.451 E1.54806
G1 X133.565 Y3.451 E.01372
G1 X176.549 Y46.435 E1.52866
G1 X176.549 Y45.89 E.01372
G1 X134.11 Y3.451 E1.50926
G1 X134.656 Y3.451 E.01372
G1 X176.549 Y45.344 E1.48986
G1 X176.549 Y44.799 E.01372
G1 X135.201 Y3.451 E1.47046
G1 X135.747 Y3.451 E.01372
G1 X176.549 Y44.253 E1.45106
G1 X176.549 Y43.708 E.01372
G1 X136.292 Y3.451 E1.43165
G1 X136.838 Y3.451 E.01372
G1 X176.549 Y43.162 E1.41225
G1 X176.549 Y42.617 E.01372
G1 X137.383 Y3.451 E1.39285
G1 X137.929 Y3.451 E.01372
G1 X176.549 Y42.071 E1.37345
G1 X176.549 Y41.526 E.01372
G1 X138.474 Y3.451 E1.35405
G1 X139.02 Y3.451 E.01372
G1 X176.549 Y40.98 E1.33465
G1 X176.549 Y40.435 E.01372
G1 X139.565 Y3.451 E1.31525
G1 X140.111 Y3.451 E.01372
G1 X176.549 Y39.889 E1.29585
G1 X176.549 Y39.344 E.01372
G1 X140.656 Y3.451 E1.27645
G1 X141.202 Y3.451 E.01372
G1 X176.549 Y38.798 E1.25705
G1 X176.549 Y38.252 E.01372
M73 P61 R29
G1 X141.748 Y3.451 E1.23765
G1 X142.293 Y3.451 E.01372
G1 X176.549 Y37.707 E1.21824
G1 X176.549 Y37.161 E.01372
G1 X142.839 Y3.451 E1.19884
G1 X143.384 Y3.451 E.01372
G1 X176.549 Y36.616 E1.17944
G1 X176.549 Y36.07 E.01372
G1 X143.93 Y3.451 E1.16004
G1 X144.475 Y3.451 E.01372
G1 X176.549 Y35.525 E1.14064
G1 X176.549 Y34.979 E.01372
G1 X145.021 Y3.451 E1.12124
G1 X145.566 Y3.451 E.01372
G1 X176.549 Y34.434 E1.10184
G1 X176.549 Y33.888 E.01372
G1 X146.112 Y3.451 E1.08244
G1 X146.657 Y3.451 E.01372
G1 X176.549 Y33.343 E1.06304
G1 X176.549 Y32.797 E.01372
G1 X147.203 Y3.451 E1.04364
G1 X147.748 Y3.451 E.01372
G1 X176.549 Y32.252 E1.02424
G1 X176.549 Y31.706 E.01372
G1 X148.294 Y3.451 E1.00483
G1 X148.839 Y3.451 E.01372
G1 X176.549 Y31.161 E.98543
G1 X176.549 Y30.615 E.01372
G1 X149.385 Y3.451 E.96603
G1 X149.931 Y3.451 E.01372
G1 X176.549 Y30.069 E.94663
G1 X176.549 Y29.524 E.01372
G1 X150.476 Y3.451 E.92723
G1 X151.022 Y3.451 E.01372
G1 X176.549 Y28.978 E.90783
G1 X176.549 Y28.433 E.01372
G1 X151.567 Y3.451 E.88843
G1 X152.113 Y3.451 E.01372
G1 X176.549 Y27.887 E.86903
G1 X176.549 Y27.342 E.01372
G1 X152.658 Y3.451 E.84963
G1 X153.204 Y3.451 E.01372
G1 X176.549 Y26.796 E.83023
G1 X176.549 Y26.251 E.01372
G1 X153.749 Y3.451 E.81083
G1 X154.295 Y3.451 E.01372
G1 X176.549 Y25.705 E.79142
G1 X176.549 Y25.16 E.01372
G1 X154.84 Y3.451 E.77202
G1 X155.386 Y3.451 E.01372
G1 X176.549 Y24.614 E.75262
G1 X176.549 Y24.069 E.01372
G1 X155.931 Y3.451 E.73322
G1 X156.477 Y3.451 E.01372
G1 X176.549 Y23.523 E.71382
G1 X176.549 Y22.978 E.01372
G1 X157.022 Y3.451 E.69442
G1 X157.568 Y3.451 E.01372
G1 X176.549 Y22.432 E.67502
G1 X176.549 Y21.886 E.01372
G1 X158.114 Y3.451 E.65562
G1 X158.659 Y3.451 E.01372
G1 X176.549 Y21.341 E.63622
G1 X176.549 Y20.795 E.01372
G1 X159.205 Y3.451 E.61682
G1 X159.75 Y3.451 E.01372
G1 X176.549 Y20.25 E.59742
G1 X176.549 Y19.704 E.01372
G1 X160.296 Y3.451 E.57801
G1 X160.841 Y3.451 E.01372
G1 X176.549 Y19.159 E.55861
G1 X176.549 Y18.613 E.01372
G1 X161.387 Y3.451 E.53921
G1 X161.932 Y3.451 E.01372
G1 X176.549 Y18.068 E.51981
G1 X176.549 Y17.522 E.01372
G1 X162.478 Y3.451 E.50041
G1 X163.023 Y3.451 E.01372
G1 X176.549 Y16.977 E.48101
G1 X176.549 Y16.431 E.01372
G1 X163.569 Y3.451 E.46161
G1 X164.114 Y3.451 E.01372
G1 X176.549 Y15.886 E.44221
G1 X176.549 Y15.34 E.01372
G1 X164.66 Y3.451 E.42281
G1 X165.205 Y3.451 E.01372
G1 X176.549 Y14.795 E.40341
G1 X176.549 Y14.249 E.01372
G1 X165.751 Y3.451 E.38401
G1 X166.297 Y3.451 E.01372
G1 X176.549 Y13.704 E.3646
G1 X176.549 Y13.158 E.01372
G1 X166.842 Y3.451 E.3452
G1 X167.388 Y3.451 E.01372
G1 X176.549 Y12.612 E.3258
G1 X176.549 Y12.067 E.01372
G1 X167.933 Y3.451 E.3064
G1 X168.479 Y3.451 E.01372
G1 X176.549 Y11.521 E.287
G1 X176.549 Y10.976 E.01372
G1 X169.024 Y3.451 E.2676
G1 X169.57 Y3.451 E.01372
G1 X176.549 Y10.43 E.2482
G1 X176.549 Y9.885 E.01372
G1 X170.115 Y3.451 E.2288
G1 X170.661 Y3.451 E.01372
G1 X176.549 Y9.339 E.2094
G1 X176.549 Y8.794 E.01372
G1 X171.206 Y3.451 E.19
G1 X171.752 Y3.451 E.01372
G1 X176.549 Y8.248 E.1706
G1 X176.549 Y7.703 E.01372
G1 X172.297 Y3.451 E.15119
G1 X172.843 Y3.451 E.01372
G1 X176.549 Y7.157 E.13179
G1 X176.549 Y6.612 E.01372
G1 X173.388 Y3.451 E.11239
G1 X173.934 Y3.451 E.01372
G1 X176.549 Y6.066 E.09299
G1 X176.549 Y5.521 E.01372
G1 X174.48 Y3.451 E.07359
G1 X175.025 Y3.451 E.01372
G1 X176.549 Y4.975 E.05419
G1 X176.549 Y4.429 E.01372
G1 X175.571 Y3.451 E.03479
G1 X176.116 Y3.451 E.01372
G1 X176.722 Y4.057 E.02156
; CHANGE_LAYER
; Z_HEIGHT: 0.73
; LAYER_HEIGHT: 0.16
; WIPE_START
G1 F12000
G1 X176.116 Y3.451 E-.32581
G1 X175.571 Y3.451 E-.20731
G1 X175.993 Y3.873 E-.22689
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 4/6
; update layer progress
M73 L4
M991 S0 P3 ;notify layer change

G1 E-1.2
; filament end gcode 

M204 S10000
G17
G3 Z.97 I1.217 J0 P1  F42000
;===== machine: A1 mini =========================
;===== date: 20231225 =======================
G392 S0
M1007 S0
M620 S2A
M204 S9000

G17
G2 Z1.13 I0.86 J0.86 P1 F10000 ; spiral lift a little from second lift

G1 Z3.73 F1200

M400
M106 P1 S0
M106 P2 S0

M104 S215


G1 X180 F18000
M620.1 E F523 T240
M620.10 A0 F523
T2
M73 E1
M620.1 E F523 T240
M620.10 A1 F523 L95.3069 H0.4 T240

G1 Y90 F9000


M400

G92 E0
M628 S0


; FLUSH_START
; always use highest temperature to flush
M400
M1002 set_filament_type:UNKNOWN
M109 S240
M106 P1 S60

G1 E23.7 F523 ; do not need pulsatile flushing for start part
G1 E0.479069 F50
G1 E5.5093 F523
G1 E0.479069 F50
G1 E5.5093 F523
G1 E0.479069 F50
G1 E5.5093 F523
G1 E0.479069 F50
G1 E5.5093 F523

; FLUSH_END
G1 E-2 F1800
G1 E2 F300
M400
M1002 set_filament_type:PLA



; WIPE
M400
M106 P1 S178
M400 S3
G1 X-3.5 F18000
G1 X-13.5 F3000
G1 X-3.5 F18000
G1 X-13.5 F3000
G1 X-3.5 F18000
M73 P62 R28
G1 X-13.5 F3000
M400
M106 P1 S0



M106 P1 S60
; FLUSH_START
G1 E8.57762 F523
G1 E0.953069 F50
G1 E8.57762 F523
G1 E0.953069 F50
G1 E8.57762 F523
G1 E0.953069 F50
G1 E8.57762 F523
G1 E0.953069 F50
G1 E8.57762 F523
G1 E0.953069 F50
; FLUSH_END
G1 E-2 F1800
G1 E2 F300










M629

M400
M106 P1 S60
M109 S215
M73 P63 R28
G1 E5 F523 ;Compensate for filament spillage during waiting temperature
M400
G92 E0
G1 E-2 F1800
M400
M106 P1 S178
M400 S3
G1 X-3.5 F18000
G1 X-13.5 F3000
G1 X-3.5 F18000
G1 X-13.5 F3000
G1 X-3.5 F18000
G1 X-13.5 F3000
G1 X-3.5 F18000
M400
G1 Z3.73 F3000
M106 P1 S0

M204 S3000


M621 S2A

M9833 F1.54265 A0.3 ; cali dynamic extrusion compensation
M1002 judge_flag filament_need_cali_flag
M622 J1
  M106 P1 S178
  M400 S7
  G1 X0 F18000
  G1 X-13.5 F3000
M73 P63 R27
  G1 X0 F18000 ;wipe and shake
  G1 X-13.5 F3000
  G1 X0 F12000 ;wipe and shake
  G1 X-13.5 F3000
  M400
  M106 P1 S0 
M623

G392 S0
M1007 S1

M106 S0
M104 S215 ; set nozzle temperature
; filament start gcode
M106 P3 S200


; OBJECT_ID: 53
G1 X176.889 Y176.889 F42000
G1 Z.73
G1 E2 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F9000
M204 S3000
G1 X3.111 Y176.889 E4.70889
G1 X3.111 Y3.111 E4.70889
G1 X176.889 Y3.111 E4.70889
G1 X176.889 Y176.829 E4.70727
M204 S10000
G1 X177.29 Y177.29 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3600
M204 S2000
G1 X2.71 Y177.29 E4.38918
G1 X2.71 Y2.71 E4.38918
G1 X177.29 Y2.71 E4.38918
G1 X177.29 Y177.23 E4.38767
; WIPE_START
M204 S3000
G1 X175.29 Y177.231 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z1.13 I1.217 J0 P1  F42000
;===================== date: 202312028 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
M622.1 S1 ; for prev firware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G17
G2 Z1.13 I0.86 J0.86 P1 F20000 ; spiral lift a little
G1 Z1.13
G1 X0 Y90 F18000 ; move to safe pos
G1 X-13.0 F3000 ; move to safe pos
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

M622.1 S1
M1002 judge_flag g39_detection_flag
M622 J1
  ; enable nozzle clog detect at 3rd layer
  


  
M623


G1 X175.943 Y176.722 F42000
G1 Z.73
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.420086
G1 F12000
M204 S3000
G1 X176.549 Y176.116 E.02156
G1 X176.549 Y175.571 E.01372
G1 X175.571 Y176.549 E.03479
G1 X175.025 Y176.549 E.01372
G1 X176.549 Y175.025 E.05419
G1 X176.549 Y174.48 E.01372
G1 X174.48 Y176.549 E.07359
G1 X173.934 Y176.549 E.01372
G1 X176.549 Y173.934 E.09299
G1 X176.549 Y173.388 E.01372
G1 X173.388 Y176.549 E.11239
G1 X172.843 Y176.549 E.01372
G1 X176.549 Y172.843 E.13179
G1 X176.549 Y172.297 E.01372
G1 X172.297 Y176.549 E.15119
G1 X171.752 Y176.549 E.01372
G1 X176.549 Y171.752 E.1706
G1 X176.549 Y171.206 E.01372
G1 X171.206 Y176.549 E.19
G1 X170.661 Y176.549 E.01372
G1 X176.549 Y170.661 E.2094
G1 X176.549 Y170.115 E.01372
G1 X170.115 Y176.549 E.2288
G1 X169.57 Y176.549 E.01372
G1 X176.549 Y169.57 E.2482
G1 X176.549 Y169.024 E.01372
G1 X169.024 Y176.549 E.2676
G1 X168.479 Y176.549 E.01372
G1 X176.549 Y168.479 E.287
G1 X176.549 Y167.933 E.01372
G1 X167.933 Y176.549 E.3064
G1 X167.388 Y176.549 E.01372
G1 X176.549 Y167.388 E.3258
G1 X176.549 Y166.842 E.01372
G1 X166.842 Y176.549 E.3452
G1 X166.297 Y176.549 E.01372
G1 X176.549 Y166.297 E.3646
G1 X176.549 Y165.751 E.01372
G1 X165.751 Y176.549 E.38401
G1 X165.205 Y176.549 E.01372
G1 X176.549 Y165.205 E.40341
G1 X176.549 Y164.66 E.01372
G1 X164.66 Y176.549 E.42281
G1 X164.114 Y176.549 E.01372
G1 X176.549 Y164.114 E.44221
G1 X176.549 Y163.569 E.01372
G1 X163.569 Y176.549 E.46161
G1 X163.023 Y176.549 E.01372
G1 X176.549 Y163.023 E.48101
G1 X176.549 Y162.478 E.01372
G1 X162.478 Y176.549 E.50041
G1 X161.932 Y176.549 E.01372
G1 X176.549 Y161.932 E.51981
G1 X176.549 Y161.387 E.01372
G1 X161.387 Y176.549 E.53921
G1 X160.841 Y176.549 E.01372
G1 X176.549 Y160.841 E.55861
G1 X176.549 Y160.296 E.01372
M73 P64 R27
G1 X160.296 Y176.549 E.57801
G1 X159.75 Y176.549 E.01372
G1 X176.549 Y159.75 E.59742
G1 X176.549 Y159.205 E.01372
G1 X159.205 Y176.549 E.61682
G1 X158.659 Y176.549 E.01372
G1 X176.549 Y158.659 E.63622
G1 X176.549 Y158.114 E.01372
G1 X158.114 Y176.549 E.65562
G1 X157.568 Y176.549 E.01372
G1 X176.549 Y157.568 E.67502
G1 X176.549 Y157.022 E.01372
G1 X157.022 Y176.549 E.69442
G1 X156.477 Y176.549 E.01372
G1 X176.549 Y156.477 E.71382
G1 X176.549 Y155.931 E.01372
G1 X155.931 Y176.549 E.73322
G1 X155.386 Y176.549 E.01372
G1 X176.549 Y155.386 E.75262
G1 X176.549 Y154.84 E.01372
G1 X154.84 Y176.549 E.77202
G1 X154.295 Y176.549 E.01372
G1 X176.549 Y154.295 E.79142
G1 X176.549 Y153.749 E.01372
G1 X153.749 Y176.549 E.81083
G1 X153.204 Y176.549 E.01372
G1 X176.549 Y153.204 E.83023
G1 X176.549 Y152.658 E.01372
G1 X152.658 Y176.549 E.84963
G1 X152.113 Y176.549 E.01372
G1 X176.549 Y152.113 E.86903
G1 X176.549 Y151.567 E.01372
G1 X151.567 Y176.549 E.88843
G1 X151.022 Y176.549 E.01372
G1 X176.549 Y151.022 E.90783
G1 X176.549 Y150.476 E.01372
G1 X150.476 Y176.549 E.92723
G1 X149.931 Y176.549 E.01372
G1 X176.549 Y149.931 E.94663
G1 X176.549 Y149.385 E.01372
G1 X149.385 Y176.549 E.96603
G1 X148.839 Y176.549 E.01372
G1 X176.549 Y148.839 E.98543
G1 X176.549 Y148.294 E.01372
G1 X148.294 Y176.549 E1.00483
G1 X147.748 Y176.549 E.01372
G1 X176.549 Y147.748 E1.02424
G1 X176.549 Y147.203 E.01372
G1 X147.203 Y176.549 E1.04364
G1 X146.657 Y176.549 E.01372
G1 X176.549 Y146.657 E1.06304
G1 X176.549 Y146.112 E.01372
G1 X146.112 Y176.549 E1.08244
G1 X145.566 Y176.549 E.01372
G1 X176.549 Y145.566 E1.10184
G1 X176.549 Y145.021 E.01372
G1 X145.021 Y176.549 E1.12124
G1 X144.475 Y176.549 E.01372
G1 X176.549 Y144.475 E1.14064
G1 X176.549 Y143.93 E.01372
G1 X143.93 Y176.549 E1.16004
G1 X143.384 Y176.549 E.01372
G1 X176.549 Y143.384 E1.17944
G1 X176.549 Y142.839 E.01372
G1 X142.839 Y176.549 E1.19884
G1 X142.293 Y176.549 E.01372
G1 X176.549 Y142.293 E1.21824
G1 X176.549 Y141.748 E.01372
G1 X141.748 Y176.549 E1.23765
G1 X141.202 Y176.549 E.01372
G1 X176.549 Y141.202 E1.25705
G1 X176.549 Y140.656 E.01372
G1 X140.656 Y176.549 E1.27645
G1 X140.111 Y176.549 E.01372
G1 X176.549 Y140.111 E1.29585
G1 X176.549 Y139.565 E.01372
G1 X139.565 Y176.549 E1.31525
G1 X139.02 Y176.549 E.01372
G1 X176.549 Y139.02 E1.33465
G1 X176.549 Y138.474 E.01372
G1 X138.474 Y176.549 E1.35405
G1 X137.929 Y176.549 E.01372
G1 X176.549 Y137.929 E1.37345
G1 X176.549 Y137.383 E.01372
G1 X137.383 Y176.549 E1.39285
G1 X136.838 Y176.549 E.01372
G1 X176.549 Y136.838 E1.41225
G1 X176.549 Y136.292 E.01372
G1 X136.292 Y176.549 E1.43165
G1 X135.747 Y176.549 E.01372
G1 X176.549 Y135.747 E1.45106
G1 X176.549 Y135.201 E.01372
G1 X135.201 Y176.549 E1.47046
G1 X134.656 Y176.549 E.01372
G1 X176.549 Y134.656 E1.48986
G1 X176.549 Y134.11 E.01372
G1 X134.11 Y176.549 E1.50926
G1 X133.565 Y176.549 E.01372
G1 X176.549 Y133.565 E1.52866
G1 X176.549 Y133.019 E.01372
G1 X133.019 Y176.549 E1.54806
G1 X132.473 Y176.549 E.01372
G1 X176.549 Y132.473 E1.56746
G1 X176.549 Y131.928 E.01372
G1 X131.928 Y176.549 E1.58686
G1 X131.382 Y176.549 E.01372
G1 X176.549 Y131.382 E1.60626
G1 X176.549 Y130.837 E.01372
G1 X130.837 Y176.549 E1.62566
G1 X130.291 Y176.549 E.01372
G1 X176.549 Y130.291 E1.64506
G1 X176.549 Y129.746 E.01372
G1 X129.746 Y176.549 E1.66447
G1 X129.2 Y176.549 E.01372
G1 X176.549 Y129.2 E1.68387
G1 X176.549 Y128.655 E.01372
G1 X128.655 Y176.549 E1.70327
G1 X128.109 Y176.549 E.01372
G1 X176.549 Y128.109 E1.72267
G1 X176.549 Y127.564 E.01372
G1 X127.564 Y176.549 E1.74207
G1 X127.018 Y176.549 E.01372
G1 X176.549 Y127.018 E1.76147
G1 X176.549 Y126.473 E.01372
G1 X126.473 Y176.549 E1.78087
G1 X125.927 Y176.549 E.01372
G1 X176.549 Y125.927 E1.80027
G1 X176.549 Y125.382 E.01372
G1 X125.382 Y176.549 E1.81967
G1 X124.836 Y176.549 E.01372
G1 X176.549 Y124.836 E1.83907
G1 X176.549 Y124.29 E.01372
G1 X124.29 Y176.549 E1.85847
G1 X123.745 Y176.549 E.01372
G1 X176.549 Y123.745 E1.87787
G1 X176.549 Y123.199 E.01372
G1 X123.199 Y176.549 E1.89728
G1 X122.654 Y176.549 E.01372
G1 X176.549 Y122.654 E1.91668
G1 X176.549 Y122.108 E.01372
G1 X122.108 Y176.549 E1.93608
G1 X121.563 Y176.549 E.01372
G1 X176.549 Y121.563 E1.95548
G1 X176.549 Y121.017 E.01372
G1 X121.017 Y176.549 E1.97488
G1 X120.472 Y176.549 E.01372
G1 X176.549 Y120.472 E1.99428
G1 X176.549 Y119.926 E.01372
G1 X119.926 Y176.549 E2.01368
G1 X119.381 Y176.549 E.01372
G1 X176.549 Y119.381 E2.03308
G1 X176.549 Y118.835 E.01372
G1 X118.835 Y176.549 E2.05248
G1 X118.29 Y176.549 E.01372
G1 X176.549 Y118.29 E2.07188
G1 X176.549 Y117.744 E.01372
G1 X117.744 Y176.549 E2.09129
G1 X117.199 Y176.549 E.01372
M73 P64 R26
G1 X176.549 Y117.199 E2.11069
G1 X176.549 Y116.653 E.01372
G1 X116.653 Y176.549 E2.13009
G1 X116.107 Y176.549 E.01372
G1 X176.549 Y116.107 E2.14949
G1 X176.549 Y115.562 E.01372
G1 X115.562 Y176.549 E2.16889
G1 X115.016 Y176.549 E.01372
G1 X176.549 Y115.016 E2.18829
G1 X176.549 Y114.471 E.01372
G1 X114.471 Y176.549 E2.20769
G1 X113.925 Y176.549 E.01372
G1 X176.549 Y113.925 E2.22709
G1 X176.549 Y113.38 E.01372
G1 X113.38 Y176.549 E2.24649
G1 X112.834 Y176.549 E.01372
G1 X176.549 Y112.834 E2.26589
G1 X176.549 Y112.289 E.01372
G1 X112.289 Y176.549 E2.28529
G1 X111.743 Y176.549 E.01372
G1 X176.549 Y111.743 E2.3047
G1 X176.549 Y111.198 E.01372
G1 X111.198 Y176.549 E2.3241
G1 X110.652 Y176.549 E.01372
G1 X176.549 Y110.652 E2.3435
G1 X176.549 Y110.107 E.01372
G1 X110.107 Y176.549 E2.3629
G1 X109.561 Y176.549 E.01372
G1 X176.549 Y109.561 E2.3823
G1 X176.549 Y109.016 E.01372
G1 X109.016 Y176.549 E2.4017
G1 X108.47 Y176.549 E.01372
G1 X176.549 Y108.47 E2.4211
G1 X176.549 Y107.925 E.01372
G1 X107.924 Y176.549 E2.4405
G1 X107.379 Y176.549 E.01372
G1 X176.549 Y107.379 E2.4599
G1 X176.549 Y106.833 E.01372
G1 X106.833 Y176.549 E2.4793
G1 X106.288 Y176.549 E.01372
G1 X176.549 Y106.288 E2.4987
G1 X176.549 Y105.742 E.01372
G1 X105.742 Y176.549 E2.5181
G1 X105.197 Y176.549 E.01372
G1 X176.549 Y105.197 E2.53751
G1 X176.549 Y104.651 E.01372
G1 X104.651 Y176.549 E2.55691
G1 X104.106 Y176.549 E.01372
G1 X176.549 Y104.106 E2.57631
G1 X176.549 Y103.56 E.01372
G1 X103.56 Y176.549 E2.59571
G1 X103.015 Y176.549 E.01372
G1 X176.549 Y103.015 E2.61511
G1 X176.549 Y102.469 E.01372
G1 X102.469 Y176.549 E2.63451
G1 X101.924 Y176.549 E.01372
G1 X176.549 Y101.924 E2.65391
G1 X176.549 Y101.378 E.01372
G1 X101.378 Y176.549 E2.67331
G1 X100.833 Y176.549 E.01372
G1 X176.549 Y100.833 E2.69271
G1 X176.549 Y100.287 E.01372
G1 X100.287 Y176.549 E2.71211
G1 X99.741 Y176.549 E.01372
G1 X176.549 Y99.742 E2.73151
G1 X176.549 Y99.196 E.01372
G1 X99.196 Y176.549 E2.75092
G1 X98.65 Y176.549 E.01372
G1 X176.549 Y98.65 E2.77032
G1 X176.549 Y98.105 E.01372
G1 X98.105 Y176.549 E2.78972
G1 X97.559 Y176.549 E.01372
G1 X176.549 Y97.559 E2.80912
G1 X176.549 Y97.014 E.01372
G1 X97.014 Y176.549 E2.82852
G1 X96.468 Y176.549 E.01372
M73 P65 R26
G1 X176.549 Y96.468 E2.84792
G1 X176.549 Y95.923 E.01372
G1 X95.923 Y176.549 E2.86732
G1 X95.377 Y176.549 E.01372
G1 X176.549 Y95.377 E2.88672
G1 X176.549 Y94.832 E.01372
G1 X94.832 Y176.549 E2.90612
G1 X94.286 Y176.549 E.01372
G1 X176.549 Y94.286 E2.92552
G1 X176.549 Y93.741 E.01372
G1 X93.741 Y176.549 E2.94492
G1 X93.195 Y176.549 E.01372
G1 X176.549 Y93.195 E2.96433
G1 X176.549 Y92.65 E.01372
G1 X92.65 Y176.549 E2.98373
G1 X92.104 Y176.549 E.01372
G1 X176.549 Y92.104 E3.00313
G1 X176.549 Y91.559 E.01372
G1 X91.558 Y176.549 E3.02253
G1 X91.013 Y176.549 E.01372
G1 X176.549 Y91.013 E3.04193
G1 X176.549 Y90.467 E.01372
G1 X90.467 Y176.549 E3.06133
G1 X89.922 Y176.549 E.01372
G1 X176.549 Y89.922 E3.08073
G1 X176.549 Y89.376 E.01372
G1 X89.376 Y176.549 E3.10013
G1 X88.831 Y176.549 E.01372
G1 X176.549 Y88.831 E3.11953
G1 X176.549 Y88.285 E.01372
G1 X88.285 Y176.549 E3.13893
G1 X87.74 Y176.549 E.01372
G1 X176.549 Y87.74 E3.15833
G1 X176.549 Y87.194 E.01372
G1 X87.194 Y176.549 E3.17774
G1 X86.649 Y176.549 E.01372
G1 X176.549 Y86.649 E3.19714
G1 X176.549 Y86.103 E.01372
G1 X86.103 Y176.549 E3.21654
G1 X85.558 Y176.549 E.01372
G1 X176.549 Y85.558 E3.23594
G1 X176.549 Y85.012 E.01372
G1 X85.012 Y176.549 E3.25534
G1 X84.467 Y176.549 E.01372
G1 X176.549 Y84.467 E3.27474
G1 X176.549 Y83.921 E.01372
G1 X83.921 Y176.549 E3.29414
G1 X83.375 Y176.549 E.01372
G1 X176.549 Y83.376 E3.31354
G1 X176.549 Y82.83 E.01372
G1 X82.83 Y176.549 E3.33294
G1 X82.284 Y176.549 E.01372
G1 X176.549 Y82.284 E3.35234
G1 X176.549 Y81.739 E.01372
G1 X81.739 Y176.549 E3.37174
G1 X81.193 Y176.549 E.01372
G1 X176.549 Y81.193 E3.39115
G1 X176.549 Y80.648 E.01372
G1 X80.648 Y176.549 E3.41055
G1 X80.102 Y176.549 E.01372
G1 X176.549 Y80.102 E3.42995
G1 X176.549 Y79.557 E.01372
G1 X79.557 Y176.549 E3.44935
G1 X79.011 Y176.549 E.01372
G1 X176.549 Y79.011 E3.46875
G1 X176.549 Y78.466 E.01372
G1 X78.466 Y176.549 E3.48815
G1 X77.92 Y176.549 E.01372
G1 X176.549 Y77.92 E3.50755
G1 X176.549 Y77.375 E.01372
G1 X77.375 Y176.549 E3.52695
G1 X76.829 Y176.549 E.01372
G1 X176.549 Y76.829 E3.54635
G1 X176.549 Y76.284 E.01372
G1 X76.284 Y176.549 E3.56575
G1 X75.738 Y176.549 E.01372
G1 X176.549 Y75.738 E3.58515
G1 X176.549 Y75.193 E.01372
G1 X75.193 Y176.549 E3.60456
G1 X74.647 Y176.549 E.01372
G1 X176.549 Y74.647 E3.62396
G1 X176.549 Y74.101 E.01372
G1 X74.101 Y176.549 E3.64336
G1 X73.556 Y176.549 E.01372
G1 X176.549 Y73.556 E3.66276
G1 X176.549 Y73.01 E.01372
G1 X73.01 Y176.549 E3.68216
G1 X72.465 Y176.549 E.01372
G1 X176.549 Y72.465 E3.70156
G1 X176.549 Y71.919 E.01372
G1 X71.919 Y176.549 E3.72096
G1 X71.374 Y176.549 E.01372
G1 X176.549 Y71.374 E3.74036
G1 X176.549 Y70.828 E.01372
G1 X70.828 Y176.549 E3.75976
G1 X70.283 Y176.549 E.01372
G1 X176.549 Y70.283 E3.77916
G1 X176.549 Y69.737 E.01372
G1 X69.737 Y176.549 E3.79856
G1 X69.192 Y176.549 E.01372
G1 X176.549 Y69.192 E3.81797
G1 X176.549 Y68.646 E.01372
G1 X68.646 Y176.549 E3.83737
G1 X68.101 Y176.549 E.01372
G1 X176.549 Y68.101 E3.85677
G1 X176.549 Y67.555 E.01372
G1 X67.555 Y176.549 E3.87617
G1 X67.01 Y176.549 E.01372
G1 X176.549 Y67.01 E3.89557
G1 X176.549 Y66.464 E.01372
M73 P65 R25
G1 X66.464 Y176.549 E3.91497
G1 X65.918 Y176.549 E.01372
G1 X176.549 Y65.918 E3.93437
G1 X176.549 Y65.373 E.01372
G1 X65.373 Y176.549 E3.95377
G1 X64.827 Y176.549 E.01372
G1 X176.549 Y64.827 E3.97317
G1 X176.549 Y64.282 E.01372
G1 X64.282 Y176.549 E3.99257
G1 X63.736 Y176.549 E.01372
G1 X176.549 Y63.736 E4.01197
G1 X176.549 Y63.191 E.01372
G1 X63.191 Y176.549 E4.03138
G1 X62.645 Y176.549 E.01372
M73 P66 R25
G1 X176.549 Y62.645 E4.05078
G1 X176.549 Y62.1 E.01372
G1 X62.1 Y176.549 E4.07018
G1 X61.554 Y176.549 E.01372
G1 X176.549 Y61.554 E4.08958
G1 X176.549 Y61.009 E.01372
G1 X61.009 Y176.549 E4.10898
G1 X60.463 Y176.549 E.01372
G1 X176.549 Y60.463 E4.12838
G1 X176.549 Y59.918 E.01372
G1 X59.918 Y176.549 E4.14778
G1 X59.372 Y176.549 E.01372
G1 X176.549 Y59.372 E4.16718
G1 X176.549 Y58.827 E.01372
G1 X58.827 Y176.549 E4.18658
G1 X58.281 Y176.549 E.01372
G1 X176.549 Y58.281 E4.20598
G1 X176.549 Y57.735 E.01372
G1 X57.735 Y176.549 E4.22538
G1 X57.19 Y176.549 E.01372
G1 X176.549 Y57.19 E4.24479
G1 X176.549 Y56.644 E.01372
G1 X56.644 Y176.549 E4.26419
G1 X56.099 Y176.549 E.01372
G1 X176.549 Y56.099 E4.28359
G1 X176.549 Y55.553 E.01372
G1 X55.553 Y176.549 E4.30299
G1 X55.008 Y176.549 E.01372
G1 X176.549 Y55.008 E4.32239
G1 X176.549 Y54.462 E.01372
G1 X54.462 Y176.549 E4.34179
G1 X53.917 Y176.549 E.01372
G1 X176.549 Y53.917 E4.36119
G1 X176.549 Y53.371 E.01372
G1 X53.371 Y176.549 E4.38059
G1 X52.826 Y176.549 E.01372
G1 X176.549 Y52.826 E4.39999
G1 X176.549 Y52.28 E.01372
G1 X52.28 Y176.549 E4.41939
G1 X51.735 Y176.549 E.01372
G1 X176.549 Y51.735 E4.43879
G1 X176.549 Y51.189 E.01372
G1 X51.189 Y176.549 E4.4582
G1 X50.644 Y176.549 E.01372
G1 X176.549 Y50.644 E4.4776
G1 X176.549 Y50.098 E.01372
G1 X50.098 Y176.549 E4.497
G1 X49.552 Y176.549 E.01372
G1 X176.549 Y49.552 E4.5164
G1 X176.549 Y49.007 E.01372
G1 X49.007 Y176.549 E4.5358
G1 X48.461 Y176.549 E.01372
G1 X176.549 Y48.461 E4.5552
G1 X176.549 Y47.916 E.01372
G1 X47.916 Y176.549 E4.5746
G1 X47.37 Y176.549 E.01372
G1 X176.549 Y47.37 E4.594
G1 X176.549 Y46.825 E.01372
G1 X46.825 Y176.549 E4.6134
G1 X46.279 Y176.549 E.01372
G1 X176.549 Y46.279 E4.6328
G1 X176.549 Y45.734 E.01372
G1 X45.734 Y176.549 E4.6522
G1 X45.188 Y176.549 E.01372
G1 X176.549 Y45.188 E4.6716
G1 X176.549 Y44.643 E.01372
G1 X44.643 Y176.549 E4.69101
G1 X44.097 Y176.549 E.01372
G1 X176.549 Y44.097 E4.71041
G1 X176.549 Y43.552 E.01372
G1 X43.552 Y176.549 E4.72981
G1 X43.006 Y176.549 E.01372
G1 X176.549 Y43.006 E4.74921
G1 X176.549 Y42.461 E.01372
G1 X42.461 Y176.549 E4.76861
G1 X41.915 Y176.549 E.01372
G1 X176.549 Y41.915 E4.78801
G1 X176.549 Y41.37 E.01372
G1 X41.369 Y176.549 E4.80741
G1 X40.824 Y176.549 E.01372
G1 X176.549 Y40.824 E4.82681
G1 X176.549 Y40.278 E.01372
G1 X40.278 Y176.549 E4.84621
G1 X39.733 Y176.549 E.01372
G1 X176.549 Y39.733 E4.86561
G1 X176.549 Y39.187 E.01372
G1 X39.187 Y176.549 E4.88501
G1 X38.642 Y176.549 E.01372
G1 X176.549 Y38.642 E4.90442
G1 X176.549 Y38.096 E.01372
G1 X38.096 Y176.549 E4.92382
G1 X37.551 Y176.549 E.01372
G1 X176.549 Y37.551 E4.94322
G1 X176.549 Y37.005 E.01372
G1 X37.005 Y176.549 E4.96262
G1 X36.46 Y176.549 E.01372
G1 X176.549 Y36.46 E4.98202
G1 X176.549 Y35.914 E.01372
M73 P67 R25
G1 X35.914 Y176.549 E5.00142
G1 X35.369 Y176.549 E.01372
G1 X176.549 Y35.369 E5.02082
G1 X176.549 Y34.823 E.01372
G1 X34.823 Y176.549 E5.04022
G1 X34.278 Y176.549 E.01372
G1 X176.549 Y34.278 E5.05962
G1 X176.549 Y33.732 E.01372
G1 X33.732 Y176.549 E5.07902
G1 X33.186 Y176.549 E.01372
G1 X176.549 Y33.187 E5.09842
G1 X176.549 Y32.641 E.01372
G1 X32.641 Y176.549 E5.11783
G1 X32.095 Y176.549 E.01372
M73 P67 R24
G1 X176.549 Y32.095 E5.13723
G1 X176.549 Y31.55 E.01372
G1 X31.55 Y176.549 E5.15663
G1 X31.004 Y176.549 E.01372
G1 X176.549 Y31.004 E5.17603
G1 X176.549 Y30.459 E.01372
G1 X30.459 Y176.549 E5.19543
G1 X29.913 Y176.549 E.01372
G1 X176.549 Y29.913 E5.21483
G1 X176.549 Y29.368 E.01372
G1 X29.368 Y176.549 E5.23423
G1 X28.822 Y176.549 E.01372
G1 X176.549 Y28.822 E5.25363
G1 X176.549 Y28.277 E.01372
G1 X28.277 Y176.549 E5.27303
G1 X27.731 Y176.549 E.01372
G1 X176.549 Y27.731 E5.29243
G1 X176.549 Y27.186 E.01372
G1 X27.186 Y176.549 E5.31183
G1 X26.64 Y176.549 E.01372
G1 X176.549 Y26.64 E5.33124
G1 X176.549 Y26.095 E.01372
G1 X26.095 Y176.549 E5.35064
G1 X25.549 Y176.549 E.01372
G1 X176.549 Y25.549 E5.37004
G1 X176.549 Y25.004 E.01372
G1 X25.003 Y176.549 E5.38944
G1 X24.458 Y176.549 E.01372
G1 X176.549 Y24.458 E5.40884
G1 X176.549 Y23.912 E.01372
G1 X23.912 Y176.549 E5.42824
G1 X23.367 Y176.549 E.01372
G1 X176.549 Y23.367 E5.44764
G1 X176.549 Y22.821 E.01372
G1 X22.821 Y176.549 E5.46704
G1 X22.276 Y176.549 E.01372
G1 X176.549 Y22.276 E5.48644
G1 X176.549 Y21.73 E.01372
G1 X21.73 Y176.549 E5.50584
G1 X21.185 Y176.549 E.01372
G1 X176.549 Y21.185 E5.52524
G1 X176.549 Y20.639 E.01372
G1 X20.639 Y176.549 E5.54465
G1 X20.094 Y176.549 E.01372
G1 X176.549 Y20.094 E5.56405
G1 X176.549 Y19.548 E.01372
G1 X19.548 Y176.549 E5.58345
G1 X19.003 Y176.549 E.01372
G1 X176.549 Y19.003 E5.60285
G1 X176.549 Y18.457 E.01372
G1 X18.457 Y176.549 E5.62225
G1 X17.912 Y176.549 E.01372
G1 X176.549 Y17.912 E5.64165
G1 X176.549 Y17.366 E.01372
G1 X17.366 Y176.549 E5.66105
G1 X16.82 Y176.549 E.01372
G1 X176.549 Y16.821 E5.68045
G1 X176.549 Y16.275 E.01372
G1 X16.275 Y176.549 E5.69985
G1 X15.729 Y176.549 E.01372
G1 X176.549 Y15.729 E5.71925
G1 X176.549 Y15.184 E.01372
G1 X15.184 Y176.549 E5.73865
G1 X14.638 Y176.549 E.01372
G1 X176.549 Y14.638 E5.75806
G1 X176.549 Y14.093 E.01372
M73 P68 R24
G1 X14.093 Y176.549 E5.77746
G1 X13.547 Y176.549 E.01372
G1 X176.549 Y13.547 E5.79686
G1 X176.549 Y13.002 E.01372
G1 X13.002 Y176.549 E5.81626
G1 X12.456 Y176.549 E.01372
G1 X176.549 Y12.456 E5.83566
G1 X176.549 Y11.911 E.01372
G1 X11.911 Y176.549 E5.85506
G1 X11.365 Y176.549 E.01372
G1 X176.549 Y11.365 E5.87446
G1 X176.549 Y10.82 E.01372
G1 X10.82 Y176.549 E5.89386
G1 X10.274 Y176.549 E.01372
G1 X176.549 Y10.274 E5.91326
G1 X176.549 Y9.729 E.01372
G1 X9.729 Y176.549 E5.93266
G1 X9.183 Y176.549 E.01372
G1 X176.549 Y9.183 E5.95206
G1 X176.549 Y8.638 E.01372
G1 X8.637 Y176.549 E5.97147
G1 X8.092 Y176.549 E.01372
G1 X176.549 Y8.092 E5.99087
G1 X176.549 Y7.546 E.01372
G1 X7.546 Y176.549 E6.01027
G1 X7.001 Y176.549 E.01372
G1 X176.549 Y7.001 E6.02967
G1 X176.549 Y6.455 E.01372
G1 X6.455 Y176.549 E6.04907
G1 X5.91 Y176.549 E.01372
G1 X176.549 Y5.91 E6.06847
G1 X176.549 Y5.364 E.01372
G1 X5.364 Y176.549 E6.08787
G1 X4.819 Y176.549 E.01372
G1 X176.549 Y4.819 E6.10727
G1 X176.549 Y4.273 E.01372
M73 P68 R23
G1 X4.273 Y176.549 E6.12667
G1 X3.728 Y176.549 E.01372
G1 X176.549 Y3.728 E6.14607
G1 X176.549 Y3.451 E.00695
G1 X176.28 Y3.451 E.00676
G1 X3.451 Y176.28 E6.14634
G1 X3.451 Y175.734 E.01372
G1 X175.734 Y3.451 E6.12694
G1 X175.189 Y3.451 E.01372
G1 X3.451 Y175.189 E6.10754
G1 X3.451 Y174.643 E.01372
G1 X174.643 Y3.451 E6.08814
G1 X174.098 Y3.451 E.01372
G1 X3.451 Y174.098 E6.06874
G1 X3.451 Y173.552 E.01372
G1 X173.552 Y3.451 E6.04934
G1 X173.007 Y3.451 E.01372
G1 X3.451 Y173.007 E6.02993
G1 X3.451 Y172.461 E.01372
G1 X172.461 Y3.451 E6.01053
G1 X171.916 Y3.451 E.01372
G1 X3.451 Y171.915 E5.99113
G1 X3.451 Y171.37 E.01372
G1 X171.37 Y3.451 E5.97173
G1 X170.824 Y3.451 E.01372
G1 X3.451 Y170.824 E5.95233
G1 X3.451 Y170.279 E.01372
G1 X170.279 Y3.451 E5.93293
G1 X169.733 Y3.451 E.01372
G1 X3.451 Y169.733 E5.91353
G1 X3.451 Y169.188 E.01372
G1 X169.188 Y3.451 E5.89413
G1 X168.642 Y3.451 E.01372
G1 X3.451 Y168.642 E5.87473
G1 X3.451 Y168.097 E.01372
G1 X168.097 Y3.451 E5.85533
G1 X167.551 Y3.451 E.01372
G1 X3.451 Y167.551 E5.83593
G1 X3.451 Y167.006 E.01372
M73 P69 R23
G1 X167.006 Y3.451 E5.81652
G1 X166.46 Y3.451 E.01372
G1 X3.451 Y166.46 E5.79712
G1 X3.451 Y165.915 E.01372
G1 X165.915 Y3.451 E5.77772
G1 X165.369 Y3.451 E.01372
G1 X3.451 Y165.369 E5.75832
G1 X3.451 Y164.824 E.01372
G1 X164.824 Y3.451 E5.73892
G1 X164.278 Y3.451 E.01372
G1 X3.451 Y164.278 E5.71952
G1 X3.451 Y163.732 E.01372
G1 X163.733 Y3.451 E5.70012
G1 X163.187 Y3.451 E.01372
G1 X3.451 Y163.187 E5.68072
G1 X3.451 Y162.641 E.01372
G1 X162.641 Y3.451 E5.66132
G1 X162.096 Y3.451 E.01372
G1 X3.451 Y162.096 E5.64192
G1 X3.451 Y161.55 E.01372
G1 X161.55 Y3.451 E5.62252
G1 X161.005 Y3.451 E.01372
G1 X3.451 Y161.005 E5.60311
G1 X3.451 Y160.459 E.01372
G1 X160.459 Y3.451 E5.58371
G1 X159.914 Y3.451 E.01372
G1 X3.451 Y159.914 E5.56431
G1 X3.451 Y159.368 E.01372
G1 X159.368 Y3.451 E5.54491
G1 X158.823 Y3.451 E.01372
G1 X3.451 Y158.823 E5.52551
G1 X3.451 Y158.277 E.01372
G1 X158.277 Y3.451 E5.50611
G1 X157.732 Y3.451 E.01372
G1 X3.451 Y157.732 E5.48671
G1 X3.451 Y157.186 E.01372
G1 X157.186 Y3.451 E5.46731
G1 X156.641 Y3.451 E.01372
G1 X3.451 Y156.641 E5.44791
G1 X3.451 Y156.095 E.01372
G1 X156.095 Y3.451 E5.42851
G1 X155.55 Y3.451 E.01372
G1 X3.451 Y155.55 E5.40911
G1 X3.451 Y155.004 E.01372
G1 X155.004 Y3.451 E5.3897
G1 X154.458 Y3.451 E.01372
G1 X3.451 Y154.458 E5.3703
G1 X3.451 Y153.913 E.01372
G1 X153.913 Y3.451 E5.3509
G1 X153.367 Y3.451 E.01372
G1 X3.451 Y153.367 E5.3315
G1 X3.451 Y152.822 E.01372
G1 X152.822 Y3.451 E5.3121
G1 X152.276 Y3.451 E.01372
G1 X3.451 Y152.276 E5.2927
G1 X3.451 Y151.731 E.01372
G1 X151.731 Y3.451 E5.2733
G1 X151.185 Y3.451 E.01372
G1 X3.451 Y151.185 E5.2539
G1 X3.451 Y150.64 E.01372
M73 P69 R22
G1 X150.64 Y3.451 E5.2345
G1 X150.094 Y3.451 E.01372
G1 X3.451 Y150.094 E5.2151
G1 X3.451 Y149.549 E.01372
G1 X149.549 Y3.451 E5.1957
G1 X149.003 Y3.451 E.01372
G1 X3.451 Y149.003 E5.17629
G1 X3.451 Y148.458 E.01372
G1 X148.458 Y3.451 E5.15689
G1 X147.912 Y3.451 E.01372
G1 X3.451 Y147.912 E5.13749
G1 X3.451 Y147.367 E.01372
G1 X147.367 Y3.451 E5.11809
G1 X146.821 Y3.451 E.01372
G1 X3.451 Y146.821 E5.09869
G1 X3.451 Y146.275 E.01372
M73 P70 R22
G1 X146.275 Y3.451 E5.07929
G1 X145.73 Y3.451 E.01372
G1 X3.451 Y145.73 E5.05989
G1 X3.451 Y145.184 E.01372
G1 X145.184 Y3.451 E5.04049
G1 X144.639 Y3.451 E.01372
G1 X3.451 Y144.639 E5.02109
G1 X3.451 Y144.093 E.01372
G1 X144.093 Y3.451 E5.00169
G1 X143.548 Y3.451 E.01372
G1 X3.451 Y143.548 E4.98229
G1 X3.451 Y143.002 E.01372
G1 X143.002 Y3.451 E4.96288
G1 X142.457 Y3.451 E.01372
G1 X3.451 Y142.457 E4.94348
G1 X3.451 Y141.911 E.01372
G1 X141.911 Y3.451 E4.92408
G1 X141.366 Y3.451 E.01372
G1 X3.451 Y141.366 E4.90468
G1 X3.451 Y140.82 E.01372
G1 X140.82 Y3.451 E4.88528
G1 X140.275 Y3.451 E.01372
G1 X3.451 Y140.275 E4.86588
G1 X3.451 Y139.729 E.01372
G1 X139.729 Y3.451 E4.84648
G1 X139.184 Y3.451 E.01372
G1 X3.451 Y139.184 E4.82708
G1 X3.451 Y138.638 E.01372
G1 X138.638 Y3.451 E4.80768
G1 X138.093 Y3.451 E.01372
G1 X3.451 Y138.092 E4.78828
G1 X3.451 Y137.547 E.01372
G1 X137.547 Y3.451 E4.76888
G1 X137.001 Y3.451 E.01372
G1 X3.451 Y137.001 E4.74947
G1 X3.451 Y136.456 E.01372
G1 X136.456 Y3.451 E4.73007
G1 X135.91 Y3.451 E.01372
G1 X3.451 Y135.91 E4.71067
G1 X3.451 Y135.365 E.01372
G1 X135.365 Y3.451 E4.69127
G1 X134.819 Y3.451 E.01372
G1 X3.451 Y134.819 E4.67187
G1 X3.451 Y134.274 E.01372
G1 X134.274 Y3.451 E4.65247
G1 X133.728 Y3.451 E.01372
G1 X3.451 Y133.728 E4.63307
G1 X3.451 Y133.183 E.01372
G1 X133.183 Y3.451 E4.61367
G1 X132.637 Y3.451 E.01372
G1 X3.451 Y132.637 E4.59427
G1 X3.451 Y132.092 E.01372
G1 X132.092 Y3.451 E4.57487
G1 X131.546 Y3.451 E.01372
G1 X3.451 Y131.546 E4.55547
G1 X3.451 Y131.001 E.01372
G1 X131.001 Y3.451 E4.53606
G1 X130.455 Y3.451 E.01372
G1 X3.451 Y130.455 E4.51666
G1 X3.451 Y129.909 E.01372
G1 X129.91 Y3.451 E4.49726
G1 X129.364 Y3.451 E.01372
G1 X3.451 Y129.364 E4.47786
G1 X3.451 Y128.818 E.01372
G1 X128.818 Y3.451 E4.45846
G1 X128.273 Y3.451 E.01372
G1 X3.451 Y128.273 E4.43906
G1 X3.451 Y127.727 E.01372
G1 X127.727 Y3.451 E4.41966
G1 X127.182 Y3.451 E.01372
G1 X3.451 Y127.182 E4.40026
G1 X3.451 Y126.636 E.01372
G1 X126.636 Y3.451 E4.38086
G1 X126.091 Y3.451 E.01372
G1 X3.451 Y126.091 E4.36146
G1 X3.451 Y125.545 E.01372
G1 X125.545 Y3.451 E4.34206
G1 X125 Y3.451 E.01372
G1 X3.451 Y125 E4.32265
G1 X3.451 Y124.454 E.01372
G1 X124.454 Y3.451 E4.30325
G1 X123.909 Y3.451 E.01372
G1 X3.451 Y123.909 E4.28385
G1 X3.451 Y123.363 E.01372
G1 X123.363 Y3.451 E4.26445
G1 X122.818 Y3.451 E.01372
M73 P71 R22
G1 X3.451 Y122.818 E4.24505
G1 X3.451 Y122.272 E.01372
G1 X122.272 Y3.451 E4.22565
G1 X121.727 Y3.451 E.01372
G1 X3.451 Y121.726 E4.20625
G1 X3.451 Y121.181 E.01372
G1 X121.181 Y3.451 E4.18685
G1 X120.635 Y3.451 E.01372
G1 X3.451 Y120.635 E4.16745
G1 X3.451 Y120.09 E.01372
G1 X120.09 Y3.451 E4.14805
G1 X119.544 Y3.451 E.01372
M73 P71 R21
G1 X3.451 Y119.544 E4.12865
G1 X3.451 Y118.999 E.01372
G1 X118.999 Y3.451 E4.10924
G1 X118.453 Y3.451 E.01372
G1 X3.451 Y118.453 E4.08984
G1 X3.451 Y117.908 E.01372
G1 X117.908 Y3.451 E4.07044
G1 X117.362 Y3.451 E.01372
G1 X3.451 Y117.362 E4.05104
G1 X3.451 Y116.817 E.01372
G1 X116.817 Y3.451 E4.03164
G1 X116.271 Y3.451 E.01372
G1 X3.451 Y116.271 E4.01224
G1 X3.451 Y115.726 E.01372
G1 X115.726 Y3.451 E3.99284
G1 X115.18 Y3.451 E.01372
G1 X3.451 Y115.18 E3.97344
G1 X3.451 Y114.635 E.01372
G1 X114.635 Y3.451 E3.95404
G1 X114.089 Y3.451 E.01372
G1 X3.451 Y114.089 E3.93464
G1 X3.451 Y113.543 E.01372
G1 X113.544 Y3.451 E3.91524
G1 X112.998 Y3.451 E.01372
G1 X3.451 Y112.998 E3.89584
G1 X3.451 Y112.452 E.01372
G1 X112.452 Y3.451 E3.87643
G1 X111.907 Y3.451 E.01372
G1 X3.451 Y111.907 E3.85703
G1 X3.451 Y111.361 E.01372
G1 X111.361 Y3.451 E3.83763
G1 X110.816 Y3.451 E.01372
G1 X3.451 Y110.816 E3.81823
G1 X3.451 Y110.27 E.01372
G1 X110.27 Y3.451 E3.79883
G1 X109.725 Y3.451 E.01372
G1 X3.451 Y109.725 E3.77943
G1 X3.451 Y109.179 E.01372
G1 X109.179 Y3.451 E3.76003
G1 X108.634 Y3.451 E.01372
G1 X3.451 Y108.634 E3.74063
G1 X3.451 Y108.088 E.01372
G1 X108.088 Y3.451 E3.72123
G1 X107.543 Y3.451 E.01372
G1 X3.451 Y107.543 E3.70183
G1 X3.451 Y106.997 E.01372
G1 X106.997 Y3.451 E3.68243
G1 X106.452 Y3.451 E.01372
G1 X3.451 Y106.452 E3.66302
G1 X3.451 Y105.906 E.01372
G1 X105.906 Y3.451 E3.64362
G1 X105.361 Y3.451 E.01372
G1 X3.451 Y105.36 E3.62422
G1 X3.451 Y104.815 E.01372
G1 X104.815 Y3.451 E3.60482
G1 X104.269 Y3.451 E.01372
G1 X3.451 Y104.269 E3.58542
G1 X3.451 Y103.724 E.01372
G1 X103.724 Y3.451 E3.56602
G1 X103.178 Y3.451 E.01372
G1 X3.451 Y103.178 E3.54662
G1 X3.451 Y102.633 E.01372
G1 X102.633 Y3.451 E3.52722
G1 X102.087 Y3.451 E.01372
G1 X3.451 Y102.087 E3.50782
G1 X3.451 Y101.542 E.01372
G1 X101.542 Y3.451 E3.48842
G1 X100.996 Y3.451 E.01372
G1 X3.451 Y100.996 E3.46901
G1 X3.451 Y100.451 E.01372
G1 X100.451 Y3.451 E3.44961
G1 X99.905 Y3.451 E.01372
G1 X3.451 Y99.905 E3.43021
G1 X3.451 Y99.36 E.01372
G1 X99.36 Y3.451 E3.41081
G1 X98.814 Y3.451 E.01372
G1 X3.451 Y98.814 E3.39141
G1 X3.451 Y98.269 E.01372
G1 X98.269 Y3.451 E3.37201
G1 X97.723 Y3.451 E.01372
G1 X3.451 Y97.723 E3.35261
G1 X3.451 Y97.177 E.01372
G1 X97.178 Y3.451 E3.33321
G1 X96.632 Y3.451 E.01372
G1 X3.451 Y96.632 E3.31381
G1 X3.451 Y96.086 E.01372
G1 X96.086 Y3.451 E3.29441
G1 X95.541 Y3.451 E.01372
G1 X3.451 Y95.541 E3.27501
G1 X3.451 Y94.995 E.01372
G1 X94.995 Y3.451 E3.25561
G1 X94.45 Y3.451 E.01372
G1 X3.451 Y94.45 E3.2362
G1 X3.451 Y93.904 E.01372
G1 X93.904 Y3.451 E3.2168
G1 X93.359 Y3.451 E.01372
M73 P72 R21
G1 X3.451 Y93.359 E3.1974
G1 X3.451 Y92.813 E.01372
G1 X92.813 Y3.451 E3.178
G1 X92.268 Y3.451 E.01372
G1 X3.451 Y92.268 E3.1586
G1 X3.451 Y91.722 E.01372
G1 X91.722 Y3.451 E3.1392
G1 X91.177 Y3.451 E.01372
G1 X3.451 Y91.177 E3.1198
G1 X3.451 Y90.631 E.01372
G1 X90.631 Y3.451 E3.1004
G1 X90.086 Y3.451 E.01372
G1 X3.451 Y90.086 E3.081
G1 X3.451 Y89.54 E.01372
G1 X89.54 Y3.451 E3.0616
G1 X88.995 Y3.451 E.01372
G1 X3.451 Y88.995 E3.0422
G1 X3.451 Y88.449 E.01372
G1 X88.449 Y3.451 E3.02279
G1 X87.903 Y3.451 E.01372
G1 X3.451 Y87.903 E3.00339
G1 X3.451 Y87.358 E.01372
G1 X87.358 Y3.451 E2.98399
G1 X86.812 Y3.451 E.01372
G1 X3.451 Y86.812 E2.96459
G1 X3.451 Y86.267 E.01372
G1 X86.267 Y3.451 E2.94519
G1 X85.721 Y3.451 E.01372
G1 X3.451 Y85.721 E2.92579
G1 X3.451 Y85.176 E.01372
G1 X85.176 Y3.451 E2.90639
G1 X84.63 Y3.451 E.01372
G1 X3.451 Y84.63 E2.88699
G1 X3.451 Y84.085 E.01372
G1 X84.085 Y3.451 E2.86759
G1 X83.539 Y3.451 E.01372
G1 X3.451 Y83.539 E2.84819
G1 X3.451 Y82.994 E.01372
G1 X82.994 Y3.451 E2.82879
G1 X82.448 Y3.451 E.01372
G1 X3.451 Y82.448 E2.80938
G1 X3.451 Y81.903 E.01372
G1 X81.903 Y3.451 E2.78998
G1 X81.357 Y3.451 E.01372
G1 X3.451 Y81.357 E2.77058
G1 X3.451 Y80.812 E.01372
G1 X80.812 Y3.451 E2.75118
G1 X80.266 Y3.451 E.01372
G1 X3.451 Y80.266 E2.73178
G1 X3.451 Y79.72 E.01372
G1 X79.72 Y3.451 E2.71238
G1 X79.175 Y3.451 E.01372
G1 X3.451 Y79.175 E2.69298
G1 X3.451 Y78.629 E.01372
M73 P72 R20
G1 X78.629 Y3.451 E2.67358
G1 X78.084 Y3.451 E.01372
G1 X3.451 Y78.084 E2.65418
G1 X3.451 Y77.538 E.01372
G1 X77.538 Y3.451 E2.63478
G1 X76.993 Y3.451 E.01372
G1 X3.451 Y76.993 E2.61538
G1 X3.451 Y76.447 E.01372
G1 X76.447 Y3.451 E2.59597
G1 X75.902 Y3.451 E.01372
G1 X3.451 Y75.902 E2.57657
G1 X3.451 Y75.356 E.01372
G1 X75.356 Y3.451 E2.55717
G1 X74.811 Y3.451 E.01372
G1 X3.451 Y74.811 E2.53777
G1 X3.451 Y74.265 E.01372
G1 X74.265 Y3.451 E2.51837
G1 X73.72 Y3.451 E.01372
G1 X3.451 Y73.72 E2.49897
G1 X3.451 Y73.174 E.01372
G1 X73.174 Y3.451 E2.47957
G1 X72.629 Y3.451 E.01372
G1 X3.451 Y72.629 E2.46017
G1 X3.451 Y72.083 E.01372
G1 X72.083 Y3.451 E2.44077
G1 X71.537 Y3.451 E.01372
G1 X3.451 Y71.537 E2.42137
G1 X3.451 Y70.992 E.01372
G1 X70.992 Y3.451 E2.40197
G1 X70.446 Y3.451 E.01372
G1 X3.451 Y70.446 E2.38256
G1 X3.451 Y69.901 E.01372
G1 X69.901 Y3.451 E2.36316
G1 X69.355 Y3.451 E.01372
G1 X3.451 Y69.355 E2.34376
G1 X3.451 Y68.81 E.01372
G1 X68.81 Y3.451 E2.32436
G1 X68.264 Y3.451 E.01372
G1 X3.451 Y68.264 E2.30496
G1 X3.451 Y67.719 E.01372
G1 X67.719 Y3.451 E2.28556
G1 X67.173 Y3.451 E.01372
G1 X3.451 Y67.173 E2.26616
G1 X3.451 Y66.628 E.01372
G1 X66.628 Y3.451 E2.24676
G1 X66.082 Y3.451 E.01372
G1 X3.451 Y66.082 E2.22736
G1 X3.451 Y65.537 E.01372
G1 X65.537 Y3.451 E2.20796
G1 X64.991 Y3.451 E.01372
G1 X3.451 Y64.991 E2.18856
G1 X3.451 Y64.446 E.01372
G1 X64.446 Y3.451 E2.16915
G1 X63.9 Y3.451 E.01372
G1 X3.451 Y63.9 E2.14975
G1 X3.451 Y63.354 E.01372
G1 X63.354 Y3.451 E2.13035
G1 X62.809 Y3.451 E.01372
G1 X3.451 Y62.809 E2.11095
G1 X3.451 Y62.263 E.01372
G1 X62.263 Y3.451 E2.09155
G1 X61.718 Y3.451 E.01372
G1 X3.451 Y61.718 E2.07215
G1 X3.451 Y61.172 E.01372
G1 X61.172 Y3.451 E2.05275
G1 X60.627 Y3.451 E.01372
G1 X3.451 Y60.627 E2.03335
G1 X3.451 Y60.081 E.01372
G1 X60.081 Y3.451 E2.01395
G1 X59.536 Y3.451 E.01372
G1 X3.451 Y59.536 E1.99455
G1 X3.451 Y58.99 E.01372
G1 X58.99 Y3.451 E1.97515
G1 X58.445 Y3.451 E.01372
G1 X3.451 Y58.445 E1.95574
G1 X3.451 Y57.899 E.01372
G1 X57.899 Y3.451 E1.93634
G1 X57.354 Y3.451 E.01372
G1 X3.451 Y57.354 E1.91694
G1 X3.451 Y56.808 E.01372
G1 X56.808 Y3.451 E1.89754
G1 X56.263 Y3.451 E.01372
G1 X3.451 Y56.263 E1.87814
G1 X3.451 Y55.717 E.01372
G1 X55.717 Y3.451 E1.85874
G1 X55.171 Y3.451 E.01372
G1 X3.451 Y55.171 E1.83934
G1 X3.451 Y54.626 E.01372
G1 X54.626 Y3.451 E1.81994
G1 X54.08 Y3.451 E.01372
G1 X3.451 Y54.08 E1.80054
G1 X3.451 Y53.535 E.01372
G1 X53.535 Y3.451 E1.78114
G1 X52.989 Y3.451 E.01372
G1 X3.451 Y52.989 E1.76174
G1 X3.451 Y52.444 E.01372
M73 P73 R20
G1 X52.444 Y3.451 E1.74233
G1 X51.898 Y3.451 E.01372
G1 X3.451 Y51.898 E1.72293
G1 X3.451 Y51.353 E.01372
G1 X51.353 Y3.451 E1.70353
G1 X50.807 Y3.451 E.01372
G1 X3.451 Y50.807 E1.68413
G1 X3.451 Y50.262 E.01372
G1 X50.262 Y3.451 E1.66473
G1 X49.716 Y3.451 E.01372
G1 X3.451 Y49.716 E1.64533
G1 X3.451 Y49.171 E.01372
G1 X49.171 Y3.451 E1.62593
G1 X48.625 Y3.451 E.01372
G1 X3.451 Y48.625 E1.60653
G1 X3.451 Y48.08 E.01372
G1 X48.08 Y3.451 E1.58713
G1 X47.534 Y3.451 E.01372
G1 X3.451 Y47.534 E1.56773
G1 X3.451 Y46.988 E.01372
G1 X46.988 Y3.451 E1.54833
G1 X46.443 Y3.451 E.01372
G1 X3.451 Y46.443 E1.52892
G1 X3.451 Y45.897 E.01372
G1 X45.897 Y3.451 E1.50952
G1 X45.352 Y3.451 E.01372
G1 X3.451 Y45.352 E1.49012
G1 X3.451 Y44.806 E.01372
G1 X44.806 Y3.451 E1.47072
G1 X44.261 Y3.451 E.01372
G1 X3.451 Y44.261 E1.45132
G1 X3.451 Y43.715 E.01372
G1 X43.715 Y3.451 E1.43192
G1 X43.17 Y3.451 E.01372
G1 X3.451 Y43.17 E1.41252
G1 X3.451 Y42.624 E.01372
G1 X42.624 Y3.451 E1.39312
G1 X42.079 Y3.451 E.01372
G1 X3.451 Y42.079 E1.37372
G1 X3.451 Y41.533 E.01372
G1 X41.533 Y3.451 E1.35432
G1 X40.988 Y3.451 E.01372
G1 X3.451 Y40.988 E1.33492
G1 X3.451 Y40.442 E.01372
G1 X40.442 Y3.451 E1.31551
G1 X39.897 Y3.451 E.01372
G1 X3.451 Y39.897 E1.29611
G1 X3.451 Y39.351 E.01372
G1 X39.351 Y3.451 E1.27671
G1 X38.806 Y3.451 E.01372
G1 X3.451 Y38.805 E1.25731
G1 X3.451 Y38.26 E.01372
G1 X38.26 Y3.451 E1.23791
G1 X37.714 Y3.451 E.01372
G1 X3.451 Y37.714 E1.21851
G1 X3.451 Y37.169 E.01372
G1 X37.169 Y3.451 E1.19911
G1 X36.623 Y3.451 E.01372
G1 X3.451 Y36.623 E1.17971
G1 X3.451 Y36.078 E.01372
G1 X36.078 Y3.451 E1.16031
G1 X35.532 Y3.451 E.01372
G1 X3.451 Y35.532 E1.14091
G1 X3.451 Y34.987 E.01372
G1 X34.987 Y3.451 E1.12151
G1 X34.441 Y3.451 E.01372
G1 X3.451 Y34.441 E1.1021
G1 X3.451 Y33.896 E.01372
G1 X33.896 Y3.451 E1.0827
G1 X33.35 Y3.451 E.01372
G1 X3.451 Y33.35 E1.0633
G1 X3.451 Y32.805 E.01372
G1 X32.805 Y3.451 E1.0439
G1 X32.259 Y3.451 E.01372
G1 X3.451 Y32.259 E1.0245
G1 X3.451 Y31.714 E.01372
G1 X31.714 Y3.451 E1.0051
G1 X31.168 Y3.451 E.01372
G1 X3.451 Y31.168 E.9857
G1 X3.451 Y30.622 E.01372
G1 X30.623 Y3.451 E.9663
G1 X30.077 Y3.451 E.01372
G1 X3.451 Y30.077 E.9469
G1 X3.451 Y29.531 E.01372
G1 X29.531 Y3.451 E.9275
G1 X28.986 Y3.451 E.01372
G1 X3.451 Y28.986 E.9081
G1 X3.451 Y28.44 E.01372
G1 X28.44 Y3.451 E.8887
G1 X27.895 Y3.451 E.01372
G1 X3.451 Y27.895 E.86929
G1 X3.451 Y27.349 E.01372
G1 X27.349 Y3.451 E.84989
G1 X26.804 Y3.451 E.01372
G1 X3.451 Y26.804 E.83049
G1 X3.451 Y26.258 E.01372
G1 X26.258 Y3.451 E.81109
G1 X25.713 Y3.451 E.01372
G1 X3.451 Y25.713 E.79169
G1 X3.451 Y25.167 E.01372
G1 X25.167 Y3.451 E.77229
G1 X24.622 Y3.451 E.01372
G1 X3.451 Y24.622 E.75289
G1 X3.451 Y24.076 E.01372
G1 X24.076 Y3.451 E.73349
G1 X23.531 Y3.451 E.01372
G1 X3.451 Y23.531 E.71409
G1 X3.451 Y22.985 E.01372
G1 X22.985 Y3.451 E.69469
G1 X22.44 Y3.451 E.01372
G1 X3.451 Y22.44 E.67529
G1 X3.451 Y21.894 E.01372
G1 X21.894 Y3.451 E.65588
G1 X21.348 Y3.451 E.01372
G1 X3.451 Y21.348 E.63648
G1 X3.451 Y20.803 E.01372
G1 X20.803 Y3.451 E.61708
G1 X20.257 Y3.451 E.01372
G1 X3.451 Y20.257 E.59768
G1 X3.451 Y19.712 E.01372
G1 X19.712 Y3.451 E.57828
G1 X19.166 Y3.451 E.01372
G1 X3.451 Y19.166 E.55888
G1 X3.451 Y18.621 E.01372
G1 X18.621 Y3.451 E.53948
G1 X18.075 Y3.451 E.01372
G1 X3.451 Y18.075 E.52008
G1 X3.451 Y17.53 E.01372
G1 X17.53 Y3.451 E.50068
G1 X16.984 Y3.451 E.01372
G1 X3.451 Y16.984 E.48128
G1 X3.451 Y16.439 E.01372
G1 X16.439 Y3.451 E.46188
G1 X15.893 Y3.451 E.01372
G1 X3.451 Y15.893 E.44247
G1 X3.451 Y15.348 E.01372
G1 X15.348 Y3.451 E.42307
G1 X14.802 Y3.451 E.01372
G1 X3.451 Y14.802 E.40367
G1 X3.451 Y14.257 E.01372
G1 X14.257 Y3.451 E.38427
G1 X13.711 Y3.451 E.01372
G1 X3.451 Y13.711 E.36487
G1 X3.451 Y13.165 E.01372
G1 X13.165 Y3.451 E.34547
G1 X12.62 Y3.451 E.01372
G1 X3.451 Y12.62 E.32607
G1 X3.451 Y12.074 E.01372
G1 X12.074 Y3.451 E.30667
G1 X11.529 Y3.451 E.01372
G1 X3.451 Y11.529 E.28727
G1 X3.451 Y10.983 E.01372
G1 X10.983 Y3.451 E.26787
G1 X10.438 Y3.451 E.01372
G1 X3.451 Y10.438 E.24847
G1 X3.451 Y9.892 E.01372
G1 X9.892 Y3.451 E.22906
G1 X9.347 Y3.451 E.01372
G1 X3.451 Y9.347 E.20966
G1 X3.451 Y8.801 E.01372
G1 X8.801 Y3.451 E.19026
G1 X8.256 Y3.451 E.01372
G1 X3.451 Y8.256 E.17086
G1 X3.451 Y7.71 E.01372
G1 X7.71 Y3.451 E.15146
G1 X7.165 Y3.451 E.01372
G1 X3.451 Y7.165 E.13206
G1 X3.451 Y6.619 E.01372
G1 X6.619 Y3.451 E.11266
G1 X6.074 Y3.451 E.01372
G1 X3.451 Y6.074 E.09326
G1 X3.451 Y5.528 E.01372
G1 X5.528 Y3.451 E.07386
G1 X4.982 Y3.451 E.01372
G1 X3.451 Y4.982 E.05446
G1 X3.451 Y4.437 E.01372
G1 X4.437 Y3.451 E.03506
G1 X3.891 Y3.451 E.01372
G1 X3.278 Y4.065 E.02183
; CHANGE_LAYER
; Z_HEIGHT: 0.89
; LAYER_HEIGHT: 0.16
; WIPE_START
G1 F12000
G1 X3.891 Y3.451 E-.32982
G1 X4.437 Y3.451 E-.2073
G1 X4.022 Y3.866 E-.22287
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 5/6
; update layer progress
M73 L5
M991 S0 P4 ;notify layer change

M106 S255
; OBJECT_ID: 53
M204 S10000
G17
G3 Z1.13 I-.861 J.86 P1  F42000
G1 X176.889 Y176.889 Z1.13
G1 Z.89
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F9000
M204 S3000
G1 X3.111 Y176.889 E4.70889
G1 X3.111 Y3.111 E4.70889
G1 X176.889 Y3.111 E4.70889
G1 X176.889 Y176.829 E4.70727
M204 S10000
G1 X177.29 Y177.29 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3600
M204 S2000
G1 X2.71 Y177.29 E4.38918
G1 X2.71 Y2.71 E4.38918
G1 X177.29 Y2.71 E4.38918
G1 X177.29 Y177.23 E4.38767
; WIPE_START
M204 S3000
G1 X175.29 Y177.231 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z1.29 I1.217 J0 P1  F42000
;===================== date: 202312028 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
M622.1 S1 ; for prev firware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G17
G2 Z1.29 I0.86 J0.86 P1 F20000 ; spiral lift a little
G1 Z1.29
G1 X0 Y90 F18000 ; move to safe pos
G1 X-13.0 F3000 ; move to safe pos
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

M622.1 S1
M1002 judge_flag g39_detection_flag
M622 J1
  ; enable nozzle clog detect at 3rd layer
  


  
M623


G1 X4.065 Y176.722 F42000
G1 Z.89
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.420086
G1 F12000
M204 S3000
G1 X3.451 Y176.109 E.02183
G1 X3.451 Y175.563 E.01372
M73 P73 R19
G1 X4.437 Y176.549 E.03506
G1 X4.982 Y176.549 E.01372
G1 X3.451 Y175.018 E.05446
G1 X3.451 Y174.472 E.01372
G1 X5.528 Y176.549 E.07386
G1 X6.074 Y176.549 E.01372
G1 X3.451 Y173.926 E.09326
G1 X3.451 Y173.381 E.01372
G1 X6.619 Y176.549 E.11266
G1 X7.165 Y176.549 E.01372
G1 X3.451 Y172.835 E.13206
G1 X3.451 Y172.29 E.01372
M73 P74 R19
G1 X7.71 Y176.549 E.15146
G1 X8.256 Y176.549 E.01372
G1 X3.451 Y171.744 E.17086
G1 X3.451 Y171.199 E.01372
G1 X8.801 Y176.549 E.19026
G1 X9.347 Y176.549 E.01372
G1 X3.451 Y170.653 E.20966
G1 X3.451 Y170.108 E.01372
G1 X9.892 Y176.549 E.22906
G1 X10.438 Y176.549 E.01372
G1 X3.451 Y169.562 E.24847
G1 X3.451 Y169.017 E.01372
G1 X10.983 Y176.549 E.26787
G1 X11.529 Y176.549 E.01372
G1 X3.451 Y168.471 E.28727
G1 X3.451 Y167.926 E.01372
G1 X12.074 Y176.549 E.30667
G1 X12.62 Y176.549 E.01372
G1 X3.451 Y167.38 E.32607
G1 X3.451 Y166.835 E.01372
G1 X13.165 Y176.549 E.34547
G1 X13.711 Y176.549 E.01372
G1 X3.451 Y166.289 E.36487
G1 X3.451 Y165.743 E.01372
G1 X14.257 Y176.549 E.38427
G1 X14.802 Y176.549 E.01372
G1 X3.451 Y165.198 E.40367
G1 X3.451 Y164.652 E.01372
G1 X15.348 Y176.549 E.42307
G1 X15.893 Y176.549 E.01372
G1 X3.451 Y164.107 E.44247
G1 X3.451 Y163.561 E.01372
G1 X16.439 Y176.549 E.46188
G1 X16.984 Y176.549 E.01372
G1 X3.451 Y163.016 E.48128
G1 X3.451 Y162.47 E.01372
G1 X17.53 Y176.549 E.50068
G1 X18.075 Y176.549 E.01372
G1 X3.451 Y161.925 E.52008
G1 X3.451 Y161.379 E.01372
G1 X18.621 Y176.549 E.53948
G1 X19.166 Y176.549 E.01372
G1 X3.451 Y160.834 E.55888
G1 X3.451 Y160.288 E.01372
G1 X19.712 Y176.549 E.57828
G1 X20.257 Y176.549 E.01372
G1 X3.451 Y159.743 E.59768
G1 X3.451 Y159.197 E.01372
G1 X20.803 Y176.549 E.61708
G1 X21.348 Y176.549 E.01372
G1 X3.451 Y158.652 E.63648
G1 X3.451 Y158.106 E.01372
G1 X21.894 Y176.549 E.65588
G1 X22.44 Y176.549 E.01372
G1 X3.451 Y157.561 E.67528
G1 X3.451 Y157.015 E.01372
G1 X22.985 Y176.549 E.69469
G1 X23.531 Y176.549 E.01372
G1 X3.451 Y156.469 E.71409
G1 X3.451 Y155.924 E.01372
G1 X24.076 Y176.549 E.73349
G1 X24.622 Y176.549 E.01372
G1 X3.451 Y155.378 E.75289
G1 X3.451 Y154.833 E.01372
G1 X25.167 Y176.549 E.77229
G1 X25.713 Y176.549 E.01372
G1 X3.451 Y154.287 E.79169
G1 X3.451 Y153.742 E.01372
G1 X26.258 Y176.549 E.81109
G1 X26.804 Y176.549 E.01372
G1 X3.451 Y153.196 E.83049
G1 X3.451 Y152.651 E.01372
G1 X27.349 Y176.549 E.84989
G1 X27.895 Y176.549 E.01372
G1 X3.451 Y152.105 E.86929
G1 X3.451 Y151.56 E.01372
G1 X28.44 Y176.549 E.8887
G1 X28.986 Y176.549 E.01372
G1 X3.451 Y151.014 E.9081
G1 X3.451 Y150.469 E.01372
G1 X29.531 Y176.549 E.9275
G1 X30.077 Y176.549 E.01372
G1 X3.451 Y149.923 E.9469
G1 X3.451 Y149.378 E.01372
G1 X30.623 Y176.549 E.9663
G1 X31.168 Y176.549 E.01372
G1 X3.451 Y148.832 E.9857
G1 X3.451 Y148.286 E.01372
G1 X31.714 Y176.549 E1.0051
G1 X32.259 Y176.549 E.01372
G1 X3.451 Y147.741 E1.0245
G1 X3.451 Y147.195 E.01372
G1 X32.805 Y176.549 E1.0439
G1 X33.35 Y176.549 E.01372
G1 X3.451 Y146.65 E1.0633
G1 X3.451 Y146.104 E.01372
G1 X33.896 Y176.549 E1.0827
G1 X34.441 Y176.549 E.01372
G1 X3.451 Y145.559 E1.10211
G1 X3.451 Y145.013 E.01372
G1 X34.987 Y176.549 E1.12151
G1 X35.532 Y176.549 E.01372
G1 X3.451 Y144.468 E1.14091
G1 X3.451 Y143.922 E.01372
G1 X36.078 Y176.549 E1.16031
G1 X36.623 Y176.549 E.01372
G1 X3.451 Y143.377 E1.17971
G1 X3.451 Y142.831 E.01372
G1 X37.169 Y176.549 E1.19911
G1 X37.714 Y176.549 E.01372
G1 X3.451 Y142.286 E1.21851
G1 X3.451 Y141.74 E.01372
G1 X38.26 Y176.549 E1.23791
G1 X38.805 Y176.549 E.01372
G1 X3.451 Y141.195 E1.25731
G1 X3.451 Y140.649 E.01372
G1 X39.351 Y176.549 E1.27671
G1 X39.897 Y176.549 E.01372
G1 X3.451 Y140.103 E1.29611
G1 X3.451 Y139.558 E.01372
G1 X40.442 Y176.549 E1.31551
G1 X40.988 Y176.549 E.01372
G1 X3.451 Y139.012 E1.33492
G1 X3.451 Y138.467 E.01372
G1 X41.533 Y176.549 E1.35432
G1 X42.079 Y176.549 E.01372
G1 X3.451 Y137.921 E1.37372
G1 X3.451 Y137.376 E.01372
G1 X42.624 Y176.549 E1.39312
G1 X43.17 Y176.549 E.01372
G1 X3.451 Y136.83 E1.41252
G1 X3.451 Y136.285 E.01372
G1 X43.715 Y176.549 E1.43192
G1 X44.261 Y176.549 E.01372
G1 X3.451 Y135.739 E1.45132
G1 X3.451 Y135.194 E.01372
G1 X44.806 Y176.549 E1.47072
G1 X45.352 Y176.549 E.01372
G1 X3.451 Y134.648 E1.49012
G1 X3.451 Y134.103 E.01372
G1 X45.897 Y176.549 E1.50952
G1 X46.443 Y176.549 E.01372
G1 X3.451 Y133.557 E1.52892
G1 X3.451 Y133.012 E.01372
G1 X46.988 Y176.549 E1.54833
G1 X47.534 Y176.549 E.01372
G1 X3.451 Y132.466 E1.56773
G1 X3.451 Y131.92 E.01372
G1 X48.08 Y176.549 E1.58713
G1 X48.625 Y176.549 E.01372
G1 X3.451 Y131.375 E1.60653
G1 X3.451 Y130.829 E.01372
G1 X49.171 Y176.549 E1.62593
G1 X49.716 Y176.549 E.01372
G1 X3.451 Y130.284 E1.64533
G1 X3.451 Y129.738 E.01372
G1 X50.262 Y176.549 E1.66473
G1 X50.807 Y176.549 E.01372
G1 X3.451 Y129.193 E1.68413
G1 X3.451 Y128.647 E.01372
G1 X51.353 Y176.549 E1.70353
G1 X51.898 Y176.549 E.01372
G1 X3.451 Y128.102 E1.72293
G1 X3.451 Y127.556 E.01372
G1 X52.444 Y176.549 E1.74233
G1 X52.989 Y176.549 E.01372
G1 X3.451 Y127.011 E1.76174
G1 X3.451 Y126.465 E.01372
G1 X53.535 Y176.549 E1.78114
G1 X54.08 Y176.549 E.01372
G1 X3.451 Y125.92 E1.80054
G1 X3.451 Y125.374 E.01372
G1 X54.626 Y176.549 E1.81994
G1 X55.171 Y176.549 E.01372
G1 X3.451 Y124.829 E1.83934
G1 X3.451 Y124.283 E.01372
G1 X55.717 Y176.549 E1.85874
G1 X56.263 Y176.549 E.01372
G1 X3.451 Y123.737 E1.87814
G1 X3.451 Y123.192 E.01372
G1 X56.808 Y176.549 E1.89754
G1 X57.354 Y176.549 E.01372
G1 X3.451 Y122.646 E1.91694
G1 X3.451 Y122.101 E.01372
G1 X57.899 Y176.549 E1.93634
G1 X58.445 Y176.549 E.01372
G1 X3.451 Y121.555 E1.95574
G1 X3.451 Y121.01 E.01372
G1 X58.99 Y176.549 E1.97515
G1 X59.536 Y176.549 E.01372
G1 X3.451 Y120.464 E1.99455
G1 X3.451 Y119.919 E.01372
G1 X60.081 Y176.549 E2.01395
G1 X60.627 Y176.549 E.01372
G1 X3.451 Y119.373 E2.03335
G1 X3.451 Y118.828 E.01372
G1 X61.172 Y176.549 E2.05275
G1 X61.718 Y176.549 E.01372
G1 X3.451 Y118.282 E2.07215
G1 X3.451 Y117.737 E.01372
G1 X62.263 Y176.549 E2.09155
G1 X62.809 Y176.549 E.01372
G1 X3.451 Y117.191 E2.11095
G1 X3.451 Y116.646 E.01372
G1 X63.354 Y176.549 E2.13035
G1 X63.9 Y176.549 E.01372
G1 X3.451 Y116.1 E2.14975
G1 X3.451 Y115.554 E.01372
G1 X64.446 Y176.549 E2.16915
G1 X64.991 Y176.549 E.01372
G1 X3.451 Y115.009 E2.18856
G1 X3.451 Y114.463 E.01372
G1 X65.537 Y176.549 E2.20796
G1 X66.082 Y176.549 E.01372
G1 X3.451 Y113.918 E2.22736
G1 X3.451 Y113.372 E.01372
G1 X66.628 Y176.549 E2.24676
G1 X67.173 Y176.549 E.01372
G1 X3.451 Y112.827 E2.26616
G1 X3.451 Y112.281 E.01372
G1 X67.719 Y176.549 E2.28556
G1 X68.264 Y176.549 E.01372
G1 X3.451 Y111.736 E2.30496
G1 X3.451 Y111.19 E.01372
G1 X68.81 Y176.549 E2.32436
G1 X69.355 Y176.549 E.01372
G1 X3.451 Y110.645 E2.34376
G1 X3.451 Y110.099 E.01372
G1 X69.901 Y176.549 E2.36316
G1 X70.446 Y176.549 E.01372
G1 X3.451 Y109.554 E2.38256
G1 X3.451 Y109.008 E.01372
G1 X70.992 Y176.549 E2.40197
G1 X71.537 Y176.549 E.01372
G1 X3.451 Y108.463 E2.42137
G1 X3.451 Y107.917 E.01372
G1 X72.083 Y176.549 E2.44077
G1 X72.629 Y176.549 E.01372
G1 X3.451 Y107.371 E2.46017
G1 X3.451 Y106.826 E.01372
G1 X73.174 Y176.549 E2.47957
G1 X73.72 Y176.549 E.01372
G1 X3.451 Y106.28 E2.49897
G1 X3.451 Y105.735 E.01372
G1 X74.265 Y176.549 E2.51837
G1 X74.811 Y176.549 E.01372
G1 X3.451 Y105.189 E2.53777
G1 X3.451 Y104.644 E.01372
G1 X75.356 Y176.549 E2.55717
G1 X75.902 Y176.549 E.01372
G1 X3.451 Y104.098 E2.57657
G1 X3.451 Y103.553 E.01372
G1 X76.447 Y176.549 E2.59597
G1 X76.993 Y176.549 E.01372
G1 X3.451 Y103.007 E2.61538
G1 X3.451 Y102.462 E.01372
G1 X77.538 Y176.549 E2.63478
G1 X78.084 Y176.549 E.01372
G1 X3.451 Y101.916 E2.65418
G1 X3.451 Y101.371 E.01372
G1 X78.629 Y176.549 E2.67358
G1 X79.175 Y176.549 E.01372
G1 X3.451 Y100.825 E2.69298
G1 X3.451 Y100.28 E.01372
G1 X79.72 Y176.549 E2.71238
G1 X80.266 Y176.549 E.01372
G1 X3.451 Y99.734 E2.73178
G1 X3.451 Y99.188 E.01372
G1 X80.812 Y176.549 E2.75118
G1 X81.357 Y176.549 E.01372
M73 P75 R19
G1 X3.451 Y98.643 E2.77058
G1 X3.451 Y98.097 E.01372
G1 X81.903 Y176.549 E2.78998
G1 X82.448 Y176.549 E.01372
G1 X3.451 Y97.552 E2.80938
G1 X3.451 Y97.006 E.01372
G1 X82.994 Y176.549 E2.82879
G1 X83.539 Y176.549 E.01372
M73 P75 R18
G1 X3.451 Y96.461 E2.84819
G1 X3.451 Y95.915 E.01372
G1 X84.085 Y176.549 E2.86759
G1 X84.63 Y176.549 E.01372
G1 X3.451 Y95.37 E2.88699
G1 X3.451 Y94.824 E.01372
G1 X85.176 Y176.549 E2.90639
G1 X85.721 Y176.549 E.01372
G1 X3.451 Y94.279 E2.92579
G1 X3.451 Y93.733 E.01372
G1 X86.267 Y176.549 E2.94519
G1 X86.812 Y176.549 E.01372
G1 X3.451 Y93.188 E2.96459
G1 X3.451 Y92.642 E.01372
G1 X87.358 Y176.549 E2.98399
G1 X87.903 Y176.549 E.01372
G1 X3.451 Y92.097 E3.00339
G1 X3.451 Y91.551 E.01372
G1 X88.449 Y176.549 E3.02279
G1 X88.995 Y176.549 E.01372
G1 X3.451 Y91.005 E3.0422
G1 X3.451 Y90.46 E.01372
G1 X89.54 Y176.549 E3.0616
G1 X90.086 Y176.549 E.01372
G1 X3.451 Y89.914 E3.081
G1 X3.451 Y89.369 E.01372
G1 X90.631 Y176.549 E3.1004
G1 X91.177 Y176.549 E.01372
G1 X3.451 Y88.823 E3.1198
G1 X3.451 Y88.278 E.01372
G1 X91.722 Y176.549 E3.1392
G1 X92.268 Y176.549 E.01372
G1 X3.451 Y87.732 E3.1586
G1 X3.451 Y87.187 E.01372
G1 X92.813 Y176.549 E3.178
G1 X93.359 Y176.549 E.01372
G1 X3.451 Y86.641 E3.1974
G1 X3.451 Y86.096 E.01372
G1 X93.904 Y176.549 E3.2168
G1 X94.45 Y176.549 E.01372
G1 X3.451 Y85.55 E3.2362
G1 X3.451 Y85.005 E.01372
G1 X94.995 Y176.549 E3.25561
G1 X95.541 Y176.549 E.01372
G1 X3.451 Y84.459 E3.27501
G1 X3.451 Y83.914 E.01372
G1 X96.086 Y176.549 E3.29441
G1 X96.632 Y176.549 E.01372
G1 X3.451 Y83.368 E3.31381
G1 X3.451 Y82.822 E.01372
G1 X97.178 Y176.549 E3.33321
G1 X97.723 Y176.549 E.01372
G1 X3.451 Y82.277 E3.35261
G1 X3.451 Y81.731 E.01372
G1 X98.269 Y176.549 E3.37201
G1 X98.814 Y176.549 E.01372
G1 X3.451 Y81.186 E3.39141
G1 X3.451 Y80.64 E.01372
G1 X99.36 Y176.549 E3.41081
G1 X99.905 Y176.549 E.01372
G1 X3.451 Y80.095 E3.43021
G1 X3.451 Y79.549 E.01372
G1 X100.451 Y176.549 E3.44961
G1 X100.996 Y176.549 E.01372
G1 X3.451 Y79.004 E3.46902
G1 X3.451 Y78.458 E.01372
G1 X101.542 Y176.549 E3.48842
G1 X102.087 Y176.549 E.01372
G1 X3.451 Y77.913 E3.50782
G1 X3.451 Y77.367 E.01372
G1 X102.633 Y176.549 E3.52722
G1 X103.178 Y176.549 E.01372
G1 X3.451 Y76.822 E3.54662
G1 X3.451 Y76.276 E.01372
G1 X103.724 Y176.549 E3.56602
G1 X104.269 Y176.549 E.01372
G1 X3.451 Y75.731 E3.58542
G1 X3.451 Y75.185 E.01372
G1 X104.815 Y176.549 E3.60482
G1 X105.361 Y176.549 E.01372
G1 X3.451 Y74.64 E3.62422
G1 X3.451 Y74.094 E.01372
G1 X105.906 Y176.549 E3.64362
G1 X106.452 Y176.549 E.01372
G1 X3.451 Y73.548 E3.66302
G1 X3.451 Y73.003 E.01372
G1 X106.997 Y176.549 E3.68243
G1 X107.543 Y176.549 E.01372
G1 X3.451 Y72.457 E3.70183
G1 X3.451 Y71.912 E.01372
G1 X108.088 Y176.549 E3.72123
G1 X108.634 Y176.549 E.01372
G1 X3.451 Y71.366 E3.74063
G1 X3.451 Y70.821 E.01372
G1 X109.179 Y176.549 E3.76003
G1 X109.725 Y176.549 E.01372
G1 X3.451 Y70.275 E3.77943
G1 X3.451 Y69.73 E.01372
G1 X110.27 Y176.549 E3.79883
G1 X110.816 Y176.549 E.01372
G1 X3.451 Y69.184 E3.81823
G1 X3.451 Y68.639 E.01372
G1 X111.361 Y176.549 E3.83763
G1 X111.907 Y176.549 E.01372
G1 X3.451 Y68.093 E3.85703
G1 X3.451 Y67.548 E.01372
G1 X112.452 Y176.549 E3.87643
G1 X112.998 Y176.549 E.01372
G1 X3.451 Y67.002 E3.89583
G1 X3.451 Y66.457 E.01372
G1 X113.543 Y176.549 E3.91524
G1 X114.089 Y176.549 E.01372
G1 X3.451 Y65.911 E3.93464
G1 X3.451 Y65.365 E.01372
G1 X114.635 Y176.549 E3.95404
G1 X115.18 Y176.549 E.01372
G1 X3.451 Y64.82 E3.97344
G1 X3.451 Y64.274 E.01372
M73 P76 R18
G1 X115.726 Y176.549 E3.99284
G1 X116.271 Y176.549 E.01372
G1 X3.451 Y63.729 E4.01224
G1 X3.451 Y63.183 E.01372
G1 X116.817 Y176.549 E4.03164
G1 X117.362 Y176.549 E.01372
G1 X3.451 Y62.638 E4.05104
G1 X3.451 Y62.092 E.01372
G1 X117.908 Y176.549 E4.07044
G1 X118.453 Y176.549 E.01372
G1 X3.451 Y61.547 E4.08984
G1 X3.451 Y61.001 E.01372
G1 X118.999 Y176.549 E4.10924
G1 X119.544 Y176.549 E.01372
G1 X3.451 Y60.456 E4.12865
G1 X3.451 Y59.91 E.01372
G1 X120.09 Y176.549 E4.14805
G1 X120.635 Y176.549 E.01372
G1 X3.451 Y59.365 E4.16745
G1 X3.451 Y58.819 E.01372
G1 X121.181 Y176.549 E4.18685
G1 X121.726 Y176.549 E.01372
G1 X3.451 Y58.274 E4.20625
G1 X3.451 Y57.728 E.01372
G1 X122.272 Y176.549 E4.22565
G1 X122.818 Y176.549 E.01372
G1 X3.451 Y57.182 E4.24505
G1 X3.451 Y56.637 E.01372
G1 X123.363 Y176.549 E4.26445
G1 X123.909 Y176.549 E.01372
G1 X3.451 Y56.091 E4.28385
G1 X3.451 Y55.546 E.01372
G1 X124.454 Y176.549 E4.30325
G1 X125 Y176.549 E.01372
G1 X3.451 Y55 E4.32265
G1 X3.451 Y54.455 E.01372
G1 X125.545 Y176.549 E4.34206
G1 X126.091 Y176.549 E.01372
M73 P76 R17
G1 X3.451 Y53.909 E4.36146
G1 X3.451 Y53.364 E.01372
G1 X126.636 Y176.549 E4.38086
G1 X127.182 Y176.549 E.01372
G1 X3.451 Y52.818 E4.40026
G1 X3.451 Y52.273 E.01372
G1 X127.727 Y176.549 E4.41966
G1 X128.273 Y176.549 E.01372
G1 X3.451 Y51.727 E4.43906
G1 X3.451 Y51.182 E.01372
G1 X128.818 Y176.549 E4.45846
G1 X129.364 Y176.549 E.01372
G1 X3.451 Y50.636 E4.47786
G1 X3.451 Y50.091 E.01372
G1 X129.909 Y176.549 E4.49726
G1 X130.455 Y176.549 E.01372
G1 X3.451 Y49.545 E4.51666
G1 X3.451 Y48.999 E.01372
G1 X131.001 Y176.549 E4.53606
G1 X131.546 Y176.549 E.01372
G1 X3.451 Y48.454 E4.55547
G1 X3.451 Y47.908 E.01372
G1 X132.092 Y176.549 E4.57487
G1 X132.637 Y176.549 E.01372
G1 X3.451 Y47.363 E4.59427
G1 X3.451 Y46.817 E.01372
G1 X133.183 Y176.549 E4.61367
G1 X133.728 Y176.549 E.01372
G1 X3.451 Y46.272 E4.63307
G1 X3.451 Y45.726 E.01372
G1 X134.274 Y176.549 E4.65247
G1 X134.819 Y176.549 E.01372
G1 X3.451 Y45.181 E4.67187
G1 X3.451 Y44.635 E.01372
G1 X135.365 Y176.549 E4.69127
G1 X135.91 Y176.549 E.01372
G1 X3.451 Y44.09 E4.71067
G1 X3.451 Y43.544 E.01372
G1 X136.456 Y176.549 E4.73007
G1 X137.001 Y176.549 E.01372
G1 X3.451 Y42.999 E4.74947
G1 X3.451 Y42.453 E.01372
G1 X137.547 Y176.549 E4.76888
G1 X138.092 Y176.549 E.01372
G1 X3.451 Y41.908 E4.78828
G1 X3.451 Y41.362 E.01372
G1 X138.638 Y176.549 E4.80768
G1 X139.184 Y176.549 E.01372
G1 X3.451 Y40.816 E4.82708
G1 X3.451 Y40.271 E.01372
G1 X139.729 Y176.549 E4.84648
G1 X140.275 Y176.549 E.01372
G1 X3.451 Y39.725 E4.86588
G1 X3.451 Y39.18 E.01372
G1 X140.82 Y176.549 E4.88528
G1 X141.366 Y176.549 E.01372
G1 X3.451 Y38.634 E4.90468
G1 X3.451 Y38.089 E.01372
G1 X141.911 Y176.549 E4.92408
G1 X142.457 Y176.549 E.01372
M73 P77 R17
G1 X3.451 Y37.543 E4.94348
G1 X3.451 Y36.998 E.01372
G1 X143.002 Y176.549 E4.96288
G1 X143.548 Y176.549 E.01372
G1 X3.451 Y36.452 E4.98229
G1 X3.451 Y35.907 E.01372
G1 X144.093 Y176.549 E5.00169
G1 X144.639 Y176.549 E.01372
G1 X3.451 Y35.361 E5.02109
G1 X3.451 Y34.816 E.01372
G1 X145.184 Y176.549 E5.04049
G1 X145.73 Y176.549 E.01372
G1 X3.451 Y34.27 E5.05989
G1 X3.451 Y33.725 E.01372
G1 X146.275 Y176.549 E5.07929
G1 X146.821 Y176.549 E.01372
G1 X3.451 Y33.179 E5.09869
G1 X3.451 Y32.633 E.01372
G1 X147.367 Y176.549 E5.11809
G1 X147.912 Y176.549 E.01372
G1 X3.451 Y32.088 E5.13749
G1 X3.451 Y31.542 E.01372
G1 X148.458 Y176.549 E5.15689
G1 X149.003 Y176.549 E.01372
G1 X3.451 Y30.997 E5.17629
G1 X3.451 Y30.451 E.01372
G1 X149.549 Y176.549 E5.1957
G1 X150.094 Y176.549 E.01372
G1 X3.451 Y29.906 E5.2151
G1 X3.451 Y29.36 E.01372
G1 X150.64 Y176.549 E5.2345
G1 X151.185 Y176.549 E.01372
G1 X3.451 Y28.815 E5.2539
G1 X3.451 Y28.269 E.01372
G1 X151.731 Y176.549 E5.2733
G1 X152.276 Y176.549 E.01372
G1 X3.451 Y27.724 E5.2927
G1 X3.451 Y27.178 E.01372
G1 X152.822 Y176.549 E5.3121
G1 X153.367 Y176.549 E.01372
G1 X3.451 Y26.633 E5.3315
G1 X3.451 Y26.087 E.01372
G1 X153.913 Y176.549 E5.3509
G1 X154.458 Y176.549 E.01372
G1 X3.451 Y25.542 E5.3703
G1 X3.451 Y24.996 E.01372
G1 X155.004 Y176.549 E5.3897
G1 X155.55 Y176.549 E.01372
G1 X3.451 Y24.45 E5.40911
G1 X3.451 Y23.905 E.01372
G1 X156.095 Y176.549 E5.42851
G1 X156.641 Y176.549 E.01372
G1 X3.451 Y23.359 E5.44791
G1 X3.451 Y22.814 E.01372
G1 X157.186 Y176.549 E5.46731
G1 X157.732 Y176.549 E.01372
G1 X3.451 Y22.268 E5.48671
G1 X3.451 Y21.723 E.01372
M73 P77 R16
G1 X158.277 Y176.549 E5.50611
G1 X158.823 Y176.549 E.01372
G1 X3.451 Y21.177 E5.52551
G1 X3.451 Y20.632 E.01372
G1 X159.368 Y176.549 E5.54491
G1 X159.914 Y176.549 E.01372
G1 X3.451 Y20.086 E5.56431
G1 X3.451 Y19.541 E.01372
G1 X160.459 Y176.549 E5.58371
G1 X161.005 Y176.549 E.01372
G1 X3.451 Y18.995 E5.60311
G1 X3.451 Y18.45 E.01372
G1 X161.55 Y176.549 E5.62252
G1 X162.096 Y176.549 E.01372
G1 X3.451 Y17.904 E5.64192
G1 X3.451 Y17.359 E.01372
G1 X162.641 Y176.549 E5.66132
G1 X163.187 Y176.549 E.01372
G1 X3.451 Y16.813 E5.68072
G1 X3.451 Y16.267 E.01372
G1 X163.733 Y176.549 E5.70012
G1 X164.278 Y176.549 E.01372
G1 X3.451 Y15.722 E5.71952
G1 X3.451 Y15.176 E.01372
M73 P78 R16
G1 X164.824 Y176.549 E5.73892
G1 X165.369 Y176.549 E.01372
G1 X3.451 Y14.631 E5.75832
G1 X3.451 Y14.085 E.01372
G1 X165.915 Y176.549 E5.77772
G1 X166.46 Y176.549 E.01372
G1 X3.451 Y13.54 E5.79712
G1 X3.451 Y12.994 E.01372
G1 X167.006 Y176.549 E5.81652
G1 X167.551 Y176.549 E.01372
G1 X3.451 Y12.449 E5.83593
G1 X3.451 Y11.903 E.01372
G1 X168.097 Y176.549 E5.85533
G1 X168.642 Y176.549 E.01372
G1 X3.451 Y11.358 E5.87473
G1 X3.451 Y10.812 E.01372
G1 X169.188 Y176.549 E5.89413
G1 X169.733 Y176.549 E.01372
G1 X3.451 Y10.267 E5.91353
G1 X3.451 Y9.721 E.01372
G1 X170.279 Y176.549 E5.93293
G1 X170.824 Y176.549 E.01372
G1 X3.451 Y9.176 E5.95233
G1 X3.451 Y8.63 E.01372
G1 X171.37 Y176.549 E5.97173
G1 X171.916 Y176.549 E.01372
G1 X3.451 Y8.084 E5.99113
G1 X3.451 Y7.539 E.01372
G1 X172.461 Y176.549 E6.01053
G1 X173.007 Y176.549 E.01372
G1 X3.451 Y6.993 E6.02993
G1 X3.451 Y6.448 E.01372
G1 X173.552 Y176.549 E6.04934
G1 X174.098 Y176.549 E.01372
G1 X3.451 Y5.902 E6.06874
G1 X3.451 Y5.357 E.01372
G1 X174.643 Y176.549 E6.08814
G1 X175.189 Y176.549 E.01372
G1 X3.451 Y4.811 E6.10754
G1 X3.451 Y4.266 E.01372
G1 X175.734 Y176.549 E6.12694
G1 X176.28 Y176.549 E.01372
G1 X3.451 Y3.72 E6.14634
G1 X3.451 Y3.451 E.00677
G1 X3.728 Y3.451 E.00695
G1 X176.549 Y176.272 E6.14607
G1 X176.549 Y175.727 E.01372
G1 X4.273 Y3.451 E6.12667
G1 X4.819 Y3.451 E.01372
G1 X176.549 Y175.181 E6.10727
G1 X176.549 Y174.636 E.01372
G1 X5.364 Y3.451 E6.08787
G1 X5.91 Y3.451 E.01372
G1 X176.549 Y174.09 E6.06847
G1 X176.549 Y173.545 E.01372
G1 X6.455 Y3.451 E6.04907
G1 X7.001 Y3.451 E.01372
G1 X176.549 Y172.999 E6.02967
G1 X176.549 Y172.454 E.01372
G1 X7.546 Y3.451 E6.01027
G1 X8.092 Y3.451 E.01372
G1 X176.549 Y171.908 E5.99087
G1 X176.549 Y171.363 E.01372
G1 X8.638 Y3.451 E5.97147
G1 X9.183 Y3.451 E.01372
G1 X176.549 Y170.817 E5.95206
G1 X176.549 Y170.271 E.01372
G1 X9.729 Y3.451 E5.93266
G1 X10.274 Y3.451 E.01372
G1 X176.549 Y169.726 E5.91326
G1 X176.549 Y169.18 E.01372
G1 X10.82 Y3.451 E5.89386
G1 X11.365 Y3.451 E.01372
M73 P78 R15
G1 X176.549 Y168.635 E5.87446
G1 X176.549 Y168.089 E.01372
M73 P79 R15
G1 X11.911 Y3.451 E5.85506
G1 X12.456 Y3.451 E.01372
G1 X176.549 Y167.544 E5.83566
G1 X176.549 Y166.998 E.01372
G1 X13.002 Y3.451 E5.81626
G1 X13.547 Y3.451 E.01372
G1 X176.549 Y166.453 E5.79686
G1 X176.549 Y165.907 E.01372
G1 X14.093 Y3.451 E5.77746
G1 X14.638 Y3.451 E.01372
G1 X176.549 Y165.362 E5.75806
G1 X176.549 Y164.816 E.01372
G1 X15.184 Y3.451 E5.73865
G1 X15.729 Y3.451 E.01372
G1 X176.549 Y164.271 E5.71925
G1 X176.549 Y163.725 E.01372
G1 X16.275 Y3.451 E5.69985
G1 X16.82 Y3.451 E.01372
G1 X176.549 Y163.18 E5.68045
G1 X176.549 Y162.634 E.01372
G1 X17.366 Y3.451 E5.66105
G1 X17.912 Y3.451 E.01372
G1 X176.549 Y162.088 E5.64165
G1 X176.549 Y161.543 E.01372
G1 X18.457 Y3.451 E5.62225
G1 X19.003 Y3.451 E.01372
G1 X176.549 Y160.997 E5.60285
G1 X176.549 Y160.452 E.01372
G1 X19.548 Y3.451 E5.58345
G1 X20.094 Y3.451 E.01372
G1 X176.549 Y159.906 E5.56405
G1 X176.549 Y159.361 E.01372
G1 X20.639 Y3.451 E5.54465
G1 X21.185 Y3.451 E.01372
G1 X176.549 Y158.815 E5.52524
G1 X176.549 Y158.27 E.01372
G1 X21.73 Y3.451 E5.50584
G1 X22.276 Y3.451 E.01372
G1 X176.549 Y157.724 E5.48644
G1 X176.549 Y157.179 E.01372
G1 X22.821 Y3.451 E5.46704
G1 X23.367 Y3.451 E.01372
G1 X176.549 Y156.633 E5.44764
G1 X176.549 Y156.088 E.01372
G1 X23.912 Y3.451 E5.42824
G1 X24.458 Y3.451 E.01372
G1 X176.549 Y155.542 E5.40884
G1 X176.549 Y154.997 E.01372
G1 X25.003 Y3.451 E5.38944
G1 X25.549 Y3.451 E.01372
G1 X176.549 Y154.451 E5.37004
G1 X176.549 Y153.905 E.01372
G1 X26.095 Y3.451 E5.35064
G1 X26.64 Y3.451 E.01372
G1 X176.549 Y153.36 E5.33124
G1 X176.549 Y152.814 E.01372
G1 X27.186 Y3.451 E5.31183
G1 X27.731 Y3.451 E.01372
G1 X176.549 Y152.269 E5.29243
G1 X176.549 Y151.723 E.01372
G1 X28.277 Y3.451 E5.27303
G1 X28.822 Y3.451 E.01372
G1 X176.549 Y151.178 E5.25363
G1 X176.549 Y150.632 E.01372
G1 X29.368 Y3.451 E5.23423
G1 X29.913 Y3.451 E.01372
G1 X176.549 Y150.087 E5.21483
G1 X176.549 Y149.541 E.01372
G1 X30.459 Y3.451 E5.19543
G1 X31.004 Y3.451 E.01372
G1 X176.549 Y148.996 E5.17603
G1 X176.549 Y148.45 E.01372
G1 X31.55 Y3.451 E5.15663
G1 X32.095 Y3.451 E.01372
M73 P80 R15
G1 X176.549 Y147.905 E5.13723
G1 X176.549 Y147.359 E.01372
G1 X32.641 Y3.451 E5.11783
G1 X33.186 Y3.451 E.01372
G1 X176.549 Y146.814 E5.09842
G1 X176.549 Y146.268 E.01372
G1 X33.732 Y3.451 E5.07902
G1 X34.278 Y3.451 E.01372
G1 X176.549 Y145.722 E5.05962
G1 X176.549 Y145.177 E.01372
G1 X34.823 Y3.451 E5.04022
G1 X35.369 Y3.451 E.01372
G1 X176.549 Y144.631 E5.02082
G1 X176.549 Y144.086 E.01372
G1 X35.914 Y3.451 E5.00142
G1 X36.46 Y3.451 E.01372
G1 X176.549 Y143.54 E4.98202
G1 X176.549 Y142.995 E.01372
G1 X37.005 Y3.451 E4.96262
G1 X37.551 Y3.451 E.01372
G1 X176.549 Y142.449 E4.94322
G1 X176.549 Y141.904 E.01372
G1 X38.096 Y3.451 E4.92382
G1 X38.642 Y3.451 E.01372
G1 X176.549 Y141.358 E4.90442
G1 X176.549 Y140.813 E.01372
M73 P80 R14
G1 X39.187 Y3.451 E4.88501
G1 X39.733 Y3.451 E.01372
G1 X176.549 Y140.267 E4.86561
G1 X176.549 Y139.722 E.01372
G1 X40.278 Y3.451 E4.84621
G1 X40.824 Y3.451 E.01372
G1 X176.549 Y139.176 E4.82681
G1 X176.549 Y138.631 E.01372
G1 X41.369 Y3.451 E4.80741
G1 X41.915 Y3.451 E.01372
G1 X176.549 Y138.085 E4.78801
G1 X176.549 Y137.539 E.01372
G1 X42.461 Y3.451 E4.76861
G1 X43.006 Y3.451 E.01372
G1 X176.549 Y136.994 E4.74921
G1 X176.549 Y136.448 E.01372
G1 X43.552 Y3.451 E4.72981
G1 X44.097 Y3.451 E.01372
G1 X176.549 Y135.903 E4.71041
G1 X176.549 Y135.357 E.01372
G1 X44.643 Y3.451 E4.69101
G1 X45.188 Y3.451 E.01372
G1 X176.549 Y134.812 E4.67161
G1 X176.549 Y134.266 E.01372
G1 X45.734 Y3.451 E4.6522
G1 X46.279 Y3.451 E.01372
G1 X176.549 Y133.721 E4.6328
G1 X176.549 Y133.175 E.01372
G1 X46.825 Y3.451 E4.6134
G1 X47.37 Y3.451 E.01372
G1 X176.549 Y132.63 E4.594
G1 X176.549 Y132.084 E.01372
G1 X47.916 Y3.451 E4.5746
G1 X48.461 Y3.451 E.01372
G1 X176.549 Y131.539 E4.5552
G1 X176.549 Y130.993 E.01372
G1 X49.007 Y3.451 E4.5358
G1 X49.552 Y3.451 E.01372
G1 X176.549 Y130.448 E4.5164
G1 X176.549 Y129.902 E.01372
G1 X50.098 Y3.451 E4.497
G1 X50.644 Y3.451 E.01372
G1 X176.549 Y129.356 E4.4776
G1 X176.549 Y128.811 E.01372
G1 X51.189 Y3.451 E4.4582
G1 X51.735 Y3.451 E.01372
G1 X176.549 Y128.265 E4.43879
G1 X176.549 Y127.72 E.01372
G1 X52.28 Y3.451 E4.41939
G1 X52.826 Y3.451 E.01372
G1 X176.549 Y127.174 E4.39999
G1 X176.549 Y126.629 E.01372
G1 X53.371 Y3.451 E4.38059
G1 X53.917 Y3.451 E.01372
G1 X176.549 Y126.083 E4.36119
G1 X176.549 Y125.538 E.01372
G1 X54.462 Y3.451 E4.34179
G1 X55.008 Y3.451 E.01372
G1 X176.549 Y124.992 E4.32239
G1 X176.549 Y124.447 E.01372
G1 X55.553 Y3.451 E4.30299
G1 X56.099 Y3.451 E.01372
M73 P81 R14
G1 X176.549 Y123.901 E4.28359
G1 X176.549 Y123.356 E.01372
G1 X56.644 Y3.451 E4.26419
G1 X57.19 Y3.451 E.01372
G1 X176.549 Y122.81 E4.24479
G1 X176.549 Y122.265 E.01372
G1 X57.735 Y3.451 E4.22538
G1 X58.281 Y3.451 E.01372
G1 X176.549 Y121.719 E4.20598
G1 X176.549 Y121.173 E.01372
G1 X58.827 Y3.451 E4.18658
G1 X59.372 Y3.451 E.01372
G1 X176.549 Y120.628 E4.16718
G1 X176.549 Y120.082 E.01372
G1 X59.918 Y3.451 E4.14778
G1 X60.463 Y3.451 E.01372
G1 X176.549 Y119.537 E4.12838
G1 X176.549 Y118.991 E.01372
G1 X61.009 Y3.451 E4.10898
G1 X61.554 Y3.451 E.01372
G1 X176.549 Y118.446 E4.08958
G1 X176.549 Y117.9 E.01372
G1 X62.1 Y3.451 E4.07018
G1 X62.645 Y3.451 E.01372
G1 X176.549 Y117.355 E4.05078
G1 X176.549 Y116.809 E.01372
G1 X63.191 Y3.451 E4.03138
G1 X63.736 Y3.451 E.01372
G1 X176.549 Y116.264 E4.01197
G1 X176.549 Y115.718 E.01372
G1 X64.282 Y3.451 E3.99257
G1 X64.827 Y3.451 E.01372
G1 X176.549 Y115.173 E3.97317
G1 X176.549 Y114.627 E.01372
G1 X65.373 Y3.451 E3.95377
G1 X65.918 Y3.451 E.01372
G1 X176.549 Y114.082 E3.93437
G1 X176.549 Y113.536 E.01372
G1 X66.464 Y3.451 E3.91497
G1 X67.01 Y3.451 E.01372
G1 X176.549 Y112.99 E3.89557
G1 X176.549 Y112.445 E.01372
G1 X67.555 Y3.451 E3.87617
G1 X68.101 Y3.451 E.01372
G1 X176.549 Y111.899 E3.85677
G1 X176.549 Y111.354 E.01372
G1 X68.646 Y3.451 E3.83737
G1 X69.192 Y3.451 E.01372
G1 X176.549 Y110.808 E3.81797
G1 X176.549 Y110.263 E.01372
G1 X69.737 Y3.451 E3.79856
G1 X70.283 Y3.451 E.01372
G1 X176.549 Y109.717 E3.77916
G1 X176.549 Y109.172 E.01372
G1 X70.828 Y3.451 E3.75976
G1 X71.374 Y3.451 E.01372
G1 X176.549 Y108.626 E3.74036
G1 X176.549 Y108.081 E.01372
G1 X71.919 Y3.451 E3.72096
G1 X72.465 Y3.451 E.01372
G1 X176.549 Y107.535 E3.70156
G1 X176.549 Y106.99 E.01372
M73 P81 R13
G1 X73.01 Y3.451 E3.68216
G1 X73.556 Y3.451 E.01372
G1 X176.549 Y106.444 E3.66276
G1 X176.549 Y105.899 E.01372
G1 X74.101 Y3.451 E3.64336
G1 X74.647 Y3.451 E.01372
G1 X176.549 Y105.353 E3.62396
G1 X176.549 Y104.807 E.01372
G1 X75.193 Y3.451 E3.60456
G1 X75.738 Y3.451 E.01372
G1 X176.549 Y104.262 E3.58515
G1 X176.549 Y103.716 E.01372
G1 X76.284 Y3.451 E3.56575
G1 X76.829 Y3.451 E.01372
G1 X176.549 Y103.171 E3.54635
G1 X176.549 Y102.625 E.01372
G1 X77.375 Y3.451 E3.52695
G1 X77.92 Y3.451 E.01372
G1 X176.549 Y102.08 E3.50755
G1 X176.549 Y101.534 E.01372
G1 X78.466 Y3.451 E3.48815
G1 X79.011 Y3.451 E.01372
G1 X176.549 Y100.989 E3.46875
G1 X176.549 Y100.443 E.01372
G1 X79.557 Y3.451 E3.44935
G1 X80.102 Y3.451 E.01372
G1 X176.549 Y99.898 E3.42995
G1 X176.549 Y99.352 E.01372
G1 X80.648 Y3.451 E3.41055
G1 X81.193 Y3.451 E.01372
G1 X176.549 Y98.807 E3.39115
G1 X176.549 Y98.261 E.01372
G1 X81.739 Y3.451 E3.37174
G1 X82.284 Y3.451 E.01372
G1 X176.549 Y97.716 E3.35234
G1 X176.549 Y97.17 E.01372
G1 X82.83 Y3.451 E3.33294
G1 X83.376 Y3.451 E.01372
G1 X176.549 Y96.625 E3.31354
G1 X176.549 Y96.079 E.01372
G1 X83.921 Y3.451 E3.29414
G1 X84.467 Y3.451 E.01372
M73 P82 R13
G1 X176.549 Y95.533 E3.27474
G1 X176.549 Y94.988 E.01372
G1 X85.012 Y3.451 E3.25534
G1 X85.558 Y3.451 E.01372
G1 X176.549 Y94.442 E3.23594
G1 X176.549 Y93.897 E.01372
G1 X86.103 Y3.451 E3.21654
G1 X86.649 Y3.451 E.01372
G1 X176.549 Y93.351 E3.19714
G1 X176.549 Y92.806 E.01372
G1 X87.194 Y3.451 E3.17774
G1 X87.74 Y3.451 E.01372
G1 X176.549 Y92.26 E3.15833
G1 X176.549 Y91.715 E.01372
G1 X88.285 Y3.451 E3.13893
G1 X88.831 Y3.451 E.01372
G1 X176.549 Y91.169 E3.11953
G1 X176.549 Y90.624 E.01372
G1 X89.376 Y3.451 E3.10013
G1 X89.922 Y3.451 E.01372
G1 X176.549 Y90.078 E3.08073
G1 X176.549 Y89.533 E.01372
G1 X90.467 Y3.451 E3.06133
G1 X91.013 Y3.451 E.01372
G1 X176.549 Y88.987 E3.04193
G1 X176.549 Y88.442 E.01372
G1 X91.559 Y3.451 E3.02253
G1 X92.104 Y3.451 E.01372
G1 X176.549 Y87.896 E3.00313
G1 X176.549 Y87.35 E.01372
G1 X92.65 Y3.451 E2.98373
G1 X93.195 Y3.451 E.01372
G1 X176.549 Y86.805 E2.96433
G1 X176.549 Y86.259 E.01372
G1 X93.741 Y3.451 E2.94492
G1 X94.286 Y3.451 E.01372
G1 X176.549 Y85.714 E2.92552
G1 X176.549 Y85.168 E.01372
G1 X94.832 Y3.451 E2.90612
G1 X95.377 Y3.451 E.01372
G1 X176.549 Y84.623 E2.88672
G1 X176.549 Y84.077 E.01372
G1 X95.923 Y3.451 E2.86732
G1 X96.468 Y3.451 E.01372
G1 X176.549 Y83.532 E2.84792
G1 X176.549 Y82.986 E.01372
G1 X97.014 Y3.451 E2.82852
G1 X97.559 Y3.451 E.01372
G1 X176.549 Y82.441 E2.80912
G1 X176.549 Y81.895 E.01372
G1 X98.105 Y3.451 E2.78972
G1 X98.65 Y3.451 E.01372
G1 X176.549 Y81.35 E2.77032
G1 X176.549 Y80.804 E.01372
G1 X99.196 Y3.451 E2.75092
G1 X99.741 Y3.451 E.01372
G1 X176.549 Y80.259 E2.73151
G1 X176.549 Y79.713 E.01372
G1 X100.287 Y3.451 E2.71211
G1 X100.833 Y3.451 E.01372
G1 X176.549 Y79.167 E2.69271
G1 X176.549 Y78.622 E.01372
G1 X101.378 Y3.451 E2.67331
G1 X101.924 Y3.451 E.01372
G1 X176.549 Y78.076 E2.65391
G1 X176.549 Y77.531 E.01372
G1 X102.469 Y3.451 E2.63451
G1 X103.015 Y3.451 E.01372
G1 X176.549 Y76.985 E2.61511
G1 X176.549 Y76.44 E.01372
G1 X103.56 Y3.451 E2.59571
G1 X104.106 Y3.451 E.01372
G1 X176.549 Y75.894 E2.57631
G1 X176.549 Y75.349 E.01372
G1 X104.651 Y3.451 E2.55691
G1 X105.197 Y3.451 E.01372
G1 X176.549 Y74.803 E2.53751
G1 X176.549 Y74.258 E.01372
G1 X105.742 Y3.451 E2.5181
G1 X106.288 Y3.451 E.01372
G1 X176.549 Y73.712 E2.4987
G1 X176.549 Y73.167 E.01372
G1 X106.833 Y3.451 E2.4793
G1 X107.379 Y3.451 E.01372
G1 X176.549 Y72.621 E2.4599
G1 X176.549 Y72.076 E.01372
G1 X107.924 Y3.451 E2.4405
G1 X108.47 Y3.451 E.01372
G1 X176.549 Y71.53 E2.4211
G1 X176.549 Y70.984 E.01372
G1 X109.016 Y3.451 E2.4017
G1 X109.561 Y3.451 E.01372
G1 X176.549 Y70.439 E2.3823
G1 X176.549 Y69.893 E.01372
G1 X110.107 Y3.451 E2.3629
G1 X110.652 Y3.451 E.01372
G1 X176.549 Y69.348 E2.3435
G1 X176.549 Y68.802 E.01372
G1 X111.198 Y3.451 E2.3241
G1 X111.743 Y3.451 E.01372
G1 X176.549 Y68.257 E2.30469
G1 X176.549 Y67.711 E.01372
G1 X112.289 Y3.451 E2.28529
G1 X112.834 Y3.451 E.01372
G1 X176.549 Y67.166 E2.26589
G1 X176.549 Y66.62 E.01372
G1 X113.38 Y3.451 E2.24649
G1 X113.925 Y3.451 E.01372
G1 X176.549 Y66.075 E2.22709
G1 X176.549 Y65.529 E.01372
G1 X114.471 Y3.451 E2.20769
G1 X115.016 Y3.451 E.01372
G1 X176.549 Y64.984 E2.18829
G1 X176.549 Y64.438 E.01372
G1 X115.562 Y3.451 E2.16889
G1 X116.107 Y3.451 E.01372
G1 X176.549 Y63.893 E2.14949
G1 X176.549 Y63.347 E.01372
G1 X116.653 Y3.451 E2.13009
G1 X117.199 Y3.451 E.01372
G1 X176.549 Y62.801 E2.11069
G1 X176.549 Y62.256 E.01372
G1 X117.744 Y3.451 E2.09128
G1 X118.29 Y3.451 E.01372
G1 X176.549 Y61.71 E2.07188
G1 X176.549 Y61.165 E.01372
G1 X118.835 Y3.451 E2.05248
G1 X119.381 Y3.451 E.01372
G1 X176.549 Y60.619 E2.03308
G1 X176.549 Y60.074 E.01372
G1 X119.926 Y3.451 E2.01368
G1 X120.472 Y3.451 E.01372
G1 X176.549 Y59.528 E1.99428
G1 X176.549 Y58.983 E.01372
M73 P82 R12
G1 X121.017 Y3.451 E1.97488
G1 X121.563 Y3.451 E.01372
G1 X176.549 Y58.437 E1.95548
G1 X176.549 Y57.892 E.01372
G1 X122.108 Y3.451 E1.93608
G1 X122.654 Y3.451 E.01372
G1 X176.549 Y57.346 E1.91668
G1 X176.549 Y56.801 E.01372
G1 X123.199 Y3.451 E1.89728
G1 X123.745 Y3.451 E.01372
G1 X176.549 Y56.255 E1.87787
G1 X176.549 Y55.71 E.01372
M73 P83 R12
G1 X124.29 Y3.451 E1.85847
G1 X124.836 Y3.451 E.01372
G1 X176.549 Y55.164 E1.83907
G1 X176.549 Y54.618 E.01372
G1 X125.382 Y3.451 E1.81967
G1 X125.927 Y3.451 E.01372
G1 X176.549 Y54.073 E1.80027
G1 X176.549 Y53.527 E.01372
G1 X126.473 Y3.451 E1.78087
G1 X127.018 Y3.451 E.01372
G1 X176.549 Y52.982 E1.76147
G1 X176.549 Y52.436 E.01372
G1 X127.564 Y3.451 E1.74207
G1 X128.109 Y3.451 E.01372
G1 X176.549 Y51.891 E1.72267
G1 X176.549 Y51.345 E.01372
G1 X128.655 Y3.451 E1.70327
G1 X129.2 Y3.451 E.01372
G1 X176.549 Y50.8 E1.68387
G1 X176.549 Y50.254 E.01372
G1 X129.746 Y3.451 E1.66447
G1 X130.291 Y3.451 E.01372
G1 X176.549 Y49.709 E1.64506
G1 X176.549 Y49.163 E.01372
G1 X130.837 Y3.451 E1.62566
G1 X131.382 Y3.451 E.01372
G1 X176.549 Y48.618 E1.60626
G1 X176.549 Y48.072 E.01372
G1 X131.928 Y3.451 E1.58686
G1 X132.473 Y3.451 E.01372
G1 X176.549 Y47.527 E1.56746
G1 X176.549 Y46.981 E.01372
G1 X133.019 Y3.451 E1.54806
G1 X133.565 Y3.451 E.01372
G1 X176.549 Y46.435 E1.52866
G1 X176.549 Y45.89 E.01372
G1 X134.11 Y3.451 E1.50926
G1 X134.656 Y3.451 E.01372
G1 X176.549 Y45.344 E1.48986
G1 X176.549 Y44.799 E.01372
G1 X135.201 Y3.451 E1.47046
G1 X135.747 Y3.451 E.01372
G1 X176.549 Y44.253 E1.45106
G1 X176.549 Y43.708 E.01372
G1 X136.292 Y3.451 E1.43165
G1 X136.838 Y3.451 E.01372
G1 X176.549 Y43.162 E1.41225
G1 X176.549 Y42.617 E.01372
G1 X137.383 Y3.451 E1.39285
G1 X137.929 Y3.451 E.01372
G1 X176.549 Y42.071 E1.37345
G1 X176.549 Y41.526 E.01372
G1 X138.474 Y3.451 E1.35405
G1 X139.02 Y3.451 E.01372
G1 X176.549 Y40.98 E1.33465
G1 X176.549 Y40.435 E.01372
G1 X139.565 Y3.451 E1.31525
G1 X140.111 Y3.451 E.01372
G1 X176.549 Y39.889 E1.29585
G1 X176.549 Y39.344 E.01372
G1 X140.656 Y3.451 E1.27645
G1 X141.202 Y3.451 E.01372
G1 X176.549 Y38.798 E1.25705
G1 X176.549 Y38.252 E.01372
G1 X141.748 Y3.451 E1.23765
G1 X142.293 Y3.451 E.01372
G1 X176.549 Y37.707 E1.21824
G1 X176.549 Y37.161 E.01372
G1 X142.839 Y3.451 E1.19884
G1 X143.384 Y3.451 E.01372
G1 X176.549 Y36.616 E1.17944
G1 X176.549 Y36.07 E.01372
G1 X143.93 Y3.451 E1.16004
G1 X144.475 Y3.451 E.01372
G1 X176.549 Y35.525 E1.14064
G1 X176.549 Y34.979 E.01372
G1 X145.021 Y3.451 E1.12124
G1 X145.566 Y3.451 E.01372
G1 X176.549 Y34.434 E1.10184
G1 X176.549 Y33.888 E.01372
G1 X146.112 Y3.451 E1.08244
G1 X146.657 Y3.451 E.01372
G1 X176.549 Y33.343 E1.06304
G1 X176.549 Y32.797 E.01372
G1 X147.203 Y3.451 E1.04364
G1 X147.748 Y3.451 E.01372
G1 X176.549 Y32.252 E1.02424
G1 X176.549 Y31.706 E.01372
G1 X148.294 Y3.451 E1.00483
G1 X148.839 Y3.451 E.01372
G1 X176.549 Y31.161 E.98543
G1 X176.549 Y30.615 E.01372
G1 X149.385 Y3.451 E.96603
G1 X149.931 Y3.451 E.01372
G1 X176.549 Y30.069 E.94663
G1 X176.549 Y29.524 E.01372
G1 X150.476 Y3.451 E.92723
G1 X151.022 Y3.451 E.01372
G1 X176.549 Y28.978 E.90783
G1 X176.549 Y28.433 E.01372
G1 X151.567 Y3.451 E.88843
G1 X152.113 Y3.451 E.01372
G1 X176.549 Y27.887 E.86903
G1 X176.549 Y27.342 E.01372
G1 X152.658 Y3.451 E.84963
G1 X153.204 Y3.451 E.01372
G1 X176.549 Y26.796 E.83023
G1 X176.549 Y26.251 E.01372
G1 X153.749 Y3.451 E.81083
G1 X154.295 Y3.451 E.01372
G1 X176.549 Y25.705 E.79142
G1 X176.549 Y25.16 E.01372
G1 X154.84 Y3.451 E.77202
G1 X155.386 Y3.451 E.01372
G1 X176.549 Y24.614 E.75262
G1 X176.549 Y24.069 E.01372
G1 X155.931 Y3.451 E.73322
G1 X156.477 Y3.451 E.01372
G1 X176.549 Y23.523 E.71382
G1 X176.549 Y22.978 E.01372
G1 X157.022 Y3.451 E.69442
G1 X157.568 Y3.451 E.01372
G1 X176.549 Y22.432 E.67502
G1 X176.549 Y21.886 E.01372
G1 X158.114 Y3.451 E.65562
G1 X158.659 Y3.451 E.01372
G1 X176.549 Y21.341 E.63622
G1 X176.549 Y20.795 E.01372
G1 X159.205 Y3.451 E.61682
G1 X159.75 Y3.451 E.01372
G1 X176.549 Y20.25 E.59742
G1 X176.549 Y19.704 E.01372
G1 X160.296 Y3.451 E.57801
G1 X160.841 Y3.451 E.01372
G1 X176.549 Y19.159 E.55861
G1 X176.549 Y18.613 E.01372
G1 X161.387 Y3.451 E.53921
G1 X161.932 Y3.451 E.01372
G1 X176.549 Y18.068 E.51981
G1 X176.549 Y17.522 E.01372
G1 X162.478 Y3.451 E.50041
G1 X163.023 Y3.451 E.01372
G1 X176.549 Y16.977 E.48101
G1 X176.549 Y16.431 E.01372
G1 X163.569 Y3.451 E.46161
G1 X164.114 Y3.451 E.01372
G1 X176.549 Y15.886 E.44221
G1 X176.549 Y15.34 E.01372
G1 X164.66 Y3.451 E.42281
G1 X165.205 Y3.451 E.01372
G1 X176.549 Y14.795 E.40341
G1 X176.549 Y14.249 E.01372
G1 X165.751 Y3.451 E.38401
G1 X166.297 Y3.451 E.01372
G1 X176.549 Y13.704 E.3646
G1 X176.549 Y13.158 E.01372
G1 X166.842 Y3.451 E.3452
G1 X167.388 Y3.451 E.01372
G1 X176.549 Y12.612 E.3258
G1 X176.549 Y12.067 E.01372
G1 X167.933 Y3.451 E.3064
G1 X168.479 Y3.451 E.01372
G1 X176.549 Y11.521 E.287
G1 X176.549 Y10.976 E.01372
G1 X169.024 Y3.451 E.2676
G1 X169.57 Y3.451 E.01372
G1 X176.549 Y10.43 E.2482
G1 X176.549 Y9.885 E.01372
G1 X170.115 Y3.451 E.2288
G1 X170.661 Y3.451 E.01372
G1 X176.549 Y9.339 E.2094
G1 X176.549 Y8.794 E.01372
G1 X171.206 Y3.451 E.19
G1 X171.752 Y3.451 E.01372
G1 X176.549 Y8.248 E.1706
G1 X176.549 Y7.703 E.01372
G1 X172.297 Y3.451 E.15119
G1 X172.843 Y3.451 E.01372
G1 X176.549 Y7.157 E.13179
G1 X176.549 Y6.612 E.01372
G1 X173.388 Y3.451 E.11239
G1 X173.934 Y3.451 E.01372
G1 X176.549 Y6.066 E.09299
G1 X176.549 Y5.521 E.01372
G1 X174.48 Y3.451 E.07359
G1 X175.025 Y3.451 E.01372
G1 X176.549 Y4.975 E.05419
G1 X176.549 Y4.429 E.01372
G1 X175.571 Y3.451 E.03479
G1 X176.116 Y3.451 E.01372
G1 X176.722 Y4.057 E.02156
; CHANGE_LAYER
; Z_HEIGHT: 1.05
; LAYER_HEIGHT: 0.16
; WIPE_START
G1 F12000
G1 X176.116 Y3.451 E-.32581
G1 X175.571 Y3.451 E-.20731
G1 X175.993 Y3.873 E-.22689
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 6/6
; update layer progress
M73 L6
M991 S0 P5 ;notify layer change

G1 E-1.2
; filament end gcode 

M204 S10000
G17
G3 Z1.29 I1.217 J0 P1  F42000
;===== machine: A1 mini =========================
;===== date: 20231225 =======================
G392 S0
M1007 S0
M620 S0A
M204 S9000

G17
G2 Z1.45 I0.86 J0.86 P1 F10000 ; spiral lift a little from second lift

G1 Z4.05 F1200

M400
M106 P1 S0
M106 P2 S0

M104 S215


G1 X180 F18000
M620.1 E F523 T240
M620.10 A0 F523
T0
M73 E0
M620.1 E F523 T240
M620.10 A1 F523 L202.987 H0.4 T240

G1 Y90 F9000


M400

G92 E0
M628 S0


; FLUSH_START
; always use highest temperature to flush
M400
M1002 set_filament_type:UNKNOWN
M109 S240
M106 P1 S60

G1 E23.7 F523 ; do not need pulsatile flushing for start part
G1 E0.540933 F50
G1 E6.22073 F523
G1 E0.540933 F50
G1 E6.22073 F523
G1 E0.540933 F50
G1 E6.22073 F523
G1 E0.540933 F50
G1 E6.22073 F523

; FLUSH_END
G1 E-2 F1800
G1 E2 F300
M400
M1002 set_filament_type:PLA



; WIPE
M400
M106 P1 S178
M400 S3
G1 X-3.5 F18000
G1 X-13.5 F3000
G1 X-3.5 F18000
G1 X-13.5 F3000
G1 X-3.5 F18000
M73 P85 R11
G1 X-13.5 F3000
M400
M106 P1 S0



M106 P1 S60
; FLUSH_START
G1 E9.1344 F523
G1 E1.01493 F50
G1 E9.1344 F523
G1 E1.01493 F50
G1 E9.1344 F523
G1 E1.01493 F50
G1 E9.1344 F523
G1 E1.01493 F50
G1 E9.1344 F523
G1 E1.01493 F50
; FLUSH_END
G1 E-2 F1800
G1 E2 F300



; WIPE
M400
M106 P1 S178
M400 S3
G1 X-3.5 F18000
G1 X-13.5 F3000
G1 X-3.5 F18000
G1 X-13.5 F3000
G1 X-3.5 F18000
G1 X-13.5 F3000
M400
M106 P1 S0



M106 P1 S60
; FLUSH_START
G1 E9.1344 F523
G1 E1.01493 F50
G1 E9.1344 F523
G1 E1.01493 F50
G1 E9.1344 F523
G1 E1.01493 F50
G1 E9.1344 F523
M73 P85 R10
G1 E1.01493 F50
G1 E9.1344 F523
G1 E1.01493 F50
; FLUSH_END
G1 E-2 F1800
G1 E2 F300



; WIPE
M400
M106 P1 S178
M400 S3
G1 X-3.5 F18000
G1 X-13.5 F3000
G1 X-3.5 F18000
G1 X-13.5 F3000
G1 X-3.5 F18000
G1 X-13.5 F3000
M400
M106 P1 S0



M106 P1 S60
; FLUSH_START
G1 E9.1344 F523
G1 E1.01493 F50
G1 E9.1344 F523
G1 E1.01493 F50
G1 E9.1344 F523
G1 E1.01493 F50
G1 E9.1344 F523
G1 E1.01493 F50
G1 E9.1344 F523
G1 E1.01493 F50
; FLUSH_END


M629

M400
M106 P1 S60
M109 S215
G1 E5 F523 ;Compensate for filament spillage during waiting temperature
M400
G92 E0
G1 E-2 F1800
M400
M106 P1 S178
M400 S3
M73 P86 R10
G1 X-3.5 F18000
G1 X-13.5 F3000
G1 X-3.5 F18000
G1 X-13.5 F3000
G1 X-3.5 F18000
G1 X-13.5 F3000
G1 X-3.5 F18000
M400
G1 Z4.05 F3000
M106 P1 S0

M204 S3000


M621 S0A

M9833 F1.54265 A0.3 ; cali dynamic extrusion compensation
M1002 judge_flag filament_need_cali_flag
M622 J1
  M106 P1 S178
  M400 S7
  G1 X0 F18000
  G1 X-13.5 F3000
  G1 X0 F18000 ;wipe and shake
  G1 X-13.5 F3000
  G1 X0 F12000 ;wipe and shake
  G1 X-13.5 F3000
  M400
  M106 P1 S0 
M623

G392 S0
M1007 S1

M106 S255
M104 S215 ; set nozzle temperature
; filament start gcode
M106 P3 S200


; OBJECT_ID: 53
G1 X177.29 Y177.29 F42000
G1 Z1.05
G1 E2 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3600
M204 S2000
G1 X2.71 Y177.29 E4.38918
G1 X2.71 Y2.71 E4.38918
G1 X177.29 Y2.71 E4.38918
G1 X177.29 Y177.23 E4.38767
; WIPE_START
M204 S3000
G1 X175.29 Y177.231 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z1.45 I1.217 J0 P1  F42000
;===================== date: 202312028 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
M622.1 S1 ; for prev firware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G17
G2 Z1.45 I0.86 J0.86 P1 F20000 ; spiral lift a little
G1 Z1.45
G1 X0 Y90 F18000 ; move to safe pos
G1 X-13.0 F3000 ; move to safe pos
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

M622.1 S1
M1002 judge_flag g39_detection_flag
M622 J1
  ; enable nozzle clog detect at 3rd layer
  


  
M623


G1 X177.078 Y176.634 F42000
G1 Z1.05
G1 E.8 F1800
; FEATURE: Top surface
G1 F9000
M204 S2000
G1 X176.634 Y177.078 E.01579
G1 X176.088 Y177.078
G1 X177.078 Y176.088 E.03519
G1 X177.078 Y175.543
G1 X175.543 Y177.078 E.05458
G1 X174.997 Y177.078
G1 X177.078 Y174.998 E.07397
G1 X177.078 Y174.452
G1 X174.452 Y177.078 E.09336
G1 X173.907 Y177.078
G1 X177.078 Y173.907 E.11275
G1 X177.078 Y173.361
G1 X173.361 Y177.078 E.13215
G1 X172.816 Y177.078
G1 X177.078 Y172.816 E.15154
G1 X177.078 Y172.27
G1 X172.27 Y177.078 E.17093
G1 X171.725 Y177.078
G1 X177.078 Y171.725 E.19032
G1 X177.078 Y171.18
G1 X171.18 Y177.078 E.20971
G1 X170.634 Y177.078
G1 X177.078 Y170.634 E.22911
G1 X177.078 Y170.089
G1 X170.089 Y177.078 E.2485
G1 X169.543 Y177.078
G1 X177.078 Y169.543 E.26789
G1 X177.078 Y168.998
G1 X168.998 Y177.078 E.28728
G1 X168.453 Y177.078
G1 X177.078 Y168.453 E.30667
G1 X177.078 Y167.907
G1 X167.907 Y177.078 E.32607
G1 X167.362 Y177.078
G1 X177.078 Y167.362 E.34546
G1 X177.078 Y166.816
G1 X166.816 Y177.078 E.36485
G1 X166.271 Y177.078
G1 X177.078 Y166.271 E.38424
G1 X177.078 Y165.726
G1 X165.726 Y177.078 E.40363
G1 X165.18 Y177.078
G1 X177.078 Y165.18 E.42303
G1 X177.078 Y164.635
G1 X164.635 Y177.078 E.44242
G1 X164.089 Y177.078
M73 P86 R9
G1 X177.078 Y164.089 E.46181
G1 X177.078 Y163.544
G1 X163.544 Y177.078 E.4812
G1 X162.999 Y177.078
G1 X177.078 Y162.999 E.50059
G1 X177.078 Y162.453
G1 X162.453 Y177.078 E.51999
G1 X161.908 Y177.078
G1 X177.078 Y161.908 E.53938
G1 X177.078 Y161.362
G1 X161.362 Y177.078 E.55877
G1 X160.817 Y177.078
G1 X177.078 Y160.817 E.57816
G1 X177.078 Y160.272
G1 X160.272 Y177.078 E.59755
G1 X159.726 Y177.078
G1 X177.078 Y159.726 E.61695
G1 X177.078 Y159.181
G1 X159.181 Y177.078 E.63634
G1 X158.635 Y177.078
G1 X177.078 Y158.635 E.65573
G1 X177.078 Y158.09
G1 X158.09 Y177.078 E.67512
G1 X157.545 Y177.078
G1 X177.078 Y157.545 E.69451
G1 X177.078 Y156.999
G1 X156.999 Y177.078 E.71391
G1 X156.454 Y177.078
G1 X177.078 Y156.454 E.7333
G1 X177.078 Y155.908
G1 X155.908 Y177.078 E.75269
G1 X155.363 Y177.078
G1 X177.078 Y155.363 E.77208
G1 X177.078 Y154.818
G1 X154.817 Y177.078 E.79147
G1 X154.272 Y177.078
G1 X177.078 Y154.272 E.81087
G1 X177.078 Y153.727
G1 X153.727 Y177.078 E.83026
G1 X153.181 Y177.078
G1 X177.078 Y153.181 E.84965
G1 X177.078 Y152.636
G1 X152.636 Y177.078 E.86904
G1 X152.09 Y177.078
G1 X177.078 Y152.09 E.88844
G1 X177.078 Y151.545
G1 X151.545 Y177.078 E.90783
G1 X151 Y177.078
G1 X177.078 Y151 E.92722
G1 X177.078 Y150.454
M73 P87 R9
G1 X150.454 Y177.078 E.94661
G1 X149.909 Y177.078
G1 X177.078 Y149.909 E.966
G1 X177.078 Y149.363
G1 X149.363 Y177.078 E.9854
G1 X148.818 Y177.078
G1 X177.078 Y148.818 E1.00479
G1 X177.078 Y148.273
G1 X148.273 Y177.078 E1.02418
G1 X147.727 Y177.078
G1 X177.078 Y147.727 E1.04357
G1 X177.078 Y147.182
G1 X147.182 Y177.078 E1.06296
G1 X146.636 Y177.078
G1 X177.078 Y146.636 E1.08236
G1 X177.078 Y146.091
G1 X146.091 Y177.078 E1.10175
G1 X145.546 Y177.078
G1 X177.078 Y145.546 E1.12114
G1 X177.078 Y145
G1 X145 Y177.078 E1.14053
G1 X144.455 Y177.078
G1 X177.078 Y144.455 E1.15992
G1 X177.078 Y143.909
G1 X143.909 Y177.078 E1.17932
G1 X143.364 Y177.078
G1 X177.078 Y143.364 E1.19871
G1 X177.078 Y142.819
G1 X142.819 Y177.078 E1.2181
G1 X142.273 Y177.078
G1 X177.078 Y142.273 E1.23749
G1 X177.078 Y141.728
G1 X141.728 Y177.078 E1.25688
G1 X141.182 Y177.078
G1 X177.078 Y141.182 E1.27628
G1 X177.078 Y140.637
G1 X140.637 Y177.078 E1.29567
G1 X140.092 Y177.078
G1 X177.078 Y140.092 E1.31506
G1 X177.078 Y139.546
G1 X139.546 Y177.078 E1.33445
G1 X139.001 Y177.078
G1 X177.078 Y139.001 E1.35384
G1 X177.078 Y138.455
G1 X138.455 Y177.078 E1.37324
G1 X137.91 Y177.078
G1 X177.078 Y137.91 E1.39263
G1 X177.078 Y137.365
G1 X137.365 Y177.078 E1.41202
G1 X136.819 Y177.078
G1 X177.078 Y136.819 E1.43141
G1 X177.078 Y136.274
G1 X136.274 Y177.078 E1.4508
G1 X135.728 Y177.078
G1 X177.078 Y135.728 E1.4702
G1 X177.078 Y135.183
G1 X135.183 Y177.078 E1.48959
G1 X134.637 Y177.078
G1 X177.078 Y134.637 E1.50898
G1 X177.078 Y134.092
G1 X134.092 Y177.078 E1.52837
G1 X133.547 Y177.078
G1 X177.078 Y133.547 E1.54776
G1 X177.078 Y133.001
G1 X133.001 Y177.078 E1.56716
G1 X132.456 Y177.078
G1 X177.078 Y132.456 E1.58655
G1 X177.078 Y131.91
G1 X131.91 Y177.078 E1.60594
G1 X131.365 Y177.078
G1 X177.078 Y131.365 E1.62533
G1 X177.078 Y130.82
G1 X130.82 Y177.078 E1.64472
G1 X130.274 Y177.078
G1 X177.078 Y130.274 E1.66412
G1 X177.078 Y129.729
G1 X129.729 Y177.078 E1.68351
G1 X129.183 Y177.078
G1 X177.078 Y129.183 E1.7029
G1 X177.078 Y128.638
G1 X128.638 Y177.078 E1.72229
G1 X128.093 Y177.078
G1 X177.078 Y128.093 E1.74168
G1 X177.078 Y127.547
G1 X127.547 Y177.078 E1.76108
G1 X127.002 Y177.078
G1 X177.078 Y127.002 E1.78047
G1 X177.078 Y126.456
G1 X126.456 Y177.078 E1.79986
G1 X125.911 Y177.078
G1 X177.078 Y125.911 E1.81925
G1 X177.078 Y125.366
G1 X125.366 Y177.078 E1.83864
G1 X124.82 Y177.078
G1 X177.078 Y124.82 E1.85804
G1 X177.078 Y124.275
G1 X124.275 Y177.078 E1.87743
G1 X123.729 Y177.078
G1 X177.078 Y123.729 E1.89682
G1 X177.078 Y123.184
G1 X123.184 Y177.078 E1.91621
G1 X122.639 Y177.078
G1 X177.078 Y122.639 E1.9356
G1 X177.078 Y122.093
G1 X122.093 Y177.078 E1.955
G1 X121.548 Y177.078
G1 X177.078 Y121.548 E1.97439
G1 X177.078 Y121.002
G1 X121.002 Y177.078 E1.99378
G1 X120.457 Y177.078
G1 X177.078 Y120.457 E2.01317
G1 X177.078 Y119.912
G1 X119.912 Y177.078 E2.03256
G1 X119.366 Y177.078
G1 X177.078 Y119.366 E2.05196
G1 X177.078 Y118.821
G1 X118.821 Y177.078 E2.07135
G1 X118.275 Y177.078
G1 X177.078 Y118.275 E2.09074
G1 X177.078 Y117.73
G1 X117.73 Y177.078 E2.11013
G1 X117.184 Y177.078
G1 X177.078 Y117.185 E2.12953
G1 X177.078 Y116.639
G1 X116.639 Y177.078 E2.14892
G1 X116.094 Y177.078
G1 X177.078 Y116.094 E2.16831
G1 X177.078 Y115.548
G1 X115.548 Y177.078 E2.1877
G1 X115.003 Y177.078
G1 X177.078 Y115.003 E2.20709
G1 X177.078 Y114.457
G1 X114.457 Y177.078 E2.22649
G1 X113.912 Y177.078
G1 X177.078 Y113.912 E2.24588
G1 X177.078 Y113.367
G1 X113.367 Y177.078 E2.26527
G1 X112.821 Y177.078
G1 X177.078 Y112.821 E2.28466
G1 X177.078 Y112.276
G1 X112.276 Y177.078 E2.30405
G1 X111.73 Y177.078
G1 X177.078 Y111.73 E2.32345
G1 X177.078 Y111.185
G1 X111.185 Y177.078 E2.34284
G1 X110.64 Y177.078
G1 X177.078 Y110.64 E2.36223
G1 X177.078 Y110.094
G1 X110.094 Y177.078 E2.38162
G1 X109.549 Y177.078
G1 X177.078 Y109.549 E2.40101
G1 X177.078 Y109.003
G1 X109.003 Y177.078 E2.42041
G1 X108.458 Y177.078
G1 X177.078 Y108.458 E2.4398
G1 X177.078 Y107.913
G1 X107.913 Y177.078 E2.45919
G1 X107.367 Y177.078
G1 X177.078 Y107.367 E2.47858
G1 X177.078 Y106.822
G1 X106.822 Y177.078 E2.49797
G1 X106.276 Y177.078
G1 X177.078 Y106.276 E2.51737
G1 X177.078 Y105.731
G1 X105.731 Y177.078 E2.53676
G1 X105.186 Y177.078
G1 X177.078 Y105.186 E2.55615
G1 X177.078 Y104.64
G1 X104.64 Y177.078 E2.57554
G1 X104.095 Y177.078
G1 X177.078 Y104.095 E2.59493
G1 X177.078 Y103.549
G1 X103.549 Y177.078 E2.61433
G1 X103.004 Y177.078
G1 X177.078 Y103.004 E2.63372
M73 P88 R9
G1 X177.078 Y102.459
G1 X102.459 Y177.078 E2.65311
G1 X101.913 Y177.078
G1 X177.078 Y101.913 E2.6725
G1 X177.078 Y101.368
G1 X101.368 Y177.078 E2.69189
G1 X100.822 Y177.078
G1 X177.078 Y100.822 E2.71129
G1 X177.078 Y100.277
G1 X100.277 Y177.078 E2.73068
G1 X99.732 Y177.078
G1 X177.078 Y99.732 E2.75007
G1 X177.078 Y99.186
G1 X99.186 Y177.078 E2.76946
G1 X98.641 Y177.078
G1 X177.078 Y98.641 E2.78885
G1 X177.078 Y98.095
G1 X98.095 Y177.078 E2.80825
G1 X97.55 Y177.078
G1 X177.078 Y97.55 E2.82764
G1 X177.078 Y97.005
G1 X97.004 Y177.078 E2.84703
G1 X96.459 Y177.078
M73 P88 R8
G1 X177.078 Y96.459 E2.86642
G1 X177.078 Y95.914
G1 X95.914 Y177.078 E2.88581
G1 X95.368 Y177.078
G1 X177.078 Y95.368 E2.90521
G1 X177.078 Y94.823
G1 X94.823 Y177.078 E2.9246
G1 X94.277 Y177.078
G1 X177.078 Y94.277 E2.94399
G1 X177.078 Y93.732
G1 X93.732 Y177.078 E2.96338
G1 X93.187 Y177.078
G1 X177.078 Y93.187 E2.98277
G1 X177.078 Y92.641
G1 X92.641 Y177.078 E3.00217
G1 X92.096 Y177.078
G1 X177.078 Y92.096 E3.02156
G1 X177.078 Y91.55
G1 X91.55 Y177.078 E3.04095
G1 X91.005 Y177.078
G1 X177.078 Y91.005 E3.06034
G1 X177.078 Y90.46
G1 X90.46 Y177.078 E3.07974
G1 X89.914 Y177.078
G1 X177.078 Y89.914 E3.09913
G1 X177.078 Y89.369
G1 X89.369 Y177.078 E3.11852
G1 X88.823 Y177.078
G1 X177.078 Y88.823 E3.13791
G1 X177.078 Y88.278
G1 X88.278 Y177.078 E3.1573
G1 X87.733 Y177.078
G1 X177.078 Y87.733 E3.1767
G1 X177.078 Y87.187
G1 X87.187 Y177.078 E3.19609
G1 X86.642 Y177.078
G1 X177.078 Y86.642 E3.21548
G1 X177.078 Y86.096
G1 X86.096 Y177.078 E3.23487
G1 X85.551 Y177.078
G1 X177.078 Y85.551 E3.25426
G1 X177.078 Y85.006
G1 X85.006 Y177.078 E3.27366
G1 X84.46 Y177.078
G1 X177.078 Y84.46 E3.29305
G1 X177.078 Y83.915
G1 X83.915 Y177.078 E3.31244
G1 X83.369 Y177.078
G1 X177.078 Y83.369 E3.33183
G1 X177.078 Y82.824
G1 X82.824 Y177.078 E3.35122
G1 X82.279 Y177.078
G1 X177.078 Y82.279 E3.37062
G1 X177.078 Y81.733
G1 X81.733 Y177.078 E3.39001
G1 X81.188 Y177.078
G1 X177.078 Y81.188 E3.4094
G1 X177.078 Y80.642
G1 X80.642 Y177.078 E3.42879
G1 X80.097 Y177.078
G1 X177.078 Y80.097 E3.44818
G1 X177.078 Y79.552
G1 X79.552 Y177.078 E3.46758
G1 X79.006 Y177.078
G1 X177.078 Y79.006 E3.48697
G1 X177.078 Y78.461
G1 X78.461 Y177.078 E3.50636
G1 X77.915 Y177.078
G1 X177.078 Y77.915 E3.52575
G1 X177.078 Y77.37
G1 X77.37 Y177.078 E3.54514
G1 X76.824 Y177.078
G1 X177.078 Y76.825 E3.56454
G1 X177.078 Y76.279
G1 X76.279 Y177.078 E3.58393
G1 X75.734 Y177.078
G1 X177.078 Y75.734 E3.60332
G1 X177.078 Y75.188
G1 X75.188 Y177.078 E3.62271
G1 X74.643 Y177.078
M73 P89 R8
G1 X177.078 Y74.643 E3.6421
G1 X177.078 Y74.097
G1 X74.097 Y177.078 E3.6615
G1 X73.552 Y177.078
G1 X177.078 Y73.552 E3.68089
G1 X177.078 Y73.007
G1 X73.007 Y177.078 E3.70028
G1 X72.461 Y177.078
G1 X177.078 Y72.461 E3.71967
G1 X177.078 Y71.916
G1 X71.916 Y177.078 E3.73906
G1 X71.37 Y177.078
G1 X177.078 Y71.37 E3.75846
G1 X177.078 Y70.825
G1 X70.825 Y177.078 E3.77785
G1 X70.28 Y177.078
G1 X177.078 Y70.28 E3.79724
G1 X177.078 Y69.734
G1 X69.734 Y177.078 E3.81663
G1 X69.189 Y177.078
G1 X177.078 Y69.189 E3.83602
G1 X177.078 Y68.643
G1 X68.643 Y177.078 E3.85542
G1 X68.098 Y177.078
G1 X177.078 Y68.098 E3.87481
G1 X177.078 Y67.553
G1 X67.553 Y177.078 E3.8942
G1 X67.007 Y177.078
G1 X177.078 Y67.007 E3.91359
G1 X177.078 Y66.462
G1 X66.462 Y177.078 E3.93298
G1 X65.916 Y177.078
G1 X177.078 Y65.916 E3.95238
G1 X177.078 Y65.371
G1 X65.371 Y177.078 E3.97177
G1 X64.826 Y177.078
G1 X177.078 Y64.826 E3.99116
G1 X177.078 Y64.28
G1 X64.28 Y177.078 E4.01055
G1 X63.735 Y177.078
G1 X177.078 Y63.735 E4.02994
G1 X177.078 Y63.189
G1 X63.189 Y177.078 E4.04934
G1 X62.644 Y177.078
M73 P89 R7
G1 X177.078 Y62.644 E4.06873
G1 X177.078 Y62.099
G1 X62.099 Y177.078 E4.08812
G1 X61.553 Y177.078
G1 X177.078 Y61.553 E4.10751
G1 X177.078 Y61.008
G1 X61.008 Y177.078 E4.1269
G1 X60.462 Y177.078
G1 X177.078 Y60.462 E4.1463
G1 X177.078 Y59.917
G1 X59.917 Y177.078 E4.16569
G1 X59.371 Y177.078
G1 X177.078 Y59.372 E4.18508
G1 X177.078 Y58.826
G1 X58.826 Y177.078 E4.20447
G1 X58.281 Y177.078
G1 X177.078 Y58.281 E4.22387
G1 X177.078 Y57.735
G1 X57.735 Y177.078 E4.24326
G1 X57.19 Y177.078
G1 X177.078 Y57.19 E4.26265
G1 X177.078 Y56.645
G1 X56.644 Y177.078 E4.28204
G1 X56.099 Y177.078
G1 X177.078 Y56.099 E4.30143
G1 X177.078 Y55.554
G1 X55.554 Y177.078 E4.32083
G1 X55.008 Y177.078
G1 X177.078 Y55.008 E4.34022
G1 X177.078 Y54.463
G1 X54.463 Y177.078 E4.35961
G1 X53.917 Y177.078
G1 X177.078 Y53.917 E4.379
G1 X177.078 Y53.372
G1 X53.372 Y177.078 E4.39839
G1 X52.827 Y177.078
G1 X177.078 Y52.827 E4.41779
G1 X177.078 Y52.281
M73 P90 R7
G1 X52.281 Y177.078 E4.43718
G1 X51.736 Y177.078
G1 X177.078 Y51.736 E4.45657
G1 X177.078 Y51.19
G1 X51.19 Y177.078 E4.47596
G1 X50.645 Y177.078
G1 X177.078 Y50.645 E4.49535
G1 X177.078 Y50.1
G1 X50.1 Y177.078 E4.51475
G1 X49.554 Y177.078
G1 X177.078 Y49.554 E4.53414
G1 X177.078 Y49.009
G1 X49.009 Y177.078 E4.55353
G1 X48.463 Y177.078
G1 X177.078 Y48.463 E4.57292
G1 X177.078 Y47.918
G1 X47.918 Y177.078 E4.59231
G1 X47.373 Y177.078
G1 X177.078 Y47.373 E4.61171
G1 X177.078 Y46.827
G1 X46.827 Y177.078 E4.6311
G1 X46.282 Y177.078
G1 X177.078 Y46.282 E4.65049
G1 X177.078 Y45.736
G1 X45.736 Y177.078 E4.66988
G1 X45.191 Y177.078
G1 X177.078 Y45.191 E4.68927
G1 X177.078 Y44.646
G1 X44.646 Y177.078 E4.70867
G1 X44.1 Y177.078
G1 X177.078 Y44.1 E4.72806
G1 X177.078 Y43.555
G1 X43.555 Y177.078 E4.74745
G1 X43.009 Y177.078
G1 X177.078 Y43.009 E4.76684
G1 X177.078 Y42.464
G1 X42.464 Y177.078 E4.78623
G1 X41.919 Y177.078
G1 X177.078 Y41.919 E4.80563
G1 X177.078 Y41.373
G1 X41.373 Y177.078 E4.82502
G1 X40.828 Y177.078
G1 X177.078 Y40.828 E4.84441
G1 X177.078 Y40.282
G1 X40.282 Y177.078 E4.8638
G1 X39.737 Y177.078
G1 X177.078 Y39.737 E4.88319
G1 X177.078 Y39.192
G1 X39.191 Y177.078 E4.90259
G1 X38.646 Y177.078
G1 X177.078 Y38.646 E4.92198
G1 X177.078 Y38.101
G1 X38.101 Y177.078 E4.94137
G1 X37.555 Y177.078
G1 X177.078 Y37.555 E4.96076
G1 X177.078 Y37.01
G1 X37.01 Y177.078 E4.98015
G1 X36.464 Y177.078
M73 P90 R6
G1 X177.078 Y36.464 E4.99955
G1 X177.078 Y35.919
G1 X35.919 Y177.078 E5.01894
G1 X35.374 Y177.078
G1 X177.078 Y35.374 E5.03833
G1 X177.078 Y34.828
G1 X34.828 Y177.078 E5.05772
G1 X34.283 Y177.078
G1 X177.078 Y34.283 E5.07711
G1 X177.078 Y33.737
G1 X33.737 Y177.078 E5.09651
G1 X33.192 Y177.078
M73 P91 R6
G1 X177.078 Y33.192 E5.1159
G1 X177.078 Y32.647
G1 X32.647 Y177.078 E5.13529
G1 X32.101 Y177.078
G1 X177.078 Y32.101 E5.15468
G1 X177.078 Y31.556
G1 X31.556 Y177.078 E5.17407
G1 X31.01 Y177.078
G1 X177.078 Y31.01 E5.19347
G1 X177.078 Y30.465
G1 X30.465 Y177.078 E5.21286
G1 X29.92 Y177.078
G1 X177.078 Y29.92 E5.23225
G1 X177.078 Y29.374
G1 X29.374 Y177.078 E5.25164
G1 X28.829 Y177.078
G1 X177.078 Y28.829 E5.27104
G1 X177.078 Y28.283
G1 X28.283 Y177.078 E5.29043
G1 X27.738 Y177.078
G1 X177.078 Y27.738 E5.30982
G1 X177.078 Y27.193
G1 X27.193 Y177.078 E5.32921
G1 X26.647 Y177.078
G1 X177.078 Y26.647 E5.3486
G1 X177.078 Y26.102
G1 X26.102 Y177.078 E5.368
G1 X25.556 Y177.078
G1 X177.078 Y25.556 E5.38739
G1 X177.078 Y25.011
G1 X25.011 Y177.078 E5.40678
G1 X24.466 Y177.078
G1 X177.078 Y24.466 E5.42617
G1 X177.078 Y23.92
G1 X23.92 Y177.078 E5.44556
G1 X23.375 Y177.078
G1 X177.078 Y23.375 E5.46496
G1 X177.078 Y22.829
G1 X22.829 Y177.078 E5.48435
G1 X22.284 Y177.078
G1 X177.078 Y22.284 E5.50374
G1 X177.078 Y21.739
G1 X21.738 Y177.078 E5.52313
G1 X21.193 Y177.078
G1 X177.078 Y21.193 E5.54252
G1 X177.078 Y20.648
G1 X20.648 Y177.078 E5.56192
G1 X20.102 Y177.078
G1 X177.078 Y20.102 E5.58131
G1 X177.078 Y19.557
G1 X19.557 Y177.078 E5.6007
G1 X19.011 Y177.078
G1 X177.078 Y19.012 E5.62009
G1 X177.078 Y18.466
G1 X18.466 Y177.078 E5.63948
G1 X17.921 Y177.078
G1 X177.078 Y17.921 E5.65888
G1 X177.078 Y17.375
G1 X17.375 Y177.078 E5.67827
G1 X16.83 Y177.078
G1 X177.078 Y16.83 E5.69766
G1 X177.078 Y16.284
M73 P92 R6
G1 X16.284 Y177.078 E5.71705
G1 X15.739 Y177.078
G1 X177.078 Y15.739 E5.73644
G1 X177.078 Y15.194
G1 X15.194 Y177.078 E5.75584
G1 X14.648 Y177.078
G1 X177.078 Y14.648 E5.77523
G1 X177.078 Y14.103
M73 P92 R5
G1 X14.103 Y177.078 E5.79462
G1 X13.557 Y177.078
G1 X177.078 Y13.557 E5.81401
G1 X177.078 Y13.012
G1 X13.012 Y177.078 E5.8334
G1 X12.467 Y177.078
G1 X177.078 Y12.467 E5.8528
G1 X177.078 Y11.921
G1 X11.921 Y177.078 E5.87219
G1 X11.376 Y177.078
G1 X177.078 Y11.376 E5.89158
G1 X177.078 Y10.83
G1 X10.83 Y177.078 E5.91097
G1 X10.285 Y177.078
G1 X177.078 Y10.285 E5.93036
G1 X177.078 Y9.74
G1 X9.74 Y177.078 E5.94976
G1 X9.194 Y177.078
G1 X177.078 Y9.194 E5.96915
G1 X177.078 Y8.649
G1 X8.649 Y177.078 E5.98854
G1 X8.103 Y177.078
G1 X177.078 Y8.103 E6.00793
G1 X177.078 Y7.558
G1 X7.558 Y177.078 E6.02732
G1 X7.013 Y177.078
G1 X177.078 Y7.013 E6.04672
G1 X177.078 Y6.467
G1 X6.467 Y177.078 E6.06611
G1 X5.922 Y177.078
G1 X177.078 Y5.922 E6.0855
G1 X177.078 Y5.376
G1 X5.376 Y177.078 E6.10489
G1 X4.831 Y177.078
G1 X177.078 Y4.831 E6.12428
G1 X177.078 Y4.286
G1 X4.286 Y177.078 E6.14368
G1 X3.74 Y177.078
G1 X177.078 Y3.74 E6.16307
G1 X177.078 Y3.195
G1 X3.195 Y177.078 E6.18246
G1 X2.922 Y176.805
G1 X176.805 Y2.922 E6.18246
G1 X176.26 Y2.922
G1 X2.922 Y176.26 E6.16306
G1 X2.922 Y175.714
G1 X175.714 Y2.922 E6.14367
G1 X175.169 Y2.922
M73 P93 R5
G1 X2.922 Y175.169 E6.12428
G1 X2.922 Y174.623
G1 X174.624 Y2.922 E6.10489
G1 X174.078 Y2.922
G1 X2.922 Y174.078 E6.0855
G1 X2.922 Y173.533
G1 X173.533 Y2.922 E6.0661
G1 X172.987 Y2.922
G1 X2.922 Y172.987 E6.04671
G1 X2.922 Y172.442
G1 X172.442 Y2.922 E6.02732
G1 X171.897 Y2.922
G1 X2.922 Y171.896 E6.00793
G1 X2.922 Y171.351
G1 X171.351 Y2.922 E5.98854
G1 X170.806 Y2.922
G1 X2.922 Y170.806 E5.96914
G1 X2.922 Y170.26
G1 X170.26 Y2.922 E5.94975
G1 X169.715 Y2.922
G1 X2.922 Y169.715 E5.93036
G1 X2.922 Y169.169
G1 X169.169 Y2.922 E5.91097
G1 X168.624 Y2.922
M73 P93 R4
G1 X2.922 Y168.624 E5.89158
G1 X2.922 Y168.079
G1 X168.079 Y2.922 E5.87218
G1 X167.533 Y2.922
G1 X2.922 Y167.533 E5.85279
G1 X2.922 Y166.988
G1 X166.988 Y2.922 E5.8334
G1 X166.442 Y2.922
G1 X2.922 Y166.442 E5.81401
G1 X2.922 Y165.897
G1 X165.897 Y2.922 E5.79462
G1 X165.352 Y2.922
G1 X2.922 Y165.352 E5.77522
G1 X2.922 Y164.806
G1 X164.806 Y2.922 E5.75583
G1 X164.261 Y2.922
G1 X2.922 Y164.261 E5.73644
G1 X2.922 Y163.715
G1 X163.715 Y2.922 E5.71705
G1 X163.17 Y2.922
G1 X2.922 Y163.17 E5.69765
G1 X2.922 Y162.625
G1 X162.625 Y2.922 E5.67826
G1 X162.079 Y2.922
G1 X2.922 Y162.079 E5.65887
G1 X2.922 Y161.534
G1 X161.534 Y2.922 E5.63948
G1 X160.988 Y2.922
G1 X2.922 Y160.988 E5.62009
G1 X2.922 Y160.443
M73 P94 R4
G1 X160.443 Y2.922 E5.60069
G1 X159.898 Y2.922
G1 X2.922 Y159.898 E5.5813
G1 X2.922 Y159.352
G1 X159.352 Y2.922 E5.56191
G1 X158.807 Y2.922
G1 X2.922 Y158.807 E5.54252
G1 X2.922 Y158.261
G1 X158.261 Y2.922 E5.52313
G1 X157.716 Y2.922
G1 X2.922 Y157.716 E5.50373
G1 X2.922 Y157.171
G1 X157.171 Y2.922 E5.48434
G1 X156.625 Y2.922
G1 X2.922 Y156.625 E5.46495
G1 X2.922 Y156.08
G1 X156.08 Y2.922 E5.44556
G1 X155.534 Y2.922
G1 X2.922 Y155.534 E5.42617
G1 X2.922 Y154.989
G1 X154.989 Y2.922 E5.40677
G1 X154.444 Y2.922
G1 X2.922 Y154.443 E5.38738
G1 X2.922 Y153.898
G1 X153.898 Y2.922 E5.36799
G1 X153.353 Y2.922
G1 X2.922 Y153.353 E5.3486
G1 X2.922 Y152.807
G1 X152.807 Y2.922 E5.32921
G1 X152.262 Y2.922
G1 X2.922 Y152.262 E5.30981
G1 X2.922 Y151.716
G1 X151.716 Y2.922 E5.29042
G1 X151.171 Y2.922
G1 X2.922 Y151.171 E5.27103
G1 X2.922 Y150.626
G1 X150.626 Y2.922 E5.25164
G1 X150.08 Y2.922
G1 X2.922 Y150.08 E5.23225
G1 X2.922 Y149.535
G1 X149.535 Y2.922 E5.21285
G1 X148.989 Y2.922
G1 X2.922 Y148.989 E5.19346
G1 X2.922 Y148.444
M73 P94 R3
G1 X148.444 Y2.922 E5.17407
G1 X147.899 Y2.922
G1 X2.922 Y147.899 E5.15468
G1 X2.922 Y147.353
G1 X147.353 Y2.922 E5.13529
G1 X146.808 Y2.922
G1 X2.922 Y146.808 E5.11589
G1 X2.922 Y146.262
G1 X146.262 Y2.922 E5.0965
G1 X145.717 Y2.922
G1 X2.922 Y145.717 E5.07711
G1 X2.922 Y145.172
G1 X145.172 Y2.922 E5.05772
G1 X144.626 Y2.922
M73 P95 R3
G1 X2.922 Y144.626 E5.03833
G1 X2.922 Y144.081
G1 X144.081 Y2.922 E5.01893
G1 X143.535 Y2.922
G1 X2.922 Y143.535 E4.99954
G1 X2.922 Y142.99
G1 X142.99 Y2.922 E4.98015
G1 X142.445 Y2.922
G1 X2.922 Y142.445 E4.96076
G1 X2.922 Y141.899
G1 X141.899 Y2.922 E4.94137
G1 X141.354 Y2.922
G1 X2.922 Y141.354 E4.92197
G1 X2.922 Y140.808
G1 X140.808 Y2.922 E4.90258
G1 X140.263 Y2.922
G1 X2.922 Y140.263 E4.88319
G1 X2.922 Y139.718
G1 X139.718 Y2.922 E4.8638
G1 X139.172 Y2.922
G1 X2.922 Y139.172 E4.84441
G1 X2.922 Y138.627
G1 X138.627 Y2.922 E4.82501
G1 X138.081 Y2.922
G1 X2.922 Y138.081 E4.80562
G1 X2.922 Y137.536
G1 X137.536 Y2.922 E4.78623
G1 X136.991 Y2.922
G1 X2.922 Y136.991 E4.76684
G1 X2.922 Y136.445
G1 X136.445 Y2.922 E4.74745
G1 X135.9 Y2.922
G1 X2.922 Y135.9 E4.72805
G1 X2.922 Y135.354
G1 X135.354 Y2.922 E4.70866
G1 X134.809 Y2.922
G1 X2.922 Y134.809 E4.68927
G1 X2.922 Y134.263
G1 X134.264 Y2.922 E4.66988
G1 X133.718 Y2.922
G1 X2.922 Y133.718 E4.65048
G1 X2.922 Y133.173
G1 X133.173 Y2.922 E4.63109
G1 X132.627 Y2.922
G1 X2.922 Y132.627 E4.6117
G1 X2.922 Y132.082
G1 X132.082 Y2.922 E4.59231
G1 X131.536 Y2.922
G1 X2.922 Y131.536 E4.57292
G1 X2.922 Y130.991
G1 X130.991 Y2.922 E4.55352
G1 X130.446 Y2.922
G1 X2.922 Y130.446 E4.53413
G1 X2.922 Y129.9
G1 X129.9 Y2.922 E4.51474
G1 X129.355 Y2.922
G1 X2.922 Y129.355 E4.49535
G1 X2.922 Y128.809
G1 X128.809 Y2.922 E4.47596
G1 X128.264 Y2.922
G1 X2.922 Y128.264 E4.45656
G1 X2.922 Y127.719
G1 X127.719 Y2.922 E4.43717
G1 X127.173 Y2.922
G1 X2.922 Y127.173 E4.41778
G1 X2.922 Y126.628
M73 P96 R3
G1 X126.628 Y2.922 E4.39839
G1 X126.082 Y2.922
G1 X2.922 Y126.082 E4.379
G1 X2.922 Y125.537
G1 X125.537 Y2.922 E4.3596
G1 X124.992 Y2.922
M73 P96 R2
G1 X2.922 Y124.992 E4.34021
G1 X2.922 Y124.446
G1 X124.446 Y2.922 E4.32082
G1 X123.901 Y2.922
G1 X2.922 Y123.901 E4.30143
G1 X2.922 Y123.355
G1 X123.355 Y2.922 E4.28204
G1 X122.81 Y2.922
G1 X2.922 Y122.81 E4.26264
G1 X2.922 Y122.265
G1 X122.265 Y2.922 E4.24325
G1 X121.719 Y2.922
G1 X2.922 Y121.719 E4.22386
G1 X2.922 Y121.174
G1 X121.174 Y2.922 E4.20447
G1 X120.628 Y2.922
G1 X2.922 Y120.628 E4.18508
G1 X2.922 Y120.083
G1 X120.083 Y2.922 E4.16568
G1 X119.538 Y2.922
G1 X2.922 Y119.538 E4.14629
G1 X2.922 Y118.992
G1 X118.992 Y2.922 E4.1269
G1 X118.447 Y2.922
G1 X2.922 Y118.447 E4.10751
G1 X2.922 Y117.901
G1 X117.901 Y2.922 E4.08812
G1 X117.356 Y2.922
G1 X2.922 Y117.356 E4.06872
G1 X2.922 Y116.81
G1 X116.811 Y2.922 E4.04933
G1 X116.265 Y2.922
G1 X2.922 Y116.265 E4.02994
G1 X2.922 Y115.72
G1 X115.72 Y2.922 E4.01055
G1 X115.174 Y2.922
G1 X2.922 Y115.174 E3.99116
G1 X2.922 Y114.629
G1 X114.629 Y2.922 E3.97176
G1 X114.084 Y2.922
G1 X2.922 Y114.083 E3.95237
G1 X2.922 Y113.538
G1 X113.538 Y2.922 E3.93298
G1 X112.993 Y2.922
G1 X2.922 Y112.993 E3.91359
G1 X2.922 Y112.447
G1 X112.447 Y2.922 E3.8942
G1 X111.902 Y2.922
G1 X2.922 Y111.902 E3.8748
G1 X2.922 Y111.356
G1 X111.356 Y2.922 E3.85541
G1 X110.811 Y2.922
G1 X2.922 Y110.811 E3.83602
G1 X2.922 Y110.266
G1 X110.266 Y2.922 E3.81663
G1 X109.72 Y2.922
G1 X2.922 Y109.72 E3.79724
G1 X2.922 Y109.175
G1 X109.175 Y2.922 E3.77784
G1 X108.629 Y2.922
G1 X2.922 Y108.629 E3.75845
G1 X2.922 Y108.084
G1 X108.084 Y2.922 E3.73906
G1 X107.539 Y2.922
G1 X2.922 Y107.539 E3.71967
G1 X2.922 Y106.993
G1 X106.993 Y2.922 E3.70028
G1 X106.448 Y2.922
G1 X2.922 Y106.448 E3.68088
G1 X2.922 Y105.902
M73 P97 R2
G1 X105.902 Y2.922 E3.66149
G1 X105.357 Y2.922
G1 X2.922 Y105.357 E3.6421
G1 X2.922 Y104.812
G1 X104.812 Y2.922 E3.62271
G1 X104.266 Y2.922
G1 X2.922 Y104.266 E3.60331
G1 X2.922 Y103.721
G1 X103.721 Y2.922 E3.58392
G1 X103.175 Y2.922
G1 X2.922 Y103.175 E3.56453
G1 X2.922 Y102.63
G1 X102.63 Y2.922 E3.54514
G1 X102.085 Y2.922
G1 X2.922 Y102.085 E3.52575
G1 X2.922 Y101.539
G1 X101.539 Y2.922 E3.50635
G1 X100.994 Y2.922
G1 X2.922 Y100.994 E3.48696
G1 X2.922 Y100.448
G1 X100.448 Y2.922 E3.46757
G1 X99.903 Y2.922
G1 X2.922 Y99.903 E3.44818
G1 X2.922 Y99.358
G1 X99.358 Y2.922 E3.42879
G1 X98.812 Y2.922
G1 X2.922 Y98.812 E3.40939
G1 X2.922 Y98.267
G1 X98.267 Y2.922 E3.39
G1 X97.721 Y2.922
G1 X2.922 Y97.721 E3.37061
G1 X2.922 Y97.176
G1 X97.176 Y2.922 E3.35122
G1 X96.631 Y2.922
M73 P97 R1
G1 X2.922 Y96.63 E3.33183
G1 X2.922 Y96.085
G1 X96.085 Y2.922 E3.31243
G1 X95.54 Y2.922
G1 X2.922 Y95.54 E3.29304
G1 X2.922 Y94.994
G1 X94.994 Y2.922 E3.27365
G1 X94.449 Y2.922
G1 X2.922 Y94.449 E3.25426
G1 X2.922 Y93.903
G1 X93.903 Y2.922 E3.23487
G1 X93.358 Y2.922
G1 X2.922 Y93.358 E3.21547
G1 X2.922 Y92.813
G1 X92.813 Y2.922 E3.19608
G1 X92.267 Y2.922
G1 X2.922 Y92.267 E3.17669
G1 X2.922 Y91.722
G1 X91.722 Y2.922 E3.1573
G1 X91.176 Y2.922
G1 X2.922 Y91.176 E3.13791
G1 X2.922 Y90.631
G1 X90.631 Y2.922 E3.11851
G1 X90.086 Y2.922
G1 X2.922 Y90.086 E3.09912
G1 X2.922 Y89.54
G1 X89.54 Y2.922 E3.07973
G1 X88.995 Y2.922
G1 X2.922 Y88.995 E3.06034
G1 X2.922 Y88.449
G1 X88.449 Y2.922 E3.04095
G1 X87.904 Y2.922
G1 X2.922 Y87.904 E3.02155
G1 X2.922 Y87.359
G1 X87.359 Y2.922 E3.00216
G1 X86.813 Y2.922
G1 X2.922 Y86.813 E2.98277
G1 X2.922 Y86.268
G1 X86.268 Y2.922 E2.96338
G1 X85.722 Y2.922
G1 X2.922 Y85.722 E2.94399
G1 X2.922 Y85.177
G1 X85.177 Y2.922 E2.92459
G1 X84.632 Y2.922
G1 X2.922 Y84.632 E2.9052
G1 X2.922 Y84.086
G1 X84.086 Y2.922 E2.88581
G1 X83.541 Y2.922
G1 X2.922 Y83.541 E2.86642
G1 X2.922 Y82.995
G1 X82.995 Y2.922 E2.84703
G1 X82.45 Y2.922
G1 X2.922 Y82.45 E2.82763
G1 X2.922 Y81.905
G1 X81.905 Y2.922 E2.80824
G1 X81.359 Y2.922
G1 X2.922 Y81.359 E2.78885
G1 X2.922 Y80.814
M73 P98 R1
G1 X80.814 Y2.922 E2.76946
G1 X80.268 Y2.922
G1 X2.922 Y80.268 E2.75007
G1 X2.922 Y79.723
G1 X79.723 Y2.922 E2.73067
G1 X79.178 Y2.922
G1 X2.922 Y79.178 E2.71128
G1 X2.922 Y78.632
G1 X78.632 Y2.922 E2.69189
G1 X78.087 Y2.922
G1 X2.922 Y78.087 E2.6725
G1 X2.922 Y77.541
G1 X77.541 Y2.922 E2.6531
G1 X76.996 Y2.922
G1 X2.922 Y76.996 E2.63371
G1 X2.922 Y76.45
G1 X76.451 Y2.922 E2.61432
G1 X75.905 Y2.922
G1 X2.922 Y75.905 E2.59493
G1 X2.922 Y75.36
G1 X75.36 Y2.922 E2.57554
G1 X74.814 Y2.922
G1 X2.922 Y74.814 E2.55615
G1 X2.922 Y74.269
G1 X74.269 Y2.922 E2.53675
G1 X73.723 Y2.922
G1 X2.922 Y73.723 E2.51736
G1 X2.922 Y73.178
G1 X73.178 Y2.922 E2.49797
G1 X72.633 Y2.922
G1 X2.922 Y72.633 E2.47858
G1 X2.922 Y72.087
G1 X72.087 Y2.922 E2.45919
G1 X71.542 Y2.922
G1 X2.922 Y71.542 E2.43979
G1 X2.922 Y70.996
G1 X70.996 Y2.922 E2.4204
G1 X70.451 Y2.922
G1 X2.922 Y70.451 E2.40101
G1 X2.922 Y69.906
G1 X69.906 Y2.922 E2.38162
G1 X69.36 Y2.922
G1 X2.922 Y69.36 E2.36222
G1 X2.922 Y68.815
G1 X68.815 Y2.922 E2.34283
G1 X68.269 Y2.922
G1 X2.922 Y68.269 E2.32344
G1 X2.922 Y67.724
G1 X67.724 Y2.922 E2.30405
G1 X67.179 Y2.922
G1 X2.922 Y67.179 E2.28466
G1 X2.922 Y66.633
G1 X66.633 Y2.922 E2.26526
G1 X66.088 Y2.922
G1 X2.922 Y66.088 E2.24587
G1 X2.922 Y65.542
G1 X65.542 Y2.922 E2.22648
G1 X64.997 Y2.922
G1 X2.922 Y64.997 E2.20709
G1 X2.922 Y64.452
G1 X64.452 Y2.922 E2.1877
G1 X63.906 Y2.922
G1 X2.922 Y63.906 E2.1683
G1 X2.922 Y63.361
G1 X63.361 Y2.922 E2.14891
G1 X62.815 Y2.922
G1 X2.922 Y62.815 E2.12952
G1 X2.922 Y62.27
G1 X62.27 Y2.922 E2.11013
G1 X61.725 Y2.922
G1 X2.922 Y61.725 E2.09074
G1 X2.922 Y61.179
G1 X61.179 Y2.922 E2.07134
G1 X60.634 Y2.922
G1 X2.922 Y60.634 E2.05195
G1 X2.922 Y60.088
G1 X60.088 Y2.922 E2.03256
G1 X59.543 Y2.922
G1 X2.922 Y59.543 E2.01317
G1 X2.922 Y58.998
G1 X58.998 Y2.922 E1.99378
G1 X58.452 Y2.922
G1 X2.922 Y58.452 E1.97438
G1 X2.922 Y57.907
M73 P98 R0
G1 X57.907 Y2.922 E1.95499
G1 X57.361 Y2.922
G1 X2.922 Y57.361 E1.9356
G1 X2.922 Y56.816
G1 X56.816 Y2.922 E1.91621
G1 X56.271 Y2.922
G1 X2.922 Y56.27 E1.89682
G1 X2.922 Y55.725
G1 X55.725 Y2.922 E1.87742
G1 X55.18 Y2.922
G1 X2.922 Y55.18 E1.85803
G1 X2.922 Y54.634
G1 X54.634 Y2.922 E1.83864
G1 X54.089 Y2.922
G1 X2.922 Y54.089 E1.81925
G1 X2.922 Y53.543
G1 X53.543 Y2.922 E1.79986
G1 X52.998 Y2.922
G1 X2.922 Y52.998 E1.78046
G1 X2.922 Y52.453
G1 X52.453 Y2.922 E1.76107
G1 X51.907 Y2.922
G1 X2.922 Y51.907 E1.74168
G1 X2.922 Y51.362
G1 X51.362 Y2.922 E1.72229
G1 X50.816 Y2.922
G1 X2.922 Y50.816 E1.7029
G1 X2.922 Y50.271
G1 X50.271 Y2.922 E1.6835
G1 X49.726 Y2.922
G1 X2.922 Y49.726 E1.66411
G1 X2.922 Y49.18
G1 X49.18 Y2.922 E1.64472
G1 X48.635 Y2.922
G1 X2.922 Y48.635 E1.62533
G1 X2.922 Y48.089
G1 X48.089 Y2.922 E1.60594
G1 X47.544 Y2.922
G1 X2.922 Y47.544 E1.58654
G1 X2.922 Y46.999
G1 X46.999 Y2.922 E1.56715
G1 X46.453 Y2.922
G1 X2.922 Y46.453 E1.54776
G1 X2.922 Y45.908
G1 X45.908 Y2.922 E1.52837
G1 X45.362 Y2.922
M73 P99 R0
G1 X2.922 Y45.362 E1.50898
G1 X2.922 Y44.817
G1 X44.817 Y2.922 E1.48958
G1 X44.272 Y2.922
G1 X2.922 Y44.272 E1.47019
G1 X2.922 Y43.726
G1 X43.726 Y2.922 E1.4508
G1 X43.181 Y2.922
G1 X2.922 Y43.181 E1.43141
G1 X2.922 Y42.635
G1 X42.635 Y2.922 E1.41201
G1 X42.09 Y2.922
G1 X2.922 Y42.09 E1.39262
G1 X2.922 Y41.545
G1 X41.545 Y2.922 E1.37323
G1 X40.999 Y2.922
G1 X2.922 Y40.999 E1.35384
G1 X2.922 Y40.454
G1 X40.454 Y2.922 E1.33445
G1 X39.908 Y2.922
G1 X2.922 Y39.908 E1.31505
G1 X2.922 Y39.363
G1 X39.363 Y2.922 E1.29566
G1 X38.818 Y2.922
G1 X2.922 Y38.818 E1.27627
G1 X2.922 Y38.272
G1 X38.272 Y2.922 E1.25688
G1 X37.727 Y2.922
G1 X2.922 Y37.727 E1.23749
G1 X2.922 Y37.181
G1 X37.181 Y2.922 E1.21809
G1 X36.636 Y2.922
G1 X2.922 Y36.636 E1.1987
G1 X2.922 Y36.09
G1 X36.09 Y2.922 E1.17931
G1 X35.545 Y2.922
G1 X2.922 Y35.545 E1.15992
G1 X2.922 Y35
G1 X35 Y2.922 E1.14053
G1 X34.454 Y2.922
G1 X2.922 Y34.454 E1.12113
G1 X2.922 Y33.909
G1 X33.909 Y2.922 E1.10174
G1 X33.363 Y2.922
G1 X2.922 Y33.363 E1.08235
G1 X2.922 Y32.818
G1 X32.818 Y2.922 E1.06296
G1 X32.273 Y2.922
G1 X2.922 Y32.273 E1.04357
G1 X2.922 Y31.727
G1 X31.727 Y2.922 E1.02417
G1 X31.182 Y2.922
G1 X2.922 Y31.182 E1.00478
G1 X2.922 Y30.636
G1 X30.636 Y2.922 E.98539
G1 X30.091 Y2.922
G1 X2.922 Y30.091 E.966
G1 X2.922 Y29.546
G1 X29.546 Y2.922 E.94661
G1 X29 Y2.922
G1 X2.922 Y29 E.92721
G1 X2.922 Y28.455
G1 X28.455 Y2.922 E.90782
G1 X27.909 Y2.922
G1 X2.922 Y27.909 E.88843
G1 X2.922 Y27.364
G1 X27.364 Y2.922 E.86904
G1 X26.819 Y2.922
G1 X2.922 Y26.819 E.84965
G1 X2.922 Y26.273
G1 X26.273 Y2.922 E.83025
G1 X25.728 Y2.922
G1 X2.922 Y25.728 E.81086
G1 X2.922 Y25.182
G1 X25.182 Y2.922 E.79147
G1 X24.637 Y2.922
G1 X2.922 Y24.637 E.77208
G1 X2.922 Y24.092
G1 X24.092 Y2.922 E.75269
G1 X23.546 Y2.922
G1 X2.922 Y23.546 E.73329
G1 X2.922 Y23.001
G1 X23.001 Y2.922 E.7139
G1 X22.455 Y2.922
G1 X2.922 Y22.455 E.69451
G1 X2.922 Y21.91
G1 X21.91 Y2.922 E.67512
G1 X21.365 Y2.922
G1 X2.922 Y21.365 E.65573
G1 X2.922 Y20.819
G1 X20.819 Y2.922 E.63633
G1 X20.274 Y2.922
G1 X2.922 Y20.274 E.61694
G1 X2.922 Y19.728
G1 X19.728 Y2.922 E.59755
G1 X19.183 Y2.922
G1 X2.922 Y19.183 E.57816
G1 X2.922 Y18.638
G1 X18.638 Y2.922 E.55877
G1 X18.092 Y2.922
G1 X2.922 Y18.092 E.53937
G1 X2.922 Y17.547
G1 X17.547 Y2.922 E.51998
G1 X17.001 Y2.922
G1 X2.922 Y17.001 E.50059
G1 X2.922 Y16.456
G1 X16.456 Y2.922 E.4812
G1 X15.91 Y2.922
G1 X2.922 Y15.91 E.46181
G1 X2.922 Y15.365
G1 X15.365 Y2.922 E.44241
G1 X14.82 Y2.922
G1 X2.922 Y14.82 E.42302
G1 X2.922 Y14.274
G1 X14.274 Y2.922 E.40363
G1 X13.729 Y2.922
G1 X2.922 Y13.729 E.38424
G1 X2.922 Y13.183
G1 X13.183 Y2.922 E.36484
G1 X12.638 Y2.922
G1 X2.922 Y12.638 E.34545
G1 X2.922 Y12.093
G1 X12.093 Y2.922 E.32606
G1 X11.547 Y2.922
G1 X2.922 Y11.547 E.30667
G1 X2.922 Y11.002
G1 X11.002 Y2.922 E.28728
G1 X10.456 Y2.922
G1 X2.922 Y10.456 E.26788
G1 X2.922 Y9.911
G1 X9.911 Y2.922 E.24849
G1 X9.366 Y2.922
G1 X2.922 Y9.366 E.2291
G1 X2.922 Y8.82
G1 X8.82 Y2.922 E.20971
G1 X8.275 Y2.922
G1 X2.922 Y8.275 E.19032
G1 X2.922 Y7.729
G1 X7.729 Y2.922 E.17092
G1 X7.184 Y2.922
G1 X2.922 Y7.184 E.15153
G1 X2.922 Y6.639
G1 X6.639 Y2.922 E.13214
G1 X6.093 Y2.922
G1 X2.922 Y6.093 E.11275
G1 X2.922 Y5.548
G1 X5.548 Y2.922 E.09336
G1 X5.002 Y2.922
G1 X2.922 Y5.002 E.07396
G1 X2.922 Y4.457
G1 X4.457 Y2.922 E.05457
G1 X3.912 Y2.922
G1 X2.922 Y3.912 E.03518
G1 X2.922 Y3.366
G1 X3.366 Y2.922 E.01579
; close powerlost recovery
M1003 S0
; WIPE_START
G1 F9000
M204 S3000
G1 X2.922 Y3.366 E-.23863
G1 X2.922 Y3.912 E-.20725
G1 X3.507 Y3.327 E-.31411
; WIPE_END
G1 E-.04 F1800
M106 S0
M981 S0 P20000 ; close spaghetti detector
; FEATURE: Custom
; MACHINE_END_GCODE_START
; filament end gcode 

;===== date: 20231229 =====================
;turn off nozzle clog detect
G392 S0

M400 ; wait for buffer to clear
G92 E0 ; zero the extruder
G1 E-0.8 F1800 ; retract
G1 Z1.55 F900 ; lower z a little
G1 X0 Y90 F18000 ; move to safe pos
G1 X-13.0 F3000 ; move to safe pos

M1002 judge_flag timelapse_record_flag
M622 J1
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M991 S0 P-1 ;end timelapse at safe pos
M623


M140 S0 ; turn off bed
M106 S0 ; turn off fan
M106 P2 S0 ; turn off remote part cooling fan
M106 P3 S0 ; turn off chamber cooling fan

;G1 X27 F15000 ; wipe

; pull back filament to AMS
M620 S255
G1 X181 F12000
T255
G1 X0 F18000
G1 X-13.0 F3000
G1 X0 F18000 ; wipe
M621 S255

M104 S0 ; turn off hotend

M400 ; wait all motion done
M17 S
M17 Z0.4 ; lower z motor current to reduce impact if there is something in the bottom

    G1 Z101.05 F600
    G1 Z99.05

M400 P100
M17 R ; restore z current

G90
G1 X-13 Y180 F3600

G91
G1 Z-1 F600
G90
M83

M220 S100  ; Reset feedrate magnitude
M201.2 K1.0 ; Reset acc magnitude
M73.2   R1.0 ;Reset left time magnitude
M1002 set_gcode_claim_speed_level : 0

;=====printer finish  sound=========
M17
M400 S1
M1006 S1
M1006 A0 B20 L100 C37 D20 M100 E42 F20 N100
M1006 A0 B10 L100 C44 D10 M100 E44 F10 N100
M1006 A0 B10 L100 C46 D10 M100 E46 F10 N100
M1006 A44 B20 L100 C39 D20 M100 E48 F20 N100
M1006 A0 B10 L100 C44 D10 M100 E44 F10 N100
M1006 A0 B10 L100 C0 D10 M100 E0 F10 N100
M1006 A0 B10 L100 C39 D10 M100 E39 F10 N100
M1006 A0 B10 L100 C0 D10 M100 E0 F10 N100
M1006 A0 B10 L100 C44 D10 M100 E44 F10 N100
M1006 A0 B10 L100 C0 D10 M100 E0 F10 N100
M1006 A0 B10 L100 C39 D10 M100 E39 F10 N100
M1006 A0 B10 L100 C0 D10 M100 E0 F10 N100
M1006 A44 B10 L100 C0 D10 M100 E48 F10 N100
M1006 A0 B10 L100 C0 D10 M100 E0 F10 N100
M1006 A44 B20 L100 C41 D20 M100 E49 F20 N100
M1006 A0 B20 L100 C0 D20 M100 E0 F20 N100
M1006 A0 B20 L100 C37 D20 M100 E37 F20 N100
M1006 W
;=====printer finish  sound=========
M400 S1
M18 X Y Z
M73 P100 R0
; EXECUTABLE_BLOCK_END


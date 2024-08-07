model LoadSubsi_model_VR

import "Subsi_Simple2.gaml"

species unity_linker parent: abstract_unity_linker {
	string player_species <- string(unity_player);
	int max_num_players  <- -1;
	list<point> init_locations <- define_init_locations();

	list<point> define_init_locations {
		return [{50.0,50.0,0.0}];
	}

	unity_property up_geom;
	GPlayLand myland;
	
	init {
		myland<-GPlayLand[length(unity_player)];
		do define_properties;
		do add_background_geometries(GPlayLand,up_geom);
	}
	
	//reflex activated only when there is at least one player and every 100 cycles
	reflex send_message when: every(1 #cycle) and not empty(unity_player){
		
		//send a message to all players; the message should be a map (key: name of the attribute; value: value of this attribute)
		//the name of the attribute should be the same as the variable in the serialized class in Unity (c# script) 
		write "Send message: "  + cycle;
		do send_message players: unity_player as list mes: ["cycle":: cycle];
	}
	
	//action that will be called by the Unity player to send a message to the GAMA simulation
	action receive_message (string id, string mes) {
		write "Player " + id + " send the message: " + mes;
	}
	
	action define_properties {
		unity_aspect geom_aspect <- geometry_aspect(10.0, #gray, precision);
		up_geom <- geometry_properties("block", "selectable", geom_aspect, #ray_interactable, false);
		unity_properties << up_geom;
	}
	
}

species unity_player parent: abstract_unity_player{
	float player_size <- 1.0;
	rgb color <- #red;
	float cone_distance <- 10.0 * player_size;
	float cone_amplitude <- 90.0;
	float player_rotation <- 90.0;
	bool to_display <- true;
	float z_offset <- 2.0;
	aspect default {
		if to_display {
			if selected {
				 draw circle(player_size) at: location + {0, 0, z_offset} color: rgb(#blue, 0.5);
			}
			draw circle(player_size/2.0) at: location + {0, 0, z_offset} color: color ;
			draw player_perception_cone() color: rgb(color, 0.5);
		}
	}
}

experiment vr_xp parent:main autorun: false type: unity {
	float minimum_cycle_duration <- 0.1;
	string unity_linker_species <- string(unity_linker);
	list<string> displays_to_hide <- ["Digital Elevation Model","W1","Subsidence - Groundwater extracted"];
	float t_ref;

	action create_player(string id) {
		ask unity_linker {
			do create_player(id);
		}
	}

	action remove_player(string id_input) {
		if (not empty(unity_player)) {
			ask first(unity_player where (each.name = id_input)) {
				do die;
			}
		}
	}

	output {
		 display "Subsidence - Groundwater extracted_VR" parent:"Subsidence - Groundwater extracted"{
			 species unity_player;
			 event #mouse_down{
				 float t <- gama.machine_time;
				 if (t - t_ref) > 500 {
					 ask unity_linker {
						 move_player_event <- true;
					 }
					 t_ref <- t;
				 }
			 }
		 }
	}
}

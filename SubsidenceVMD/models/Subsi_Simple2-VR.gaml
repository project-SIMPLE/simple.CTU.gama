model LoadSubsi_model_VR

import "Subsi_Simple2mini.gaml"

global {
//color of the different players
	list<rgb> color_players <- [#red, #yellow, #green, #violet];

	init {
	}

}

species unity_linker parent: abstract_unity_linker {
	string player_species <- string(unity_player);
	float min_player_position_update_duration <- 0.01;
	list<point> init_locations <- define_init_locations();

	//number of players in the game
	int number_players <- 1 max: 4;

	//max number of players that can play the game
	int max_num_players <- number_players;

	//in this model, information about other player will be automatically sent to the Player at every step, so we set do_info_world to true
	bool do_send_world <- false;

	//min number of players to start the simulation
	int min_num_players <- number_players;
	list<point> define_init_locations {
		return GPlayLand collect each.location; //[{50.0,50.0,0.0}];
	}

	unity_property up_geom;

	init {
		do define_properties;
		//		do add_background_geometries(GPlayLand,up_geom);
	}

	//reflex activated only when there is at least one player and every 100 cycles
	reflex send_message when: every(1 #cycle) and not empty(unity_player) {

	//send a message to all players; the message should be a map (key: name of the attribute; value: value of this attribute)
	//the name of the attribute should be the same as the variable in the serialized class in Unity (c# script) 
	//		write "Send message: "  + cycle;
		do send_message players: unity_player as list mes: ["cycle"::cycle];
	}

	//action that will be called by the Unity player to send a message to the GAMA simulation
	action receive_message (string id, string mes) {
		write "Player " + id + " send the message: " + mes;
	}
	
	
	action construction_message (string idP,string id,int iid, int x, int y, int z) {
			write "" + idP+ " |" + id + " |" + iid + " " + x + " " + y + " " + z;
//		x <- (100 - x) * 1.6 + 10;
//		y <- y * 1.8 + 100;
		x<-x*100+first(unity_player where (each.name=idP)).myland.location.x;
		y<-y*100+first(unity_player where (each.name=idP)).myland.location.y;
		if (id contains "Coconut" or id contains "Banana" or id contains "Rice") {
			tree t <- first(tree where (each._id = iid));
			if (t != nil) {
				ask t {
					location <- {x, y};
				}

			} else {
				create tree {
					_id <- iid;
					location <- {x, y};
				}

			}

		}

		if (id contains "SpawnEnemy") {
			warning t <- first(warning where (each._id = iid));
			if (t != nil) {
				ask t {
					location <- {x, y};
				}

			} else {
				create warning {
					_id <- iid;
					location <- {x, y};
				}

			}

		}

		if (id contains "SaltyWater") {
			enemy t <- first(enemy where (each._id = iid));
			if (t != nil) {
				ask t {
					location <- {x, y};
				}

			} else {
				create enemy {
					_id <- iid;
					location <- {x, y};
				}

			}

		}

		if (id contains "WaterPump") {
			Pumper t <- first(Pumper where (each._id = iid));
			if (t != nil) {
				ask t {
					location <- {x, y};
				}

			} else {
				create Pumper {
					_id <- iid;
					location <- {x, y};
				}

			}

		}

		if (id contains "Gate") {
			SluiceGate t <- first(SluiceGate where (each._id = iid));
			if (t != nil) {
				ask t {
					location <- {x, y};
				}

			} else {
				create SluiceGate {
					_id <- iid;
					location <- {x, y};
				}

			}

		}

	}

	action define_properties {
		unity_aspect geom_aspect <- geometry_aspect(10.0, #gray, precision);
		up_geom <- geometry_properties("block", "selectable", geom_aspect, #ray_interactable, false);
		unity_properties << up_geom;
	}

}

species unity_player parent: abstract_unity_player {
//size of the player in GAMA
	float player_size <- 1500.0;
	GPlayLand myland;
	//color of the player in GAMA
	rgb color <- color_players[int(self)];

	//vision cone distance in GAMA
	float cone_distance <- 10.0 * player_size;

	//vision cone amplitude in GAMA
	float cone_amplitude <- 90.0;

	//rotation to apply from the heading of Unity to GAMA
	float player_rotation <- 90.0;

	init {
		myland <- GPlayLand[length(unity_player) - 1];
		myland.active <- true;
	}
	//display the player
	bool to_display <- true;
	float z_offset <- 2.0;

	reflex ss {
		location <- (location*100) + myland.location;
	}

	aspect default {
		if to_display {
			if selected {
				draw circle(player_size) at: location + {0, 0, z_offset} color: rgb(#blue, 0.5);
			}

			draw cube(player_size / 2.0) at: location + {0, 0, z_offset} color: color;
			draw player_perception_cone() color: rgb(color, 0.5);
		}

	}

}

experiment vr_xp autorun: false type: unity {
	float minimum_cycle_duration <- 0.05;
	string unity_linker_species <- string(unity_linker);
	list<string> displays_to_hide <- ["Digital Elevation Model", "W1", "Subsidence - Groundwater extracted"];
	float t_ref;

	action create_player (string id) {
		ask unity_linker {
			do create_player(id);
		}

	}

	action remove_player (string id_input) {
		if (not empty(unity_player)) {
			ask first(unity_player where (each.name = id_input)) {
				do die;
			}

		}

	}

	output {
		display "Subsidence - Groundwater extracted1" type: 3d {
			mesh DEM_subsidence scale: 1000 color: scale([#darkblue::-7.5, #blue::-5, #lightblue::-2.5, #white::0, #green::1]) no_data: -9999.0 smooth: false;
			species GPlayLand position: {0, 0, 0.01};
			species Pumper;
			species Lake;
			species SluiceGate;
		}

		display "P1" background: #black type: 3d axes: false {
			camera 'default' location: {329234.207,59182.1128,10335.0201} target: {329234.207,59181.9324,0.0};
			species GPlayLand aspect: land2d;
			species unity_player;
			species tree;
			species SluiceGate;
			species Lake;
			species warning;
			species Pumper;
			species enemy; 
			//			 event #mouse_down{
			//				 float t <- gama.machine_time;
			//				 if (t - t_ref) > 500 {
			//					 ask unity_linker {
			//						 move_player_event <- true;
			//					 }
			//					 t_ref <- t;
			//				 }
			//			 }
		}

	}

}

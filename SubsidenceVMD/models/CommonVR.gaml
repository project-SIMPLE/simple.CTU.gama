/**
* Name: CommonVR
* Based on the internal empty template. 
* Author: patricktaillandier
* Tags: 
*/


model CommonVR


import "Subsi_Simple2mini1.gaml"

global {
//color of the different players
	list<rgb> color_players <- [#yellow, #green, #violet, #red];

 
	init {
	}

	action readVR {
		ask GPlayLand where (each.subside) {
			unity_player u <- first(unity_player where (each.myland = self));
			//			write "" + u;
//			ask unity_linker {
//				do send_message players: u as list mes: ["subside"::true];
//			}

		}

	}

}

species unity_linker parent: abstract_unity_linker {
//name of the species used to represent a Unity player
	string player_species <- string(unity_player);
	float min_player_position_update_duration <- 0.1;

	//in this model, information about other player will be automatically sent to the Player at every step, so we set do_info_world to true
	bool do_send_world <- true;

	//number of players in the game
	int number_players <- 1 max: 1;

	//max number of players that can play the game
	int max_num_players <- number_players;

	//min number of players to start the simulation
	int min_num_players <- 99999;

	//initial location of the player
	list<point> init_locations <- define_init_locations();
	list<point> define_init_locations {
		return GPlayLand collect each.location; //[{50.0,50.0,0.0}];
	}

	//	unity_property up_geom;
	init {
		do define_properties;
		//		do add_background_geometries(GPlayLand,up_geom);
	}
	
	reflex when: cycle = 0 {
		do send_message(unity_player as list, ["readyToStart"::""]);
	}

	//reflex activated only when there is at least one player and every 100 cycles
	//	reflex send_message when: every(1 #cycle) and not empty(unity_player) {
	//
	//	//send a message to all players; the message should be a map (key: name of the attribute; value: value of this attribute)
	//	//the name of the attribute should be the same as the variable in the serialized class in Unity (c# script) 
	//	//		write "Send message: "  + cycle;
	//		do send_message players: unity_player as list mes: ["cycle"::cycle];
	//	}

	//action that will be called by the Unity player to send a message to the GAMA simulation
	action receive_message (string id, string mes) {
	//		write "Player " + id + " send the message: " + mes;
	}

	action construction_message (string idP, string id, int iid, int x, int y, int z) {
			
//			write "" + idP;
//				write "" + idP+ " |" + id + " |" + iid + " |" + x + " |" + y + " |" + z;
	//		x <- (100 - x) * 1.6 + 10;
	//		y <- y * 1.8 + 100;
		unity_player Pl <- first(unity_player where (each.name = idP));
		float x2 <- x * 100 + Pl.myland.location.x;
		float y2 <- y * 100 + Pl.myland.location.y;
		string idds <- string(iid);
		if (id contains "Coconut" or id contains "Banana" or id contains "Orange") {
			tree t <- first(tree where (each._id = idds));
			if (t != nil) {
				ask t {
					location <- {x2, y2};
				}

			} else {
				create tree {
					_id <- idds;
					playerLand_ID <- Pl.myland.playerLand_ID;
					location <- {x2, y2};
				}

			}

		}

		if (id contains "SpawnEnemy") {
			warning t <- first(warning where (each._id = idds));
			if (t != nil) {
				ask t {
					location <- {x2, y2};
				}

			} else {
				create warning {
					_id <- idds;
					playerLand_ID <- Pl.myland.playerLand_ID;
					location <- {x2, y2};
				}

			}

		}

		if (id contains "SaltyWater") {		
		
			enemy t <- first(enemy where (each._id = idds));
			if (t != nil) {
				ask t {
					location <- {x2, y2};
				}

			} else {
				create enemy {
					_id <- idds;
					playerLand_ID <- Pl.myland.playerLand_ID;
					location <- {x2, y2};
				}

			}

		}

		if (id contains "WaterPump") {
			Pumper t <- first(Pumper where (each._id = idds));
			if (t != nil) {
				ask t {
					location <- {x2, y2};
				}

			} else {
				create Pumper {
					_id <- idds;
					playerLand_ID <- Pl.myland.playerLand_ID;
					Pl.myland.playerPumper << self;
					location <- {x2, y2};
				}

			}

		}

		if (id contains "Gate") {
			SluiceGate t <- first(SluiceGate where (each._id = idds));
			if (t != nil) {
				ask t {
					location <- {x2, y2};
				}

			} else {
				create SluiceGate {
					playerLand_ID <- Pl.myland.playerLand_ID;
					_id <- idds;
					location <- {x2, y2};
				}

			}

		}

		if (id contains "Lake") {
			Lake t <- first(Lake where (each._id = idds));
			if (t != nil) {
				ask t {
					location <- {x2, y2};
				}

			} else {
				create Lake {
					playerLand_ID <- Pl.myland.playerLand_ID;
					_id <- idds;
					location <- {x2, y2};
				}

			}

		}

	}

	action DeletePlayer (string idP, string id, int iid) {
	//			write "" + id  ; 
		string idds <- string(iid);
		
		if (id contains "Coconut" or id contains "Banana" or id contains "Orange") {
			tree t <- first(tree where (each._id = idds));
			if (t != nil) {
				ask t {
					do die;
				}

			}

		}

		if (id contains "SpawnEnemy") {
			ask warning {
				do die;
			}

		}

		if (id contains "SaltyWater(Clone)") {
			enemy t <- first(enemy where (each._id = idds));
			if (t != nil) {
				ask t {
					do die;
				}

			}

		}

	}

	action define_properties {
		unity_aspect geom_aspect <- geometry_aspect(10.0, #gray, precision);
		//		up_geom <- geometry_properties("block", "selectable", geom_aspect, #ray_interactable, false);
		//		unity_properties << up_geom;
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

	//display the player
	bool to_display <- true;

	init {
		myland <- GPlayLand[length(unity_player) - 1];
		write myland;
		myland.cntDem <- 0;
		myland.subside <- false;
		myland.active <- true;
		do Restart(myland.playerLand_ID);
	}

	action Restart (int id) {
		ask tree where (each.playerLand_ID = id) {
			do die;
		}

		ask warning where (each.playerLand_ID = id) {
			do die;
		}

		ask enemy where (each.playerLand_ID = id) {
			do die;
		}

		ask Lake where (each.playerLand_ID = id) {
			do die;
		}

		ask Pumper where (each.playerLand_ID = id) {
			do die;
		}

		ask SluiceGate where (each.playerLand_ID = id) {
			do die;
		}

	}

	float z_offset <- 2.0;

	reflex ss {
		heading <- -heading;
		location <- (location * 100) + myland.location;
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

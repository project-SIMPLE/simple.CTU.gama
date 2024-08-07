/**
* Name: UserInteraction
* Show how to define a simple multi-player game in Unity. It works with the Scene "Assets/Scenes/Code Example/Multi-player" from the Unity Template.
* In this model each player can observe the other players (use of an avatar for each player). They can interact with a central pylon to change its color to their color.
* Author: Patrick Taillandier
* Tags: Unity, Multi Player
*/


model MultiPlayerGame

global {
	//unity properties that will be used for the players
	unity_property up_ghost;
	unity_property up_lg;
	unity_property up_slime;
	unity_property up_turtle;
	
	//initial space where the players can appear at the beginning of the game
	
	//color of the different players
	list<rgb> color_players <- [#red, #yellow,#green, #violet];
	
	init {
	
	}

}
//Species that will make the link between GAMA and Unity. It has to inherit from the built-in species asbtract_unity_linker
species unity_linker parent: abstract_unity_linker {
	//name of the species used to represent a Unity player
	string player_species <- string(unity_player);
	
	float min_player_position_update_duration <- 0.01;

	//in this model, information about other player will be automatically sent to the Player at every step, so we set do_info_world to true
	bool do_send_world <- false;
	
	//number of players in the game
	int number_players <- 1 max: 4;

	//max number of players that can play the game
	int max_num_players  <- number_players;

	//min number of players to start the simulation
	int min_num_players  <- number_players;
	
	//initial location of the player
	list<point> init_locations <- random_loc();
	
	init {
		//define the unity properties
		do define_properties;
		player_unity_properties <- [ up_lg,up_turtle, up_slime, up_ghost ];
		
	}
	
	//return for each player a random location inside the init_space
	list<point> random_loc {
		list<point> points;
		loop times: max_num_players {
			points << any_location_in(world);
		}
		return points;
		
	}	
	
	
	
	//action that defines the different unity properties
	action define_properties {
		
		//define a unity_aspect called ghost_aspect that will display in Unity a player with the Ghost prefab, with a scale of 2.0, no y-offset, 
		//a rotation coefficient of -1.0, a rotation offset of 90°, and we use the default precision. 
		unity_aspect ghost_aspect <- prefab_aspect("Prefabs/Visual Prefabs/Character/Ghost",2.0,0.0,-1.0,90.0,precision);
		//define the up_ghost unity property, with the name "ghost", no specific layer, a collider, and the agents location are not sent back to GAMA. 
		up_ghost <- geometry_properties("ghost","",ghost_aspect,#collider,false);
		// add the up_ghost unity_property to the list of unity_properties
		unity_properties << up_ghost; 
		
		//define a unity_aspect called slime_aspect that will display in Unity a player with the Slime prefab, with a scale of 2.0, no y-offset, 
		//a rotation coefficient of -1.0, a rotation offset of 90°, and we use the default precision. 
		unity_aspect slime_aspect <- prefab_aspect("Prefabs/Visual Prefabs/Character/Slime",2.0,0.0,-1.0,90.0,precision);
		//define the up_slime unity property, with the name "slime", no specific layer, a collider, and the agents location are not sent back to GAMA. 
		up_slime <- geometry_properties("slime","",slime_aspect,new_geometry_interaction(true, false,false,[]),false);
		// add the up_slime unity_property to the list of unity_properties
		unity_properties << up_slime; 
		
			//define a unity_aspect called lg_aspect that will display in Unity a player with the LittleGhost prefab, with a scale of 2.0, no y-offset, 
		//a rotation coefficient of -1.0, a rotation offset of 90°, and we use the default precision. 
		unity_aspect lg_aspect <- prefab_aspect("Prefabs/Visual Prefabs/Character/LittleGhost",2.0,0.0,-1.0,90.0,precision);
		//define the up_lg unity property, with the name "little_ghost", no specific layer, a collider, and the agents location are not sent back to GAMA. 
		up_lg <- geometry_properties("little_ghost","",lg_aspect,new_geometry_interaction(true, false,false,[]),false);
		// add the up_lg unity_property to the list of unity_properties
		unity_properties << up_lg; 
		
		//define a unity_aspect called turtle_aspect that will display in Unity a player with the TurtleShell prefab, with a scale of 2.0, no y-offset, 
		//a rotation coefficient of -1.0, a rotation offset of 90°, and we use the default precision. 
		unity_aspect turtle_aspect <- prefab_aspect("Prefabs/Visual Prefabs/Character/TurtleShell",2.0,0.0,-1.0,90.0,precision);
		//define the up_turtle unity property, with the name "turtle", no specific layer, a collider, and the agents location are not sent back to GAMA. 
		up_turtle <- geometry_properties("turtle","",turtle_aspect,new_geometry_interaction(true, false,false,[]),false);
		// add the up_turtle unity_property to the list of unity_properties
		unity_properties << up_turtle; 
		
	
		
	}
	
	
	//action that will be called from unity with two argument: the id of the pylon selected, the player that change the color of the pylon
	action change_color(string id, string player) {
		//player that triggers the action
		unity_player the_player <-  unity_player first_with (each.name = player) ;
		
	}
	
}


//species used to represent an unity player, with the default attributes. It has to inherit from the built-in species asbtract_unity_player
species unity_player parent: abstract_unity_player {
	//size of the player in GAMA
	float player_size <- 1.0;

	//color of the player in GAMA
	rgb color <- color_players[int(self)] ;
	
	//vision cone distance in GAMA
	float cone_distance <- 10.0 * player_size;
	
	//vision cone amplitude in GAMA
	float cone_amplitude <- 90.0;

	//rotation to apply from the heading of Unity to GAMA
	float player_rotation <- 90.0;
	
	//display the player
	bool to_display <- true;
	
	
	//default aspect to display the player as a circle with its cone of vision
	aspect default {
		if to_display {
			if selected {
				 draw circle(player_size) at: location + {0, 0, 4.9} color: rgb(#blue, 0.5);
			}
			draw circle(player_size/2.0) at: location + {0, 0, 5} color: color ;
			draw player_perception_cone() color: rgb(color, 0.5);
		}
	}
}




experiment main type: gui {
	output {
		display map type:3d{
//			graphics "world" {
//				draw world color: #lightgray;
//			}
		}
	} 
}

//default Unity (VR) experiment that inherit from the SimpleMessage experiment
//The unity type allows to create at the initialization one unity_linker agent
experiment vr_xp parent:main autorun: false type: unity {
	//minimal time between two simulation step
	float minimum_cycle_duration <- 0.05;

	//name of the species used for the unity_linker
	string unity_linker_species <- string(unity_linker);
	
	//allow to hide the "map" display and to only display the displayVR display 
	list<string> displays_to_hide <- ["map"];
	


	//action called by the middleware when a player connects to the simulation
	action create_player(string id) {
		write sample(id);
		ask unity_linker {
			do create_player(id);
			
		}
	}

	//action called by the middleware when a plyer is remove from the simulation
	action remove_player(string id_input) {
		if (not empty(unity_player)) {
			ask first(unity_player where (each.name = id_input)) {
				do die;
			}
		}
	}
	
	//variable used to avoid to move too fast the player agent
	float t_ref;

		 
	output { 
		//In addition to the layers in the map display, display the unity_player and let the possibility to the user to move players by clicking on it.
		display displayVR parent: map  {
			species unity_player;
			event #mouse_down  {
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
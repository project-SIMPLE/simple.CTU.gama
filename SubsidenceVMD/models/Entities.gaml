model Entities
 
 
import "Global.gaml" 
 
grid cell file: ground_water_level_grid {
	list<float> value_players;
	list<cell> neighbors2;
	int num_neighbors;	
	int num_neighbors2;
	
	init {
		neighbors2 <- self neighbors_at 2 - neighbors;
		num_neighbors <- length(neighbors);
		num_neighbors2 <- length(neighbors2);
		
		loop times: 4 {
			value_players << grid_value;
		}
	}
	
	float remove_water(int playerId, float quantity) {
		float temp <- min(quantity, value_players[playerId]);
		value_players[playerId] <- value_players[playerId] - temp;
		return temp;
	}  
	reflex refill_water {
		loop i from: 0 to: 3 {
			value_players[i] <- min(grid_value,grid_value * refill_rate +  value_players[i]);
		}
	}
}


  
  
 
species Pumper  {
	int playerLand_ID;
	string _id;
	cell my_cell;
	float fresh_water_generation_rate;
	aspect default {
		draw cube(1000) texture: ipumper;
	}

	reflex extract_water {
		float sum_extracted <- my_cell.remove_water(playerLand_ID,  pump_per_step * water_pump_distance[0]);
		ask my_cell.neighbors {
			sum_extracted <- sum_extracted + remove_water(myself.playerLand_ID,  pump_per_step * water_pump_distance[1] / num_neighbors);
		}
		ask my_cell.neighbors2 {
			sum_extracted <- sum_extracted + remove_water(myself.playerLand_ID,  pump_per_step * water_pump_distance[2] / num_neighbors2);
		}
		fresh_water_generation_rate <- sum_extracted/pump_per_step * max_fresh_water_generation_rate;
	}
}


species GPlayLand {
	int playerLand_ID;
	list<Pumper> pumpers;
	list<tree> trees;
	list<freshwater> fresh_waters;
	list<enemy> enemies;
	list<warning> warnings;
	
	bool subside <- false; 
	int cntDem <- 0;
	int numberPumper <- 1;
	int numberLake <- 1;
	int numberSluice <- 1;
	float volumePump <- 0.0;
	//has the player finished ? 
	bool finished <- false;
	team my_team;
	int remaining_time <- 18000;
	int current_score;

	int rot <- 0;
	
	aspect default {
		draw world.shape color: my_team.color;
	}

}

species team {
	int score <- 0;
	rgb color;
	int generation <- 1;
}

 
species tree {
	string _id;
	int playerLand_ID;
	int iid;
	int isz <- 2000;

	aspect default {
	//		draw itree size: 300;
		draw itrees[iid] size: isz;
	}

}

species warning {
	string _id;
	int playerLand_ID;
	int count <- 0;


	aspect default {
		draw iwarning border: #red size: 1000;
	}

}


species enemy  {
	string _id;
	int playerLand_ID;
	point target;
	bool spotted <- false;


	aspect default {
		draw circle(300) color: #red;
	}

}

species freshwater {
	string _id;
	int playerLand_ID;
	enemy target;

	
	aspect default {
		draw circle(300) color: #blue;
	}

}
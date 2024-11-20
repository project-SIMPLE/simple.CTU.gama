model Entities

import "Global.gaml"
grid cell file: ground_water_level_grid {
	list<float> water_level;
	list<cell> neighbors2;
	int num_neighbors;
	int num_neighbors2;

	init {
		neighbors2 <- self neighbors_at 2 - neighbors;
		num_neighbors <- length(neighbors);
		num_neighbors2 <- length(neighbors2);
		loop times: 4 {
			water_level << grid_value;
		}

	}

	float subsidence (int player_land_id) {
		return grid_value - water_level[player_land_id];
	}

	float remove_water (int playerId, float quantity) {
		float temp <- min(quantity, water_level[playerId]);
		water_level[playerId] <- water_level[playerId] - temp;
		return temp;
	}

	reflex refill_water {
		loop i from: 0 to: 3 {
			water_level[i] <- min(grid_value, grid_value * refill_rate + water_level[i]);
		}

	}

}

species Pumper {
	int playerLand_ID;
	string _id;
	cell my_cell;
	float fresh_water_generation_rate;

	aspect default {
		draw cube(8000) color: #magenta; //texture: ipumper;
	}

	reflex extract_water {
		float sum_extracted <- my_cell.remove_water(playerLand_ID, pump_per_step * water_pump_distance[0]);
		ask my_cell.neighbors {
			sum_extracted <- sum_extracted + remove_water(myself.playerLand_ID, pump_per_step * water_pump_distance[1] / num_neighbors);
		}

		ask my_cell.neighbors2 {
			sum_extracted <- sum_extracted + remove_water(myself.playerLand_ID, pump_per_step * water_pump_distance[2] / num_neighbors2);
		}

		fresh_water_generation_rate <- sum_extracted = 0 ? min_fresh_water_generation_time : ((pump_per_step / sum_extracted) * reference_fresh_water_generation_time);
	}

}

species GPlayLand {
	int playerLand_ID;
	map<string, Pumper> pumpers;
	map<string, tree> trees;
	int deadtrees <- 0;
	map<string, freshwater> fresh_waters;
	map<string, enemy> enemies;
	map<string, enemy_spawner> enemy_spawners;
	bool subside <- false;
	int cntDem <- 0;
	int numberPumper <- 1;
	int numberLake <- 1;
	int numberSluice <- 1;
	float volumePump <- 0.0;
	//has the player finished ? 
	bool started <- false;
	bool finished <- false;
	team my_team;
	int remaining_time <- 18000;
	int current_score;
	int rot <- 0;
	int cntTime;

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
	int isz <- 30000;

	aspect default {
	//		draw itree size: 300;
		draw itrees[iid] size: isz;
		//draw circle(isz) color: #magenta;
	}

}

species enemy_spawner {
	string _id;
	int playerLand_ID;
	list<cell> my_cells;
	float subsidence_area;
	float enemy_generation_rate <- 1.0;
	rgb color <- rnd_color(255);

	reflex update_enemy_generation_rate {
		subsidence_area <- my_cells mean_of (each.subsidence(playerLand_ID));
		enemy_generation_rate <- reference_fresh_water_generation_time * (0.5 + subsidence_area);
	}

	aspect default {
		if (enemy_generation_rate > enemy_generation_rate_visibility_threshold) {
			draw iwarning border: #red size: 30 * enemy_generation_rate;
		}

	}

}

species enemy {
	string _id;
	int playerLand_ID;

	aspect default {
		if self overlaps world {
			draw circle(3000) color: #red;
		}

	}

}

species freshwater {
	string _id;
	int playerLand_ID;

	aspect default {
		if self overlaps world {
			draw circle(3000) color: #lightgreen;
		}

	}

}
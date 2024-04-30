model AnalystMap

global {
	geometry shape <- square(200);
	image_file itree <- image_file("../includes/tree.png");
	image_file ipumper <- image_file("../includes/pumper.png");
	image_file igate <- image_file("../includes/gate.png");
	image_file ilake <- image_file("../includes/lake.png");
	image_file iwarning <- image_file("../includes/warn.png");

	init {
		create ground {
			rot <- 0;
			location <- a[0].location;
		}

		create ground {
			rot <- 1;
			location <- a[1].location;
		}

		create ground {
			rot <- 2;
			active <- true;
			location <- a[3].location;
		}

		create ground {
			rot <- 3;
			location <- a[2].location;
		}

		//		create tree number: 3;
		//		create enemy number: 3;
		//		create pumper number: 3;
		//		create lake number: 3;
		//		create gate number: 3;
		//		create warning number: 3;
	}

	action DeletePlayer (string id) {
	//		write "" + id + " " + x + " " + y + " " + z; 
		if (id contains "Coconut" or id contains "Banana" or id contains "Rice") {
			tree t <- first(tree where (each._id = id));
			if (t != nil) {
				ask t {
					do die;
				}

			}

		}

		if (id contains "SpawnEnemy") {
			warning t <- first(warning where (each._id = id));
			if (t != nil) {
				ask t {
					do die;
				}

			}

		}

		if (id contains "SaltyWater(Clone)") {
			enemy t <- first(enemy where (each._id = id));
			if (t != nil) {
				ask t {
					do die;
				}

			}

		}

	}

	action Restart (string id) {
		ask tree {
			do die;
		}

		ask warning {
			do die;
		}

		ask enemy {
			do die;
		}

		ask pumper {
			do die;
		}

		ask gate {
			do die;
		}

	}

	action move_player_external (string id, int x, int y, int z) {
	//		write "" + id + " " + x + " " + y + " " + z;
		x <- (100 - x) * 1.6 + 10;
		y <- y * 1.8 + 100;
		if (id contains "Coconut" or id contains "Banana" or id contains "Rice") {
			tree t <- first(tree where (each._id = id));
			if (t != nil) {
				ask t {
					location <- {x, y};
				}

			} else {
				create tree {
					_id <- id;
					location <- {x, y};
				}

			}

		}

		if (id contains "SpawnEnemy") {
			warning t <- first(warning where (each._id = id));
			if (t != nil) {
				ask t {
					location <- {x, y};
				}

			} else {
				create warning {
					_id <- id;
					location <- {x, y};
				}

			}

		}

		if (id contains "SaltyWater(Clone)") {
			enemy t <- first(enemy where (each._id = id));
			if (t != nil) {
				ask t {
					location <- {x, y};
				}

			} else {
				create enemy {
					_id <- id;
					location <- {x, y};
				}

			}

		}

		if (id contains "WaterPump") {
			pumper t <- first(pumper where (each._id = id));
			if (t != nil) {
				ask t {
					location <- {x, y};
				}

			} else {
				create pumper {
					_id <- id;
					location <- {x, y};
				}

			}

		}

		if (id contains "Gate") {
			gate t <- first(gate where (each._id = id));
			if (t != nil) {
				ask t {
					location <- {x, y};
				}

			} else {
				create gate {
					_id <- id;
					location <- {x, y};
				}

			}

		}

	}

}

grid a width: 2 height: 2 {
}

species enemy {
	string _id;

	aspect default {
		draw circle(1) color: #red;
	}

}

species tree {
	string _id;

	aspect default {
		draw itree size: 5;
	}

}

species warning {
	string _id;

	aspect default {
		draw iwarning border: #red size: 5;
	}

}

species pumper {
	string _id;

	aspect default {
		draw ipumper border: #red size: 5;
	}

}

species lake {
	string _id;

	aspect default {
		draw ilake border: #red size: 5;
	}

}

species gate {
	string _id;

	aspect default {
		draw igate border: #red size: 5;
	}

}

species ground {
	int rot <- 0;
	bool active <- false;
	geometry shape <- rotated_by((obj_file("../includes/SM_base2.obj") as geometry), -90::{1, 0, 0});

	aspect default {
		draw shape size: 102 color: active ? #green : #grey rotate: 90 * rot::{0, 0, 1};
	}

}

experiment Display type: gui autorun: true {
	float minimum_cycle_duration <- 0.15;
	output synchronized: true {
		layout #split tabs: false consoles: false editors: false;
		display complex background: #black type: 3d axes: false {
			light #ambient intensity: 100;
			species ground position: {0, 0, -0.01};
			species tree;
			species gate;
			species lake;
			species warning;
			species pumper;
			species enemy;
		}

	}

}

model LoadSubsi


global {

}

species enemy skills: [moving] {
	string _id;
	int playerLand_ID;
	point target;

	reflex move {
	//we use the return_path facet to return the path followed
		do goto target: target on: road_network recompute_path: false return_path: false speed: 10.0;
		if (location = target) {
			do die;
		}

	}

	aspect default {
		draw circle(300) color: #red;
	}

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

	//	reflex ss {
	//		count <- count + 1;
	//		if (count > 100) {
	//			do die;
	//		}
	//
	//	}
	aspect default {
		draw iwarning border: #red size: 1000;
	}

}

species Pumper parent: DraggedAgent {
	int playerLand_ID;
	string _id;
	string aquifer; // 'qh', 'qp3'
	geometry shape <- square(1000);

	aspect default {
		draw cube(1000) texture: ipumper;
		//		draw shape color:#red;
		//		draw circle(1000) color: #pink;
	}

	reflex update_aqifer { //aquifer qh have no more water 
	//		if (groundwater1_qh[geometry(self).location] > 0) {
	//			aquifer <- 'qh';
	//		} else {
	//			aquifer <- 'qp3';
	//		}

	}

}

species Lake {
	int playerLand_ID;
	string _id;

	aspect default {
		draw ilake border: #red size: 1000;

		//		draw rectangle(1000, 3000) color: #blue border: #black;
	}

}

species SluiceGate {
	int playerLand_ID;
	string _id;

	aspect default {
	//		draw circle(2000) color: #gray;
		draw igate border: #red size: 1000;
	}

}

species route {
}

species river {

	aspect default {
		draw shape + 100 color: #blue;
	}

}

species GPlayLand {
	int playerLand_ID;
	list<Pumper> playerPumper;
	list<Lake> playerLake;
	list<SluiceGate> playerSluicegate;
	//exchange construction. 
	list<Pumper> VRPumper;
	list<Lake> VRLake;
	list<SluiceGate> VRSluice;
	bool subside <- false;
	int cntDem <- 0;
	int numberPumper <- 1;
	int numberLake <- 1;
	int numberSluice <- 1;
	float volumePump <- 0.0;

	aspect default {
	//		draw shape.contour + 1000 color: #red;
		draw iscene;
	}

	aspect full {
	//		draw shape.contour + 1000 color: #red;
		draw iscenefull;
	}

	reflex {
		volumePump <- numberPumper * pumVolumeHour;
	}

	int rot <- 0;
	bool active <- false;

	aspect land2d {
	//		draw sland at: location + {1000, 0, 0} size: 12000 color: active ? #green : #grey rotate: 90 * 2::{0, 0, 1};
		draw "Dead Trees:" + length(tree where !dead(each)) at: location + {1000, 0, 0} size: 10;
	}

}

species aez {

	aspect default {
		draw shape.contour + 500 color: #gray;
	}

}

experiment main type: gui {
	list<font>
	fonts <- [font("Helvetica", 48, #plain), font("Times", 30, #plain), font("Courier", 30, #plain), font("Arial", 24, #bold), font("Times", 30, #bold + #italic), font("Geneva", 30, #bold)];
	list<rgb> flood_color <- palette([#white, #blue]);
	list<rgb> depth_color <- palette([#grey, #black]);
	output {
		display "Subsidence - Groundwater extracted" type: 3d axes: false background: #black {
//			camera #from_above locked: true;
			event #mouse_down {
				ask simulation {
					do mouse_down;
				}

			}

			event #mouse_up {
				ask simulation {
					do mouse_up;
				}

			}

			event #mouse_move {
				ask simulation {
					do mouse_move;
				}

			}

			//			mesh SubsidenceCell scale: 5000 color: scale([#darkblue::-7.5, #blue::-5, #lightblue::-2.5, #white::0, #green::1]) no_data: -9999.0 smooth: true triangulation: true;
			species GPlayLand position: {0, 0, -0.01};
			//			species route;
			species Pumper;
			species Lake;
			species SluiceGate;
			species enemy;
			species tree;
			//			graphics information {
			//				draw "Scenario: " + currentScenario + " Flood- min:" + min(DEM_subsidence) + " - max:" + max(DEM_subsidence) at: {0, 0} wireframe: true width: 2 color: #black font: fonts[1];
			//			}

		}

//		display "Groundwater extractors" type: 3d axes: false {
//		//			species GPlayLand aspect: full position: {0, 0, -0.01};
//			species Pumper;
//			species Lake;
//			species SluiceGate;
//			species enemy;
//		}

	}

}

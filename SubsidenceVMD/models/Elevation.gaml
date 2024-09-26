model LoadSubsi

import "Mouse Event.gaml"
import "Entities.gaml"

global {
	int fsize <- 100;
	field SubsidenceCell_elevation <- field(fsize, fsize);
	field SubsidenceCell_gridvalue <- copy(SubsidenceCell_elevation);
	//	field AquiferQHCell_volume <- field(fsize,fsize);
	//	field AquiferQHCell_groundWaterDepth <- copy(AquiferQHCell_volume);
	//	field AquiferQP3Cell_volume <- field(fsize,fsize);
	//	field AquiferQP3Cell_groundWaterDepth <- copy(AquiferQP3Cell_volume);
	field subsidence2018 <- field(fsize, fsize);
	shape_file players0_shape_file <- shape_file("../includes/4players.shp");
	float pixelSize <- fsize * fsize; //  500*500/10000 ha  (ha)
	float total_waterused <- 0.0; //total water used 
	shape_file river_region0_shape_file <- shape_file("../includes/river_region.shp");
	geometry shape <- envelope(players0_shape_file);
	//	map<int, float> wu_cost; //(unit: m3/ha) <-[5::34,34::389,12::180,6::98,14::294,101::150];//waterused of GPlayLanduse types 
	// para of Pumper 
	float pumVolumeHour <- 5.0; //2,4 - 6 m3/h // alow <  10m3/day--> 10 * 30day*3months
	float pumHourperDay <- 6.0;
	float pumDayperMonth <- 30.0;
	float pumMonthperYear <- 6.0;
	//int totalNumberPumper <-1;
	float totalGroundVolumeUsed <- 0.0;
	map<string, float> rateSubsidence <- ['sluice'::0.1, 'qh'::1, 'qp3'::1.3, 'qp23'::1.5];

	//salt water quantity level
	float saltwaterQuantity <- 1.0;
	graph road_network;
	list<point> route_source <- [{14608.46364974312, 418.2869639501441}, {19463.75474771089, 333.1064177788794}, {7708.839458182105, 77.56478216056712}];
	point route_target <- {6175.589640471502, 30146.297395684524};
	//	list<point> source_enemy<-[{12904.852740244474,25972.450658208225},{12904.852740244474,25972.450658208225},{8475.46436587174,24609.561913607642}];
	geometry avai_space;

	init {
		create river from: river_region0_shape_file;
	}

	reflex mainReflex2 {
		do updateSubsidenceAquifer;
		diffuse var: phero on: SubsidenceCell_elevation proportion: 1;
	}

	action updateSubsidenceAquifer {
		totalGroundVolumeUsed <- 0.0;
		float tmpDepthLose <- 0.0;
		float totalLosdepth <- 0.0;
		loop player_temp over: GPlayLand {
			player_temp.volumePump <- player_temp.numberPumper * pumVolumeHour * pumHourperDay * pumDayperMonth * pumMonthperYear; // volum hour * hour*days*months m3	
			//			write "Pump volume of player " + player_temp + ":" + player_temp.volumePump;
			tmpDepthLose <- player_temp.volumePump / pixelSize; //m
			ask player_temp.playerPumper {
				Pumper tmpPumper <- self;
				loop s over: mysub {
					SubsidenceCell_elevation[geometry(s).location] <- SubsidenceCell_elevation[geometry(s).location] + 100; // rateSubsidence[tmpPumper.aquifer] * tmpDepthLose;

				}

			}

			totalGroundVolumeUsed <- totalGroundVolumeUsed + player_temp.volumePump / 1E6;
		}

	}

}

species enemy skills: [moving] {
	string _id;
	int playerLand_ID;
	point target;
	bool spotted<-false;
	reflex move {
	//we use the return_path facet to return the path followed
		do goto target: target on: road_network recompute_path: false return_path: false speed: 50.0;
		if (location distance_to target <10) {
			do die;
		}

	}

	aspect default {
		draw circle(300) color: #red;
	}

}

species freshwater skills: [moving] {
	string _id;
	int playerLand_ID;
	enemy target;

	reflex chose when: target = nil or dead(target) {
		target <- ((enemy at_distance 7000) where (!each.spotted)) closest_to self;
		if(target!=nil){
			target.spotted<-true;
		}else{
			do die;
		}
	}

	reflex move {
		 
			do goto target: target.location on: road_network recompute_path: true speed: 70.0;
			if (location distance_to target<10) {
				ask target{do die;}
				do die;
			}
 

	}

	aspect default {
		draw circle(300) color: #blue;
	}

}

species Pumper parent: DraggedAgent {
	list mysub;
	int playerLand_ID;
	string _id;
	string aquifer; // 'qh', 'qp3'
	geometry shape <- square(1000);
	int rndstart<-100+int(self)*50;
	aspect default {
		draw cube(1000) texture: ipumper;
		//		draw shape color:#red;
		//		draw circle(1000) color: #pink;
	}

	reflex product_fresh_water when: (cycle > 0) and (cycle mod rndstart = 0) {
		create freshwater {
			location <- myself.location;
//			target <- (enemy at_distance 100) closest_to self;
		}

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
//		draw shape texture:iscene;
	}

	aspect d2 {
	//		draw shape.contour + 1000 color: #red;
//	draw shape texture:iscene;
		draw iscene size:10000;
	}
	aspect full {
	//		draw shape.contour + 1000 color: #red;
		draw iscenefull;
	}

	reflex ss {
		volumePump <- numberPumper * pumVolumeHour;
	}

	int rot <- 0;
	bool active <- false;

	aspect land2d {
		draw shape;
		draw "Dead Trees:" + length(tree where !dead(each)) at: location + {1000, 0, 0} size: 10;
	}

}

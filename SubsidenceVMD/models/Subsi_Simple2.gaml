model LoadSubsi

global {
	shape_file aezone_MKD_region_simple_region0_shape_file <- shape_file("../includes/AEZ/aezone_MKD_region_simple_region.shp");
	shape_file MKD_WGS84_shape_file <- shape_file("../includes/AdminBound/MKD_WGS84.shp");
	string scenarioB <- "B1/B1_";
	string scenarioM <- "M1/M1_";
	string currentScenario;
	int _year <- 2018;
	grid_file dem_file <- grid_file("../includes/DEM/dem_500x500_extendbound.tif");
	
	grid_file volumeqh_file <- grid_file("../includes/groundwater/1_volume_qh_500.tif");
	grid_file volumeqp3_file <- grid_file("../includes/groundwater/2_volume_qp3_500.tif");
	grid_file volumeqp23_file <- grid_file("../includes/groundwater/3_volume_qp23_500.tif");
	//field diffB1_M1_file <- field(grid_file("../includes/Cum_subsidence/diff_B1_M1.tif"));
	shape_file players0_shape_file <- shape_file("../includes/4players.shp");
	field DEM <- copy(field(dem_file));
	file cell_file <- grid_file("../includes/ht2015_500x500_cutPQ.tif");
	float pixelSize <- 25.0;  //  500*500/10000 ha  (ha)
	float total_waterused <-0.0; //total water used 
	//list<farming_unit> active_cell <- cell_dat where (each.grid_value != 8.0);
	//	field flooding <- field(dem_file);
	shape_file river_region0_shape_file <- shape_file("../includes/river_region.shp");
	field subsidentField <- field(grid_file("../includes/Cum_subsidence/" + scenarioB + _year + ".tif"));
	field DEM_subsidence <- field(dem_file);
	field groundwater1 <- field(volumeqh_file);
	field groundwater2 <- field(volumeqp3_file);
	field groundwater3 <- field(volumeqp23_file);
	
	geometry shape <- envelope(volumeqp3_file);
	//defining parameters
	map<int,float> wu_cost;//(unit: m3/ha) <-[5::34,34::389,12::180,6::98,14::294,101::150];//waterused of GPlayLanduse types 
	float maxPumperVolume <- 10.0*30*3 ;  //2,4 - 6 m3/h // alow <  10m3/day--> 10 * 30day*3months
	int totalNumberPumper <-1;
	
	
	init {
		create aez from: aezone_MKD_region_simple_region0_shape_file;
		create GPlayLand from: players0_shape_file {
			create Pumper number:1{
				location <- any_location_in (myself.shape);
			}
			create Lake number:1{
				location <- any_location_in (myself.shape);
			}
			create SluiceGate number:1{
				location <- any_location_in (myself.shape);
			}			
		}
		create river from: river_region0_shape_file;
		do load_WU_data;	
		//do load_profile_adaptation;
		total_waterused <- calWater_unit();
	}
	reflex subsidence{
		do subsidence;
	}
	
	// load map landuse :: water demand
	action load_WU_data {
		matrix cb_matrix <- matrix(csv_file("../includes/water_need_landuse.csv", true));
		loop i from: 0 to: cb_matrix.rows - 1 {
			int lu <- int(cb_matrix[0, i]);
			wu_cost <+ (lu)::float(cb_matrix[2, i]); 
		} 
		write wu_cost;
	}
	// calculate total water unit of the data
	float calWater_unit{
		float totalWu<-0.0;
		ask LandCell {
			totalWu <- totalWu + wu_cost[landuse]*pixelSize /1E6; // million m3 ;
		}
		return totalWu;
	}
	//subsidence 
	action subsidence {		
		loop cell_temp over: LandCell{		
			// tam thoi gan luong nuoc bơm. Sẽ chỉnh lại lượng nwocs bơn tại vị trí của máy bơm lấy từ Game play
			cell_temp.waterExtracted<- wu_cost[cell_temp.landuse]*pixelSize;  //m3  /1E6; 
			
			cell_temp.loseDepth<-cell_temp.waterExtracted/pixelSize;
			cell_temp.loseDepth <-0.2; // for testing 
			
			if (DEM_subsidence[geometry(cell_temp).location] != -9999.0) {
				DEM_subsidence[geometry(cell_temp).location]<- (DEM_subsidence[geometry(cell_temp).location]-cell_temp.loseDepth);
			}
		}  		
	}
	

}
species Pumper {
	
	aspect default {
		draw circle(10) color: #pink;
	}
	init {
		
	}

}

species Lake {
	
	aspect default {
		draw rectangle(1.5,1) color:#blue border: #black;
	}
	}
species SluiceGate {
	
	aspect default {
		draw circle(20) color: #gray;
	}
}

species river {

	aspect default {
		draw shape + 100 color: #blue;
	}

}

species GPlayLand {
	list<Pumper> playerPumper;
	list<Lake> playerLake;
	list<SluiceGate> playerSluice;	
	int numberPumper <-1;
	int numberLake <-1; 
	int numberSluice <-1;  
	float volumePump <- 0.0;
	aspect default {
		draw shape.contour + 1000 color: #red;
	}
	reflex{
		volumePump <- numberPumper * maxPumperVolume; 
	}
}

species aez {

	aspect default {
		draw shape.contour + 500 color: #gray;
	}
}
grid LandCell file: cell_file neighbors: 8 {
	int landuse <- int(grid_value);
	float elevation;
	float waterVolume;
	float groundWaterDepth; // (Water volume/pixel_size ^2)
	float waterDemand; 
	float plantHealth; // plant die
	float waterExtracted;//: Water volume - waterExtracted
	float loseDepth; //: groundwater extracted is converted to water depth lose (WaterExtracted/pixelSize)	
		
}

experiment main type: gui {
	list<font>
	fonts <- [font("Helvetica", 48, #plain), font("Times", 30, #plain), font("Courier", 30, #plain), font("Arial", 24, #bold), font("Times", 30, #bold + #italic), font("Geneva", 30, #bold)];
	list<rgb> flood_color <- palette([#white, #blue]);
	list<rgb> depth_color <- palette([#grey, #black]);
	output {
			display "Digital Elevation Model" type: 3d {
				mesh DEM color:depth_color scale:1000 no_data: -9999.0 smooth:true triangulation:false;
				graphics information{
				  draw "DEM (" + _year +") min:" + min(DEM) + " - max:" + max(DEM) at: {0, 0} wireframe: true width: 2 color:#black font:fonts[1];	
				}
			}
		display "W1" type: 3d {
			mesh groundwater1 smooth: false;
			//mesh DEM color:depth_color scale:1000 no_data: -9999.0 smooth:true triangulation:false;
			graphics information {
							draw "Scenario: " + currentScenario + " Flood- min:" + min(DEM) + " - max:" + max(DEM) at: {0, 0} wireframe: true width: 2 color: #black font: fonts[1];
						}			
			species aez;
			species river;
			species GPlayLand position: {0, 0, 0.01};
		}
		display "Subsidence - Groundwater extracted" type: 3d {
			mesh DEM_subsidence scale:1000 color:scale([#darkblue::-7.5,#blue::-5,#lightblue::-2.5,#white::0,#green::1]) no_data: -9999.0 smooth: false;
			species GPlayLand position: {0, 0, 0.01};
			species Pumper;
			species Lake;
			species SluiceGate;
//			graphics information{
//			  draw "Scenario: " + currentScenario+ " Flood- min:" + min(DEM) + " - max:" + max(DEM) at: {0, 0} wireframe: true width: 2 color:#black font:fonts[1];	
//			} 
		}
		

//		display "W2" type: 3d {
//			mesh groundwater2 smooth: false;
//						graphics information {
//							draw "Scenario: " + currentScenario + " Flood- min:" + min(DEM) + " - max:" + max(DEM) at: {0, 0} wireframe: true width: 2 color: #black font: fonts[1];
//						}
//			species aez;
//			species river;
//			species GPlayLand position: {0, 0, 0.01};
//		}
//
//		display "W3" type: 3d {
//			mesh groundwater3 smooth: false;
//						graphics information {
//							draw "Scenario: " + currentScenario + " Flood- min:" + min(DEM) + " - max:" + max(DEM) at: {0, 0} wireframe: true width: 2 color: #black font: fonts[1];
//						}
//			species aez;
//			species river;
//			species GPlayLand position: {0, 0, 0.01};
//		}

	}

}

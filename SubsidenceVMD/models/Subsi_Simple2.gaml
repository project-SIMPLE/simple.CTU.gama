model LoadSubsi

global {
	shape_file aezone_MKD_region_simple_region0_shape_file <- shape_file("../includes/AEZ/aezone_MKD_region_simple_region.shp");
	shape_file MKD_WGS84_shape_file <- shape_file("../includes/AdminBound/MKD_WGS84.shp");
	string scenarioB <- "B1/B1_";
	string scenarioM <- "M1/M1_";
	string currentScenario;
	int _year <- 2018;
	grid_file dem_file <- grid_file("../includes/DEM/dem_500x500_extendbound.tif");
	grid_file dem_file1 <- grid_file("../includes/groundwater/1_volume_qh_500.tif");
	grid_file dem_file2 <- grid_file("../includes/groundwater/2_volume_qp3_500.tif");
	grid_file dem_file3 <- grid_file("../includes/groundwater/3_volume_qp23_500.tif");
	field diffB1_M1_file <- field(grid_file("../includes/Cum_subsidence/diff_B1_M1.tif"));
	shape_file players0_shape_file <- shape_file("../includes/4players.shp");
	field DEM <- copy(field(dem_file));
	//	field flooding <- field(dem_file);
	shape_file river_region0_shape_file <- shape_file("../includes/river_region.shp");
	field subsidentField <- field(grid_file("../includes/Cum_subsidence/" + scenarioB + _year + ".tif"));
	field groundwater1 <- field(dem_file1);
	field groundwater2 <- field(dem_file2);
	field groundwater3 <- field(dem_file3);
	geometry shape <- envelope(dem_file2);

	init {
		create aez from: aezone_MKD_region_simple_region0_shape_file;
		create land from: players0_shape_file;
		create river from: river_region0_shape_file;
	}

}

species river {

	aspect default {
		draw shape + 100 color: #blue;
	}

}

species land {

	aspect default {
		draw shape.contour + 1000 color: #red;
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
			species land position: {0, 0, 0.01};
		}

		display "W2" type: 3d {
			mesh groundwater2 smooth: false;
						graphics information {
							draw "Scenario: " + currentScenario + " Flood- min:" + min(DEM) + " - max:" + max(DEM) at: {0, 0} wireframe: true width: 2 color: #black font: fonts[1];
						}
			species aez;
			species river;
			species land position: {0, 0, 0.01};
		}

		display "W3" type: 3d {
			mesh groundwater3 smooth: false;
						graphics information {
							draw "Scenario: " + currentScenario + " Flood- min:" + min(DEM) + " - max:" + max(DEM) at: {0, 0} wireframe: true width: 2 color: #black font: fonts[1];
						}
			species aez;
			species river;
			species land position: {0, 0, 0.01};
		}

	}

}

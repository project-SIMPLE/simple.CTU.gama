model LoadSubsi

global {
	shape_file MKD_WGS84_shape_file <- shape_file("../includes/AdminBound/MKD_WGS84.shp");
	string scenarioB <- "B1/B1_";
	string scenarioM<-"M1/M1_";
	int _year <- 2018;
	file dem_file <- grid_file("../includes/DEM/dem_500x500_align.tif");
	field diffB1_M1_file <-field(grid_file("../includes/Cum_subsidence/diff_B1_M1.tif"));
	int previousScenariosSubsidence <- 1;
//	int currentScenariosSubsidence <- 1;
//  ca be use matrix or field 
	//matrix<float> flooding <- field(dem_file);
	field flooding <- field(dem_file);
	field DEM <- field(dem_file);
	field allField <- field(grid_file("../includes/Cum_subsidence/" + scenarioB + _year + ".tif"));
	geometry shape <- envelope(dem_file);
	float water_consummation_rate <-0.03;
	float SLR_level <- 0.15 ; // Scenario SLR 15 cm
	init {
		
		 
	}
	reflex load {
		water_consummation_rate <- rnd(0.4);
		write water_consummation_rate;
		if (cycle < (2099 - _year)) {
			_year <- (_year + 1) > 2099 ? 2018 : (_year + 1);
		}
   // select subsidence scenarios based on water consummation. 
		if water_consummation_rate <0.02 {
			allField <- field(grid_file("../includes/Cum_subsidence/" + scenarioM + _year + ".tif"));
			
		}
		else{ 
					allField <- field(grid_file("../includes/Cum_subsidence/" + scenarioB + _year + ".tif"));
			
		} 
//calculate elevation of flooding level. <0 means flooded		
  		//flooding  <- DEM  - allField  - SLR_level; 
  		loop cell_temp over: flooding cells_in shape  {
				if flooding[geometry(cell_temp).location] > -9999.0{
					flooding[geometry(cell_temp).location]<- DEM[geometry(cell_temp).location]-allField[geometry(cell_temp).location]-0.15;
				}
			}
		
		 save flooding to:"../results/flooding_tif.tif" format:"geotiff" crs:"EPSG:32846";
	}

	init {
		create boundMK from: MKD_WGS84_shape_file;
	}

}
//grid cell_dem file: dem_file {
//	float elevation <- float(grid_value);
//	rgb color;
//
//}
species boundMK {
}

experiment main type: gui {
	list<rgb> flood_color <- palette([#white,#blue]);

	list<rgb> depth_color <- palette([#white, #red,#blue]);
	
	output {
		display "DEM" type: 3d {
			//mesh allField scale: -10000 grayscale: true no_data: 3.40282e+38;
			mesh DEM color:depth_color no_data: -9999.0 smooth: false;
		}
		display "Flooding Subsidence SLR 15cm" type: 3d {
			species boundMK;
			//mesh flooding color:scale([#red::1, #yellow::2, #green::3, #blue::6]) no_data: -9999 smooth: false;
			mesh flooding color:flood_color no_data: -9999 smooth: false; 
			//scale([#grey::-100,#darkblue::-10, #blue::-3, #cyan::-1, #lightblue::-0.001, #red::1, #darkred::2, #black::30]) no_data: -9999 smooth: false;
		}
		display "Flooding Subsidence SLR 15cm old way " type: 3d {
			species boundMK;
			///mesh flooding color:scale([#red::1, #orange::5,  #blue::6]) no_data: -9999 smooth: false;
			mesh flooding color:flood_color no_data: -9999.0 smooth: false; 

		}
	}

}

model LoadSubsi

global {
	shape_file MKD_WGS84_shape_file <- shape_file("../includes/AdminBound/MKD_WGS84.shp");
	string scenarioB <- "M1/M1_";//"B1/B1_";
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
		if  _year <= 2100{
			 
			allField <- field(grid_file("../includes/Cum_subsidence/" + scenarioB + _year + ".tif"));
			
			loop cell_temp over: allField cells_in shape  {
				if allField[geometry(cell_temp).location] >10000{
					allField[geometry(cell_temp).location]<--9999;
					//allField[geometry(cell_temp).location]<--9999;
					
				}
			}
			write allField;
			 save allField to:"../includes/Cum_subsidenceCorrected/" + scenarioB + _year + ".tif" format:"geotiff" crs:"EPSG:32846";
			 write "Corrected " + scenarioB + _year + ".tif";
			 _year <- _year + 1;
		}
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
	list<rgb> flood_color <- palette([#darkgreen, #green, rgb(32, 176, 0), rgb(224, 224, 0), rgb(128, 128, 255), #blue]);//palette(reverse([#darkblue, #darkblue, #blue, #lightblue, #cyan, #red, #darkred]));
	output {
		
		display "Flooding Subsidence SLR 15cm old way " type: 3d {
			species boundMK;
			//mesh flooding color:scale([#red::1, #yellow::2, #green::3, #blue::6]) no_data: -9999 smooth: false;
			mesh flooding color:scale([#darkblue::-10, #blue::-3, #cyan::-1, #lightblue::-0.001, #red::1, #darkred::2, #black::30]) no_data: -9999 smooth: false; 

		}
	}

}

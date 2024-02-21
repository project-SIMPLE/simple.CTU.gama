model LoadSubsi

global {
	shape_file MKD_WGS84_shape_file <- shape_file("../includes/AdminBound/MKD_WGS84.shp");
	string scenarioB <- "B1/B1_";
	string scenarioM<-"M1/M1_";
	string currentScenario;
	int _year <- 2018;
	
	
	file dem_file <- grid_file("../includes/DEM/dem_500x500_align.tif");
	field diffB1_M1_file <-field(grid_file("../includes/Cum_subsidence/diff_B1_M1.tif"));
	
	
    field DEM <- field(dem_file);
	field flooding <- field(dem_file);
	
	field subsidentField <- field(grid_file("../includes/Cum_subsidence/" + scenarioB + _year + ".tif"));
	geometry shape <- envelope(dem_file);
	float water_consummation_rate <-0.03;
	int a <-1;
	
	float SLR_level <- 0.15 ; // Scenario SLR 15 cm
	
	init {
		create boundMK from: MKD_WGS84_shape_file;
	}
	
	reflex load {
		//water_consummation_rate <- 0.01;//rnd(0.4);	
		write "water comps rate in read Subsi:"+water_consummation_rate;
		if (cycle < (2099 - _year)) {
			_year <- (_year + 1) > 2099 ? 2018 : (_year + 1);
		}
        // select subsidence scenarios based on water consummation. 
		if water_consummation_rate <0.02 {
			currentScenario<-"scenarioM";
			subsidentField <- field(grid_file("../includes/Cum_subsidence/" + scenarioM + _year + ".tif"));
		}
		else{             
			currentScenario<-"scenarioB";
			subsidentField <- field(grid_file("../includes/Cum_subsidence/" + scenarioB + _year + ".tif"));
		}
        //calculate elevation of flooding level. <0 means flooded
		field tmpField <- copy(DEM);		
  		//flooding  <- tmpField  - allField  - SLR_level;  // ko duoc vi no-data bị tính luôn 
  		loop cell_temp over: flooding cells_in shape  {
			if (subsidentField[geometry(cell_temp).location] != -9999.0) and (tmpField[geometry(cell_temp).location] != -9999.0){
				flooding[geometry(cell_temp).location]<- (tmpField[geometry(cell_temp).location]-subsidentField[geometry(cell_temp).location]);
			}
		}	 
		//save flooding to:"../results/flooding_tif.geotif" format:"geotiff" crs:"EPSG:32846";
	}
}

species boundMK {
	aspect base{
		draw shape color:#black wireframe:true;
	}
}

//experiment main type: gui {
//}

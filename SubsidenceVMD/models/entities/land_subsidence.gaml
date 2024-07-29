model land_subsidence

import "../params.gaml"

global {
	shape_file MKD_WGS840_shape_file <- shape_file("../includes/AdminBound/MKD_WGS84.shp");
	geometry shape <- envelope(MKD_WGS840_shape_file);
	//	string scen <- "B1/BI_";
	string scen <- "M1/M1_";
	int y <- 2018;
	field allField <- field(grid_file("../includes/Cum_subsidence/" + scen + y + ".tif"));

	//	reflex load {
	//		y<-(y+1)>2099?2018:(y+1);
	//		allField <- field(grid_file("../includes/Cum_subsidence/" + scen + y + ".tif"));
	//	}
	field field_subsidence <- field(636, 728, 0.0); //field(cell_subsidence_file);
	action load_subsidence (int idx) {
		write idx;
		field_subsidence <- field(grid_file("../includes/Cum_subsidence/" + scen + (y + idx) + ".tif"));
		//		field_subsidence<- field(grid_file(map_scenario_subsidence[scenario_subsidence][idx]));
	}

}

species land_subsidence {
	int Id_1;
	int Id_2;
	int climat_cod;
	string NAME_1;
	string NAME_2;
	string NAME_3;
	string GID_1;
	string GID_2;
	string GID_3;
	string VARNAME_1;
	string VARNAME_2;
	string VARNAME_3;
	string STT;
	//	list data_pr;
	map<string, float> data_pr;
	map<string, float> data_tas;

	init {
	}

	aspect default {
		draw shape wireframe: true border: #gray;
	}

}

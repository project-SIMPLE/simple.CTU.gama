/**
* Name: readLUgameplay
* Based on the internal empty template. 
* Author: Lenovo
* Tags: 
*/
model readLUgameplay   

import "entities/farming_unit.gaml"
global {
	json_file JsonFile <- json_file("../includes/ExchangeGameplay/_lstLU_decisionJSon.json");
	map<string, unknown> VR_json <- JsonFile.contents;
	list<map<string, float>> VR_decision ;
	init { 
	} 
	action read_decisionGP{
		VR_decision <- VR_json["decision"];
		write VR_decision;
        loop i_decision over: VR_decision {                 
            //write "x:" + i_decision["lon"] + "; lat:"+i_decision["lat"] +"; landuse:"+ int(i_decision["landuse"]);
        }
	}
	reflex LU_gameplay{
		do read_decisionGP;
		 loop i over: VR_decision {                 
            //write active_cell [{i["lat"],i["lon"]}].landuse; //cell_hieuchinh[self.grid_x, self.grid_y].landuse
            point pt1 <- {i["lon"],i["lat"]}; // point (x, y)
            pt1 <- point(to_GAMA_CRS(pt1, "EPSG:32648"));
            //point pt2 <- {i["lat"],i["lon"]};
            //pt2 <- point(to_GAMA_CRS(pt2, "EPSG:32648"));
            //write pt.location;
            //write active_cell;
            list<farming_unit> lstLU;
            lstLU <- active_cell intersecting pt1;
            if length(lstLU)>0{
	            ask lstLU{
	            	write "interecting:" +self.landuse + "; land unit:"+ self.landunit;	    
	            	ask  active_cell  where (each.landunit=self.landunit and each.landuse=self.landuse) {
	            		landuse <-int(i["landuse"]);
	            	}     	
	            }            	
            }
        }
	}
} 

experiment "Landuse_Simple"   {
	parameter "Weight of density" var: w_neighbor_density <- 0.6;
	parameter "Weight of ability" var: w_ability <- 0.5;
	parameter "Weight of suitability" var: w_suitability <- 0.7;
	parameter "Weight of profit" var: w_profit <- 0.8;
	output {
		display LU_sim type: opengl axes: false {
			mesh field_farming_unit color: scale(lu_color) smooth: false;
		}
	}

} 

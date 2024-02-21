/**
* Name: readLUgameplay
* Based on the internal empty template. 
* Author: Lenovo
* Tags: 
*/
model readLUgameplay   

import "entities/farming_unit.gaml"
import "functions.gaml"
import "Subsi.gaml"
global {
	//Data list - sent by GamePlay
	json_file JsonFile <- json_file("../includes/ExchangeGameplay/_lstLU_decisionJSon.json");
	// export suggestion to Game play
	//json_file JsonFileExportVR <- json_file("../includes/ExchangeGameplay/_suggestGamePlay.json");
	map<string, unknown> VR_json <- JsonFile.contents;
	list<map<string, float>> VR_decision ;
	float total_wu2018 <-0.0;
	init { 
		create AEZ from: aez_file;
		do load_suitability_data;
		do load_cost_benefit_data;
		do load_WU_data;
		do load_ability_data;
		//do load_profile_adaptation;
		do load_macroeconomic_data;
//		do load_climate_TAS;
		write "matrix loaded";
		write "cell initialized";
		do set_landunit;
		total_wu2018 <- calWater_unit();
		
	} 
	// calculate total water unit of the data
	float calWater_unit{
		float tmpWu<-0.0;
		ask active_cell {
			//update: wu_cost[landuse]*pixel_size /1E9; // biliion m3
			tmpWu <- tmpWu + wu_cost[landuse]*pixel_size /1E9; // biliion m3 ;
		}
		return tmpWu;
	}
	action read_decisionGamePlay{
		VR_decision <- VR_json["decision"];
		write VR_decision;
        loop i_decision over: VR_decision {                 
            //write "x:" + i_decision["lon"] + "; lat:"+i_decision["lat"] +"; landuse:"+ int(i_decision["landuse"]);
        }
	}
	reflex set_LU_gameplay{
		do read_decisionGamePlay;
		 loop i over: VR_decision {                 
            point pt1 <- {i["lon"],i["lat"]}; // point (x, y)
            pt1 <- point(to_GAMA_CRS(pt1, "EPSG:32648"));
            list<farming_unit> lstLU;
            lstLU <- active_cell intersecting pt1;
            if length(lstLU)>0{
	            ask lstLU{
	            //	write "interecting:" +self.landuse + "; land unit:"+ self.landunit;
	            	list<farming_unit> lstLU_selected<-  active_cell  where (each.landuse=self.landuse) ;//(each.landunit=self.landunit and each.landuse=self.landuse);
	            	ask  lstLU_selected { //where (each.landuse=self.landuse) {
	            		self.landuse <-int(i["landuse"]);// 
	            		//write "landuse choiced :" + landuse;
	            		self.grid_value <- float(landuse) ;
	            	}     	
	            }            	
            }
        }
       
	}
	reflex sent_Suggestion_gameplay{
		total_wu <- calWater_unit();
       	write "Water unit 2018:"+total_wu2018;
        write "water unit:" + total_wu;
        if (total_wu2018!= 0.0){
        	water_consummation_rate<-(total_wu-total_wu2018)/total_wu2018;
        	write "water comps rate in read GP:"+water_consummation_rate;        	
        }
        string sSuggestion <- "{\"information\": [{\"waterunit\": 15.6},{\"total_profit\": 15000.0}]}";
        map pp<-["waterunit":: 15.6];
		save to_json(pp) to: "../includes/ExchangeGameplay/_infoGamePlay.json" format:"text" rewrite: true;//includes/ExchangeGameplay/_suggestGamePlay.json");
	}
} 

experiment "Landuse_Simple"   {
	parameter "Weight of density" var: w_neighbor_density <- 0.6;
	parameter "Weight of ability" var: w_ability <- 0.5;
	parameter "Weight of suitability" var: w_suitability <- 0.7;
	parameter "Weight of profit" var: w_profit <- 0.8;
	list<font> fonts <- [font("Helvetica", 48, #plain),font("Times", 30, #plain) ,font("Courier", 30, #plain), font("Arial", 24, #bold),font("Times", 30, #bold+#italic) ,font("Geneva", 30, #bold)];
	list<rgb> flood_color <- palette([#white,#blue]);
	list<rgb> depth_color <- palette([#grey,#black]);
	
	output {
		display LU_sim type: opengl axes: false {
			
			mesh farming_unit color: scale(lu_color) smooth: false;
			species boundMK aspect:base;
		}
		display "Digital Elevation Model" type: 3d {
			mesh DEM color:depth_color scale:1000 no_data: -9999.0 smooth:true triangulation:false;
			graphics information{
			  draw "DEM (" + _year +") min:" + min(DEM) + " - max:" + max(DEM) at: {0, 0} wireframe: true width: 2 color:#black font:fonts[1];	
			}
		}
		display "Flooding Subsidence SLR 15cm" type: 3d {
			species boundMK aspect:base;
			mesh flooding scale:1000 color:scale([#darkblue::-7.5,#blue::-5,#lightblue::-2.5,#white::0,#green::1]) no_data: -9999.0 smooth: false;
			graphics information{
			  draw "Scenario: " + currentScenario+ " Flood- min:" + min(DEM) + " - max:" + max(DEM) at: {0, 0} wireframe: true width: 2 color:#black font:fonts[1];	
			} 
		}	
	}
} 

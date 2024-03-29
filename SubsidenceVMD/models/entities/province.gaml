model province

species province {
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
	list<float> pump_val<-[-1.0,0.1,0.2];
	float pumping <- 0.2 ;//any(pump_val); //-1 no , 0-2%
	float budget_invest<-shape.area;
	float pumping_price <- pumping > -1 ? pumping * budget_invest /2E6: 0;
//	bool agreed_aez <- true;
	float debt<-0.0;
	float benefit<-0.0;
	map<int,float> debt_lu<-[5::0.0,34::0.0,12::0.0,6::0.0,14::0.0,101::0.0];
	
	map<int,float> benefit_lu<-[5::0.0,34::0.0,12::0.0,6::0.0,14::0.0,101::0.0];
	float wu;
	float subsi_threshold<-0.0;
	init { 
	}

	aspect default {
		draw shape border: #black wireframe:true;
	}

}

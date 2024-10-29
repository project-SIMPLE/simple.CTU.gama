model Entities


global {
	image_file itree <- image_file("../includes/tree.png");
	list<image_file> itrees <- [image_file("../includes/tree1.png"), image_file("../includes/tree2.png"), image_file("../includes/tree3.png")];
	image_file iscene <- image_file("../includes/scene.jpg");
	image_file iscenefull <- image_file("../includes/scenefull.jpg");
	image_file ipumper <- image_file("../includes/pumper.png");
	image_file iwarning <- image_file("../includes/warn.png");


}
 
 
 
species Pumper  {
	list mysub;
	int playerLand_ID;
	string _id;
	string aquifer; // 'qh', 'qp3'
	geometry shape <- square(1000);

	aspect default {
		draw cube(1000) texture: ipumper;
	}

	

}


species GPlayLand {
	int playerLand_ID;
	list<Pumper> pumpers;
	list<tree> trees;
	list<freshwater> fresh_waters;
	list<enemy> enemies;
	list<warning> warnings;
	
	bool subside <- false; 
	int cntDem <- 0;
	int numberPumper <- 1;
	int numberLake <- 1;
	int numberSluice <- 1;
	float volumePump <- 0.0;
	//has the player finished ? 
	bool finished <- false;
	team my_team;
	int remaining_time <- 18000;
	int current_score;

	int rot <- 0;

}

species team {
	int score <- 0;
	rgb color;
	int generation <- 1;
}

 
species tree {
	string _id;
	int playerLand_ID;
	int iid;
	int isz <- 2000;

	aspect default {
	//		draw itree size: 300;
		draw itrees[iid] size: isz;
	}

}

species warning {
	string _id;
	int playerLand_ID;
	int count <- 0;


	aspect default {
		draw iwarning border: #red size: 1000;
	}

}


species enemy  {
	string _id;
	int playerLand_ID;
	point target;
	bool spotted <- false;


	aspect default {
		draw circle(300) color: #red;
	}

}

species freshwater {
	string _id;
	int playerLand_ID;
	enemy target;

	
	aspect default {
		draw circle(300) color: #blue;
	}

}
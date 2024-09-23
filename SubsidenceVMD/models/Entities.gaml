model Entities


global {
	image_file itree <- image_file("../includes/tree.png");
	list<image_file> itrees <- [image_file("../includes/tree1.png"), image_file("../includes/tree2.png"), image_file("../includes/tree3.png")];
	image_file iscene <- image_file("../includes/scene.jpg");
	image_file iscenefull <- image_file("../includes/scenefull.jpg");
	image_file ipumper <- image_file("../includes/pumper.png");
	image_file igate <- image_file("../includes/gate.png");
	image_file ilake <- image_file("../includes/lake.png");
	image_file iwarning <- image_file("../includes/warn.png");
	shape_file routes0_shape_file <- shape_file("../includes/routes.shp");


}

species aez {

	aspect default {
		draw shape.contour + 500 color: #gray;
	}

}
 

species route {
}
 


species river {

	aspect default {
		draw shape + 100 color: #blue;
	}

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

	//	reflex ss {
	//		count <- count + 1;
	//		if (count > 100) {
	//			do die;
	//		}
	//
	//	}
	aspect default {
		draw iwarning border: #red size: 1000;
	}

}
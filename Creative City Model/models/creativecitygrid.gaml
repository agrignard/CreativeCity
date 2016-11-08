/**
* Name: creativecitygrid
* Author: Kenneth
* Description: 
* Tags: Tag1, Tag2, TagN
*/

model creativecitygrid

global {
  float mean_pop_count; 
  float high_dense_level;
  float n_number;
  float percent_educated;//% of population with college education;
  float percent_educated_cr;//% of creative population with college education
  float indexofgini;
  float percent_poor;
  float percent_middle;
  float percent_rich;
  float cr_space_percent;
  float mean_income_all;
  float median_income_all;
  float mean_income_cr;
  float pop_growth_rate<-30;
  int pop -> {length(person)};
  int dimensions <- 25;
  string landuse;
  
  /*reflex buildagent{
  //allows for turtles to be created as a result of population growth rate by year
  //if pop_growth_rate is greater than zero
  	if(pop_growth_rate>0){
      create species:person number:((pop_growth_rate/12)*pop){
      	if(flip(0.5)){
      		educated <- true;	
      	}
      }  
   	}
    }*/
  file my_csv_file <- csv_file("../includes/kendallsquarelayout11-4-16.csv",",");
  init {
    matrix data <- matrix(my_csv_file);
    ask patches{
      landuse <- (data[grid_x,grid_y]);
      write data[grid_x,grid_y];    
    }
    ask patches{
      do update_color;
    }
    create person number:100{
      	if(flip(0.5)){
      		educated <- true;	
      	}
      }  
  }
}

species person skills: [moving]{
	bool content_w_neighbor;//indicates whether or not the turtle is content with the tolerance of his neighbors
	int tolerance;//percent of similar neighbors desired
	int similar_nearby;//number of agents with similar tolerance on neighboring patches (similar tolerance is +/- 5 points)
	int similar_here;//number of agents on same patch with similar tolerance (similar tolerance is +/- 5 points)
	int similar_total;//total number of similar tolerance turtles here and on neighbors
	int total_nearby;//total number of neighboring agents
	int total_here;//total number of agents on the same patch
	int total;//total number of agents here and nearby
	bool creative;//whether or not agent is creative
	bool creative_h;//whether or not agent is highly creative
	bool creative_m;//whether or not agent is medium creative
	bool creative_l;//whether or not agent is low creative
	int income;//income of agent, based on gamma or bimodal distribution
	int income_start;//income assigned at model start - can be used to see how much money made since the beginning of the model
	bool educated <- nil;// whether or not agent has a university degree
	bool partnered;//If true, the person is paired with an investment or creative inspiration partner.
    bool partner_timeshare;//How long the person prefers to partner with investor/creative inspiration.
	bool is_happy -> {tolerance >= (similar_total / total_nearby)} ;
	reflex monthly_actions{
		//kill off agents if pop_growth_rate is less than zero
		 if(pop_growth_rate>0){
			if (flip(pop_growth_rate/12/100)) {
                do die;
        //checks to every month to see if the agent has been assigned a creative boolean value yet, agents that have been
            }
        }
}
}

grid patches width: dimensions height: dimensions neighbors: 8  {

    rgb color;//color of grid patch
    int neighborhood;//neighborhood which grid patch belongs
    int patch_population; //population of grid path
    int pop_count_cr; //creative population count
    int pop_count_cr_h; //highly creative population count
    int pop_count_cr_m; //medium creative population count
    int occupancy_start;//occupancy of patch at the beginning of the simulation
    bool creative_space;//whether or not patch is creative space
    bool creative_value;//creative value of patch
    int num_content_cr;//number of content creative residents of patch
    int pop_count_cr_n;//new pop count used to decline in number of creatives visit
    int pop_count_cr_diff;//diff of count of creative pop to current count of creative pop if negative then gained value, otherwise decrease
    int pop_count_cr_minus;//factor to subtract for loss of creative value
    string landuse;//What purpose is this land used for?
    reflex update{
    ask person at_distance(1){
       if(self overlaps myself){
          myself.patch_population  <- myself.patch_population + 1;
          }
       }
    
    }
    action update_color {
        if (landuse = "water") {
            color <- #blue;
        }
        else if (landuse = "commercial") {
            color <- #red;
        }
        else if (landuse = "green space") {
            color <- #green;
        }
         else if (landuse = "residential"){
            color <- #yellow;
        }
	        else{
            color <- #purple;
        }
    }
  }

experiment MyExperiment type: gui {
    output {
        display MyDisplay type: java2D {
            grid patches lines:#black;
            species person;
        }
    }
}

class Cloth implements Physical{
  public PShape shape;
  public boolean render_vertices = true;
  public Cell[][] cells;
  public float cell_distance = 1;
  PVector origin = new PVector(0,0,0);
  //square shaped, entire code should probably work for rectangles also, but would complicate UI
  public void createCloth(int size, float distance, float k){
    cells = new Cell[size][size];
    cell_distance = distance;
    for(int row=0; row<size; row++){
      for(int column=0; column<size; column++){
        Cell x = new Cell();
        x.rest_len = distance;
        x.position = new PVector(origin.x+row*cell_distance, origin.y, origin.z+column*cell_distance);
        x.setup();
        x.k = k;
        cells[row][column] = x;
      } 
    }
    for(int row=0; row<size; row++){
      for(int column=0; column<size; column++){
          if(column>0){
            cells[row][column].adjacent_cells.add(cells[row][column-1]);
          }
          if(row>0){
            cells[row][column].adjacent_cells.add(cells[row-1][column]);
          }
          if(column<size-1){
            cells[row][column].adjacent_cells.add(cells[row][column+1]);
          }
          if(row<size-1){
            cells[row][column].adjacent_cells.add(cells[row+1][column]);
          }
      } 
    }
    updateShape();
  }
  public void updateShape(){
    shape = createShape();
    shape.beginShape(TRIANGLE_STRIP);    
    //i seriously wish there was an easier way to do this. define cloth surface by declaring 2 triangles for all 4 point sets on cloth "web" of cells. every frame...
    //seems that P3D really doesnt want to create flat surfaces and WILL try to close this chape, resulting in cloth looking stretched in some cases(even for endShape() called without the parameter). this is not issue with simulation but the renderer.
    //havent found a solution to this so far. if makes simulation too messy just comment out calling this function in draw(), so only net is visible.
    for(int x = 0; x<cells.length-1; x++){
      for(int y = 0; y<cells[0].length-1; y++){
          shape.vertex(cells[x][y].position.x, cells[x][y].position.y, cells[x][y].position.z);
          shape.vertex(cells[x+1][y].position.x, cells[x+1][y].position.y, cells[x+1][y].position.z);
          shape.vertex(cells[x+1][y+1].position.x, cells[x+1][y+1].position.y, cells[x+1][y+1].position.z);
          shape.vertex(cells[x][y].position.x, cells[x][y].position.y, cells[x][y].position.z);
          shape.vertex(cells[x][y+1].position.x, cells[x][y+1].position.y, cells[x][y+1].position.z);
          shape.vertex(cells[x+1][y+1].position.x, cells[x+1][y+1].position.y, cells[x+1][y+1].position.z);
          shape.vertex(cells[x][y].position.x, cells[x][y].position.y, cells[x][y].position.z);
      }
    }
    shape.endShape();
  }
  public void draw(){
    updateShape();
    
    shape(shape, 0,0);
    for(Cell[] cls:cells){
      for(Cell cl:cls){
        if(render_vertices){
          cl.draw();
          fill(255);
        }
        else cl.update();

    }
  } 
}
  void applyGravity(){
    for(Cell[] cls:cells){
      for(Cell cl:cls){
        cl.applyGravity();
      }
    }
  };
  
  //random to simulate force application such as wind. simulating wind by particle emission largely unfeasible with current collision algorithm, this should be a sufficient approximation. scales with cloth size to imitate larger hit area.
  //ideally this would also increase the spread to neighbors, instead of scale, with cloth size, so it looks more "wavy"
  void applyExternalForce(PVector force){
    for(int x = 0; x<cells.length; x++){
      int row = (int)random(cells.length);
      int column = (int)random(cells[0].length);
      cells[row][column].applyExternalForce(force);      
    }
  };
  ArrayList<Cell> getCells(){
    ArrayList<Cell> c = new ArrayList<Cell>();
    for(Cell[] cls:cells){
      for(Cell cl:cls){
        c.add(cl);
      }
    }
    return c;
  }
  //cloth on it's own is sum of forces within the cloth. not used anywhere, but for extendability's sake.
  PVector getForce(){
    PVector x = new PVector(0,0,0);
    for(Cell[] cls:cells){
      for(Cell cl:cls){
        x.add(cl.velocity);
      }
    }
    return x;
  };
}

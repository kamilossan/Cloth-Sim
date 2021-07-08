ArrayList<Mover> physicalBodies = new ArrayList();
ArrayList<Physical> objects = new ArrayList();
Surface s;
SimCamera camera;
SimpleUI ui;
boolean forcesEnabled;
float sphereRadius;
float clothStiffness;
int clothSize;
float windForce;
boolean setAnchored = true;

void setup(){
  clothSize = 40;
  clothStiffness = 0.1;
  sphereRadius = 10;
  windForce = 0;
  forcesEnabled = false;
  physicalBodies = new ArrayList();
  objects = new ArrayList();
  size(1200,900, P3D);
  setupInterface();
  //set framerate to constant - default 60fps, consistent with usual VSync
  frameRate(Timer.FRAME_RATE);
  noStroke(); 
  generateSurface();
 
}

void spawnSphere(){
  Sphere sphere = new Sphere(sphereRadius);
  sphere.position = new PVector(0,200,0);
  objects.add(sphere);
  physicalBodies.add(sphere);
}


void mousePressed(){
  handleMouseInteraction();
}
void draw(){
  background(128,128, 200);
  fill(255);
  lights();
  ambientLight(200,200,200);  
  for(Physical obj:objects){
  obj.draw();
  Constants.WIND = new PVector(windForce, 0,0);
  if(forcesEnabled){
    obj.applyGravity();
    obj.applyExternalForce(Constants.WIND);
  }
  }
  s.drawMe();
  objectControls();
  updateCollisions();
    camera.update();
  camera.startDrawHUD();
    ui.update();
  camera.endDrawHUD();  
}

void objectControls(){
  if(key=='w' && keyPressed){
    for(Mover obj:physicalBodies){
      if(obj.selected){
        obj.velocity.y+=-10/Timer.FRAME_RATE;
      //  print(obj.position);
      }
    }
  }
  if(key=='s' && keyPressed){
    for(Mover obj:physicalBodies){
      if(obj.selected){
        obj.velocity.y+=10/Timer.FRAME_RATE;
      }
    }
  }
  if(key=='a' && keyPressed){
    for(Mover obj:physicalBodies){
      if(obj.selected){
        obj.velocity.x+=-10/Timer.FRAME_RATE;
      }
    }
  }
  if(key=='d' && keyPressed){
    for(Mover obj:physicalBodies){
      if(obj.selected){
        obj.velocity.x+=10/Timer.FRAME_RATE;
      }
    }
  }
  if(key=='f' && keyPressed){
    for(Mover obj:physicalBodies){
      if(obj.selected){
        obj.position.z+=-10/Timer.FRAME_RATE;
      }
    }
  }
  if(key=='g' && keyPressed){
    for(Mover obj:physicalBodies){
      if(obj.selected){
        obj.position.z+=10/Timer.FRAME_RATE;
      }
    }
  }
 
}

void keyReleased(){
   if(key==' '){
    for(Mover obj:physicalBodies){
      if(obj.selected){
        obj.anchored = setAnchored;
      } 
    }
    setAnchored = !setAnchored;
  }
    if(keyCode==ENTER){
    for(Mover obj:physicalBodies){
      if(obj.selected){
        obj.selected = false;
      }
    }
    //fallback to setting anchored to true once deselected.
      setAnchored = true;
  }
}



void setupInterface(){
  if(camera==null){
    camera = new SimCamera();
    camera.setHUDArea(20,20,200,300);
  }
    camera.setPositionAndLookat(vec(0, -100, -300), vec(150, 150, 0));
    ui = new SimpleUI();
    ui.addToggleButton("forces", 20,20);
    ui.addToggleButton("reset", 20,50);
    ui.addToggleButton("spawn ball", 20,80);
    ui.addToggleButton("spawn cloth", 20,110);
    ui.addSlider("cloth size", 90,130).setSliderValue(0.4);
    ui.addSlider("ball size", 90,170).setSliderValue(0.1);
    ui.addSlider("cloth stiffness", 90,210).setSliderValue(0.1);
    ui.addSlider("wind", 90,250).setSliderValue(0.5);

}
void handleUIEvent(UIEventData uied){
  if(uied.eventIsFromWidget("forces")){
    forcesEnabled = !forcesEnabled;
  }
  if(uied.eventIsFromWidget("reset")){
    setup();
  }
    if(uied.eventIsFromWidget("spawn ball")){
    spawnSphere();
  }
    if(uied.eventIsFromWidget("spawn cloth")){
    spawnCloth();
  }
    if(uied.eventIsFromWidget("cloth size")&& uied.mouseEventType.equals("mouseReleased")){
    clothSize = (int)(uied.sliderValue*100);
    print(clothSize);
  }
    if(uied.eventIsFromWidget("ball size")&& uied.mouseEventType.equals("mouseReleased")){
    sphereRadius = uied.sliderValue*100;
  }
    if(uied.eventIsFromWidget("cloth stiffness")&& uied.mouseEventType.equals("mouseReleased")){
    clothStiffness = uied.sliderValue;
  }
    if(uied.eventIsFromWidget("wind")&& uied.mouseEventType.equals("mouseReleased")){
    windForce = (uied.sliderValue-0.5)*100;
    Constants.WIND = new PVector(windForce, 0, 0);
  }
  
}

void updateCollisions(){
  for(int n = 0; n < physicalBodies.size(); n++){
    Mover thisMover = physicalBodies.get(n);
    Mover otherMover = thisMover.findCollisionWithOtherMover(physicalBodies,n);
    if(otherMover != null) {
      thisMover.collisionResponse(otherMover);
    }
    
    //check if particle hit the floor level to bounce off
      s.checkCollision(thisMover);
   // }
  }
}

void spawnCloth(){
  Cloth x = new Cloth();
  x.origin = new PVector(0,200,0);
  x.createCloth(clothSize, 2, clothStiffness);
  x.draw();
  for(Cell c:x.getCells()){
    physicalBodies.add(c);
  }
  objects.add(x);
}

void generateSurface(){
  s = new Surface(10,10,1000);
  s.setTransformAbs(1, 0,0,0, new PVector(-5000, 250, -5000));
}

void handleMouseInteraction(){
  SimRay mr = camera.getMouseRay();
  for(Mover obj:physicalBodies){
    if(mr.calcIntersection(obj.cell)){
      if(mouseButton==LEFT){
      obj.selected = !obj.selected;
    }
      if(mouseButton==RIGHT){
      obj.anchored = !obj.anchored;
      }
    }
  }
}

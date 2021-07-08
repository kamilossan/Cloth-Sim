
class Surface extends SimSurfaceMesh{
  float h;
   Surface(int numInX, int numInZ, float scale){
        super(numInX, numInZ, scale);
        PImage img = loadImage("floor.jpg");
        setTextureMap(img);
   }
   //simply bounce off the declared surface. not correct for newtonian collision, but solves for identity equation for axis-aligned flat surfaces. just there to provide simulation ground, constant collision check is too expensive for entire cloth.
   //(especially since surface collision in current form checks against quad vertices, so the larger the surface the exponentially more checks it is, and if too thin cloth will just fall through)
   //absolute value to prevent body from getting "stuck" while perpetually reversing direction of force - this will always point away from surface. Since resposne is equal to attack, it shouldn't be able to accidentally multiply repelling force
   
   void repelCollided(Mover collided){
         collided.velocity.y = -abs(collided.velocity.y*(1-collided.friction));
   }
   
   void setTransformAbs(float scale, float rotx, float roty, float rotz, PVector pos){
     super.setTransformAbs(scale, rotx, roty, rotz, pos);
     h = pos.y;
     
   }
   //checks only y coordinate, so objects will bounce outside platform range also. could check other coordinates, but this is intended - dont want stuff to fall into aether if platform is too small
   void checkCollision(Mover mover){
     if(mover.cell.getCentre().y+mover.radius>=h){
       repelCollided(mover);
     }
   }
   void drawMe(){
   noFill();
   super.drawMe();
   fill(255);
   }
}

//ripped sphere collision syntax from the original Mover class
// only part of original Mover used, slightly simplified for the network of spheres that a cloth is going to be, essentially just ripping elastic collision
//by default mass and radius assumed 0.1/0.5, producing best effects for cloth simulation, this will remain constant - spheres there are simply supposed to denote vertices of the net
// TODO: make mass and radius adjustable, as this will change the properties of cloth and has to be overridden by Sphere object

class Mover{
  PVector velocity, position;
  float default_mass;
  float radius = 0.5;
  float mass = 0.1;
  float friction = 0.3;
  boolean anchored = false;
  boolean selected = false;
  SimSphere cell;
  boolean collisionCheck(Mover otherMover){
    
    if(otherMover == this) return false; // can't collide with yourself!
    
    float distance = otherMover.position.dist(this.position);
    float minDist = otherMover.radius + this.radius;
    if (distance < minDist)  return true;
    return false;
  }
  
  void applyFriction(){
    //velocity is a coefficient of forces in relation to mass. so, if friction is dependent of velocity, there is no necessity to use mass again. drag is defined in relation to velocity squared, so this is essentially the same as adding negative force.
    //except im not using a dynamic acceleration variable, so im adjusting velocity directly.
    velocity.mult(1-friction/Timer.FRAME_RATE/mass);
  }
  
   void collisionResponse(Mover otherMover) {
    // based on 
    // https://en.wikipedia.org/wiki/Elastic_collision
    
     if(otherMover == this) return; // can't collide with yourself!
     
     
    PVector v1 = this.velocity;
    PVector v2 = otherMover.velocity;
    
    PVector cen1 = this.position;
    PVector cen2 = otherMover.position;
    
    // calculate v1New, the new velocity of this mover
    float massPart1 = 2*otherMover.mass / (this.mass + otherMover.mass);
    PVector v1subv2 = PVector.sub(v1,v2);
    PVector cen1subCen2 = PVector.sub(cen1,cen2);
    float topBit1 = v1subv2.dot(cen1subCen2);
    float bottomBit1 = cen1subCen2.mag()*cen1subCen2.mag();
    
    float multiplyer1 = massPart1 * (topBit1/bottomBit1);
    PVector changeV1 = PVector.mult(cen1subCen2, multiplyer1);
    
    PVector v1New = PVector.sub(v1,changeV1);
    
    // calculate v2New, the new velocity of other mover
    float massPart2 = 2*this.mass/(this.mass + otherMover.mass);
    PVector v2subv1 = PVector.sub(v2,v1);
    PVector cen2subCen1 = PVector.sub(cen2,cen1);
    float topBit2 = v2subv1.dot(cen2subCen1);
    float bottomBit2 = cen2subCen1.mag()*cen2subCen1.mag();
    
    float multiplyer2 = massPart2 * (topBit2/bottomBit2);
    PVector changeV2 = PVector.mult(cen2subCen1, multiplyer2);
    
    PVector v2New = PVector.sub(v2,changeV2);
    
    this.velocity = v1New;
    otherMover.velocity = v2New;
    ensureNoOverlap(otherMover);
  }
    void ensureNoOverlap(Mover otherMover){
    // the purpose of this method is to avoid Movers sticking together:
    // if they are overlapping it moves this Mover directly away from the other Mover to ensure
    // they are not still overlapping come the next collision check 
    
    
    PVector cen1 = this.position;
    PVector cen2 = otherMover.position;
    
    float cumulativeRadii = (this.radius + otherMover.radius)+2; // extra fudge factor
    float distanceBetween = cen1.dist(cen2);
    
    float overlap = cumulativeRadii - distanceBetween;
    if(overlap > 0){
      // move this away from other
      PVector vectorAwayFromOtherNormalized = PVector.sub(cen1, cen2).normalize();
      PVector amountToMove = PVector.mult(vectorAwayFromOtherNormalized, overlap);
      this.position.add(amountToMove);
    }
  }
  Mover findCollisionWithOtherMover(ArrayList<Mover> movers, int thisMoversListPos){
    // Returns null if no collision found, otherwise returns the other mover this one
    // is colliding with
    // This is optimised to only search for collisions with movers of a greater index in the otherMovers list
    // as lower ones have already calculated collision with this Mover
    for (int n = thisMoversListPos + 1; n < movers.size(); n++) {
      Mover otherMover = movers.get(n);
      
      if( this.collisionCheck(otherMover) ) return otherMover;
    }

    // if no collisions have been found return null;
    return null;

}
  //template to override
  void draw(){};
  
  
}

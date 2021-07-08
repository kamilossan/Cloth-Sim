class Cell extends Mover implements Physical {
  //neighbors, also treated as spring anchors for force calculations 
  ArrayList<Cell> adjacent_cells = new ArrayList<Cell>();


  //constant "spring" resistance, ie. tension between cloth cells.
  float k = 0.1;

  float rest_len;

  public void setup() {
    default_mass = mass;
    velocity = new PVector(0, 0, 0);
    cell = new SimSphere(0.5);
  }
  public void draw() {
    if (selected) {
      if (anchored) {
        fill(120, 120, 60);
      } else {
        fill(128);
      }
    } else if (anchored) {
      fill(60, 120, 120);
    } else {
      fill(120, 60, 60);
    }
    update();
    cell.drawMe();
  }
  public void update() {
    if (!anchored & !selected) {
      mass = default_mass;
      for (Cell x : adjacent_cells) {
        PVector dir = PVector.sub(position, x.position);
        float distance = dir.mag();
        float dif = rest_len - distance;
        //hooke's law. normally would be negated, but processing coordinate space counts from upper corner(ie. downward means higher value), so it's done naturally. otherwise cloth will fall apart
        float force = x.k*dif;
        //F=MA
        PVector acceleration = dir.normalize().mult(force).div(mass);
        velocity.add(Timer.TranslateForce(acceleration));

        //ignore small forces to prevent overt bounciness. some will still happen due to ensureNoCollision() code, but thats to be expected
        //uncomment if necessary, found largely counterproductive for 0<k<1
        //if(velocity.mag()>0.01){
        position.add(velocity);
        applyFriction();
        //}
      }
    } else {
      position.add(velocity);
      velocity = new PVector(0, 0, 0);
      //assume near infinite mass for rigid bodies for collision - so majority of the energy is transferred back to collided body, since velocity is 0, this should not result in increased force upon collision
      mass = 10000;
    }

    cell.setTransformAbs(1, 0, 0, 0, position);
  }
  void applyExternalForce(PVector force) {
    if (!anchored) velocity.add(Timer.TranslateForce(force.div(mass)));
  };
  //force divides by mass, but gravity scales linearly with mass also, so assuming earth-like conditions this will be practically constant (GM/r^2)
  void applyGravity() {
    if (!anchored) velocity.add(Timer.TranslateForce(new PVector(0, Constants.GRAVITY_FORCE, 0)));
  };

  //get rid of the internal collision check. it should be handled internally by hooke's law - if cells too close they will be repelled. adding this in resulted in really wonky interactions, especially with the ground.
  void ensureNoOverlap(Mover otherMover) {
    if (!(otherMover instanceof Cell)) {
      super.ensureNoOverlap(otherMover);
    }
  }

  PVector getForce() {
    return velocity.copy();
  }
}

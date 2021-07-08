class Sphere extends Mover implements Physical {

  void applyExternalForce(PVector force) {
    if (!anchored) velocity.add(Timer.TranslateForce(force.div(mass)));
  };

  void applyGravity() {
    if (!anchored) velocity.add(Timer.TranslateForce(new PVector(0, Constants.GRAVITY_FORCE, 0)));
  }
  PVector getForce() {
    return velocity.copy();
  }
  Sphere(float radius) {
    super();
    this.radius = radius;
    //assuming material density of 1/unit^3, mass will thus be equal to volume of sphere (not used for cloth, cause cloth vertices are supposed to be largely dimensionless and are not *actually* spheres of material
    mass = 4*PI*radius*radius*radius/3;
    setup();
  }
  void draw() {
    //applyGravity();
    if (anchored | selected) {
      position.add(velocity);
      velocity = new PVector(0, 0, 0);
      //assume near infinite mass for rigid bodies for collision - so majority of the energy is transferred back to collided body
      
      mass = 10000;
    } else {
      mass = default_mass;
      applyFriction();
      //print(velocity.mag());
      position.add(velocity);    

      //print(velocity);
    }
    cell.setTransformAbs(1, 0, 0, 0, position);
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
    cell.drawMe();
    fill(255);
  }
  void setup() {
    velocity = new PVector(0, 0, 0);
    position = new PVector(0, 0, 0);
    default_mass = mass;
    cell = new SimSphere(radius);
  }
  void ensureNoOverlap(Mover otherMover) {
    if (!(otherMover instanceof Cell)) {
      super.ensureNoOverlap(otherMover);
    }
  }
}

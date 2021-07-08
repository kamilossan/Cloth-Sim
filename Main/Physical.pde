interface Physical{
   void applyGravity();
   void applyExternalForce(PVector force);
   PVector getForce();
   void draw();
}

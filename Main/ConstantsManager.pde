static class Timer{
  //for simplicty sake im handling time distribution by setting constant framerate 60/s rather than counting elapsed time. less laggy to divide by 60 than try getting time elapsed per frame. also avoids float point inaccuracy
  public static float FRAME_RATE = 60;
  public static PVector TranslateForce(PVector force){
    return force.div(FRAME_RATE);
  }
}
static class Constants{
  public static float GRAVITY_FORCE = 1;
  public static PVector WIND = new PVector(0,0,0);
}

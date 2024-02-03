/**
 **********************************************************************************************************************
 * @file       sketch_2_Hello_Wall.pde
 * @author     Steve Ding, Colin Gallacher
 * @version    V3.0.0
 * @date       08-January-2021
 * @brief      Smart cane simulation by Samuel Segun 
 **********************************************************************************************************************
 * @attention
 *
 *
 **********************************************************************************************************************
 */
 
  /* library imports *****************************************************************************************************/ 
import processing.serial.*;
import static java.util.concurrent.TimeUnit.*;
import java.util.concurrent.*;
import java.util.HashMap;
import java.util.Map;
import processing.sound.*;
import java.math.BigDecimal;
import java.math.RoundingMode;
/* end library imports *************************************************************************************************/  


/* scheduler definition ************************************************************************************************/ 
private final ScheduledExecutorService scheduler      = Executors.newScheduledThreadPool(1);
/* end scheduler definition ********************************************************************************************/ 

public enum HaplyVersion {
  V2,
  V3,
  V3_1
}

final HaplyVersion version = HaplyVersion.V3_1;

/* device block definitions ********************************************************************************************/
Board             haplyBoard;
Device            widgetOne;
Mechanisms        pantograph;

byte              widgetOneID                         = 5;
int               CW                                  = 0;
int               CCW                                 = 1;
boolean           renderingForce                     = false;
/* end device block definition *****************************************************************************************/



/* framerate definition ************************************************************************************************/
long              baseFrameRate                       = 120;
/* end framerate definition ********************************************************************************************/ 



/* elements definition *************************************************************************************************/

/* Screen and world setup parameters */
float             pixelsPerMeter                      = 4000.0;
float             radsPerDegree                       = 0.01745;

/* pantagraph link parameters in meters */
float             l                                   = 0.07;
float             L                                   = 0.09;


/* end effector radius in meters */
float             rEE                                 = 0.006;

/* virtual wall parameter  */
float             kWall                               = 550;
PVector           fWall                               = new PVector(0, 0);
PVector           penWall                             = new PVector(0, 0);
PVector           posWall                             = new PVector(0.01, 0.10);



/* generic data for a 2DOF device */
/* joint space */
PVector           angles                              = new PVector(0, 0);
PVector           torques                             = new PVector(0, 0);

/* task space */
PVector           posEE                               = new PVector(0, 0);
PVector           fEE                                 = new PVector(0, 0); 

/* device graphical position */
PVector           deviceOrigin                        = new PVector(0, 0);

/* World boundaries reference */
final int         worldPixelWidth                     = 1000;
final int         worldPixelHeight                    = 650;


/* graphical elements */
PShape pGraph, joint, endEffector;
PShape wall;
PShape box;
/* end elements definition *********************************************************************************************/ 

/* Haptic lines and boxes design **********************************************/


WhiteNoise noise;
PVector fTexture;

/* Declare parameters */

//JSONArray boxArr = new JSONArray();

/* Haptic Side walks **************************************/
HapticLine leftWall1;
HapticLine rightWall1;
HapticLine rightWall2;

HapticLine leftWall2;
HapticLine leftWall3;
HapticLine rightWall3;
HapticLine rightWall4;


HapticLine middleTopWall1;
HapticLine middleBottomWall1;

HapticLine middleTopWall2;
HapticLine middleBottomWall2;



float x1_val;
float y1_val;
float x2_val;
float y2_val;


boolean rightwallCrossed = false;
boolean leftwallCrossed = false;
boolean topwallCrossed = false;
boolean bottomwallCrossed = false;

Serial myPort;

/* setup section *******************************************************************************************************/
void setup(){
   /* screen size definition */
   size(1000, 650);
   
  noise = new WhiteNoise(this);
  
  //String myPortName = Serial.list()[0];
  myPort = new Serial(this, "COM10", 9600);
  
  
  /* put setup code here, run once: */
  
  /* Walls **********************************************************/
  

 x1_val = 320; //200
 y1_val = 150;
 x2_val = 320; //200
 y2_val = 550;
 
  /**** first walls ***/
 leftWall1 = new HapticLine (x1_val, y1_val, x2_val, y2_val);
 rightWall1 = new HapticLine (x1_val+100, y1_val, x1_val+100, y1_val+150);
 rightWall2 = new HapticLine (x1_val+100, y1_val+250, x2_val+100, y2_val);
 
 
 /*** Second walls ****/
 leftWall2 = new HapticLine (x1_val+200, y1_val, x1_val+200, y1_val+150);
 leftWall3 = new HapticLine (x1_val+200, y1_val+250, x2_val+200, y2_val);
 rightWall3 = new HapticLine (x1_val+300, y1_val, x1_val+300, y1_val+150);
 rightWall4 = new HapticLine (x1_val+300, y1_val+250, x1_val+300, y2_val);
  
  
 /*** Middle walls ***/
 middleTopWall1 = new HapticLine (x1_val+100, y1_val+150, x1_val+200, y1_val+150);
 middleBottomWall1 = new HapticLine (x1_val+100, y1_val+250, x1_val+200, y1_val+250);
 
 middleTopWall2 = new HapticLine (x1_val+300, y1_val+150, x1_val+400, y1_val+150);
 middleBottomWall2 = new HapticLine (x1_val+300, y1_val+250, x1_val+400, y1_val+250);
 
 
 



 
  
  /* device setup */
  
  /**  
   * The board declaration needs to be changed depending on which USB serial port the Haply board is connected.
   * In the base example, a connection is setup to the first detected serial device, this parameter can be changed
   * to explicitly state the serial port will look like the following for different OS:
   *
   *      windows:      haplyBoard = new Board(this, "COM10", 0);
   *      linux:        haplyBoard = new Board(this, "/dev/ttyUSB0", 0);
   *      mac:          haplyBoard = new Board(this, "/dev/cu.usbmodem1411", 0);
   */ 
  haplyBoard          = new Board(this, Serial.list()[1], 0);
  //haplyBoard = new Board(this, "COM7", 0);
 
  
 
  
  
  widgetOne = new Device(widgetOneID, haplyBoard);
  if (version == HaplyVersion.V2) {
    pantograph = new Pantograph();
    widgetOne.set_mechanism(pantograph);
    widgetOne.add_actuator(1, CCW, 2);
    widgetOne.add_actuator(2, CW, 1);
    widgetOne.add_encoder(1, CCW, 241, 10752, 2);
    widgetOne.add_encoder(2, CW, -61, 10752, 1);
  } else if (version == HaplyVersion.V3 || version == HaplyVersion.V3_1) {
    pantograph = new Pantographv3();
    widgetOne.set_mechanism(pantograph);
    widgetOne.add_actuator(1, CCW, 2);
    widgetOne.add_actuator(2, CCW, 1);
    if (version == HaplyVersion.V3) {
      widgetOne.add_encoder(1, CCW, 97.23, 2048*2.5*1.0194*1.0154, 2);   //right in theory
      widgetOne.add_encoder(2, CCW, 82.77, 2048*2.5*1.0194, 1);    //left in theory
    } else {
      widgetOne.add_encoder(1, CCW, 168, 4880, 2);
      widgetOne.add_encoder(2, CCW, 12, 4880, 1); 

    }
  }
  widgetOne.device_set_parameters();
  //panto_setup();
  
  
  
  
  
  
  
  /* visual elements setup */
  background(0);
  deviceOrigin.add(worldPixelWidth/2, 0);
  
  /* create pantagraph graphics */
  create_pantagraph();
  
  /* create wall graphics */
  wall = create_wall(posWall.x-0.2, posWall.y+rEE, posWall.x+0.2, posWall.y+rEE);
  wall.setStroke(color(0));
  
  
  
  /* setup framerate speed */
  frameRate(baseFrameRate);
  
  
  /* setup simulation thread to run at 1kHz */ 
  SimulationThread st = new SimulationThread();
  scheduler.scheduleAtFixedRate(st, 1, 1, MILLISECONDS);
     
   
  
  
}
/* end setup section ***************************************************************************************************/


 

/* draw section ********************************************************************************************************/
void draw(){
   
  
  /* put graphical code here, runs repeatedly at defined framerate in setup, else default at 60fps: */
  if(renderingForce == false){
   
    background(255); 
  
    
    update_animation(angles.x*radsPerDegree, angles.y*radsPerDegree, posEE.x, posEE.y);
    
    
    
    
  }
  
  
}
/* end draw section ****************************************************************************************************/



/* simulation section **************************************************************************************************/
class SimulationThread implements Runnable{
  
  public void run(){
    /* put haptic simulation code here, runs repeatedly at 1kHz as defined in setup */
    
    renderingForce = true;
    
    if(haplyBoard.data_available()){
      /* GET END-EFFECTOR STATE (TASK SPACE) */
      widgetOne.device_read_data();
    
      angles.set(widgetOne.get_device_angles()); 
      posEE.set(widgetOne.get_device_position(angles.array()));
      posEE.set(device_to_graphics(posEE)); 
     
   
      /* haptic wall force calculation */
      fWall.set(0, 0);
      
      if (gameMode) {
        
        posEE.set(screenPos.copy());
        
        println(posEE);
        
        
      }
   
      
      
      /*** conditions for intersection ***/
      
      if ((posEE.y > screenY2Ava(rightWall1.y2) && posEE.y < screenY2Ava(rightWall2.y1)) 
          && (posEE.x > screenX2Ava(leftWall1.x1) && posEE.x < screenX2Ava(rightWall1.x1))) {
            //println("T intersection");
            myPort.write('V');
            myPort.write('N');
            
          }
          
     if ((posEE.y > screenY2Ava(leftWall2.y2) && posEE.y < screenY2Ava(leftWall3.y1)) 
          && (posEE.x > screenX2Ava(leftWall2.x1) && posEE.x < screenX2Ava(rightWall3.x1))) {
            //println("X intersection");
            myPort.write('X');
            myPort.write('N');
            
          }
        
        
      
      /** conditions for vertical exit points ***/
      
      if (posEE.y < screenY2Ava(leftWall1.y1)) {
        //println("Top Exit");
        myPort.write('T');
        
        myPort.write('N');
      }
      
      if (posEE.y > screenY2Ava(leftWall1. y2)) {
        //println("Bottom Exit");
        myPort.write('B');
        
        myPort.write('N');
        
      }
      
      
     
      
    /** conditions for horizontal exit points ***/
      
      if (posEE.x < screenX2Ava(leftWall1.x1)) {
       //println("Left wall crossed!");
       myPort.write('L');
       myPort.write('N');
       
      }
      
       if (posEE.x > screenX2Ava(middleTopWall2.x2)) {
       
        //println("Right Exit");
        myPort.write('R');
        myPort.write('N');
      }
      
      
      /**
      if (!((posEE.y > screenY2Ava(y1_val+175) && posEE.y < screenY2Ava(y1_val+225)) 
          && (posEE.x > screenX2Ava(x1_val+50) && posEE.x < screenX2Ava(x1_val+250))) && posEE.x > x1_val+50)  {
        //println("Bottom Exit");
        myPort.write('B');
        myPort.write('N');
      } */
      
      
     /*** conditions for the walls ***/
     
     // change avatar coordinates to 4 d.p.
     BigDecimal posX = new BigDecimal(posEE.x);
     posX = posX.setScale(5, RoundingMode.HALF_UP);
     float currPosEEx = posX.floatValue();
     
     BigDecimal posY = new BigDecimal(posEE.y);
     posY = posY.setScale(5, RoundingMode.HALF_UP);
     float currPosEEy = posY.floatValue();
     
     /* condition for rightWall1 crossing" */
     // margin of 0.001 used because of 2diy precision issue
     if ((abs(currPosEEx - screenX2Ava(rightWall1.x1)) < 0.001 && currPosEEy > screenY2Ava(rightWall1.y1) && currPosEEy < screenY2Ava(rightWall1.y2)) 
           || (abs(currPosEEx - screenX2Ava(rightWall2.x1)) < 0.001 && currPosEEy > screenY2Ava(rightWall2.y1) && currPosEEy < screenY2Ava(rightWall2.y2))) {
       // println("Contact with the right wall made");
       rightwallCrossed = true;
       leftwallCrossed = false;
       topwallCrossed = false;
       bottomwallCrossed = false;
       
       
       
     }
      
     if ((posEE.x > screenX2Ava(rightWall1.x1) && posEE.x < screenX2Ava(leftWall2.x1) && posEE.y < screenY2Ava(rightWall1.y2) && rightwallCrossed == true) 
             || (posEE.x > screenX2Ava(rightWall1.x1) && posEE.x < screenX2Ava(leftWall2.x1) && posEE.y > screenY2Ava(rightWall2.y1) && rightwallCrossed == true)) {
                
               //println("Right wall crossed!");
                 myPort.write('R');
                 myPort.write('N');
              
             }
             
             
     /** condition for leftWall2 crossing **/
     if ((abs(currPosEEx - screenX2Ava(leftWall2.x1)) < 0.001 && currPosEEy > screenY2Ava(leftWall2.y1) && currPosEEy < screenY2Ava(leftWall2.y2)) 
       || (abs(currPosEEx - screenX2Ava(leftWall3.x1)) < 0.001 && currPosEEy > screenY2Ava(leftWall3.y1) && currPosEEy < screenY2Ava(leftWall3.y2))){
       
       //println("Contact with the left wall made");
       rightwallCrossed = false;
       leftwallCrossed = true;
       topwallCrossed = false;
       bottomwallCrossed = false;
       
     
    }
   

    if ((posEE.x > screenX2Ava(rightWall1.x1) && posEE.x < screenX2Ava(leftWall2.x1) && posEE.y < screenY2Ava(leftWall2.y2) && leftwallCrossed == true) 
       || (posEE.x > screenX2Ava(rightWall1.x1) && posEE.x < screenX2Ava(leftWall2.x1) && posEE.y > screenY2Ava(leftWall3.y1) && leftwallCrossed == true)) { 
         //println("Left wall crossed!);
         
         myPort.write('L'); 
         myPort.write('N'); // stop 
         
       }
       
       
       
      /** condition for rightwall3 crossing **/
      if ((abs(currPosEEx - screenX2Ava(rightWall3.x1)) < 0.001 && currPosEEy > screenY2Ava(rightWall3.y1) && currPosEEy < screenY2Ava(rightWall3.y2))
          || (abs(currPosEEx - screenX2Ava(rightWall4.x1)) < 0.001 && currPosEEy > screenY2Ava(rightWall4.y1) && currPosEEy < screenY2Ava(rightWall4.y2))) {
             // println("Contact with the right wall made");
             rightwallCrossed = true;
             leftwallCrossed = false;
             topwallCrossed = false;
             bottomwallCrossed = false;
       
     }
     
   
      if ((posEE.x > screenX2Ava(rightWall3.x1) && posEE.y < screenY2Ava(rightWall3.y2) && rightwallCrossed == true) 
             || (posEE.x > screenX2Ava(rightWall4.x1) && posEE.y > screenY2Ava(rightWall4.y1) && rightwallCrossed == true)) {
                //println("Right wall crossed!");
                myPort.write('R');
                
                myPort.write('N');
             }
             
    //println("posEEy:", "wallYPos:", "margin:",currPosEEy, screenY2Ava(middleBottomWall1.y1), abs(currPosEEy - screenY2Ava(middleBottomWall1.y1)));
    /** condition for topwall1 crossing **/
    if ((abs(currPosEEy - screenY2Ava(middleTopWall1.y1)) < 0.001 && currPosEEx > screenX2Ava(middleTopWall1.x1) && currPosEEx < screenX2Ava(middleTopWall1.x2))
        || (abs(currPosEEy - screenY2Ava(middleTopWall2.y1)) < 0.001 && currPosEEx > screenX2Ava(middleTopWall2.x1) && currPosEEx < screenX2Ava(middleTopWall2.x2))) {
       // println("Contact with the top wall made");
       bottomwallCrossed = false; 
       rightwallCrossed = false;
       leftwallCrossed = false;
       topwallCrossed = true;
        
     
     }
     
   if ((currPosEEx > screenX2Ava(middleTopWall1.x1) && currPosEEx < screenX2Ava(middleTopWall1.x2) && currPosEEy < screenY2Ava(middleTopWall1.y1) && topwallCrossed == true) 
         || (currPosEEx > screenX2Ava(middleTopWall2.x1) && currPosEEx < screenX2Ava(middleTopWall2.x2) && currPosEEy < screenY2Ava(middleTopWall2.y1) && topwallCrossed == true)) {
           
           //println ("Top wall crossed!");
           myPort.write('T');
           
           myPort.write('N');
           
         }
         
   /** condition for bottom wall crossing **/
   // margin of 0.001 used because of 2diy precision issue
    if ((abs(currPosEEy - screenY2Ava(middleBottomWall1.y1)) < 0.001 && currPosEEx > screenX2Ava(middleBottomWall1.x1) && currPosEEx < screenX2Ava(middleBottomWall1.x2))
        || (abs(currPosEEy - screenY2Ava(middleBottomWall2.y1)) < 0.001 && currPosEEx > screenX2Ava(middleBottomWall2.x1) && currPosEEx < screenX2Ava(middleBottomWall2.x2))) {
       // println("Contact with the bottom wall made");
       rightwallCrossed = false;
       leftwallCrossed = false;
       topwallCrossed = false;
       bottomwallCrossed = true;   
     
     }
   if ((currPosEEx > screenX2Ava(middleBottomWall1.x1) && currPosEEx < screenX2Ava(middleBottomWall1.x2) && currPosEEy > screenY2Ava(middleBottomWall1.y1) && bottomwallCrossed == true) 
       || (currPosEEx > screenX2Ava(middleBottomWall2.x1) && currPosEEx < screenX2Ava(middleBottomWall2.x2) && currPosEEy > screenY2Ava(middleBottomWall2.y1) && bottomwallCrossed == true)) {
         
         //println ("Bottom wall crossed!");
         myPort.write('B');
         myPort.write('N');
       }

      fEE = (fWall.copy()).mult(-1);//.add(force);
     
      fEE.set(graphics_to_device(fEE));
     // println("mouse:", mouseX, mouseY);
      ///println("f:", force);
      /* end haptic wall force calculation */
    }
    
    
    torques.set(widgetOne.set_device_torques(fEE.array()));
    widgetOne.device_write_torques();
  
  
    renderingForce = false;
    //noise.stop();
  }
}
/* end simulation section **********************************************************************************************/


/* helper functions section, place helper functions here ***************************************************************/
void create_pantagraph(){
  float lAni = pixelsPerMeter * l;
  float LAni = pixelsPerMeter * L;
  float rEEAni = pixelsPerMeter * rEE;
  
  pGraph = createShape();
  pGraph.beginShape();
  pGraph.fill(255);
  pGraph.stroke(0);
  pGraph.strokeWeight(2);
  
  pGraph.vertex(deviceOrigin.x, deviceOrigin.y);
  pGraph.vertex(deviceOrigin.x, deviceOrigin.y);
  pGraph.vertex(deviceOrigin.x, deviceOrigin.y);
  pGraph.vertex(deviceOrigin.x, deviceOrigin.y);
  pGraph.endShape(CLOSE);
  
  joint = createShape(ELLIPSE, deviceOrigin.x, deviceOrigin.y, rEEAni, rEEAni);
  joint.setStroke(color(0));
  
  endEffector = createShape(ELLIPSE, deviceOrigin.x, deviceOrigin.y, 2*rEEAni, 2*rEEAni);
  endEffector.setStroke(color(0));
  strokeWeight(5);
  
}


PShape create_wall(float x1, float y1, float x2, float y2){
  x1 = pixelsPerMeter * x1;
  y1 = pixelsPerMeter * y1;
  x2 = pixelsPerMeter * x2;
  y2 = pixelsPerMeter * y2;
  
  return createShape(LINE, deviceOrigin.x + x1, deviceOrigin.y + y1, deviceOrigin.x + x2, deviceOrigin.y+y2);
}


void update_animation(float th1, float th2, float xE, float yE){
  background(255);

  float lAni = pixelsPerMeter * l;
  float LAni = pixelsPerMeter * L;
  
  xE = pixelsPerMeter * xE;
  yE = pixelsPerMeter * yE;
  
  th1 = 3.14 - th1;
  th2 = 3.14 - th2;
  
  pGraph.setVertex(1, deviceOrigin.x + lAni*cos(th1), deviceOrigin.y + lAni*sin(th1));
  pGraph.setVertex(3, deviceOrigin.x + lAni*cos(th2), deviceOrigin.y + lAni*sin(th2));
  pGraph.setVertex(2, deviceOrigin.x + xE, deviceOrigin.y + yE);
  
  shape(pGraph);
  shape(joint);
  
  
  
  shape(leftWall1.line);
  shape(rightWall1.line);
  shape(rightWall2.line);
  shape(leftWall2.line);
  shape(leftWall3.line);
  shape(rightWall3.line);
  shape(rightWall4.line);
  shape(middleTopWall1.line);
  shape(middleBottomWall1.line);
  shape(middleTopWall2.line);
  shape(middleBottomWall2.line);
  //shape(wall);
  
  
  
  
 
  
  translate(xE, yE);
  shape(endEffector);
    
}


PVector device_to_graphics(PVector deviceFrame){
  return deviceFrame.set(-deviceFrame.x, deviceFrame.y);
}


PVector graphics_to_device(PVector graphicsFrame){
  return graphicsFrame.set(-graphicsFrame.x, graphicsFrame.y);
}



/* end helper functions section ****************************************************************************************/







  
 /* Calculate the distance between circle and the avatar as the avatar moves */
float calculateEEObjectDistance (float x1, float y1, float x2, float y2) {
    x2 = screenX2Ava(x2);
    y2 = screenY2Ava(y2);
    float distance = (float) Math.sqrt(Math.pow(x2 - x1, 2) + Math.pow(y2 - y1, 2));
    return distance;
   }
   
/* Calculate the angle between circle and the avatar as the avatar moves */
float calculateEEObjectAngle (float x1, float y1, float x2, float y2) {
    x2 = screenX2Ava(x2);
    y2 = screenY2Ava(y2);
    float angle = (float) Math.atan2(y2 - y1, x2 - x1);
    return angle;
   }
 
 

    
 
   
   
  
      
  /* screen pixels to Avatar coordinates */
  
  float screenX2Ava (float x) {
   return (x - deviceOrigin.x)/pixelsPerMeter;
  }
  
  float screenY2Ava (float y) {
   return (y - deviceOrigin.y)/pixelsPerMeter;
  }
  
  
 /* Texture model */
 
 void rockyTexture (float y, float fNormal) {
        fTexture = new PVector(0,0);
        float ampli = 3;
       
        float mu = 0.9;
        float spacing = 100; // at 100 spacing, the rougness is coarse, this becomes smooth as spacing reduces, at 1000, rougness is smooth ( smooth, coarse roughness, moderate roughness. ampli 30, mu=0.1  
        float fFriction = -1 * mu * kWall * max(penWall.y, fNormal); // I noticed there is a texture gradient from the wall down waard....like uo going deeperinto the ocean
        fTexture.add(fFriction - fFriction * ampli * sin(2 * PI * posEE.x * spacing), 0); // bycle effect       
        //print("ftext", fTexture);
 }
 
 

 void gunEffectTexture() {
      fTexture = new PVector(0,0);
      float amp = 1.5; //default =1.5 //
      float stickingEffect = 0;
      float freq = 50;
      
      fTexture.set(amp * sin(2 * PI * 1/(posEE.x)), 0); //rocky surface, it was very fast with targent. also when combined with force constraint and at sample rate of MHz, you will generate grinding equipent expeirence
        //posEEL = posEE.x;
        //stickingEffect = (posEE.x - posEEL)*200;
         //fTexture.set(posEE.x * 100* sin(2 * PI * freq * posEE.x*100), 0); // undamped oscillation
         
      }
      
  void stickyTexture() {    
        fTexture = new PVector(0, 0);
        float ampli = 1.5;
        float freq = 50;
        
        // texture taking account of of x and y
        fTexture.add(ampli * sin(2 * PI * freq * posEE.x), ampli * sin(2 * PI * freq * posEE.y)); // with ampli set to 1.5, the texture felt sticky/muddy/gum like experience  + 
        
  }
  
  void containerShakingTexture () {
     fTexture = new PVector(0,0);
        
        float ampli = 1.5; //default is 1 and deafult ftexture y value is 0
        float spatialPeriod = 1;
        //posEELast.set(posEE);
        //surfaceDisp = posEE.x - posEELast.x;
        fTexture.set(ampli * sin (2 * PI * 1/posEE.x * spatialPeriod), 0); // container haptics effects;
        
  }
  
  void testTexture() {
        fTexture = new PVector(0,0);
        float ftext = 0;
        float ampli = 1.5;
        float spatialPeriod = 1;
        float p = 53; // p = 3, 31, 121
        //posEELast.set(posEE);
        //surfaceDisp = posEE.x - posEELast.x;
        //fTexture.set(ampli * sin (2 * PI * 121 * posEE.x), 0); // slightly rough;
        ftext = ampli * sin(2 * PI * p * posEE.x);
        fTexture.set(ampli * sin (2 * PI * 121 * posEE.x)* ftext, 0); // sticky effect
  }
  /* Define a rectangular wall */
  

     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
   
    
      
 

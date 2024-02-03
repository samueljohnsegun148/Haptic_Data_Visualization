 
 public class HapticBox {
   PShape box;
   float x1;
   float y1;
   float x2;
   float y2;
   int nextID = 0;
   float boxCenterX;
   float boxCenterY;
   private int boxId;
   
   
   
   public HapticBox (float x1, float y1, float x2, float y2){
       this.x1 = x1;
       this.y1 = y1;
       this.x2 = x2;
       this.y2 = y2;
       boxCenterX = (x2 - x1)*0.5;
       boxCenterY = (y2- x1)*0.5;
       boxId = nextID++;
       box = createShape(RECT, x1, y1, x2, y2);
       //box.setFill(color(0, 0, 0));
       box.setStroke(true);
      
   }
   
 }

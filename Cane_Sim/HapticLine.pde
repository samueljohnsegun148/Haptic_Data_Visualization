 
 public class HapticLine {
   PShape line;
   float x1;
   float y1;
   float x2;
   float y2;
   public HapticLine (float x1, float y1, float x2, float y2){
     this.x1 = x1;
       this.y1 = y1;
       this.x2 = x2;
       this.y2 = y2;
     strokeWeight(4);
     line = createShape(LINE, x1, y1, x2, y2);
     //box.setFill(color(0, 0, 0));
     line.setStroke(true);
     //shape(box, 50, 50); 
      strokeWeight(4);
     
   }
  
 }

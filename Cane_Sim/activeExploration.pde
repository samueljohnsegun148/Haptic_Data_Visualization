
float avatarSpeed = 10;
float avaPosY;
float avaPosX;
PVector screenPos = new PVector(0, 0);
boolean gameMode = false;
PVector posEELast = new PVector (0, 0);
PVector xDiff = new PVector (0, 0);
PVector force = new PVector (0, 0);

void keyPressed() {
     
      if (key == CODED) {
        
          if (keyCode == UP) {
            avaPosY = (screenY2Ava(-1 * avatarSpeed));
            screenPos = new PVector (posEE.x, posEE.y + avaPosY);
            //posEE.set();
           //println("up:", screenPos);
            gameMode = true;
          } else if (keyCode == DOWN) {
            avaPosY = (screenY2Ava(avatarSpeed));
            screenPos = new PVector(posEE.x, posEE.y + avaPosY);
            //println("down:", screenPos);
            gameMode = true;
          } else if (keyCode == RIGHT) {
            avaPosX = (screenY2Ava(avatarSpeed));
            screenPos = new PVector(posEE.x + avaPosX, posEE.y);
            //println("right:", screenPos);
            gameMode = true;
          
        } else if (keyCode == LEFT) {
          avaPosX = (screenY2Ava(-1 * avatarSpeed));
          screenPos = new PVector(posEE.x + avaPosX, posEE.y);
          gameMode = true;
          //println("left:", screenPos);
        } else {
          //screenPos = new PVector (posEE.x, posEE.y);
        }
        
        }
       
    }    
//}
   //void keyReleased() {
     //if (key == 'e'){
       //if(keyCode == DOWN || keyCode == UP || keyCode == LEFT || keyCode == RIGHT) {
         //gameMode = false;//false;  
     //} 
    //}
   //}

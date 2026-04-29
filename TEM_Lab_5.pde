//State System 
int START = 0, PLAY = 1, GAMEOVER = 2, WIN = 3;
int state = START;

//  Player Variables 
float px, py, vx, vy;
float accel = 0.8, friction = 0.92, gravity = 0.6, jumpForce = -14;
float pR = 15; 

//  Enemy Arrays
int numEnemies = 8;
float[] ex = new float[numEnemies];
float[] ey = new float[numEnemies];
float[] evx = new float[numEnemies];
float[] evy = new float[numEnemies];
float eR = 12; 

int lives, startTime;
int duration = 30; 
boolean canHit = true;
int hitTimer, cooldownMs = 800;

//  Win Counter variable
int winCount = 0; 

void setup() {
  size(800, 600);
  resetGame();
}

void draw() {
  background(25); 
  
  if (state == START) {
    displayScreen("DODGE & SURVIVE", "Press ENTER to Start");
  } 
  else if (state == PLAY) {
    runGame();
  } 
  else if (state == GAMEOVER) {
    displayScreen("GAME OVER", "Press 'R' to Try Again");
  } 
  else if (state == WIN) {
    // Show total wins on the win screen
    displayScreen("YOU WON!", "Total Wins: " + winCount + "\nPress 'R' to Play Again");
  }
}

void resetGame() {
  px = width/2; 
  py = height - 50;
  vx = 0; 
  vy = 0;
  lives = 3;
  
  for (int i = 0; i < numEnemies; i++) {
    ex[i] = random(width);
    ey[i] = random(height/2); 
    evx[i] = random(-4, 4);
    evy[i] = random(-4, 4);
  }
}

void runGame() {
  int elapsed = (millis() - startTime) / 1000;
  int timeLeft = duration - elapsed;
  
  // Movement logic
  if (keyPressed) {
    if (keyCode == LEFT) vx -= accel;
    if (keyCode == RIGHT) vx += accel;
  }
  vx *= friction; 
  px += vx;
  vy += gravity;
  py += vy;
  
  if (py > height - pR) { py = height - pR; vy = 0; }
  px = constrain(px, pR, width - pR);

  // Enemies & Collision
  for (int i = 0; i < numEnemies; i++) {
    ex[i] += evx[i];
    ey[i] += evy[i];
    if (ex[i] < eR || ex[i] > width - eR) evx[i] *= -1;
    if (ey[i] < eR || ey[i] > height - eR) evy[i] *= -1;
    
    float d = dist(px, py, ex[i], ey[i]);
    if (canHit && d < (pR + eR)) {
      lives--;
      canHit = false;
      hitTimer = millis();
      if (lives <= 0) state = GAMEOVER;
    }
  }

  if (!canHit && millis() - hitTimer > cooldownMs) canHit = true;

  // Win Condition Check
  if (timeLeft <= 0) {
    state = WIN;
    winCount++; 
  }

  drawVisuals(timeLeft);
}

void drawVisuals(int t) {
  if (!canHit && (frameCount % 10 < 5)) fill(255, 0, 0);
  else fill(0, 200, 255);
  ellipse(px, py, pR*2, pR*2);
  
  fill(255, 100, 100);
  for (int i = 0; i < numEnemies; i++) {
    ellipse(ex[i], ey[i], eR*2, eR*2);
  }
  
  fill(255);
  textSize(20);
  textAlign(LEFT);
  text("LIVES: " + lives, 20, 40);
  text("WINS: " + winCount, 20, 70); 
  textAlign(RIGHT);
  text("TIME: " + t + "s", width - 20, 40);
}

void displayScreen(String title, String sub) {
  textAlign(CENTER);
  fill(255);
  textSize(50);
  text(title, width/2, height/2 - 20);
  textSize(22);
  fill(0, 255, 150);
  text(sub, width/2, height/2 + 40);
}

void keyPressed() {
  if (state == START && keyCode == ENTER) {
    state = PLAY;
    startTime = millis();
  }
  if (state == PLAY && key == ' ' && py >= height - pR - 1) {
    vy = jumpForce;
  }
  if ((state == GAMEOVER || state == WIN) && (key == 'r' || key == 'R')) {
    resetGame();
    state = START;
  }
}

//This file aims to show an example of a function, make it invalid if necessary
void setup() {
    size(500, 500);
    noStroke();
}

void draw() {
    background(255);
    if (mouseX < 200 || mouseX > 300 || mouseY < 200 || mouseY > 300 ) {
        fill(0);
    }

    else if (mousePressed == true) {
        if (mouseButton == LEFT) {
            fill(34, 198, 45);
        }
        else if (mouseButton == RIGHT) {
            fill(23, 19, 231);
        }
    }
        
    else {
        fill(255);
    }
    rectMode(CENTER);
    rect(250, 250, 100, 100);
}
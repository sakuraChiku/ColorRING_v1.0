color c = (0);

void setup() {
  size(500, 500);
  frameRate(240);
}

void draw() {
    if (!mousePressed) background(255);
}

void mouseDragged() {
    fill(c);
    ellipse(mouseX, mouseY, 10, 10);
}
//                    this function can be used to fill the color, creating a mark pen, but the framerate should be changed
// Paint brush class
class PaintBrush {
    ArrayList<BrushStroke> strokes;
    BrushStroke currentStroke;
    int brushColor;
    float brushSize;
    int brushAlpha;
    boolean isDrawing;
    
    PaintBrush() {
        strokes = new ArrayList<BrushStroke>();
        brushColor = color(0, 0, 0);
        brushSize = 5;
        brushAlpha = 255;
        isDrawing = false;
    }
    
    void startStroke(int x, int y) {
        currentStroke = new BrushStroke(brushColor, brushSize, brushAlpha);
        currentStroke.addPoint(x, y);
        isDrawing = true;
    }
    
    void continueStroke(int x, int y) {
        if (isDrawing && currentStroke != null) {
            currentStroke.addPoint(x, y);
        }
    }
    
    void endStroke() {
        if (currentStroke != null && currentStroke.points.size() > 0) {
            strokes.add(currentStroke);
        }
        currentStroke = null;
        isDrawing = false;
    }
    
    void display() {
        pushStyle();
        // Draw all saved strokes
        for (BrushStroke stroke : strokes) {
            stroke.display();
        }
        // Draw current stroke being drawn
        if (currentStroke != null) {
            currentStroke.display();
        }
        popStyle();
    }
    
    void setColor(int r, int g, int b) {
        brushColor = color(r, g, b);
    }
    
    void setSize(float size) {
        brushSize = size;
    }
    
    void setAlpha(int alpha) {
        brushAlpha = alpha;
    }
}

// Single brush stroke
class BrushStroke {
    ArrayList<PVector> points;
    color strokeColor;
    float strokeSize;
    int strokeAlpha;
    
    BrushStroke(color c, float size, int alpha) {
        points = new ArrayList<PVector>();
        strokeColor = c;
        strokeSize = size;
        strokeAlpha = alpha;
    }
    
    void addPoint(int x, int y) {
        points.add(new PVector(x, y));
    }
    
    void display() {
        if (points.size() < 2) return;
        
        pushStyle();
        stroke(red(strokeColor), green(strokeColor), blue(strokeColor), strokeAlpha);
        strokeWeight(strokeSize);
        strokeCap(ROUND);
        noFill();
        
        beginShape();
        for (PVector p : points) {
            vertex(p.x, p.y);
        }
        endShape();
        popStyle();
    }
}
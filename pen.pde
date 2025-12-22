// Paint brush class
class PaintBrush {
    ArrayList<BrushStroke> strokes;
    BrushStroke currentStroke;
    int brushColor;
    float brushSize;
    int brushAlpha;
    boolean isDrawing;
    boolean isEraserMode;
    PGraphics pg; // Layer for painting
    
    PaintBrush() {
        strokes = new ArrayList<BrushStroke>();
        brushColor = color(0, 0, 0);
        brushSize = 5;
        brushAlpha = 255;
        isDrawing = false;
        isEraserMode = false;
        // Create a transparent layer matching the canvas size
        pg = createGraphics(width, height);
    }
    
    void startStroke(int x, int y) {
        currentStroke = new BrushStroke(brushColor, brushSize, brushAlpha, isEraserMode);
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
    
    void clear() {
        strokes.clear();
    }
    
    void setEraser(boolean active) {
        isEraserMode = active;
    }
    
    void display() {
        // Draw everything to the off-screen buffer first
        pg.beginDraw();
        pg.clear(); // Clear layer to fully transparent
        
        for (BrushStroke stroke : strokes) {
            stroke.displayOn(pg);
        }
        // Draw current stroke being drawn
        if (currentStroke != null) {
            currentStroke.displayOn(pg);
        }
        pg.endDraw();
        
        // Draw the buffer onto the main canvas
        image(pg, 0, 0);
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

    void mousePreview() {
        pushStyle();
        if (isEraserMode) {
            stroke(200);
            fill(200, 100);
        } else {
            stroke(brushColor);
            fill(red(brushColor), green(brushColor), blue(brushColor), 100);
        }
        ellipse(mouseX, mouseY, brushSize, brushSize);
        popStyle();
    }
}

// Single brush stroke
class BrushStroke {
    ArrayList<PVector> points;
    color strokeColor;
    float strokeSize;
    int strokeAlpha;
    boolean isEraser;
    
    BrushStroke(color c, float size, int alpha, boolean eraser) {
        points = new ArrayList<PVector>();
        strokeColor = c;
        strokeSize = size;
        strokeAlpha = alpha;
        isEraser = eraser;
    }
    
    void addPoint(int x, int y) {
        points.add(new PVector(x, y));
    }
    
    void displayOn(PGraphics pg) {
        if (points.size() < 2) return;
        
        pg.pushStyle();
        
        if (isEraser) {
            // Eraser mode: Replace pixels with transparency
            pg.blendMode(REPLACE);
            pg.stroke(0, 0); // 0 alpha = transparent
        } else {
            // Normal mode: Blend color
            pg.blendMode(BLEND);
            pg.stroke(red(strokeColor), green(strokeColor), blue(strokeColor), strokeAlpha);
        }
        
        pg.strokeWeight(strokeSize);
        pg.strokeCap(ROUND);
        pg.noFill();
        
        pg.beginShape();
        for (PVector p : points) {
            pg.vertex(p.x, p.y);
        }
        pg.endShape();
        
        pg.popStyle();
    }
}
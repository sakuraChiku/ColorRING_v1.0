// Cropping interaction for run[1]

boolean isSelecting = false;
float selX1, selY1, selX2, selY2;

void cutting_draw() {
	if (run[1] != 1) return;
	// draw selection rectangle on top of canvas display
	if (isSelecting) {
		pushStyle();
		noFill();
		stroke(0, 120, 200);
		strokeWeight(2);
		rectMode(CORNERS);
		rect(selX1, selY1, selX2, selY2);
		popStyle();
	}
}

void cutting_mousePressed() {
	if (run[1] != 1) return;
	// start selection only if clicking inside displayed image area
	if (importer != null && importer.img != null) {
		float ix = importer.x;
		float iy = importer.y;
		float iw = importer.displayWidth;
		float ih = importer.displayHeight;
		if (mouseX >= ix && mouseX <= ix+iw && mouseY >= iy && mouseY <= iy+ih) {
			isSelecting = true;
			selX1 = constrain(mouseX, ix, ix+iw);
			selY1 = constrain(mouseY, iy, iy+ih);
			selX2 = selX1;
			selY2 = selY1;
		}
	}
}

void cutting_mouseDragged() {
	if (run[1] != 1) return;
	// println("cutting_mouseDragged: mouse= " + mouseX + "," + mouseY + " isSelecting=" + isSelecting);
	if (!isSelecting) return;
	if (importer == null) return;
	// limit to image display bounds
	float ix = importer.x;
	float iy = importer.y;
	float iw = importer.displayWidth;
	float ih = importer.displayHeight;
	
    float currX = constrain(mouseX, ix, ix+iw);
    float currY = constrain(mouseY, iy, iy+ih);

    if (cut_sidebar != null && cut_sidebar.presetIndex > 0) {
        float targetAR = 1.0;
        if (cut_sidebar.presetIndex == 1) targetAR = 1.0;
        else if (cut_sidebar.presetIndex == 2) targetAR = 16.0/9.0;
        else if (cut_sidebar.presetIndex == 3) targetAR = 4.0/3.0;
        else if (cut_sidebar.presetIndex == 4) targetAR = 3.0/2.0;
        
        float w = currX - selX1;
        float h = currY - selY1;
        
        if (abs(h) < 0.1) h = (h >= 0 ? 0.1 : -0.1); // avoid div by zero
        
        float currentAR = abs(w) / abs(h);
        
        if (currentAR > targetAR) {
            // Too wide, shrink width to match height * AR
            float newW = abs(h) * targetAR * (w >= 0 ? 1 : -1);
            selX2 = selX1 + newW;
            selY2 = currY;
        } else {
            // Too tall, shrink height to match width / AR
            float newH = abs(w) / targetAR * (h >= 0 ? 1 : -1);
            selX2 = currX;
            selY2 = selY1 + newH;
        }
    } else {
    	selX2 = currX;
    	selY2 = currY;
    }
}

void cutting_mouseReleased() {
	if (run[1] != 1) return;
	if (!isSelecting) return;
	if (importer == null || importer.canvas == null) {
		isSelecting = false;
		return;
	}

	// compute selection rect in display coords
	float ix = importer.x;
	float iy = importer.y;
	float iw = importer.displayWidth;
	float ih = importer.displayHeight;

	float x0 = min(selX1, selX2);
	float y0 = min(selY1, selY2);
	float x1 = max(selX1, selX2);
	float y1 = max(selY1, selY2);

	// map to original canvas coordinates
	float sx = (x0 - ix) * (importer.canvas.width / iw);
	float sy = (y0 - iy) * (importer.canvas.height / ih);
	float sw = (x1 - x0) * (importer.canvas.width / iw);
	float sh = (y1 - y0) * (importer.canvas.height / ih);

	// ensure integer and boundaries
	int isx = int(constrain(sx, 0, importer.canvas.width-1));
	int isy = int(constrain(sy, 0, importer.canvas.height-1));
	int isw = int(constrain(sw, 1, importer.canvas.width - isx));
	int ish = int(constrain(sh, 1, importer.canvas.height - isy));

	// perform crop on canvas
    // FIX: Do not crop 'importer.canvas' directly as it contains baked-in effects (color, exposure, etc).
    // Instead, reconstruct the geometric state (Scale/Rotate) from 'importer.originalCanvas' and crop that.
    
    PGraphics src = importer.originalCanvas;
    
    // Replicate the geometric transformation logic from applyPipeline/Cut_Sidebar
    // to ensure we crop the correct area relative to what the user sees.
    if (cut_sidebar != null) {
        float s = cut_sidebar.scaleVal;
        float r = radians(cut_sidebar.rotationDeg);
        
        if (s != 1.0 || r != 0) {
            int w = src.width;
            int h = src.height;
            int tW = max(1, int(w * s));
            int tH = max(1, int(h * s));
            
            int maxPixels = 6000000;
            long pixels = (long)tW * (long)tH;
            float downscale = 1.0;
            if (pixels > maxPixels) {
                downscale = sqrt((float)maxPixels / (float)pixels);
                tW = max(1, int(tW * downscale));
                tH = max(1, int(tH * downscale));
            }
            float effectiveScale = s * downscale;
            
            PGraphics temp = createGraphics(tW, tH);
            temp.beginDraw();
            temp.background(200); 
            temp.pushMatrix();
            temp.translate(temp.width/2, temp.height/2);
            temp.rotate(r);
            temp.scale(effectiveScale);
            temp.image(src, -w/2, -h/2);
            temp.popMatrix();
            temp.endDraw();
            src = temp;
        }
    }
    
    // Now 'src' is the clean (no color effects) but transformed image.
    // Its dimensions should match importer.canvas (where the selection was made).
    
	PGraphics newCanvas = createGraphics(isw, ish);
	newCanvas.beginDraw();
	newCanvas.image(src, 0, 0, isw, ish, isx, isy, isx + isw, isy + ish);
	newCanvas.endDraw();
	
	// Commit the crop as the new original
	importer.originalCanvas = newCanvas;
    
    // Reset geometric sliders since we baked them into the new original
    if (cut_sidebar != null) {
        cut_sidebar.scaleVal = 1.0;
        cut_sidebar.rotationDeg = 0;
    }

	// Re-apply all effects (Basics, Color, Details) to the new clean original
    applyPipeline();

	isSelecting = false;
}

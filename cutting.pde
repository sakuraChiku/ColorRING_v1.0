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
	println("cutting_mousePressed: mouse= " + mouseX + "," + mouseY);
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
	println("cutting_mouseDragged: mouse= " + mouseX + "," + mouseY + " isSelecting=" + isSelecting);
	if (!isSelecting) return;
	if (importer == null) return;
	// limit to image display bounds
	float ix = importer.x;
	float iy = importer.y;
	float iw = importer.displayWidth;
	float ih = importer.displayHeight;
	selX2 = constrain(mouseX, ix, ix+iw);
	selY2 = constrain(mouseY, iy, iy+ih);
}

void cutting_mouseReleased() {
	if (run[1] != 1) return;
	if (!isSelecting) return;
	if (importer == null || importer.canvas == null) {
		isSelecting = false;
		return;
	}
	println("cutting_mouseReleased: sel= " + selX1 + "," + selY1 + " -> " + selX2 + "," + selY2);

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
	println("cutting_mouseReleased: canvas size=" + importer.canvas.width + "x" + importer.canvas.height + " crop=" + isx +"," + isy +"," + isw +"," + ish);

	// perform crop on canvas
	// Avoid creating huge intermediate PImage via get(); draw directly into a new PGraphics
	long pixelCount = (long)isw * (long)ish;
	int maxPixels = 6000000; // ~6MP safety threshold
	float scaleFactor = 1.0;
	if (pixelCount > maxPixels) {
		scaleFactor = sqrt((float)maxPixels / (float)pixelCount);
	}
	int targetW = max(1, int(isw * scaleFactor));
	int targetH = max(1, int(ish * scaleFactor));
	PGraphics newCanvas = createGraphics(targetW, targetH);
	newCanvas.beginDraw();
	newCanvas.image(importer.canvas, 0, 0, targetW, targetH, isx, isy, isx + isw, isy + ish);
	newCanvas.endDraw();
	importer.canvas = newCanvas;
	// commit cropped result as base originalCanvas
	importer.originalCanvas = importer.canvas;

	// update img used for display and re-calc placement
	importer.img = importer.canvas.get();
	importer.scaleAndPositionImage();

	isSelecting = false;
}

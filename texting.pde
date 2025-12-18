import java.util.ArrayList;

class TextEditor {
    ArrayList<TextBox> boxes;
    TextBox activeBox = null;
    PFont arial, times, courier, georgia;
    TextEditor() {
        boxes = new ArrayList<TextBox>();
    }

    void setup() {
        // load fonts (names chosen for macOS; fallbacks provided by Processing if not found)
        arial = createFont("Arial", 24, true);
        times = createFont("Times New Roman", 24, true);
        courier = createFont("Courier New", 24, true);
        georgia = createFont("Georgia", 24, true);
        // do not set global cursor here; cursor is controlled by main sketch
        textFont(arial, 24);
    }

    void mouseClicked() {
        // Only allow creating/activating textboxes inside the designated text area
        if (!isInTextArea(mouseX, mouseY)) {
            // clicking outside deactivates any active box and does nothing else
            if (activeBox != null) {
                activeBox.active = false;
                activeBox = null;
            }
            return;
        }

        // check existing boxes from topmost (last) to first
        for (int i = boxes.size()-1; i >= 0; i--) {
            TextBox b = boxes.get(i);
            if (b.contains(mouseX, mouseY)) {
                // activate this box
                if (activeBox != null) activeBox.active = false;
                activeBox = b;
                activeBox.active = true;
                activeBox.setCaretByMouse(mouseX, mouseY);
                return;
            }
        }
        // not clicked on any box -> create new textbox at mouse
        if (activeBox != null) activeBox.active = false;
        TextBox t = new TextBox(mouseX, mouseY);
        boxes.add(t);
        activeBox = t;
    }

    // defined text area (inclusive)
    boolean isInTextArea(int mx, int my) {
        return (mx >= 0 && mx <= 550 && my >= 100 && my <= 600);
    }

    void keyPressed() {
        if (activeBox == null) return;
        activeBox.handleKey();
    }

    void draw() {
        for (int i = 0; i < boxes.size(); i++) {
            boxes.get(i).drawBox();
        }
    }

    // draw boxes without any active caret (for when text tool is not selected)
    void drawStatic() {
        for (int i = 0; i < boxes.size(); i++) {
            TextBox b = boxes.get(i);
            pushStyle();
            textFont(b.textFont, b.textSize);
            for (int j = 0; j < b.lines.size(); j++) {
                float yy = b.y + j * b.lineHeight;
                fill(b.textColor);  // use box's text color
                String line = b.lines.get(j);
                float offset = 0;
                for (int k = 0; k < line.length(); k++) {
                    String cs = line.substring(k, k+1);
                    text(cs, b.x + offset, yy);
                    offset += textWidth(cs);
                }
            }
            popStyle();
        }
    }

    // draw only the caret for the active box (called when text tool active)
    void drawActiveCaret() {
        if (activeBox == null) return;
        TextBox b = activeBox;
        if (!b.active) return;
        pushStyle();
        textFont(b.textFont, b.textSize);
        String cur = b.lines.get(b.caretLine);
        float tw = b.measureWidth(cur.substring(0, min(b.caretChar, cur.length())));
        float cy = b.y + b.caretLine * b.lineHeight;
        stroke(0);
        line(b.x + tw, cy - textAscent(), b.x + tw, cy + textDescent());
        popStyle();
    }

    void deactivate() {
        if (activeBox != null) {
            activeBox.active = false;
        }
    }

    // ensure there is an active textbox; if none, create one at given coords
    void ensureActiveBox(int xPos, int yPos) {
        if (activeBox == null) {
            TextBox t = new TextBox(xPos, yPos);
            boxes.add(t);
            activeBox = t;
            activeBox.active = true;
        } else {
            // reactivate existing box
            activeBox.active = true;
        }
    }

    // set text color for active box
    void setActiveBoxColor(int r, int g, int b) {
        if (activeBox != null) {
            activeBox.textColor = color(r, g, b);
        }
    }
    
    // set font for active box
    void setActiveBoxFont(int fontIndex) {
        if (activeBox != null) {
            PFont selectedFont;
            switch(fontIndex) {
                case 0: selectedFont = arial; break;
                case 1: selectedFont = times; break;
                case 2: selectedFont = courier; break;
                case 3: selectedFont = georgia; break;
                default: selectedFont = arial;
            }
            activeBox.textFont = selectedFont;
        }
    }
    
    // set font size for active box
    void setActiveBoxSize(int size) {
        if (activeBox != null) {
            activeBox.textSize = size;
            activeBox.lineHeight = textAscent() + textDescent() + 8;
        }
    }
    
    // get font index of active box
    int getActiveBoxFontIndex() {
        if (activeBox == null) return 0;
        if (activeBox.textFont == arial) return 0;
        if (activeBox.textFont == times) return 1;
        if (activeBox.textFont == courier) return 2;
        if (activeBox.textFont == georgia) return 3;
        return 0;
    }
    
    // get font size of active box
    int getActiveBoxSize() {
        if (activeBox == null) return 24;
        return activeBox.textSize;
    }

    class TextBox {
        int x, y; // baseline start
        ArrayList<String> lines;
        int caretLine;
        int caretChar;
        float lineHeight;
        boolean active;
        color textColor;  // color of text in this box
        PFont textFont;  // font for this box
        int textSize;    // font size for this box

        TextBox(int x_, int y_) {
            x = x_;
            y = y_;
            lines = new ArrayList<String>();
            lines.add("");
            caretLine = 0;
            caretChar = 0;
            lineHeight = textAscent() + textDescent() + 8;
            active = true;
            textColor = color(0);  // default black
            textFont = arial;  // default font
            textSize = 24;     // default size
        }

        void drawBox() {
            pushStyle();
            textFont(textFont, textSize);
            for (int i = 0; i < lines.size(); i++) {
                float yy = y + i * lineHeight;
                fill(textColor);  // use text color
                String line = lines.get(i);
                float offset = 0;
                for (int j = 0; j < line.length(); j++) {
                    String cs = line.substring(j, j+1);
                    text(cs, x + offset, yy);
                    offset += textWidth(cs);
                }
            }
            if (active) {
                String cur = lines.get(caretLine);
                float tw = measureWidth(cur.substring(0, min(caretChar, cur.length())));
                float cy = y + caretLine * lineHeight;
                stroke(0);
                line(x + tw, cy - textAscent(), x + tw, cy + textDescent());
            }
            popStyle();
        }

        boolean contains(int mx, int my) {
            float top = y - textAscent() - 4;
            float bottom = y + lines.size() * lineHeight + 4;
            return (mx >= x - 6 && mx <= width && my >= top && my <= bottom);
        }

        void setCaretByMouse(int mx, int my) {
            int idx = floor((my - y) / lineHeight);
            if (idx < 0) idx = 0;
            if (idx >= lines.size()) idx = lines.size() - 1;
            caretLine = idx;
            String line = lines.get(caretLine);
            caretChar = 0;
            float acc = 0;
            for (int i = 0; i < line.length(); i++) {
                String cs = line.substring(i, i+1);
                acc += measureWidth(cs);
                if (x + acc > mx) {
                    caretChar = i;
                    return;
                }
                caretChar = i+1;
            }
        }

        void handleKey() {
            if (key == CODED) {
                if (keyCode == LEFT) {
                    if (caretChar > 0) {
                        caretChar--;
                    } else if (caretLine > 0) {
                        caretLine--;
                        caretChar = lines.get(caretLine).length();
                    }
                } else if (keyCode == RIGHT) {
                    String cur = lines.get(caretLine);
                    if (caretChar < cur.length()) {
                        caretChar++;
                    } else if (caretLine < lines.size() - 1) {
                        caretLine++;
                        caretChar = 0;
                    }
                }
                return;
            }

            if (key == BACKSPACE) {
                if (caretChar > 0) {
                    String cur = lines.get(caretLine);
                    String updated = cur.substring(0, caretChar-1) + cur.substring(caretChar);
                    lines.set(caretLine, updated);
                    caretChar--;
                } else if (caretLine > 0) {
                    String cur = lines.get(caretLine);
                    int prevLen = lines.get(caretLine-1).length();
                    String merged = lines.get(caretLine-1) + cur;
                    lines.set(caretLine-1, merged);
                    lines.remove(caretLine);
                    caretLine--;
                    caretChar = prevLen;
                }
                return;
            }

            if (key == ENTER || key == RETURN) {
                String cur = lines.get(caretLine);
                String left = cur.substring(0, caretChar);
                String right = cur.substring(caretChar);
                lines.set(caretLine, left);
                lines.add(caretLine+1, right);
                caretLine++;
                caretChar = 0;
                return;
            }

            if (key != CODED && key >= ' ') {
                String cur = lines.get(caretLine);
                String updated = cur.substring(0, caretChar) + key + cur.substring(caretChar);
                if (measureWidth(updated) + x < width - 10) {
                    lines.set(caretLine, updated);
                    caretChar++;
                }
            }
        }

        // measure width of a string by summing per-character widths using appropriate fonts
        float measureWidth(String s) {
            float acc = 0;
            for (int i = 0; i < s.length(); i++) {
                acc += textWidth(s.substring(i, i+1));
            }
            return acc;
        }
    }
}

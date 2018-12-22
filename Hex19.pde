// hex 19
// https://www.theguardian.com/science/datablog/2018/dec/15/royal-statistical-society-christmas-quiz-25th-anniversary-edition

PShape hexShape;
HashMap<Integer, Hex> hexes = new HashMap();

int STEPS = 19;
int SIZE = 40;
HashMap<Integer, ArrayList<Integer>> markov = new HashMap();

// split into 10s for no real reason
int[] indexes = {
  11, 12, 13,
  25, 26, 27, 28, 
  31, 32,
  40, 41, 42, 43, 46, 47, 48, 49,
  53, 54, 55, 56, 57, 58, 59,
  62, 63, 64, 65, 66, 67, 68, 69,
  70, 71, 72, 73, 76, 77, 78, 79,
  80, 81, 82, 83, 84, 85, 86,
  90, 91, 93, 94, 95, 96, 97, 98, 99,
  100, 101,
  112, 113, 114, 115, 116,
  128, 129,
  130,
  143, 144, 145,
  158, 159,
  160,
  174
};

void setup() {
  size(1000, 1000);
  textSize(20);
  frameRate(100  );
  textAlign(CENTER, CENTER);
  int i = 0;
  for(int y = 0 ; y < 12 ; y++) {
    for(int x = 0 ; x < 15 ; x++) {
      if (isInIndex(i)) {
        if ((x % 2) == 1) {
          hexes.put(i, new Hex(i, 50 + x * SIZE * 1.5, 50 + y * SIZE * .866 * 2));
        } else {
          hexes.put(i, new Hex(i, 50 + x * SIZE * 1.5, 50 + ((float)y + .5) * SIZE * .866 * 2));
        }
      }
      i++;
    }
  }
  
  // calculate the markov chain of possible routes
  // (all directions equally likely)
  for (Integer sourceKey : hexes.keySet()) {
    Hex source = hexes.get(sourceKey);
    ArrayList<Integer> list = new ArrayList<Integer>();
    for(Integer destKey : hexes.keySet()) {
      if (sourceKey == destKey) {
        continue;
      }
      Hex dest = hexes.get(destKey);
      if (dist(source.x, source.y, dest.x, dest.y) < 2 * SIZE) {
        list.add(dest.index);
      }
    }
    println(source.index, ": ", list);
    markov.put(source.index, list);
  }
}

void keyPressed() {
  saveFrame("Hex19_###.png");
}

boolean isInIndex(int index) {
  for (int i = 0 ; i < indexes.length ; i++) {
    if (indexes[i] == index) {
      return true;
    }
  }
  return false;  
}

int min = 0, max = 1; // for heatmap
void draw() {
  background(0);
  for (Hex h : hexes.values()) {
    h.draw();
  }
  // start at the start
  int position = 11;
  Hex p0 = hexes.get(position);

  // green spot at beginning
  noStroke();
  fill(0, 255, 0, 128);
  ellipse(p0.x, p0.y, SIZE, SIZE);

  // random walk
  Hex p1 = null;
  for (int i = 0 ; i < STEPS ; i++) {
    ArrayList<Integer> list = markov.get(position);
    int newPosition = list.get((int)random(list.size()));
    p0 = hexes.get(position);
    p1 = hexes.get(newPosition);
    stroke(0, 64, 0);
    strokeWeight(5);
    line(p0.x, p0.y, p1.x, p1.y);
    position = newPosition;
  }
  // increment the count of the hex at the final position
  p1.count++;
  if (p1.count > max) {
    max = p1.count;
  }

  // red spot at end
  noStroke();
  fill(255, 0, 0, 128);
  ellipse(p1.x, p1.y, SIZE, SIZE);
}

// debug, to define shape
void mouseClicked() {
  Hex mini = null;
  float mind = 10000000;
  for(Hex hex : hexes.values()) {
    float d = dist(mouseX, mouseY, hex.x, hex.y);
    if (d < mind) {
      mini = hex;
      mind = d;
    }
  }
  mini.selected = !mini.selected;
  
  println("#################");
  for (Hex h : hexes.values()) {
    if (h.selected) {
      println(h.index);
    }
  }
}

class Hex {
  float x, y;
  boolean selected;
  int index;
  int count;
  
  Hex(int i, float x, float y) {
    this.index = i;
    this.x = x;
    this.y = y;
  }
  
  void draw() {
    // define shape first time through
    if (hexShape == null) {
      hexShape = createShape();
      hexShape.beginShape();
      hexShape.stroke(0);
      hexShape.strokeWeight(4);
      for (int i = 0 ; i < 6 ; i++) {
        float angle = TWO_PI * i / 6.0;
        hexShape.vertex(SIZE * cos(angle), SIZE * sin(angle));
      }
      hexShape.endShape(CLOSE);
    }
    // hsb for heatmap
    colorMode(HSB, 360, 100, 100);
    // 240 is blue, 360 is red
    color col = color((int)map(count, min, max, 240, 360), 75, 75);
    hexShape.setFill(col);
    shape(hexShape, x, y);

    // back to rgb
    colorMode(RGB);
    stroke(0);
    fill(0);
    text(count, x, y);
    /*
    if (selected) {
      stroke(0);
      line(x - 10, y - 10, x + 10, y + 10);
      line(x - 10, y + 10, x + 10, y - 10);
    }
    */
  }
}

// PINS DEFINITION
#define PIN_RED 0
#define PIN_BLUE 1
#define PIN_GREEN 2

#define PIN_BUTTON 3
#define PIN_SENSOR 4

// FLAGS DEFINITION
#define FLAG_R 1
#define FLAG_G 2
#define FLAG_B 4

#define OFF 0
#define ON 1

// States
byte colourMode;
byte ledState;
boolean randomMode;
boolean randomShock;

// Global variables
int count;
int count1;

void setup() {

  // Pin init.
  pinMode(PIN_RED, OUTPUT);
  pinMode(PIN_GREEN, OUTPUT);
  pinMode(PIN_BLUE, OUTPUT);
  pinMode(PIN_BUTTON, INPUT);
  pinMode(PIN_SENSOR, INPUT);

  // Initialize States
  colourMode = FLAG_R + FLAG_G + FLAG_B;
  ledState = OFF;
  randomShock = false;
  randomMode = false;

}

void loop() {

  // Avoid delays, count the time to choose between update colour or switch
  if (digitalRead(PIN_BUTTON) == LOW) {
    // Waiting for button release...
    for (count = 0; count < 200; count++) {
      if (digitalRead(PIN_BUTTON) == HIGH) {
        // Button released

        // Waiting for second button tap...
        for (count1 = 0; count1 < 30; count1++) {
            if (digitalRead(PIN_BUTTON) == LOW) {
              // Double Button Tap.
              count = 220;

              // Interrupt counting, only want to change shock mode
              break;
            }
            delay(5); // 5 milisec * 200 = 1 second
        }

        // No second tap detected.
        // Interrupt counting, only want to update colour
        break;
      }
      delay(5); // 5 milisec * 200 = 1 second
    }

    // More than one second, switch on/off
    if (count == 200) {
      if (ledState == ON) {
        switchOff();
        ledState = OFF;
      }
      else {
        switchOn();
        ledState = ON;
      }
    } else if (count == 220) {
      // Special Double Tap Mode
      if (randomShock == true){
        randomShock = false;
        shock();
      } else {
        randomShock = true;
        shock();
      }
    } else {
      changeColour();
      updateLEDs();
    }
  }

  if (digitalRead(PIN_SENSOR) == LOW) {
    shock();
  }

  if (randomMode) {
      // Colour mode 0, 2, 4, 6, 8 are useless. Red always on.
      // Colour mode 1 (R), 3 (RG), 5 (RB), 7 (RGB)
      colourMode++;
      if (colourMode % 2 == 0) {
        colourMode++;
      }
      if (colourMode > 7) {
        colourMode = 1;
      }
      updateLEDs();
      delay(30);
  }

}

void switchOn() {
  // Prepare other colours on
  if ((colourMode & FLAG_G) == FLAG_G)
    digitalWrite(PIN_GREEN, HIGH);
  if ((colourMode & FLAG_B) == FLAG_B)
    digitalWrite(PIN_BLUE, HIGH);

  // Switch On progressively
    for (count = 0; count <= 255; count++) {
      analogWrite(PIN_RED, count);
      delay(5);
    }
    digitalWrite(PIN_RED, HIGH);
}

void switchOff() {
  // Switch On progressively
    for (count = 255; count > 0; count--) {
      analogWrite(PIN_RED, count);
      delay(5);
    }
    digitalWrite(PIN_RED, LOW);

    // Switch off other colours
    if ((colourMode & FLAG_G) == FLAG_G)
      digitalWrite(PIN_GREEN, LOW);
    if ((colourMode & FLAG_B) == FLAG_B)
      digitalWrite(PIN_BLUE, LOW);
}

// Check colour state and set next state
void changeColour() {
  // Red is global colour sw and mandatory
  // [RGB-R-RG-BR]
  
  if (randomMode) {
    colourMode = FLAG_R;
    randomMode = false;
  } else {
    if (colourMode == (FLAG_R | FLAG_G | FLAG_B)) {
      randomMode = true;
      colourMode = 0;
    } else if (colourMode == FLAG_R)
      colourMode = (FLAG_R | FLAG_G);
    else if (colourMode == (FLAG_R | FLAG_G))
      colourMode = (FLAG_R | FLAG_B);
    else if (colourMode == (FLAG_R | FLAG_B))
      colourMode = (FLAG_R | FLAG_G | FLAG_B);
    else
      colourMode = (FLAG_R | FLAG_G | FLAG_B);
  }
  
}

// Update colourMode to LEDs activating them
void updateLEDs() {
  if ((colourMode & FLAG_R) == FLAG_R) {
    if (ledState == ON)
      digitalWrite(PIN_RED, HIGH);
    else
      digitalWrite(PIN_RED, LOW);
  } else
    digitalWrite(PIN_RED, LOW);

  if ((colourMode & FLAG_G) == FLAG_G) {
    if (ledState == ON)
      digitalWrite(PIN_GREEN, HIGH);
    else
      digitalWrite(PIN_GREEN, LOW);
  } else
    digitalWrite(PIN_GREEN, LOW);

  if((colourMode & FLAG_B) == FLAG_B) {
    if (ledState == ON)
      digitalWrite(PIN_BLUE, HIGH);
    else
      digitalWrite(PIN_BLUE, LOW);
  } else
    digitalWrite(PIN_BLUE, LOW);
}

void shock() {
  if (ledState == ON) {
    // Save colour mode.
    byte tempColourMode = colourMode;
    byte countColourMode = 0;

    for (count = 0; count < 5; count++) {
      ledState = OFF;
      updateLEDs();
      delay(30);

      ledState = ON;
      if (randomShock == true) {
        // Colour mode 0, 2, 4, 6, 8 are useless. Red always on.
        // Colour mode 1 (R), 3 (RG), 5 (RB), 7 (RGB)
        countColourMode++;
        if (countColourMode % 2 == 0) {
          countColourMode++;
        }
        if (countColourMode > 7) {
          countColourMode = 1;
        }
        colourMode = countColourMode;
      }
      updateLEDs();
      delay(30);
    }

    for (count = 0; count < 3; count++) {
      ledState = OFF;
      updateLEDs();
      delay(50);
      ledState = ON;
      if (randomShock == true) {
        // Colour mode 0, 2, 4, 6, 8 are useless. Red always on.
        // Colour mode 1 (R), 3 (RG), 5 (RB), 7 (RGB)
        countColourMode++;
        if (countColourMode % 2 == 0) {
          countColourMode++;
        }
        if (countColourMode > 7) {
          countColourMode = 1;
        }
        colourMode = countColourMode;
      }
      updateLEDs();
      delay(50);
    }

    // Restore colour mode.
    colourMode = tempColourMode;
  }
}

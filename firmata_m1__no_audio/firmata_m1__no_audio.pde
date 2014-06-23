//version 1.0.0.0 y
//made in Japan


//Firmata
import org.firmata.*;
import processing.serial.*;
import cc.arduino.*;

//Arduino ,pressure sensor
Arduino arduino;
int sensor_pin = 0;
//motor x1
int motorA = 7;
int motorB = 8;
int PWM_mot = 9;


float sensor_value;
int sen_v;
//boolean playing = player.isPlaying();
boolean run = true;
int mode=0;
int max_hippari=0;

void setup() {
  size(400, 200);
  //println(Arduino.list()); //list ports
  arduino = new Arduino(this, Arduino.list()[2], 57600);
}

void draw() {
  background(0);
  fill(255);
  float millis = millis();

  //Debug
  text("sensor: " + sensor_value, 10, 20);
  text("mode: " + mode, 10, 40);
  String run_string =String.valueOf( run );
  text("run: " + run_string, 10, 60); 

  //  String playing_string =String.valueOf( player.isPlaying() );
  //  text("playing: " + playing_string, 10, 80); 
  //  text("playing: " + player.isPlaying(), 10, 80); 


  if (millis % 5 == 0) {
    //read sensor value
    float sensor_ori_value = arduino.analogRead(sensor_pin);
    sensor_value = map(sensor_ori_value, 0, 665, 0, 100);
  } else { //run motor
    if (run) {
            if (sensor_value <=50 ) {
        mode = 3;
        max_hippari=1; //最大まで引っ張られたことを記録
        arduino.digitalWrite(motorA, Arduino.LOW);
        arduino.digitalWrite(motorB, Arduino.HIGH);
        arduino.analogWrite(PWM_mot, 170);
      } 
//      if (sensor_value <= 50) {
//        mode = 3;
//        max_hippari=1; //最大まで引っ張られたことを記録
//        arduino.digitalWrite(motorA, Arduino.LOW);
//        arduino.digitalWrite(motorB, Arduino.HIGH);
//        arduino.analogWrite(PWM_mot, 170);
//      } 
//      else if (sensor_value > 30 && sensor_value <= 70) {
//        mode = 2;
//        arduino.digitalWrite(motorA, Arduino.LOW);
//        arduino.digitalWrite(motorB, Arduino.HIGH);
//        arduino.analogWrite(PWM_mot, 139);
//      } 
//      else if (sensor_value > 70 && sensor_value <= 90) {
//        mode = 1;
//        arduino.digitalWrite(motorA, Arduino.LOW);
//        arduino.digitalWrite(motorB, Arduino.HIGH);
//        arduino.analogWrite(PWM_mot, 58);
//      } 
      else {
        mode = 0;
        arduino.digitalWrite(motorA, Arduino.LOW);
        arduino.digitalWrite(motorB, Arduino.LOW);
      }
    }
  }
}



void mouseClicked() {
  if (run) {
    run = false;
  } else {
    run = true;
  }
}

//sound stop
void stop()
{

}

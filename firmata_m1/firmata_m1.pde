//version 1.0.0.0 //<>//
//made in Japan

//予定
//・音声ファイルのパスの一元管理
//・何も引っ張っていないときでもたまに鳴き声流す
//・（電源をACに）

//課題
//音声ファイル再生、コードの書き方がおかしい気がする
//今のコードだと常にmode==3のときにしか流れない。
//→途中でmode==2になると切れる。

//Firmata
import org.firmata.*;
import processing.serial.*;
import cc.arduino.*;

//Sound
import ddf.minim.*;
Minim minim;
AudioPlayer player_nukareta; //抜かれた時
AudioPlayer player_1; //mode1
AudioPlayer player_2; //mode2
AudioPlayer player_3; //mode3



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
  minim = new Minim(this);
  player_nukareta = minim.loadFile("../../Sound/hya-yorokobi.mp3");
  player_3 = minim.loadFile("../../Sound/aaaaa.mp3");
  player_2 = minim.loadFile("../../Sound/ho-rarechara.mp3");
  player_1 = minim.loadFile("../../Sound/fuck-e.mp3");
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
    nakigoe(); //play sounds
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

void nakigoe() {
  if (!player_nukareta.isPlaying() && !player_3.isPlaying() && !player_2.isPlaying() && !player_1.isPlaying()) { //play sound
    if (max_hippari == 1 && sensor_value > 95 ) {
      player_nukareta.play();
      max_hippari = 0;
    }
    if (mode == 3) {
      player_3.play();
    } else if (mode == 2) {
      player_2.play();
    } else if (mode == 1) {
      player_1.play();
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
  player_nukareta.close();
  player_1.close();
  player_2.close();
  player_3.close();
  minim.stop();
  super.stop();
}

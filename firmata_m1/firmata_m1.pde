//version 1.0.1.0 Dev //<>//
//made by Shohei N. in Japan 
//special thanks to Kento S. for advice

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
AudioPlayer player_pulled; //抜かれた時
AudioPlayer player_1; //mode1
AudioPlayer player_2; //mode2
AudioPlayer player_3; //mode3

//Arduino,pressure sensor
Arduino arduino;
int sensor_pin = 0;
//motor x1
int motorA = 7;
int motorB = 8;
int PWM_mot = 9;


float sensor_value;
boolean run = true;
//Hippari Gui
int mode=0;
int max_hippari=0;

boolean playing;
int waitingchirp;

void setup() {
  size(400, 200);
  //println(Arduino.list()); //list ports
  arduino = new Arduino(this, Arduino.list()[2], 57600);
  // set up MusicPlayer
  minim = new Minim(this);
  player_pulled = minim.loadFile("../../Sound/hya-yorokobi.mp3");
  player_3 = minim.loadFile("../../Sound/aaaaa.mp3");
  player_2 = minim.loadFile("../../Sound/ho-rarechara.mp3");
  player_1 = minim.loadFile("../../Sound/fuck-e.mp3");

  //
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
  //String playing_string =String.valueOf( player_1.isPlaying() );
  text("playing_1: " + player_1.isPlaying(), 10, 100); 
  text("playing_2: " + player_2.isPlaying(), 10, 120); 
  text("playing_3: " + player_3.isPlaying(), 10, 140); 
  text("playing_pulled: " + player_pulled.isPlaying(), 10, 160); 


  if (millis % 5 == 0) {
    //read sensor value
    float sensor_ori_value = arduino.analogRead(sensor_pin);
    sensor_value = map(sensor_ori_value, 0, 665, 0, 100);

    //play sounds -nakigoe
    if (!player_pulled.isPlaying() && !player_3.isPlaying() && !player_2.isPlaying() && !player_1.isPlaying()) { //play sound
      if (max_hippari == 1 && sensor_value > 95 ) {
        nakigoe(true, player_pulled);
        max_hippari = 0;
      }
      if (mode == 3) {
        nakigoe(true, player_3);
      } else if (mode == 2) {
        nakigoe(true, player_2);
      } else if (mode == 1) {
        nakigoe(true, player_1);
      }
    }
  } else { //run motor
    if (run) {
      if (sensor_value <= 50) {
        mode = 3;
        max_hippari=1; //最大まで引っ張られたことを記録
        arduino.digitalWrite(motorA, Arduino.LOW);
        arduino.digitalWrite(motorB, Arduino.HIGH);
        arduino.analogWrite(PWM_mot, 170);
      } else if (sensor_value > 30 && sensor_value <= 70) {
        mode = 2;
        arduino.digitalWrite(motorA, Arduino.LOW);
        arduino.digitalWrite(motorB, Arduino.HIGH);
        arduino.analogWrite(PWM_mot, 139);
      } else if (sensor_value > 70 && sensor_value <= 90) {
        mode = 1;
        arduino.digitalWrite(motorA, Arduino.LOW);
        arduino.digitalWrite(motorB, Arduino.HIGH);
        arduino.analogWrite(PWM_mot, 58);
      } else {
        mode = 0;
        arduino.digitalWrite(motorA, Arduino.LOW);
        arduino.digitalWrite(motorB, Arduino.LOW);
      }
    }
  }
}

void nakigoe(boolean frag, AudioPlayer myPlayer) {
  if (frag) {
    myPlayer.play();
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
  player_pulled.close();
  player_1.close();
  player_2.close();
  player_3.close();
  minim.stop();
  super.stop();
}

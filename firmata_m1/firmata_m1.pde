//version 1.4 Dev //<>//
//made by Shohei N. in Japan 
//special thanks to Kento S. for advice

//予定
//抜いた人参を戻したときの検知
//引き合ってる時の音量下げる
//引き合いと抜けたあとの音がかぶる

//Firmata
import org.firmata.*;
import processing.serial.*;
import cc.arduino.*;

//Sound
import ddf.minim.*;
Minim minim;
AudioPlayer player_1[]=new AudioPlayer[2]; //土の中での存在感,もう１個音源あり未実装
AudioPlayer player_3[]=new AudioPlayer[4]; //引っ張られる
AudioPlayer player_4[]=new AudioPlayer[4]; //抜けた時ぽん
AudioPlayer player_5[]=new AudioPlayer[4]; //抜けたあと
AudioPlayer player_6[]=new AudioPlayer[2]; //戻された時
//※2の場面は音声なし

//play random sounds
int x1;
int x3;
int x4;
int x5;
int x6;


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
boolean mode1=false;
boolean max_hippari=false;
int mode1random;

boolean playing = false;
float waitingchirp;

void setup() {
  size(300, 500);
  //println(Arduino.list()); //list ports
  arduino = new Arduino(this, Arduino.list()[2], 57600);
  // set up MusicPlayer
  minim = new Minim(this);
  player_1[0] = minim.loadFile("1_cpz-n.mp3");
  player_1[1] = minim.loadFile("1_mg.mp3");
  player_3[0] = minim.loadFile("3_hya1.mp3");
  player_3[1] = minim.loadFile("3_hya2.mp3");
  player_3[2] = minim.loadFile("3_hya3best.mp3");
  player_3[3] = minim.loadFile("3_mn.mp3");
  player_4[0] = minim.loadFile("4_corkpon.mp3");
  player_4[1] = minim.loadFile("4_iyopon.mp3");
  player_4[2] = minim.loadFile("4_pon-yt.mp3");
  player_4[3] = minim.loadFile("4_ryopon.mp3");
  player_5[0] = minim.loadFile("5_ha-1.mp3");
  player_5[1] = minim.loadFile("5_ha-2.mp3");
  player_5[2] = minim.loadFile("5_ha-nao.mp3");
  player_5[3] = minim.loadFile("5_oko.mp3");
  player_6[0] = minim.loadFile("6_fu1.mp3");
  player_6[1] = minim.loadFile("6_fu2.mp3");
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
  String playing_string =String.valueOf( playing );
  text("playing: " + playing_string, 10, 100); 
  text("waitingchirp: "+waitingchirp, 10, 120);

  if (millis % 5 == 0) {
    if (run) {
      if (sensor_value <= 70) {
        mode = 1;
        mode1=true;
        max_hippari=true; //最大まで引っ張られたことを記録
        arduino.digitalWrite(motorA, Arduino.LOW);
        arduino.digitalWrite(motorB, Arduino.HIGH);
        arduino.analogWrite(PWM_mot, 170);
      } else {
        mode = 0;
        arduino.digitalWrite(motorA, Arduino.LOW);
        arduino.digitalWrite(motorB, Arduino.LOW);
      }
    }
  } else { 
    //read sensor value
    float sensor_ori_value = arduino.analogRead(sensor_pin);
    sensor_value = map(sensor_ori_value, 0, 665, 0, 100);

    waitingchirp = (int)random(1000);//引いてない時の鳴き声再生
    mode1random = (int)random(10);

    //play sounds -nakigoe
    //if (!player_1.isPlaying() && !player_3.isPlaying() && !player_4.isPlaying() && !player_5.isPlaying() && !player_6.isPlaying()) { //play sound
    if (!playing) {
      if (max_hippari && sensor_value > 95 ) { //抜かれたとき
        //decide playing sounds at random
        x4=(int)random(3);
        x5=(int)random(4);
        playing=true;
        nakigoe(true, player_4[x4]);//pon
        nakigoe(true, player_5[x5]);//after pulling
        max_hippari = false;
      } else if (mode1 && mode1random == 7) { //引っ張りあってるとき
        x3=(int)random(3);
        playing=true;
        nakigoe(true, player_3[x3]);
        mode1=false;
      } else if (mode == 0 && waitingchirp == 7) { //待機時にランダムで
        x1=(int)random(1);
        playing=true;
        nakigoe(true, player_1[x1]);
      }
    }
  }
}

void nakigoe(boolean frag, AudioPlayer myPlayer) {
  if (frag) {
    myPlayer.rewind();
    myPlayer.play();
    playing=false;
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
  //  player_pulled.close();
  //  player_1.close();
  //  player_2.close();
  //  player_3.close();
  //  player_1.close();
  minim.stop();
  super.stop();
}

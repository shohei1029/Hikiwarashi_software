//version 2.1.0.0 Dev for IVRC
//made by Shohei N. in Japan 
//special thanks to HASEKEN, sasaken and Mr.Asano for advice

//課題(ATのときの)
//抜いた人参を戻したときの検知
//引き合ってる時の音量下げる
//引き合いと抜けたあとの音がかぶる
//圧力センサ２つ．力が急激になくなったらなったら揺れがとまる。また引っ張られたら始まる。

//メモ
//ニンジン1を揺らすのはキーボードの'a''A'キーをおした時→このコードの後ろのほうにある
//ニンジン１ 新しく作るもの１ →手動キーボード操作ではじまる．ニンジン２と同様に抜けたら音が鳴る．
//ニンジン２ 従来のものの改良 →ことこと揺れるだけ，ランダム
//ニンジン３ 新しく作るもの２ メインらしい

//↓変更（なおちゃんの気まぐれ
//引っ張られてる感知は圧力センサ。抜けた感知はスイッチ。にんじんささってる＝電流流れてる(ON)  
//ニンジン１と２は音を変えたい。１はちょっとだけでいい。3がメイン。3もボタン押したら勝手に動くように。
//ニンジン3がメイン。ニンジン2がことこと揺れるだけ！！！
//AT東北の音声はニンジン1用。ニンジン3用は新しくとる←ファイルを入れやすいよう変数に。それぞれ３種類くらい

//実装予定（未実装）
//ニンジン３は別音声。分岐自体をなんとかする必要。

//使用法メモ
//キーボード 'a' でニンジン１が揺れて 'b' でニンジン3が揺れるかもね

//Firmata
import org.firmata.*;
import processing.serial.*;
import cc.arduino.*;
import ddf.minim.*;

//ArduinoのPin関係
//Arduino,pressure sensor
Arduino arduino;
int sensor_pin = 0; //ninjin3
int sensor_pin_ninjin1 = 2; //ニンジン1(新設)の圧力センサ
int switch_ninjin1 = 4; //ニンジン１のスイッチ（仮
int switch_ninjin3 = 5; //ニンジン3のスイッチ（仮

//motor 1,3
int motor1 = 1; //仮
int motor3 = 3; //仮
//motor 2 (ATで使ったやつ)
int motorA = 7;
int motorB = 8;
int PWM_mot = 9;





//Sound
Minim minim;
//ニンジン1用にする
AudioPlayer player_1[]=new AudioPlayer[2]; //土の中での存在感
AudioPlayer player_3[]=new AudioPlayer[4]; //引っ張られる
AudioPlayer player_4[]=new AudioPlayer[4]; //抜けた時ぽん
AudioPlayer player_5[]=new AudioPlayer[4]; //抜けたあと
AudioPlayer player_6[]=new AudioPlayer[2]; //戻された時
//ニンジン3(メイン)用
AudioPlayer ninjin3_player_1[]=new AudioPlayer[2]; //土の中での存在感
AudioPlayer ninjin3_player_3[]=new AudioPlayer[4]; //引っ張られる
AudioPlayer ninjin3_player_4[]=new AudioPlayer[4]; //抜けた時ぽん
AudioPlayer ninjin3_player_5[]=new AudioPlayer[4]; //抜けたあと
AudioPlayer ninjin3_player_6[]=new AudioPlayer[2]; //戻された時
//※2の場面は音声なし

//play random sounds
//鳴き声を出すときとか，何番目の鳴き声を出すかがランダムで決めた奴が入ってる．
int x1;
int x3;
int x4;
int x5;
int x6;

float sensor_value; //ニンジン3
float sensor_value_ninjin1; //ニンジン1
boolean run = true;
float millis = millis();
//Hippari GuI(ai)
int mode=0;
boolean mode1=false;
boolean max_hippari=false;
int mode1random;

boolean playing = false;
boolean ninjin1 = false;
boolean nuketa_ninjin1 = false;
boolean nuketa_ninjin3 = false;
float waitingchirp;
int ninjin2_shake;


void setup() {
  size(300, 500);
  //println(Arduino.list()); //list ports
  arduino = new Arduino(this, Arduino.list()[2], 57600);
  // set up MusicPlayer
  minim = new Minim(this);
  //ファイル名の設定．
  //player_1 は 待機時にランダムで流すやつ
  //player_2 は 使ってない
  //player_3 は 引っ張られているとき
  //player_4 は 抜けた時のぽんっって音
  //player_5 は 抜けたあとの鳴き声
  //player_6 は ニンジン戻された後の鳴き声，でも戻されたことの検知方法が決まってない
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

  //ニンジン3用．ファイル数は↑のやつと同じにしてくれると楽でいい。
  //ニンジン3は別音声ってのはぶっちゃここだけの話まだ実装していない．先輩方の助言を乞うのも正解 
  ninjin3_player_1[0] = minim.loadFile("1_cpz-n.mp3");
  ninjin3_player_1[1] = minim.loadFile("1_mg.mp3");
  ninjin3_player_3[0] = minim.loadFile("3_hya1.mp3");
  ninjin3_player_3[1] = minim.loadFile("3_hya2.mp3");
  ninjin3_player_3[2] = minim.loadFile("3_hya3best.mp3");
  ninjin3_player_3[3] = minim.loadFile("3_mn.mp3");
  ninjin3_player_4[0] = minim.loadFile("4_corkpon.mp3");
  ninjin3_player_4[1] = minim.loadFile("4_iyopon.mp3");
  ninjin3_player_4[2] = minim.loadFile("4_pon-yt.mp3");
  ninjin3_player_4[3] = minim.loadFile("4_ryopon.mp3");
  ninjin3_player_5[0] = minim.loadFile("5_ha-1.mp3");
  ninjin3_player_5[1] = minim.loadFile("5_ha-2.mp3");
  ninjin3_player_5[2] = minim.loadFile("5_ha-nao.mp3");
  ninjin3_player_5[3] = minim.loadFile("5_oko.mp3");
  ninjin3_player_6[0] = minim.loadFile("6_fu1.mp3");
  ninjin3_player_6[1] = minim.loadFile("6_fu2.mp3");
}



//Main
void draw() {
  background(0);
  fill(255);
  //float millis = millis();

  //Debug,画面に圧力センサの値，メモリの数値/TFを表示
  debug();

  if (millis % 5 == 0) {
    if (run) {
      if (sensor_value <= 90) { //引っ張っている検知 ninjin3
        mode = 1; //mode==1は引っ張りあってることを示す
        mode1=true;
        max_hippari=true; //最大まで引っ張られたことを記録
        //arduino.digitalWrite(motorA, Arduino.LOW); //ニンジン２はことこと揺らすだけなので削除
        //arduino.digitalWrite(motorB, Arduino.HIGH);
        //arduino.analogWrite(PWM_mot, 250);
        arduino.digitalWrite(motor3, Arduino.HIGH);

      } else if (sensor_value_ninjin1 <= 90) {
        mode = 1; //mode==1は引っ張りあってることを示す
        mode1=true;
        max_hippari=true; //最大まで引っ張られたことを記録
        arduino.digitalWrite(motor1, Arduino.HIGH);
  
      } else {
        mode = 0;
        //arduino.digitalWrite(motorA, Arduino.LOW);
        //arduino.digitalWrite(motorB, Arduino.LOW);
        arduino.digitalWrite(motor1, Arduino.LOW);
        arduino.digitalWrite(motor3, Arduino.LOW);


      }
    }
  } else { 
    //read sensor value
    float sensor_ori_value = arduino.analogRead(sensor_pin);
    sensor_value = map(sensor_ori_value, 0, 665, 0, 100); //圧力センサの値を0~100へ正規化
    float sensor_ori_value_ninjin1 = arduino.analogRead(sensor_pin_ninjin1);
    sensor_value_ninjin1 = map(sensor_ori_value_ninjin1, 0, 665, 0, 100); //圧力センサの値を0~100へ正規化

    waitingchirp = (int)random(1000);//引いてない時の鳴き声再生
    mode1random = (int)random(10);
    ninjin2_shake = (int)random(2000);


    //play sounds -nakigoe
    //if (!player_1.isPlaying() && !player_3.isPlaying() && !player_4.isPlaying() && !player_5.isPlaying() && !player_6.isPlaying()) { //play sound
    if (!playing) {
//      if (max_hippari && (sensor_value > 80 || sensor_value_ninjin1 > 80)) { //抜かれたとき
        //"HIGH"は1らしい
        if (arduino.digitalRead(switch_ninjin1) == 0 || arduino.digitalRead(switch_ninjin3) == 0) { //抜かれた時．未テストでうまく動かないかも．そんときは↑コメント消してこっちをコメントアウトしてみ
        //if (millis == pulled_delay + 801) { //抜かれた801ミリ秒後に音声再生
          if (arduino.digitalRead(switch_ninjin1) == 0){
            nuketa_ninjin1 = true;
          } else if (arduino.digitalRead(switch_ninjin3) == 0){
            nuketa_ninjin3 = true;
          }

        x4=(int)random(3); //decide playing sounds at random
        x5=(int)random(4);
        playing=true;

        println("1");
        nakigoe(true, player_4[x4]);//pon
        mmdelay(1000); //1秒(1000ミリ秒)待つ
        nakigoe(true, player_5[x5]); //after pulling

        max_hippari = false;
      } else if (mode1) { //引っ張りあってるとき
        x3=(int)random(3);
        playing=true;
        println("2");
        nakigoe(true, player_3[x3]);
        mmdelay(100); //100ミリ秒待つ

        playing = false;
        mode1=false;
      } else if (nuketa_ninjin1 == true && arduino.digitalRead(switch_ninjin1) == 1) { //抜けたにんじん1が戻された時."HIGH"って返してくれるのか不明．動かなかったら先輩に伺ったほうがいいかも
        nuketa_ninjin1 = false;
        x6=(int)random(1);
        playing=true;
        nakigoe(true,player_6[x6]);
        playing=false;

      } else if (nuketa_ninjin3 == true && arduino.digitalRead(switch_ninjin3) == 1) { //抜けたにんじん3が戻された時
        nuketa_ninjin3 = false;
        x6=(int)random(1);
        playing=true;
        nakigoe(true,player_6[x6]);
        playing=false;
      } else if (mode == 0 && waitingchirp == 7) { //待機時にランダムで.別に7じゃなくてもなんでもいい
        x1=(int)random(1);
        playing=true;
        println("3");
        nakigoe(true, player_1[x1]);
        playing=false;

      } else if (ninjin2_shake == 7) { //ランダムでニンジン2を揺らす
        arduino.digitalWrite(motorA, Arduino.LOW);
        arduino.digitalWrite(motorB, Arduino.HIGH);
        arduino.analogWrite(PWM_mot, 250);
        mmdelay(1000);
        arduino.digitalWrite(motorA, Arduino.LOW);
        arduino.digitalWrite(motorB, Arduino.LOW);

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

void mmdelay(int delay_mm) {
  //  float pulled_delay;
  //  float pulled_delay_after;
  float pulled_delay = millis;
  float pulled_delay_after = pulled_delay;
  while (pulled_delay_after < pulled_delay + delay_mm) {
    pulled_delay_after = millis();
  }
}

void keyPressed() {
  if (key == 'a') {
    //モーター１を動かす動作を入れる
    arduino.digitalWrite(motor1, Arduino.HIGH);
    mmdelay(100);
    arduino.digitalWrite(motor1, Arduino.LOW);

  } else if (key == 'b') {
    //モーター3を動かす動作を入れる
    arduino.digitalWrite(motor3, Arduino.HIGH);
    mmdelay(100);
    arduino.digitalWrite(motor3, Arduino.LOW);

  }
  println(key);
  //arduino.digitalWrite(motor1, Arduino.LOW);
}

void mouseClicked() { //画面上をクリックすることでプログラムの動作をON-OFFできる  
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

void debug() {
  text("sensor: " + sensor_value, 10, 20);
  text("mode: " + mode, 10, 40);
  String run_string =String.valueOf( run );
  text("run: " + run_string, 10, 60); 
  String playing_string =String.valueOf( playing );
  text("playing: " + playing_string, 10, 100); 
  text("waitingchirp: "+waitingchirp, 10, 120);
}

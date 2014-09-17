//Hikiwarashi_hikari version 1.1.0.0 for IVRC
//made by Shohei N. in Japan 
//special thanks to Mr.Asano for advice

//mode 0 はうまくゆっくりしたゆらぎを＜＜簡単に＞＞出す方法が思いつかないため未実装．（ちゃんとやろうと思えばできる）

import ddf.minim.*;
Minim minim;
PImage img;

AudioPlayer move1_sound;
AudioPlayer move2_sound;
AudioPlayer move3_sound;


int mode;
int count_mode0;
int count_mode2;
int count_mode3;



void setup() {
  size(1280, 800);
  mode = 0;
  count_mode2 = 0;
  count_mode3 = 0;
  smooth();
  noStroke();
  img = loadImage("mask.png");

  minim = new Minim(this);
  move1_sound = minim.loadFile("NightForests.mp3");
  //move2_sound = minim.loadFile("Thunderclap.mp3");
  move2_sound = minim.loadFile("thunderstorm_01.mp3");
  move3_sound = minim.loadFile("thunder01.mp3");
}


void draw() {
  background(100);


  text(mode, width/2, height/3);
  //fill(255, 100);
  fill(255);



  switch(mode) {
    case 0:
    move0();
    move2_sound.pause();
    move3_sound.pause();
    play_sound(move1_sound);
    count_mode3 = 0;
    count_mode2 = 0;
    image(img,0,0,width,height);

    break;

    case 1:
    move1();
    move2_sound.pause();
    move3_sound.pause();
    play_sound(move1_sound);
    count_mode3 = 0;
    count_mode2 = 0;
    image(img,0,0,width,height);

    break;

    case 2:    
      //background(0);

      move2();
      move1_sound.pause();
      move3_sound.pause();
      play_sound(move2_sound);
      count_mode3 = 0;
    //count_mode2 = 0;
    image(img,0,0,width,height);

    break;

    case 3:
      //background(0);

      move3();
      move1_sound.pause();
      move2_sound.pause();
      play_sound(move3_sound);
      count_mode2 = 0;
      image(img,0,0,width,height);

      break;

      default:
      count_mode3 = 0;
      count_mode2 = 0;
      break;
    }
  }


  void keyPressed() {
    if (key == '1') {
      mode = 1;
    }
    else if (key == '2') {
      mode = 2;
    }
    else if (key == '3') {
      mode = 3;
    }
    else {
      mode = 0;
    }
    println("mode = " + mode);
  }


  void move0() {
    for (int x = 0; x < width ; x += 50) {
      for (int y = 0 ; y < height ; y += 50) {
        fill(255, 200);
        ellipse(x+random(6), y+random(5, 6), 50, 50);
      }
    }
  }

  void move1() {
    for (int x = 0; x < width ; x += 30) {
      for (int y = 0 ; y < height ; y += 30) {
        fill(255, 200);
        ellipse(x+random(6), y+random(5, 6), 30, 30);
      }
    }
  }

  void move2() {
    if(count_mode2 >= 0 && count_mode2 < 60){  

      if (count_mode2 %15 == 0) {
        fill(255);
      }
      else {
        fill(100);
      }
      rect(0, 0, width, height);
      count_mode2++;

    }

  }

  void move3() {
    if(count_mode3 > 5 && count_mode3 < 20){  
      fill(255);
    }
    else {
      fill(100);
    }
    rect(0, 0, width, height);
    count_mode3++;
  }

  void play_sound(AudioPlayer myPlayer) {
    if (myPlayer.isPlaying() != true){
      myPlayer.rewind();
    }
    myPlayer.play();
  }


  void stop()
  {
    move1_sound.close();
    move2_sound.close();
    move3_sound.close();
    minim.stop();
    super.stop();
  }

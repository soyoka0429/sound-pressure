import ddf.minim.*;
import ddf.minim.analysis.*;

import processing.serial.*;
Serial myPort;
int S_a1;

Minim minim; //Minim型変数であるminimの宣言
AudioPlayer player;  //サウンドデータ格納用の変数
FFT fft;    //フーリエ変換用変数

PImage img;

void setup(){
  colorMode( HSB, 360, 100, 100 );
  size(512,160);
  //stroke(223,61,99);
  myPort=new Serial(this,"/dev/cu.usbmodem14301",9600);  //シリアル通信の初期化
  
  minim = new Minim(this);
  S_a1 = 45; //LEDを光らせる閾値 105ですっきり動く？
  
  // 解析する音楽
  player = minim.loadFile("sample.mp3", 512);  //練習1024→これ512
  
  player.loop();
 
  //FFTオブジェクトを作成。bufferSize()は1024、sampleRateは初期設定では44100Hz。
  fft = new FFT(player.bufferSize(), player.sampleRate());
  println("sampling reate is " +player.sampleRate());
  println("spec size is " +fft.specSize());
  println("bandwidth is: " +fft.getBandWidth());    //最小単位の帯域
  
  img = loadImage("a.png");
}

void draw()
{
  //S_a1 = 85; //LEDを光らせる閾値
  
  background(223,0,96);
  noStroke();
  fill(219,7,93);
  rect(35,92,147,30,6);
  rect(328,92,147,30,6);
  //ボタン増
  if (mousePressed == true){
    if(mouseX < 200){
      fill(219,40,93);
      rect(35,92,147,30,6);
    }
  }
  //ボタン減
  if (mousePressed == true){
    if(mouseX > 300){
      fill(219,40,93);
      rect(328,92,147,30,6);
    }
  }
  
  //バー
  stroke(219,5,93);
  noFill();
  rect(50,55,412,20);
  noStroke();
  fill(219,89-S_a1,93);
  rect(50,55,412-5*S_a1,20);
  
  image(img, 0, 0);
 
  //fftを左と右の音声を混ぜて解析
  //左右の音をそれぞれ取りたければ、player.left、player.rightという形で使う
  fft.forward(player.mix);
  
  // 周波数帯（86.133〜172.266）が閾値以上の時，シリアルでを送信
  if (fft.getBand(1) > S_a1){ 
   myPort.write('1');  //電気信号は0か1かだね
  }
  else{
    myPort.write('0');
  }
  //この信号は、電圧の制御というより点く/点かないの制御…向いてない？
  //理想はバッファサイズで電圧の大きさが変わる
  
  //サンプリングレートが44100Hzの場合、実際の周波数はその半分の0~22050Hzしか入っていない。
  //なので、バッファサイズが1024だとすると、specSize()はバッファ/2 +1 になる。つまり513。
  //また、バッファが1024ということは、44100Hzを1024分割していることになり、結果BandWidthは43.066406になる。
  stroke(255);
  //line(0,height-S_a1*4,width,height-S_a1*4); // 閾値ライン
  
  for(int i = 0; i < fft.specSize(); i++)
  {
    //画面のy座標の中心から上下に延びる線を描く
    stroke(i*0.4+207,-i*0.3+98,96);
    float x1 = map(i,0,fft.specSize(),0,width);
    line(x1, height, x1, (height - fft.getBand(i)*4/1.7));
  }
  
  //閾値操作、上
  if(412-5*S_a1 > 5){
  if(pmouseX > 1){
    if(pmouseX < 250){
      if (mousePressed == true){
        S_a1 += 1;
      }
    }
  }
  }
  
  //閾値操作、下
  if(412-5*S_a1 < 412){
  if(pmouseX > 260){
    if(pmouseX < 512){
      if (mousePressed == true){
        S_a1 -= 1;
      }
    }
  }
  }
  
}
 
void stop()
{
  player.close();// アプリケーションの終了前にAudioPlayerを終了する
  
  minim.stop();  // minimを終了
  
  super.stop();  //ソフト全体を終了
}

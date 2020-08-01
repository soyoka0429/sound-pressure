void setup(){
  Serial.begin(9600);
  pinMode(13,OUTPUT); //デジタルpin13
}

void loop(){
  //シリアルボードからデータを受け取ったら
  if(Serial.available() >0){

    //受診したデータを読み込む
    char data = Serial.read();

    //データが1なら点灯
    if(data == '1'){
      digitalWrite(13,HIGH); //デジタルpin13出力オン
    }

    //データが0なら点灯
    if(data == '0'){
      digitalWrite(13,LOW); //デジタルpin13出力オン
    }
  }
  
}

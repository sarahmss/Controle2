#define VelocidadePin 9 // Jumper Amarelo
#define Rotacao1Pin 10 // Jumper Branco
#define Rotacao2Pin 11 // Jumper Preto
#define TensaoGerador A0 

#define Duracao_Resposta 3000000 // [us] -> 3 [s]

#define u 250

void setup(){
  pinMode(VelocidadePin, OUTPUT);
  pinMode(Rotacao1Pin, OUTPUT);
  pinMode(Rotacao2Pin, OUTPUT);
  pinMode(TensaoGerador, INPUT);
  Serial.begin(115200);

  //Essas configurações tem que ser mantida, para não ter entrada negativa no arduino/
  digitalWrite(Rotacao1Pin,1); 
  digitalWrite(Rotacao2Pin,0);
  Serial.print("Tempo,Saida/");

}

/*
  @brief: 
    Função para aplicar uma entrada e coletar 
    dados do sistema em malha aberta
  @param:
    — u: Entrada degrau do sistema u[n]
  */

void loop(){

  // Ativa o motor
  analogWrite(VelocidadePin, u); 

  while( micros() <= Duracao_Resposta){
    Serial.print(micros());
    Serial.print(",");
    Serial.print(analogRead(TensaoGerador));
    Serial.print("/");
    
  }
  // Desativa o motor
  analogWrite(VelocidadePin, 0); 
  _delay_us(6900);

}
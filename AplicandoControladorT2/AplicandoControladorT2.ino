#define VelocidadePin 9 // Jumper Amarelo
#define Rotacao1Pin 10 // Jumper Branco
#define Rotacao2Pin 11 // Jumper Preto
#define Tensao_Gerador A0 

#define Duracao_Resposta 3000000 // [us] -> 3 [s]

int monitor = 0;

void setup(){
  
  pinMode(VelocidadePin, OUTPUT);
  pinMode(Rotacao1Pin, OUTPUT); 
  pinMode(Rotacao2Pin, OUTPUT); 
  pinMode(Tensao_Gerador, INPUT);
  Serial.begin(115200);

  // Essas configurações tem que ser mantida, para não ter entrada negativa no arduino
  digitalWrite(Rotacao1Pin, HIGH);
  digitalWrite(Rotacao2Pin, LOW);
  Serial.print("Tempo,Entrada,Erro,Saida/");
}

void PrintOut(float un, float en, float yn)
{
    // Tempo percorrido
    Serial.print(micros());
    Serial.print(",");

    // Entrada da planta
    Serial.print(un); 
    Serial.print(",");

    // erro
    Serial.print(en);  
    Serial.print(",");

    // saida 
    Serial.print(yn); 
    Serial.print("/");

}

/*
  @brief: 
    Função principal que implementa um controlador por realimentação de estados com ação integral, 
    em conjunto com um observador de estado. A função estima o estado interno do sistema, 
    calcula a saída estimada e aplica a lei de controle para seguir uma referência constante.

  @variáveis principais:
    — T     : Período de amostragem do sistema discreto
    — Ad    : matriz A do modelo discreto (escalares no caso SISO)
    — Bd    : matriz B do modelo discreto
    — Cd    : matriz C do modelo discreto
    — Dd    : matriz D do modelo discreto

    — K     : Ganho da realimentação de estados
    — Ki    : Ganho do integrador (ação integral)
    — L     : Ganho do observador contínuo
    — Ld    : Ganho do observador discreto (Ld = L * T)

    — R     : Referência desejada (setpoint)
    — uk    : Entrada de controle aplicada ao sistema
    — yk    : Saída real do sistema (medida)
    — xhat  : Estado estimado pelo observador
    — xnk   : Estado do integrador (acumulador do erro)
    — yhat  : Saída estimada pelo observador
    — ek    : Erro entre a referência e a saída real (ek = R - yk)
    — ehat  : Erro de estimação do estado (ehat = xk - xhat)
*/

void loop(){
 // Definindo e inicializando as variáveis
  float T = 0.008;  // Tempo de amostragem
  float Ad = 0.9894; // Matriz A do sistema discretizado
  float Bd = 0.008;  // Matriz B do sistema discretizado
  float Cd = 798.1;  // Matriz C do sistema discretizado
  float Dd = 0;  // Matriz C do sistema discretizado

  float K = 4.0032;  // Ganho do controlador
  float Ki = 0.0319;  // Ganho do integrador
  float L = 0.0351;    // Ganho do observador
  float Ld = L * T;    // Ganho do observador
 
  int R = 600;
  int deg = 156;
  float  uk   = 0;
  float  yk   = 0;
  float  xk   = 0;
  float  xhat = 0;
  float  xnk  = 0;
  float  yhat = 0;
  float  ehat = 0;
  float  ek   = R - yk;    
  int changeRef = 10;   
  
  // while(micros() <= 1000000){
  //   // Soft-start
  //   analogWrite(VelocidadePin, deg);  // Ativa o motor com a velocidade da região a qual o controlador foi projetada
  //   yk = analogRead(Tensao_Gerador); // Valor da saída
  //   ek = R - yk;
  //   PrintOut(R, ek, yk);
  //   _delay_us(5800);
  // }
  // analogWrite(VelocidadePin, deg + 10);  // Pequeno incremento da referência para continuar na região linear projetada


  while(micros() <= Duracao_Resposta){
    ek = R - yk;
    ehat = xk - xhat;  

    // Atualização do estado associado ao integrador
    xnk = xnk + (T * ek);
  
    // Estimação da saída
    yhat = Cd * xhat + Dd * uk;

    // Atualização do estado estimado pelo observador
    xhat = ((Ad - Ld*Cd)*xhat) + (Bd * uk)+ (Ld * yk);
    
    // Lei de controle com estado estimado
    uk = -(K)*xhat + (Ki)*xnk;

    uk = uk > 255 ? 255 : uk;
    uk = uk < 0 ? 0 : uk;

    analogWrite(VelocidadePin, (uk * deg));  // Ativa o motor com a nova entrada
    yk = analogRead(Tensao_Gerador); // Valor da saída
    PrintOut((uk * deg), ek, yk);
    _delay_us(5800);

    if (ek == 0){
      changeRef ++;
      if (changeRef == 10){
        R = R + 10; // Pequeno incremento da referência para continuar na região linear projetada
        changeRef = 0;
      }
    }
  }
  // Desativa o motor
  analogWrite(VelocidadePin, LOW); 
}
#define VelocidadePin 9 // Jumper Amarelo
#define Rotacao1Pin 10 // Jumper Branco
#define Rotacao2Pin 11 // Jumper Preto
#define Tensao_Gerador A0 

#define Duracao_Resposta 5000000 // [us] -> 3 [s]

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
  Serial.print("Tempo, Uk, xhat, Erro, Saida/");
}

void PrintOut(float un, float xhat, float en, float yn)
{
    // Tempo percorrido
    Serial.print(micros());
    Serial.print(",");

    // saida do controlador
    Serial.print(un); 
    Serial.print(",");

    // Tensao Aplicada na planta
    Serial.print(xhat); 
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
  
  // Euler
  float Ad = 0.9167; // Matriz A do sistema discretizado
  float Bd = 0.008;  // Matriz B do sistema discretizado
  float Cd = 6198.0;  // Matriz C do sistema discretizado
  float Dd = 0;  // Matriz C do sistema discretizado

  // Tustin
  // float Ad = 0.92; // Matriz A do sistema discretizado
  // float Bd = 0.00768;  // Matriz B do sistema discretizado
  // float Cd = 5950.0;  // Matriz C do sistema discretizado
  // float Dd = 23.8;  // Matriz C do sistema discretizado

  // ZOH
  //float Ad = 0.92; // Matriz A do sistema discretizado
  //float Bd = 0.007676;  // Matriz B do sistema discretizado
  //float Cd = 6198.0;  // Matriz C do sistema discretizado
  //float Dd = 0;  // Matriz C do sistema discretizado

  // Ts down
  //float K = 35.3499;  // Ganho do controlador
  //float Ki = 0.2204;  // Ganho do integrador
  //float L = 0.0368;    // Ganho do observador
  //float Ld = L * T;    // Ganho do observador

  // Up 8% Ts 0.17s
  //float K = 4.8388;  // Ganho do controlador
  //float Ki = 0.0245;  // Ganho do integrador
  //float L = 0.014;    // Ganho do observador
  //float Ld = L * T;    // Ganho do observador
  
  // Up 12% Ts 0.27s
  //float K = 27.7221;  // Ganho do controlador
  //float Ki = 0.1937;  // Ganho do integrador
  //float L = 0.0324;    // Ganho do observador
  //float Ld = L * T;    // Ganho do observador

  // Up 8% Ts 0.31s
  float K = 15.0092;  // Ganho do controlador
  float Ki = 0.0680;  // Ganho do integrador
  float L = 0.0222;    // Ganho do observador
  float Ld = L * T;    // Ganho do observador
 

  int   R = 595;
  int   deg = 156;
  float Vref  = 0;
  float  uk   = 0;
  float  Vap  = 0;
  float  yk   = 0;
  float  xk   = 0;
  float  xhat = 0;
  float  xnk  = 0;
  float  yhat = 0;
  float  ek   = R - yk;   
  while(micros() <= Duracao_Resposta){
    

    // Atualização do estado associado ao integrador
    xnk = xnk + (T * ek);
  
    // Estimação da saída
    yhat = Cd * xhat + Dd * uk;

    // Atualização do estado estimado pelo observador
    xhat = ((Ad - Ld*Cd)*xhat) + (Bd * uk)+ (Ld * yk);
    
    // Lei de controle com estado estimado
    uk = -(K)*xhat + (Ki)*xnk;
    
    Vref = uk * deg;
    Vref = Vref > 255 ? 255 : Vref;
    Vref = Vref < 0 ? 0 : Vref;

    analogWrite(VelocidadePin, Vref);  // Ativa o motor com a nova entrada
    yk = analogRead(Tensao_Gerador); // Valor da saída
    PrintOut(uk, xhat, ek, yk);

    ek = R - yk;
    _delay_us(5800);

    if (micros() > 1500000 && micros() < 2500000) {
      R = 650;
    }
    else if (micros() > 2500000 && micros() < 3500000){
      R = 600;
    }
    else if (micros() > 3500000){
      R = 590;
    }

  }

  // Desativa o motor
  analogWrite(VelocidadePin, LOW); 
}
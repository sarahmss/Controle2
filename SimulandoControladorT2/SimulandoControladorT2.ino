#define VelocidadePin 9 // Jumper Amarelo
#define Rotacao1Pin 10 // Jumper Branco
#define Rotacao2Pin 11 // Jumper Preto
#define Tensao_Gerador A0 

#define Duracao_Resposta 3000000 // [us] -> 10 [s]

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

  // Variáveis gerais

  Serial.print("Tempo,Entrada,Erro,Saida/");
}

void PrintOut(float uk, float ek, float yk)
{
    // Tempo percorrido
    Serial.print(micros());
    Serial.print(",");

    // Entrada da planta
    Serial.print(uk); 
    Serial.print(",");

    // erro
    Serial.print(ek);  
    Serial.print(",");

    // saida 
    Serial.print(yk); 
    Serial.println("/");

}

/*
  @brief: 
    Função para aplicar um filtro digital e 
    um controlador no sistema de malha fechada
  @param:
    — uk: Valor da entrada degrau do sistema
    — uk_c: Entrada do controlador u[n]
    — uk_1: Valor passado da entrada do controlador u[n-1]
    — y: Saída do controlador y[n]
    — ek: Erro do sistema e[n]
    — ek_1: Valor passado do erro do sistema e[n-1]
*/

float System1(float uk_1, float yk_1)
{

  return (79.01*uk_1 + 0.8871*yk_1);

}

float System(float uk_1, float xk_1)
{
  float A = 0.8802; // Matriz A do sistema discretizado
  float B = 0.008; // Matriz B do sistema discretizado
  float C = 10480; // Matriz C do sistema discretizado

  float xk = 0;
  float yk = 0;

  xk = A*xk_1 + B*uk_1;
  yk = C*xk;

  return (yk);
}

void loop(){

  // Definindo e inicializando as variáveis
  int R = 200;
  float  ek = 0, ek_1 = 0;              
  float  uk = R;
  float  uk_1 = 0;
  float  yk = 0, yk_1 = 0;

  float  x_hat, x_hat_1 = 0;
  float  xnk, xnk_1 = 0;

  float T = 0.008; // Tempo de amostragem
  float A = -14.97; // Matriz A do sistema
  float B = 1; // Matriz B do sistema
  float C = 10479; // Matriz C do sistema

  float K = -9.6367; // Ganho do controlador
  float Ki = 0.0022; // Ganho do integrador
  float L = 0.004; // Ganho do observador

  // Soft-start
  //analogWrite(VelocidadePin, R);  // Ativa o motor com a velocidade da região a qual o controlador foi projetada

  //delay(3000); // Espaço de tempo para que o sistema atinja o regime permanente

  //R = 205; // Pequeno incremento da referência para continuar na região linear projetada

  while(micros() <= Duracao_Resposta){
    ek = R - yk;                              

    // Aplicando o controlador
    x_hat = (T*A - T*L*C + 1)*x_hat_1 + (T*B)*uk_1 + (T*L)*yk_1;
    xnk = xnk_1 + (T)*ek_1;

    uk = -(K)*x_hat + (Ki)*xnk;

    uk = uk > 255 ? 255 : uk;
    uk = uk < 0 ? 0 : uk;

    //analogWrite(VelocidadePin, uk);  // Ativa o motor com a nova entrada
    //yk = analogRead(Tensao_Gerador); // Valor da saída

    //yk = System(uk_1, x_hat_1);
    yk = System1(uk_1, yk_1);

    PrintOut(uk, ek, yk);

    // Guardando as variáveis antes de sofrerem alteração (iteração passada xn_1 = x[n-1])
    uk_1 = uk;
    ek_1 = ek;  

    x_hat_1 = x_hat;
    xnk_1 = xnk;

    _delay_us(5800);
  }
  // Desativa o motor
  //analogWrite(VelocidadePin, LOW); 
}
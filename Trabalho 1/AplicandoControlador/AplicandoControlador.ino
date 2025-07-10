
// #define a 0.07024
// #define b 0.06967
// #define c 1.007

#define VelocidadePin 9 // Jumper Amarelo
#define Rotacao1Pin 10 // Jumper Branco
#define Rotacao2Pin 11 // Jumper Preto
#define Tensao_Gerador A0 

#define Duracao_Resposta 3000000 // [us] -> 10 [s]

#define R 200

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


float Controlador(float yn, float en, float en_1, float en_2, float un_1, float un_2){
  float N = 400;
  float Kp = 1.5 * 0.0065;
  float Kd = 3.5 * 8.6033 * 10e-6;
  float Ki = 1.2203;
  float Ts = 0.008;

  float x = 4 * N * Kd;
  float y = 2 * N * Ts * Kp;
  float z = N * (Ts * Ts)  * Ki;

  // Causal
  float un = ((x + y + z)*en + (-2*x + 2*z)*en_1 + (x - y + z)*en_2 + 8*un_1 -(4 - 2*N*Ts)*un_2) / (4 + 2*N*Ts);

  // Não Causal
  // float un = (Kp*en) + (Kd*(en - en_1)) + (Ki*(en + en_1)); 

  un = un > 255 ? 255 : un;
  un = un < 0 ? 0 : un;
  return(un);
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
    Função para aplicar um filtro digital e 
    um controlador no sistema de malha fechada
  @param:
    — u: Valor da entrada degrau do sistema
    — u_c: Entrada do controlador u[n]
    — un_1: Valor passado da entrada do controlador u[n-1]
    — y: Saída do controlador y[n]
    — e: Erro do sistema e[n]
    — en_1: Valor passado do erro do sistema e[n-1]
*/
void loop(){

  float  en = 0, en_1 = 0, en_2 = 0;              
  float  un = R;
  float  yn = 0, un_1 = 0, un_2 = 0;


  while(micros() <= Duracao_Resposta){
    en = R - yn;                              
    un = Controlador(yn, en, en_1, en_2, un_1, un_2);
    analogWrite(VelocidadePin, un);  // Ativa o motor com a nova entrada
    yn = analogRead(Tensao_Gerador); // Valor da saída
    PrintOut(un, en, yn);

    // Guardando as variáveis antes de sofrerem alteração (iteração passada x1 = [x-1])
    un_1 = un;
    un_2 = un_1;
    en_1 = en;  
    en_2 = en_1;  

    _delay_us(5800);
  }
  // Desativa o motor
  analogWrite(VelocidadePin, LOW); 
}
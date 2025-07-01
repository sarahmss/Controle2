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

  // Definindo e inicializando as variáveis
  float  en = 0, en_1 = 0;              
  float  un = R;
  float  yn = 0, un_1 = 0;
  float  x_hat, x_hat_1 = 0;
  float  xn, xn_1 = 0;

  float T = 0.008; // Tempo de amostragem
  float A = ; // Matriz A do sistema discretizado
  float B = ; // Matriz B do sistema discretizado
  float C = ; // Matriz C do sistema discretizado

  float K = ; // Ganho do controlador
  float Ki = ; // Ganho do integrador
  float L = ; // Ganho do observador

  // Soft-start
  analogWrite(VelocidadePin, R);  // Ativa o motor com a velocidade da região a qual o controlador foi projetada

  delay(3000); // Espaço de tempo para que o sistema atinja o regime permanente

  R  = 205; // Pequeno incremento da referência para continuar na região linear projetada

  while(micros() <= Duracao_Resposta){
    en = R - yn;                              

    // Aplicando o controlador
    x_hat = (T*A + T*C + 1)*x_hat_1 + (T*B)*un_1 + (T*L)*yn_1;
    xn = xn_1 + (T)*en_1;

    un = -(K)*x_hat + (Ki)*xn;

    un = un > 255 ? 255 : un;
    un = un < 0 ? 0 : un;

    analogWrite(VelocidadePin, un);  // Ativa o motor com a nova entrada
    yn = analogRead(Tensao_Gerador); // Valor da saída
    PrintOut(un, en, yn);

    // Guardando as variáveis antes de sofrerem alteração (iteração passada x1 = [x-1])
    un_1 = un;
    un_2 = un_1;
    en_1 = en;  
    en_2 = en_1;  

    x_hat_1 = x_hat;
    xn_1 = xn;

    _delay_us(5800);
  }
  // Desativa o motor
  analogWrite(VelocidadePin, LOW); 
}
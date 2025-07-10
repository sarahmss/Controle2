#include <PID_v1.h>

// Parâmetros do sistema
#define Velocidade_Pin 9
#define Rotacao1_Pin 10
#define Rotacao2_Pin 11
#define Tensao_Gerador A0

#define Duracao_Resposta 10000000UL // 10 segundos em microssegundos

// Variáveis PID
double Setpoint = 200;   // Valor desejado (entrada de referência)
double Input = 0;        // Valor lido (saída da planta)
double Output = 0;       // Valor calculado (entrada da planta)

// Ganhos do controlador
double Kp = 0.0888;
double Ki = 127.0172;
double Kd = 0.000025192;

// Instância do controlador PID
PID myPID(&Input, &Output, &Setpoint, Kp, Ki, Kd, DIRECT);

void setup() {
  pinMode(Velocidade_Pin, OUTPUT);
  pinMode(Rotacao1_Pin, OUTPUT);
  pinMode(Rotacao2_Pin, OUTPUT);
  pinMode(Tensao_Gerador, INPUT);

  digitalWrite(Rotacao1_Pin, 1);
  digitalWrite(Rotacao2_Pin, 0);

  Serial.begin(115200);
  Serial.print("Tempo,Entrada,Erro,Saida/");

  myPID.SetMode(AUTOMATIC);           // Liga o PID
  myPID.SetSampleTime(8);             // Tempo de amostragem: 8 ms
  myPID.SetOutputLimits(0, 255);      // Limites de saída compatíveis com analogWrite
}

void loop() {
  unsigned long t0 = micros();
  while (micros() - t0 <= Duracao_Resposta) {
    // Leitura da saída da planta
    Input = analogRead(Tensao_Gerador);

    // Atualização do PID
    myPID.Compute();

    // Aplica a saída ao motor
    analogWrite(Velocidade_Pin, (int)Output);

    // Calcula erro apenas para log
    double erro = Setpoint - Input;

    // Imprime dados
    Serial.print(micros() - t0);
    Serial.print(",");
    Serial.print(Input);
    Serial.print(",");
    Serial.print(erro);
    Serial.print(",");
    Serial.print(Output);
    Serial.print("/");

    // Espera o próximo ciclo (8 ms)
    delayMicroseconds(6900); // para completar ~8ms com o tempo de loop
  }

  analogWrite(Velocidade_Pin, 0); // Desliga motor após teste
  while (true); // para o loop
}

#include <stdio.h>

int main() {
    int kmx, kmy, vx, vy;
    int h = 0; // Hora

    printf("Digite a posição inicial do carro X (kmx): ");
    scanf("%d", &kmx);
    printf("Digite a velocidade do carro X (vx): ");
    scanf("%d", &vx);
    printf("Digite a posição inicial do carro Y (kmy): ");
    scanf("%d", &kmy);
    printf("Digite a velocidade do carro Y (vy): ");
    scanf("%d", &vy);

    if ((kmx>kmy && vx>vy) || (kmx<kmy && vx<vy) || (vx==vy)) {
        printf("\nNunca haverá ultrapassagem!\n");
        return 1; // Erro
    }

    printf("\nkmx = %d | vx = %d | kmy = %d | vy = %d\n", kmx, vx, kmy, vy);  

    while ((vx > vy && kmx <= kmy) || (vx < vy && kmy <= kmx)) { // Enquanto não houver ultrapassagem entre os carros, o loop ocorrerá
        printf("Hora %d: Carro X em %d e Carro Y em %d\n", h, kmx, kmy);
        h++;
        kmx += vx; // Atualiza a posição do carro X
        kmy += vy; // Atualiza a posição do carro Y

        
    }
    printf("Hora %d: Carro X em %d e Carro Y em %d\n", h, kmx, kmy);

    if (kmx > kmy) {
        printf("O Carro X ultrapassou o Carro Y na hora %d apos o KM %d\n", h, kmy);
    } else {
        printf("O Carro Y ultrapassou o Carro X na hora %d apos o KM %d\n", h, kmx);
    }

    return 0;
}

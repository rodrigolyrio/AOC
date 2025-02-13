#include <stdio.h>

int formarTriangulo(int x, int y, int z) { // Verifica todas as possibilidades dentro dos três valores informados pelo usuario
    if (x + y > z && x + z > y && y + z > x) { 
        return 1; // True: é um triângulo
    } else {
        return 0; // False: não é um triângulo
    }
}

int main() {
    int x, y, z;

    printf("Digite os 3 lados do triangulo (os valores devem ser >= 1):\n");
    scanf("%d %d %d", &x, &y, &z);

    if (x < 1 || y < 1 || z < 1) {
        printf("Erro. Os valores devem ser maiores ou iguais a 1!\n");
        return 1; // Erro
    }

    if (formarTriangulo(x, y, z)) {
        printf("Os valores %d, %d e %d formam um triangulo.\n", x, y, z);
    } else {
        printf("Os valores %d, %d e %d nao formam um triangulo.\n", x, y, z);
    }

    return 0;
}

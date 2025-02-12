#include <stdio.h>
// Ler 3 valores (considere que não serão informados valores iguais) e escrever a soma dos dois maiores valores apenas. 
int main() {
    int a, b, c;

    printf("Digite o valor de a: ");
    scanf("%d", &a);
    printf("Digite o valor de b: ");
    scanf("%d", &b);
    printf("Digite o valor de c: ");
    scanf("%d", &c);

    if (a < b && a < c) {
        printf("Soma dos dois maiores: %d\n", b + c);
    } else {
        if (b < c) {
            printf("Soma dos dois maiores: %d\n", a + c);
        } else {
            printf("Soma dos dois maiores: %d\n", a + b);
        }
    }

    return 0;
}

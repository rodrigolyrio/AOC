#include <stdio.h>
// Faça um programa em C que leia quatro valores referentes a quatro notas escolares (0 a 100) de um aluno e escreva uma mensagem dizendo que o aluno foi aprovado, se o valor da média escolar for maior ou igual a 60.
int main() {
    float nota1, nota2, nota3, nota4, media;

    printf("Digite a primeira nota (0 a 100): ");
    scanf("%f", &nota1);
    printf("Digite a segunda nota (0 a 100): ");
    scanf("%f", &nota2);
    printf("Digite a terceira nota (0 a 100): ");
    scanf("%f", &nota3);
    printf("Digite a quarta nota (0 a 100): ");
    scanf("%f", &nota4);

    media = (nota1 + nota2 + nota3 + nota4) / 4;

    if (media >= 60) {
        printf("Aluno aprovado com média %.2f\n", media);
    } else {
        printf("Aluno reprovado com média %.2f\n", media);
    }

    return 0;
}

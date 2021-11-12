/*
 * main.c
 *
 *  Created on: 26/01/2011
 *      Author: einstein
 */
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <time.h>

#define mat(i,j) mat[i*N+j]
#define proximo(x) x+1
#define anterior(x) x-1
#define MAX 512
#define INFINITO 999999
#define ZERO 0

unsigned long long int qtd = 0ULL;

int N = 12;
int upper_bound = INFINITO;


int mat[MAX];

void read(){
	int i , j ;
	scanf("%d", &N);
	for( i = 0 ; i < (N*N) ; i++ ){
        scanf("%d", &mat[ i ] ) ;
    }

}


void print(int *v,int custo_ciclo, int custo) {
	int i;
	for (i = 0; i < N; i++){
	    if(i<N-1)
            custo+=mat(v[i],v[i+1]);
        else
            custo+=mat(v[i],0);
		printf("%d ", v[i]);
    }

    printf("   custo: %d\n", custo);
	printf("\n");
}


unsigned long long int dfs_all_permutations(){


	unsigned long long int qtd = 0ULL;

	register int  vFlag[16];
	register int  vertice[16]; //representa o cicl
	register int custo = ZERO;
	register int i, nivel = 0; //para dizer que 0-1 ja foi visitado e a busca comeca de 1, bote 2
    /*Inicializacao*/
    
	for (i = 0; i < N; ++i) { //
		vFlag[i] = 0;
		vertice[i] = -1;
	}
   	while (nivel >= 0) { // modificar aqui se quiser comecar a busca de determinado nivel

		if(vertice[nivel] !=-1 ) {
			vFlag[vertice[nivel]] = 0; 
			//custo-= mat(vertice[anterior(nivel)],vertice[nivel]);
		}
		do {
			vertice[nivel]++;
		} while (vertice[nivel] < N && vFlag[vertice[nivel]]); //

		if (vertice[nivel] < N) {
			vFlag[vertice[nivel]] = 1;
			nivel++;
			if (nivel == N){ //se o vértice do nível for == N, entao formou o ciclo e vc soma peso + vertice anterior -> inicio
				++qtd;
				//if(custo + mat(vertice[anterior(nivel)],0)<upper_bound)
                   // upper_bound=custo + mat(vertice[anterior(nivel)],0);
				nivel--;
			}else{
			}
		} else {
			vertice[nivel] = -1;
			nivel--;

		}
	}
	return qtd;
}

int dfs2() {

	register int  vFlag[MAX];
	register int  vertice[MAX]; //representa o ciclo

	register int custo = ZERO;
	register int i, nivel = 1; //para dizer que 0-1 ja foi visitado e a busca comeca de 1, bote 2
	
    /*Inicializacao*/
	for (i = 0; i < N; ++i) { //
		vFlag[i] = 0;
		vertice[i] = -1;
	}

    /*
        para dizer que 0-1 sao fixos
    */
    vertice[0] = 0;
    vFlag[0] = 1;


   	while (nivel >= 1) { // modificar aqui se quiser comecar a busca de determinado nivel

		if(vertice[nivel] !=-1 ) {vFlag[vertice[nivel]] = 0; custo-= mat(vertice[anterior(nivel)],vertice[nivel]);};

		do {
			vertice[nivel]++;
		} while (vertice[nivel] < N && vFlag[vertice[nivel]]); //


		if (vertice[nivel] < N) {

            custo+= mat(vertice[anterior(nivel)],vertice[nivel]);


			vFlag[vertice[nivel]] = 1;
			nivel++;

			if (nivel == N){ //se o vértice do nível for == N, entao formou o ciclo e vc soma peso + vertice anterior -> inicio
				++qtd;
				if(custo + mat(vertice[anterior(nivel)],0)<upper_bound)
                    upper_bound=custo + mat(vertice[anterior(nivel)],0);
				nivel--;
			}else{

			}
		} else {
			vertice[nivel] = -1;
			nivel--;

		}
	}

	return upper_bound;
}


int dfs_novo() {

	register int  vFlag[MAX];
	register int  vertice[MAX]; //representa o ciclo

	register int custo = ZERO;
	register int i, nivel = 1;  //---> nivel zero ja tem a raiz


    /*Inicializacao*/
	for (i = 0; i < N; ++i) { //
		vFlag[i] = 0;
		vertice[i] = -1;
	}

    /*
        para dizer que 0-1 sao fixos
    */
    vertice[0] = 0; //raiz
    vFlag[0] = 1;


   	while (nivel >= 1) { // modificar aqui se quiser comecar a busca de determinado nivel

		if(vertice[nivel] !=-1 ) {
			vFlag[vertice[nivel]] = 0; 
			custo-= mat(vertice[anterior(nivel)],vertice[nivel]);
		}

		for(vertice[nivel]++;vertice[nivel] < N && vFlag[vertice[nivel]]; vertice[nivel]++); //

		if (vertice[nivel] < N) {

            custo+= mat(vertice[anterior(nivel)],vertice[nivel]);


			vFlag[vertice[nivel]] = 1;
			nivel++;

			if (nivel == N){ //se o vértice do nível for == N, entao formou o ciclo e vc soma peso + vertice anterior -> inicio
				++qtd;
				if(custo + mat(vertice[anterior(nivel)],0)<upper_bound)
                    upper_bound=custo + mat(vertice[anterior(nivel)],0);
				nivel--;
			}else{

			}
		} else {
			vertice[nivel] = -1;
			nivel--;

		}
	}

	return upper_bound;
}






int main() {
	//	dfs();
	//read();
	
//	tempo_inicial= time(NULL);
	printf("#################################\nAll Permutations\n");
	printf("\nDimensao para todas as permutacoes: %d \n",N);
	printf("%llu", dfs_all_permutations());
//	tempo_final = time(NULL);
	//printf("\nQTD de solucoes encontradas:%llu.\n",qtd);
//	printf("\n\tTEMPO(S): %f\n\n", (double)(tempo_final-tempo_inicial));
	



// 	qtd = 0;
// 	upper_bound = INFINITO;
// 
// 	tempo_inicial= time(NULL);
// 
// 	printf("#################################\nTODAS SOL - SERIAL E N RECURSIVO\n");
// 	printf("\nDimensao: %d",N);
// 	printf("\nOtimo dfs_tentavia(): %d", dfs2());
// 	tempo_final = time(NULL);
// 	printf("\nQTD de solucoes encontradas:%d.\n",qtd);
// 	printf("\n\tTEMPO(S): %f\n\n", (double)(tempo_final-tempo_inicial));
// 	

    /*for(i = 0; i<N; ++i){
        for(j = 0; j<N; ++j){
            printf("%d ", mat(i,j));
        }
        puts("\n");
    }*/

	return 0;
}

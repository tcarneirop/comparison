#include <stdio.h>
#include <time.h>
#include <stdlib.h>
#include <sys/time.h>

#define _EMPTY_      -1

#define MAX 32

double rtclock()
{
    struct timezone Tzp;
    struct timeval Tp;
    int stat;
    stat = gettimeofday (&Tp, &Tzp);
    if (stat != 0) printf("Error return from gettimeofday: %d",stat);
    return(Tp.tv_sec + Tp.tv_usec*1.0e-6);
}

inline bool stillLegal(const short *board, const int r)
{
  
  register int i;
  register int ld;
  register int rd;
  // // Check vertical
  for ( i = 0; i < r; ++i)
    if (board[i] == board[r]) return false;
  //  Check diagonals
    ld = board[r];  //left diagonal columns
    rd = board[r];  // right diagonal columns
    for ( i = r-1; i >= 0; --i) {
      --ld; ++rd;
      if (board[i] == ld || board[i] == rd) return false;
    }

    return true;
}


int BP_queens_serial(int size, unsigned long long *tree_size){

    register unsigned int flag = 0;
    register int bit_test = 0;
    register short vertice[MAX]; //representa o ciclo
    register int i, depth; //para dizer que 0-1 ja foi visitado e a busca comeca de 1, bote 2
    register unsigned long long local_tree = 0ULL;
    int num_sol = 0;

    for (i = 0; i < size; ++i) { //
        vertice[i] = -1;
    }

    depth = 0;

    do{

        vertice[depth]++;
        bit_test = 0;
        bit_test |= (1<<vertice[depth]);


        if(vertice[depth] == size){
            vertice[depth] = _EMPTY_;
                //if(block_ub > upper)   block_ub = upper;
        }else if ( stillLegal(vertice, depth) && !(flag &  bit_test ) ){ //is legal

                flag |= (1ULL<<vertice[depth]);
                depth++;
                ++local_tree;
                if (depth == size){ //handle solution
                   // handleSolution(vertice,size);
                   num_sol++;
            }else continue;
        }else continue;

        depth--;
        flag &= ~(1ULL<<vertice[depth]);

    }while(depth >= 0);

    *tree_size = local_tree;

    return num_sol;
}


int main(int argc, char *argv[]){

    int size = atoi(argv[1]);
    unsigned long long tree_size = 0ULL;


     printf("\nQueens serial -- size: %d.",size);
    double initial_time = rtclock();
    int nsol = BP_queens_serial(size,&tree_size);
    double final_time = rtclock();


  printf("\nNumber of solutions found: %d. \n\t Tree size: %llu.\n",nsol,tree_size);
      printf("\nElapsed total: %.3f\n", (final_time-initial_time));

  return 0;
}
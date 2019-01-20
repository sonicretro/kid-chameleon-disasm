#include <cstdio>
#include <cstdlib>
#include <list>
#include "compress_algo.cpp"

using namespace std;

char version[11] = "2018-03-04";

int main(int argc, char* argv[]) {
    if(argc < 3) {
        printf("Usage: compress.exe inputfile outputfile\n");
        printf("Version: %s", version);
        return 0;
    }

    FILE* input = fopen(argv[1], "rb");
    if(input == NULL) {
        printf("File not found.");
        return 0;
    }

    fseek(input, 0, SEEK_END);
    int size = ftell(input);
    rewind(input);

    /* create array with data to be compressed */
    unsigned char* data = (unsigned char*) malloc(size);
    fread(data, size, 1, input);
    fclose(input);

    compress(data, size, argv[2], true);
}

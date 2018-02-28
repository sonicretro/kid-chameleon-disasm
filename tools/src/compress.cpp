#include <cstdio>
#include <cstdlib>
#include <list>

using namespace std;

typedef struct byteinfo {
    unsigned int position;
    unsigned short length;
};

int max(int a, int b) {
    return (b<a) ? a : b;
}

int main(int argc, char* argv[]) {
    if(argc < 3) {
        printf("Usage: compress.exe inputfile outputfile");
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
    
    /* contains info on where the pattern beginning at position i
     * has already occurred previously, and how long it is
     * (for the longest previous re-appearance of the pattern) */
    byteinfo* infoarray = (byteinfo*) calloc(size, sizeof(byteinfo));
    
    for(int i=0; i<size; i++) {
        for(int j=max(0, i-0x7FF); j<i; j++) {
            unsigned short length = 0;
            /* while characters match at both positions: increase pattern length */
            while(data[j+length] == data[i+length] && i+length < size && length < 0xFF) length++;
            /* if new found pattern longer than previous one, and in case of long-ref not of length 2 */
            if(length >= infoarray[i].length && !(length == 2 && i-j > 0xFF)) {
                infoarray[i].position = j;
                infoarray[i].length = length;
            }
        }
        #ifdef DEBUG
        printf("%04x: %04x - %d\n", i, infoarray[i].position, infoarray[i].length);
        #endif
    }
    
    /* list to contain the compression commands */
    list<byteinfo> compinfo;
    /* current position, initialised as last byte of the file */
    int position = size;
    /* number of bits the compression header will take */
    unsigned short bitcount = 0;
    /* number of bytes the compression data will take */
    unsigned short bytecount = 0;

    /* go through from back to beginning finding encodings */
    while(position > 0) {
        byteinfo temp;
        /* in case no match will be found, use direct copy */
        temp.position = 0;
        temp.length = 1;
        /* search for patterns in front of position reaching up to position */
        for(int i=position-2; i>max(0, position-0xFF); i--) {
            /* check if is pattern long enough, and in case of long-ref not of length 2 */
            if(infoarray[i].length >= position-i && !(position-i == 2 && i-infoarray[i].position > 0xFF)) {
                temp.position = infoarray[i].position;
                temp.length = position-i;
            }
        }
        compinfo.push_front(temp);
        
        if(temp.length == 1) {
            /* direct copy */
            bitcount++;
            bytecount++;
        } else if(temp.length <= 3 && position-temp.position <= 0xFF) {
            /* short reference */
            bitcount += 3;
            bytecount++;
        } else if(temp.length <= 5) {
            /* long reference 1 */
            bitcount += 7;
            bytecount++;
        } else {
            /* long reference 2 */
            bitcount += 7;
            bytecount += 2;
        }
        
        /* go back by the length of the found pattern */
        position -= temp.length;
    }
    
    /* terminating sequence */
    bitcount += 7;
    bytecount += 2;
    
    unsigned short command_size = (bitcount+7)>>3;
    unsigned short input_size = bytecount;
    
    unsigned char* cmdarray = (unsigned char*) calloc(command_size, 1);
    unsigned char* inputarray = (unsigned char*) calloc(input_size, 1);
    
    bitcount = 0;
    bytecount = 0;
    
    /* theoretical position in uncompressed data */
    position = 0;
    
    list<byteinfo>::iterator it;
    /* loop to encode the data */
    for(it=compinfo.begin(); it!=compinfo.end(); it++) {
        
        #ifdef DEBUG
        printf("%04x: %04x - %02x ", position, it->position, it->length);
        #endif
        
        unsigned short offset = position - it->position;
        
        if(it->length == 1) {
            /* direct copy */
            #ifdef DEBUG
            printf("dr 01\n");
            #endif
            cmdarray[bitcount>>3] |= 0x80>>(bitcount&0x07);
            inputarray[bytecount] = data[position];
            bitcount++;
            bytecount++;
        } else if(it->length <= 3 && offset <= 0xFF) {
            /* short reference */
            unsigned char bitcode = it->length - 2;
            #ifdef DEBUG
            printf("sh %02x\n", bitcode);
            #endif
            cmdarray[bitcount>>3] |= (bitcode<<5) >> (bitcount&0x07);
            cmdarray[(bitcount>>3) + 1] |= ((bitcode<<13) >> (bitcount&0x07)) & 0xFF;
            inputarray[bytecount] = offset;
            bitcount += 3;
            bytecount++;
        } else if(it->length <= 5) {
            /* long reference 1 */
            unsigned char bitcode = 0x20 + ((offset&0x700)>>6) + it->length - 3;
            #ifdef DEBUG
            printf("l1 %02x\n", bitcode);
            #endif
            cmdarray[bitcount>>3] |= (bitcode<<1) >> (bitcount&0x07);
            cmdarray[(bitcount>>3) + 1] |= ((bitcode<<9) >> (bitcount&0x07)) & 0xFF;
            inputarray[bytecount] = offset&0xFF;
            bitcount += 7;
            bytecount++;
        } else {
            /* long reference 2 */
            unsigned char bitcode = 0x20 + ((offset&0x700)>>6) + 0x03;
            #ifdef DEBUG
            printf("l2 %02x, %02x\n", bitcode);
            #endif
            cmdarray[bitcount>>3] |= (bitcode<<1) >> (bitcount&0x07);
            cmdarray[(bitcount>>3) + 1] |= ((bitcode<<9) >> (bitcount&0x07)) & 0xFF;
            inputarray[bytecount] = offset&0xFF;
            inputarray[bytecount+1] = it->length;
            bitcount += 7;
            bytecount += 2;
        }
        
        position += it->length;
    }
    
    /* terminating sequence */
    cmdarray[bitcount>>3] |= (0x23<<1) >> (bitcount&0x07);
    cmdarray[(bitcount>>3) + 1] |= ((0x23<<9) >> (bitcount&0x07)) & 0xFF;
    inputarray[bytecount] = 0x00;
    inputarray[bytecount+1] = 0x00;
    
    #ifdef DEBUG
    printf("command_size: %04x\ninput_size: %04x\n", command_size, input_size);
    #endif
    
    FILE* comp = fopen(argv[2], "wb");
        if(comp == NULL) {
        printf("Could not write file.");
        return 0;
    }

    /* write data to file */
    fputc(command_size/0x100, comp);
    fputc(command_size%0x100, comp);
    fwrite(cmdarray, command_size, 1, comp);
    fwrite(inputarray, input_size, 1, comp);
    fclose(comp);
    
    printf("\nUncompressed size: %5d bytes", size);
    printf("\nCompressed size:   %5d bytes", 2 + command_size + input_size);
    printf("\nCompression ratio:  %.2f%%", (1 - (float)(2 + command_size + input_size)/(float)size) * 100);
}

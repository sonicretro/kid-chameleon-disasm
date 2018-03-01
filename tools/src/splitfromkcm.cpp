#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <algorithm>
#include <vector>
#include <array>
#include <unordered_map>
#include <fstream>
#include <sstream>
#include <iostream>
#include <string>
#include <list>
// build with -std=c++11

#include "bigendian_io.h"
#include "bitstream.h"


using namespace std;

typedef struct byteinfo {
    unsigned int position;
    unsigned short length;
};

int max(int a, int b) {
    return (b<a) ? a : b;
}

int compress(unsigned char* data, int size, const char* outfilename) {
   
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
    
    FILE* comp = fopen(outfilename, "wb");
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
    
    // printf("\nUncompressed size: %5d bytes", size);
    // printf("\nCompressed size:   %5d bytes", 2 + command_size + input_size);
    // printf("\nCompression ratio:  %.2f%%", (1 - (float)(2 + command_size + input_size)/(float)size) * 100);
}


// Blazing fast function that gives the index of the MSB.
// nabbed from https://github.com/flamewing/mdcomp
static inline unsigned char slog2(unsigned short v) {
    unsigned char r; // result of slog2(v) will go here
    unsigned char shift;

    r = static_cast<int>(v > 0xFF) << 3;
    v >>= r;
    shift = static_cast<int>(v > 0xF) << 2;
    v >>= shift;
    r |= shift;
    shift = static_cast<int>(v > 0x3) << 1;
    v >>= shift;
    r |= shift;
    r |= (v >> 1);
    return r;
}


void compress_blocks(unsigned char* kcm, int length, int xsize, int ysize, const char* block_name) {
    int xbits = slog2(xsize)+1;
    int ybits = slog2(ysize)+1;
    //printf("%02x %02x %d %d\n", xsize, ysize, xbits, ybits);

    // expand block layout into a matrix
    std::vector< std::vector < std::array<unsigned char, 5> > > blocks(ysize, std::vector<std::array<unsigned char, 5> >(xsize));
    int pos = 0;
    for (int i = 0; i < length; ++i) {
        if (kcm[i] < 0x80) {
            // we don't need to fill in the empty cells as the matrix
            // is initialized with 0s
            pos += kcm[i]+1;
        } else {
            // write block to matrix
            for (int j = 0; j < 5; ++j) {
                blocks[pos/xsize][pos%xsize][j] = kcm[i++];
            }
            --i;
            pos++;
        }
    }

    // print the matrix
    // for (int y = 0; y < ysize; ++y) {
    //     for (int x = 0; x < xsize; ++x) {
    //         if (blocks[y][x][0] >= 0x80) {
    //             printf("%1x", blocks[y][x][0]&0x0F);
    //         } else {
    //             printf(".");
    //         }
    //     }
    //     printf("\n");
    // }

    std::ofstream out;
    out.open(block_name, std::ofstream::out | std::ofstream::binary);
    obitstream<uint16_t> bits(out);
    bits.write(0x40, 8);
    bits.write(xbits, 4);
    bits.write(ybits, 4);
    
    for (int type = 0x80; type < 0xA0; ++type) {
        for (int hidden = 0; hidden < 2; ++hidden) {
            int id = type + 0x20*hidden;
            //if ((id & 0x9F) == 0x83) continue;
                
            // how many bits for length of column/row of consecutive blocks
            int reptbits = 4;
            if ((id & 0x9F) == 0x83) reptbits = 3;
            if ((id & 0x9F) == 0x84) reptbits = 0;
            if ((id & 0x9F) == 0x8B) reptbits = 0;
            // how many bits of extra info per repeated block
            int reptinfobits = 0;
            if ((id & 0x9F) == 0x81) reptinfobits = 5;
            if ((id & 0x9F) == 0x8A) reptinfobits = 4;
            if ((id & 0x9F) == 0x8C) reptinfobits = 4;
            if ((id & 0x9F) == 0x90) reptinfobits = 3;

            bool type_found = false;
            for (int y = 0; y < ysize; ++y) {
                for (int x = 0; x < xsize; ++x) {
                    if (blocks[y][x][0] == id) {
                        if (! type_found) {
                            // first time we encounter this type of block, write header.
                            bits.write(id&0x3F, 6);
                            type_found = true;
                        }
                        bits.write(x, xbits);
                        bits.write(y, ybits);
                        // check for row of repeated blocks
                        int xi = 0;
                        int yi = 0;
                        // Check how many blocks we capture horizontally/vertically
                        if ((id & 0x9F) == 0x83) {
                            // for ghost blocks we actually need to check whether everything is equal
                            std::array<unsigned char, 5> content = blocks[y][x];
                            while (x+xi < xsize && xi < (1<<reptbits) && blocks[y][x+xi] == content) {
                                xi++;
                            }
                            while (y+yi < ysize && yi < (1<<reptbits) && blocks[y+yi][x] == content) {
                                yi++;
                            }
                        } else {
                            // for all other blocks it's enough if the id matches
                            while (x+xi < xsize && xi < (1<<reptbits) && blocks[y][x+xi][0] == id) {
                                xi++;
                            }
                            while (y+yi < ysize && yi < (1<<reptbits) && blocks[y+yi][x][0] == id) {
                                yi++;
                            }
                        }
                        // Check if we capture more blocks vertically or horizontally.
                        int xd = 0;
                        int yd = 0;
                        int chain_length;
                        int direction;
                        if (yi > xi) {
                            yd = 1;
                            chain_length = yi;
                            direction = 1;
                        } else {
                            xd = 1;
                            chain_length = xi;
                            direction = 0;
                        }
                        // Erase the blocks that we captured
                        for (int i = 0; i < chain_length; ++i) {
                            blocks[y+i*yd][x+i*xd][0] = 0;
                        }
                        // Write the captured blocks
                        if ((id & 0x9F) == 0x84) {
                            // telepad
                            //printf("telepad: %02X %02X %02X %02X\n", blocks[y][x][1], blocks[y][x][2], blocks[y][x][3], blocks[y][x][4]);
                            bits.write(blocks[y][x][1], 8); // map
                            bits.write(blocks[y][x][2], 8); // y coord
                            bits.write((blocks[y][x][4] << 8) + blocks[y][x][3], 9); // x coord 
                        } else if ((id & 0x9F) == 0x83) {
                            // Ghost block
                            //printf("Ghost: %d %d %02X %02X %02X %02X %d\n", x, y, blocks[y][x][1], blocks[y][x][2], blocks[y][x][3], blocks[y][x][4], chain_length);
                            bits.write(chain_length-1, reptbits);
                            bits.write(direction, 1);
                            bits.write(blocks[y][x][1], 8);
                            bits.write((blocks[y][x][3] << 8) + blocks[y][x][2], 11);
                            bits.write(blocks[y][x][4], 8);
                        } else if ((id & 0x9F) != 0x8B) {
                            // lift doesn't need anything, all other blocks are as follows:
                            bits.write(chain_length-1, reptbits);
                            bits.write(direction, 1);
                            if (reptinfobits != 0) {
                                for (int i = 0; i < chain_length; ++i) {
                                    bits.write(blocks[y+i*yd][x+i*xd][1], reptinfobits);
                                }                        
                            }
                        }
                    }
                }
            }
            if (type_found) {
                bits.write((1<<xbits)-1, xbits); // terminate this type of block
            }
        }
    }
    bits.write(0x3F, 6); // terminate block layout
    bits.flush();
}


int split_kcm(int map_id, std::vector<std::string> filenames) {
    std::string level = "level/";
    
    // read the kcm file into memory
    char dump_filename[12];
    sprintf(dump_filename, "map%02x.kcm", map_id);
    FILE* dump = fopen(dump_filename, "rb");
    if (dump == NULL) {
        std::cout << "Could not open " << dump_filename << std::endl;
        return -1;
    }
    fseek(dump, 0, SEEK_END);
    int kcmsize = ftell(dump);    
    fseek(dump, 0, SEEK_SET);
    unsigned char* kcm = (unsigned char*) malloc(kcmsize);
    fread(kcm, kcmsize, 1, dump);
    fclose(dump);

    // header
    FILE* fheader = fopen(("level/" + filenames[2]).c_str(), "wb");
    // endianness swaps
    std::swap(kcm[16], kcm[17]);
    std::swap(kcm[14], kcm[15]);
    std::swap(kcm[12], kcm[13]);
    std::swap(kcm[10], kcm[11]);
    fwrite(kcm+6, 12, 1, fheader);
    fclose(fheader);

    // get offsets within the kcm file for each kind of data
    int tile_offset = kcm[18] + (kcm[19]<<8);
    int block_offset = kcm[20] + (kcm[21]<<8);
    int bg_offset = kcm[22] + (kcm[23]<<8);
    int enemy_offset = kcm[24] + (kcm[25]<<8);
    int eof = kcm[26] + (kcm[27]<<8);   // end of file

    // tile layout (front)
    compress(kcm+tile_offset, block_offset-tile_offset, ("level/" + filenames[4]).c_str());

    // background
    FILE* fbackground = fopen(("level/" + filenames[6]).c_str(), "wb");
    fwrite(kcm+bg_offset, enemy_offset-bg_offset, 1, fbackground);
    fclose(fbackground);    

    // enemy data
    FILE* fenemy = fopen(("level/" + filenames[3]).c_str(), "wb");
    unsigned char eheader1[] = {0, 0, 0, 0};
    unsigned char eheader2[] = {0x7D, 0, 0x80};
    fwrite(eheader1, 4, 1, fenemy);
    fwrite(kcm+enemy_offset, 6, 1, fenemy);
    fwrite(eheader2, 3, 1, fenemy);
    fwrite(kcm+enemy_offset+6, eof-enemy_offset-6, 1, fenemy);
    fclose(fenemy);

    // blocks
    int xsize = kcm[6] * 0x14;
    int ysize = (kcm[7] & 0x3F) * 0x0E;
    compress_blocks(kcm+block_offset, bg_offset-block_offset, xsize, ysize, ("level/" + filenames[5]).c_str());

    free(kcm);
    std::cout << "Successfully split " << dump_filename << std::endl;
    return 0;
}


int parse_input(std::vector<int>& map_ids, std::string in) {
    bool is_all = false;
    if (in == "all") {
        is_all = true;
    } else if (in.size() != 0) {
        // try to convert to integer        
        try {
            int map_id = std::stoi(in, nullptr, 16);
            map_ids.push_back(map_id);
        } catch (...) {
            std::cout << in << " - Not a valid number." << std::endl;
        }
    }
    return is_all;
}


int main(int argc, char* argv[]) {

    std::cout << "Splits .kcm files into files as specified in level/level_files.txt." << std::endl;
    std::ifstream infile("level/level_files.txt");
    if (infile.fail()) {
        std::cout << "Can't open \"level/level_files.txt\"" << std::endl;
        return -1;
    }

    // make a dictionary which for each map_id, stores a vector
    // with the filename for (in that order)
    // platform, bgscroll, header, enemy, foreground, block, background data
    std::unordered_map<int, std::vector<std::string> > filemap;
    std::string line;
    while (std::getline(infile, line))
    {
        std::istringstream iss(line);
        int id;
        std::string id_str;
        try {
            iss >> id_str;
            id = std::stoi(id_str, nullptr, 16);
        } catch (...) {
            continue;
        }

        std::vector<std::string> filenames;
        while (iss) {
            std::string sub;
            iss >> sub;
            if (sub.size() != 0) {
                filenames.push_back(sub);
            }
        }

        // if there are not 7 entries, then it's not valid
        if (filenames.size() == 7) {
            filemap[id] = filenames;
        }
    }

    // Parse user input (either commandline parameters, or console input)
    std::vector<int> map_ids;
    bool all = false;
    if (argc == 1) {
        std::string in;
        std::cout << "Enter MapIDs in hexadecimal, separated by spaces, or \"all\": ";
        std::getline(std::cin, in);
        std::istringstream iss(in);
        while (iss) {
            std::string sub;
            iss >> sub;
            bool is_all = parse_input(map_ids, sub);
            all = all || is_all;
        }
    } else {
        for (int i = 1; i < argc; ++i) {
            std::string arg(argv[i]);
            bool is_all = parse_input(map_ids, arg);
            all = all || is_all;
        }
    }

    // split all specified files
    if (all) {
        for (auto const& id_f : filemap) {
            int map_id = id_f.first;
            std::vector<std::string> filenames = id_f.second;
            split_kcm(map_id, filenames);
        }
    } else {
        for (int map_id : map_ids) {
            if (filemap.find(map_id) != filemap.end()) {
                split_kcm(map_id, filemap[map_id]);
            } else {
                printf("Map %02X is not a valid map.\n", map_id);
            }
        }
    }

    return 0;
}
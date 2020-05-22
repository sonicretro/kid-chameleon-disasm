#include <cstdio>
#include <cstdlib>
#include <vector>
#include <array>
#include <list>
#include <fstream>
#include <sstream>
#include <iostream>
#include <string>

#include "bigendian_io.h"
#include "bitstream.h"

using namespace std;

char version[11] = "2020-05-21";


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


void compress_blocks(std::vector< std::vector < std::array<unsigned char, 5> > > blocks, const char* block_name) {
    int xsize = (int) blocks[0].size();
    int ysize = (int) blocks.size();
    int xbits = slog2(xsize)+1;
    int ybits = slog2(ysize)+1;

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


int main(int argc, char* argv[]) {
    if(argc < 3) {
        printf("Usage: compress_blocks.exe inputfile outputfile\n");
        printf("Version: %s\n", version);
        printf("Compresses blocks from expanded kcm format into the game's format.\n");
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

    // put data into matrix
    int pos = 0;
    int xsize = (data[pos++] << 8) + data[pos++];
    int ysize = (data[pos++] << 8) + data[pos++];
    std::vector< std::vector < std::array<unsigned char, 5> > > blocks(ysize, std::vector<std::array<unsigned char, 5> >(xsize));
    for (int y = 0; y < ysize; ++y) {    
        for (int x = 0; x < xsize; ++x) {
            for (int b = 0; b < 5; ++b) {
                blocks[y][x][b] = data[pos++];
            }
        }
    }

    compress_blocks(blocks, argv[2]);

    return 0;
}

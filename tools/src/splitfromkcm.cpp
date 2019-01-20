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

#include "compress_algo.cpp"

using namespace std;

char version[11] = "2018-03-04";


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
    compress(kcm+tile_offset, block_offset-tile_offset, ("level/" + filenames[4]).c_str(), false);

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
    std::cout << "Version: " << version << std::endl;
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

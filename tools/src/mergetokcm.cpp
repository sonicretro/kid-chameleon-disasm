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

char version[11] = "2018-03-01";
// mostly based on Saxman's old code

char map_theme_text[11][9]={
    "null",
    "castle",
    "ice",
    "ruins",
    "island",
    "desert",
    "swamp",
    "mountain",
    "cave",
    "woods",
    "city"
};

char command_options[4][10]={
    "-info",
    "-map",
    "-theme",
    "-hologram"
};

#define GRID_SIZE_PER_SCREEN    280

unsigned char   theme;

int             address_map_header = 0;
int             address_map_order = 0;
signed char     dump_editor_data = 1;
unsigned char   level;
unsigned char   map;

unsigned short  grid_size;  // maximum of 8,400 squares for 30 screens
unsigned char   map_size_x;
unsigned char   map_size_y;
unsigned char   map_shift;  // never use this with too many screens
unsigned short  map_theme;
signed short    player_x;
signed short    player_y;
signed short    flag_x;
signed short    flag_y;
int             address_tile_front;
int             address_block;
int             address_tile_back;
int             address_enemy;

int             address_level_name;
unsigned char   *level_name;
char            level_number;

int i = 0;      // Global temporary variable
int n = 0;      // Global temporary variable

unsigned char *output_data;
unsigned short output_size=0;
unsigned short output_pos=0;

FILE *rom;
FILE *fheader;
FILE *fenemy;
FILE *fblock;
FILE *fforeground;
FILE *fbackground;
FILE *kcm;
FILE *dump;

char number_text[3];
char dump_filename[12];
char rom_filename[128];


int ReadData();
void WriteData(unsigned char var);
int SeekData(int pos, signed char seek);
void ExpandBlockLayout(FILE*);
void Decompress(FILE*, unsigned short size);

void ReadMapHeader(FILE*);
int merge_kcm(int, std::vector<std::string>);

struct BLOCK_HEADER
{
    char hidden: 1;
    char block: 5;
};

struct TELEPAD
{
    char map: 8;
    char warp_y: 8;
    short warp_x: 9;
};



int swap_endian(unsigned int in, char size){
    unsigned int out;
    
    switch(size){
        case 2:
            out = ((in & 0xFF) << 8) + ((in & 0xFF00) >> 8);
            break;
        case 4:
            out = (in << 24) + ((in & 0xFF00) << 8) + ((in & 0xFF0000) >> 8) + (in >> 24);
            break;
    }
    
    return out;
}

void swap_bits(int in, char bits){
    int out;
    
    while(bits > 0){
        out |= ((in & 1) << (bits-1));
        in >>= 1;
        bits--;
    }
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

    std::cout << "Merges files as specified in level/level_files.txt into a single .kcm file." << std::endl;
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
            merge_kcm(map_id, filenames);
        }
    } else {
        for (int map_id : map_ids) {
            if (filemap.find(map_id) != filemap.end()) {
                merge_kcm(map_id, filemap[map_id]);
            } else {
                printf("Map %02X is not a valid map.\n", map_id);
            }
        }
    }

    return 0;
}


int merge_kcm(int map_id, std::vector<std::string> filenames) {
    FILE* fheader = fopen(("level/" + filenames[2]).c_str(), "rb");
    if (fheader == NULL) {
        std::cout << "Could not open " << "level/" + filenames[2] << std::endl;
        return -1;
    }
    FILE* fbackground = fopen(("level/" + filenames[6]).c_str(), "rb");
    if (fbackground == NULL) {
        std::cout << "Could not open " << "level/" + filenames[6] << std::endl;
        return -1;
    }
    FILE* fforeground = fopen(("level/" + filenames[4]).c_str(), "rb");
    if (fforeground == NULL) {
        std::cout << "Could not open " << "level/" + filenames[4] << std::endl;
        return -1;
    } 
    FILE* fenemy = fopen(("level/" + filenames[3]).c_str(), "rb");
    if (fenemy == NULL) {
        std::cout << "Could not open " << "level/" + filenames[3] << std::endl;
        return -1;
    }
    FILE* fblock = fopen(("level/" + filenames[5]).c_str(), "rb");
    if (fblock == NULL) {
        std::cout << "Could not open " << "level/" + filenames[5] << std::endl;
        return -1;
    }

    sprintf(dump_filename, "map%02x.kcm", map_id);
    dump = fopen(dump_filename, "w+b");
    
    output_size = 0;
    output_pos = 0;
    output_data = 0;
    
    ReadMapHeader(fheader);
    
    output_size = 28;
    output_pos = 28;
    output_data = (unsigned char*)realloc(output_data, output_size);
    
    output_data[0] = 'K';
    output_data[1] = 'M';
    output_data[2] = 'A';
    output_data[3] = 'P';
    output_data[4] = 0x80;
    output_data[5] = 0x00;
    output_data[6] = map_size_x;
    output_data[7] = map_size_y + (map_shift << 6);
    output_data[8] = map_theme;
    output_data[9] = map_theme >> 8;
    output_data[10] = player_x;
    output_data[11] = player_x >> 8;
    output_data[12] = player_y;
    output_data[13] = player_y >> 8;
    output_data[14] = flag_x;
    output_data[15] = flag_x >> 8;
    output_data[16] = flag_y;
    output_data[17] = flag_y >> 8;
    
    // tile layout (front)
    output_data[18] = output_pos;
    output_data[19] = output_pos >> 8;
    Decompress(fforeground, grid_size);
    //output_size = grid_size + 24;
    //output_pos = output_size;
    //output_data = realloc(output_data, output_size);  // this fixes a bug
    
    // block layout
    output_data[20] = output_pos;
    output_data[21] = output_pos >> 8;
    ExpandBlockLayout(fblock);
    //output_size = grid_size + (grid_size << 8) + 24;
    //output_pos = output_size;
    //output_data = realloc(output_data, output_size);  // this fixes a bug
    
    // tile layout (back)
    output_data[22] = output_pos;
    output_data[23] = output_pos >> 8;
    // INSERT CODE HERE
    fseek(fbackground, 0, SEEK_END);
    int bgsize = ftell(fbackground);
    output_size += bgsize;
    fseek(fbackground, 0, SEEK_SET);
    output_data = (unsigned char*) realloc(output_data, output_size);
    fread(output_data+output_pos, bgsize, 1, fbackground);
    output_pos += bgsize;
    fclose(fbackground);

    // enemy layout
    output_data[24] = output_pos;
    output_data[25] = output_pos >> 8;
    // INSERT CODE HERE
    fseek(fenemy, 0, SEEK_END);
    int enemysize = ftell(fenemy)-7;
    output_size += enemysize;
    fseek(fenemy, 4, SEEK_SET); // skip the first 4 bytes
    output_data = (unsigned char*) realloc(output_data, output_size);
    fread(output_data+output_pos, 6, 1, fenemy);
    output_pos += 6;
    fseek(fenemy, 4+6+3, SEEK_SET); // skip another 3 bytes
    fread(output_data+output_pos, enemysize-6, 1, fenemy);
    output_pos += enemysize-6;
    fclose(fenemy);


    output_data[26] = output_pos;
    output_data[27] = output_pos >> 8;

    for(i=0; i < output_size; i++)
        fwrite(&output_data[i], 1, 1, dump);
    
    free(output_data);
    fclose(dump);
    printf("Successfully created %s\n", dump_filename);
    output_data = 0;
    dump = 0;

    return 0;
}








void ReadMapHeader(FILE* rom)
{   
    ///////////////////////
    // Get map header info
    ///////////////////////
    fseek(rom, 0, SEEK_SET);
    
    fread(&map_size_x, 1, 1, rom);
    fread(&map_size_y, 1, 1, rom);
    map_shift = map_size_y >> 6;
    map_size_y &= 0x3F; // fix for maps 29 and 42
    fread(&map_theme, 2, 1, rom);
    fread(&player_x, 2, 1, rom);
    fread(&player_y, 2, 1, rom);
    player_x = swap_endian(player_x, 2);
    player_y = swap_endian(player_y, 2);
    fread(&flag_x, 2, 1, rom);
    fread(&flag_y, 2, 1, rom);
    flag_x = swap_endian(flag_x, 2);
    flag_y = swap_endian(flag_y, 2);
    fread(&address_tile_front, 4, 1, rom);
    fread(&address_block, 4, 1, rom);
    fread(&address_tile_back, 4, 1, rom);
    fread(&address_enemy, 4, 1, rom);
    address_tile_front = swap_endian(address_tile_front, 4);
    address_block = swap_endian(address_block, 4);
    address_tile_back = swap_endian(address_tile_back, 4);
    address_enemy = swap_endian(address_enemy, 4);
    
    grid_size = map_size_x * map_size_y * GRID_SIZE_PER_SCREEN;
}





int ReadData(){
    if(output_pos >= output_size)
        return 0;
    
    output_pos++;
    return output_data[output_pos-1];
}



void WriteData(unsigned char var){
    if(output_pos >= output_size){
        output_size++;
        output_data = (unsigned char*)realloc(output_data, output_size);
    }
    output_data[output_pos] = var;
    output_pos++;
    //printf("\n----%04X\n", output_size);
    //printf("\n----%04X\n", output_pos);
}



int SeekData(int pos, signed char seek){
    switch(seek){
        case SEEK_CUR:
            output_pos += pos;
            break;
        case SEEK_SET:
            output_pos = pos;
            break;
        case SEEK_END:
            output_pos = output_size - pos;
            break;
        default:
            return 1;
    };
    //printf("\n    %04X", output_size);
    
    return 0;
}



void ExpandBlockLayout(FILE* rom)
{
    /*
    Code is included to prevent ghost blocks (0x03) from being overwritten by
    other blocks due to the way ghost blocks behave in Kid Chameleon. When they
    disappear or reappear, they overwrite any blocks that are in the way. An
    example of this is found in map 0x37 (The Crystal Crags II).
    */
    unsigned char *block_data;
    unsigned char x_bits;
    unsigned char y_bits;
    unsigned char bitpos=0;
    unsigned short blockpos=0;
    unsigned char data1;
    unsigned int data2;
    unsigned int data3;
    unsigned char block_type=0;
    unsigned short x_pos;
    unsigned short y_pos;
    unsigned char *data_bits;
    unsigned int data_size=0;
    unsigned char c;
    
    block_data = (unsigned char*)calloc(grid_size * 6, 1);
    data_bits = 0;
    /*block_data[0] = 0;
    block_data[1] = 0;
    block_data[2] = 0;
    block_data[3] = 0;
    block_data[4] = 0;
    block_data[5] = 0;
    block_data[6] = 0;
    block_data[7] = 0;*/
    
    // Read layout header
    fseek(rom, 1, SEEK_SET);
    fread(&y_bits, 1, 1, rom);
    x_bits = (y_bits >> 4);
    y_bits &= 0xF;
    i = 0;
    //printf("x_bits = %i\ny_bits = %i\n\n", x_bits, y_bits);
    fread(&data1, 1, 1, rom);
    //printf("data1 = %02X\n", data1);
    
    
    
    while(block_type != 0x3F){
        // Read block header
        data_size += 6;
        data_bits = (unsigned char*)realloc(data_bits, data_size);
        for(n=0; n<6; n++){
            if(bitpos > 7){
                bitpos = 0;
                fread(&data1, 1, 1, rom);
                //printf("data1 = %02X\n", data1);
            }
            data_bits[i+n] = (data1 >> (7-bitpos)) & 1;
            bitpos++;
        }
        block_type = (data_bits[i] << 5) + (data_bits[i+1] << 4) + (data_bits[i+2] << 3)
                    + (data_bits[i+3] << 2) + (data_bits[i+4] << 1) + data_bits[i+5];
        //printf("block_type = %02X  %i%i%i%i%i%i\n", block_type, data_bits[i], data_bits[i+1], data_bits[i+2], data_bits[i+3], data_bits[i+4], data_bits[i+5]);
        i += 6;
        if(block_type != 0x3F){
            block_type += 0x80; // avoids conflict with 0x00 blocks mistaken for nothing
            data_size += x_bits;
            data_bits = (unsigned char*)realloc(data_bits, data_size);
            x_pos = 0;
            y_pos = 0;
            for(n=0; n < x_bits; n++){
                if(bitpos > 7){
                    bitpos = 0;
                    fread(&data1, 1, 1, rom);
                    //printf("data1 = %02X\n", data1);
                }
                data_bits[i+n] = (data1 >> (7-bitpos)) & 1;
                x_pos += (data_bits[i+n] << x_bits-n-1);
                bitpos++;
            }
            i += x_bits;
            while(x_pos != ((1 << x_bits) - 1)){
                data_size += y_bits;
                data_bits = (unsigned char*)realloc(data_bits, data_size);
                for(n=0; n < y_bits; n++){
                    if(bitpos > 7){
                        bitpos = 0;
                        fread(&data1, 1, 1, rom);
                        //printf("data1 = %02X\n", data1);
                    }
                    data_bits[i+n] = (data1 >> (7-bitpos)) & 1;
                    y_pos += (data_bits[i+n] << y_bits-n-1);
                    bitpos++;
                }
                i += y_bits;
                //printf("    x_pos = %02X\n    y_pos = %02X\n", x_pos, y_pos);
                
                switch(block_type & 0x1F){
                    case 0x0:   // rock
                    case 0x2:   // ice
                    case 0x5:   // iron
                    case 0x6:   // rubber
                    case 0x7:   // shifting
                    case 0x9:   // mushroom
                        data_size += 5;
                        data_bits = (unsigned char*)realloc(data_bits, data_size);
                        
                        if(block_data[(x_pos + (y_pos * 20 * map_size_x)) * 6] != 0x83)
                            block_data[(x_pos + (y_pos * 20 * map_size_x)) * 6] = block_type;
                        
                        data2 = 0;
                        for(n=0; n < 5; n++){
                            if(bitpos > 7){
                                bitpos = 0;
                                fread(&data1, 1, 1, rom);
                                //printf("data1 = %02X\n", data1);
                            }
                            data_bits[i+n] = (data1 >> (7-bitpos)) & 1;
                            data2 += (data_bits[i+n] << 4-n);
                            bitpos++;
                        }
                        i += 5;
                        //printf("    quantity = %X\n    direction = %X\n", data2 >> 1, data2 & 1);
                        
                        if((data2 & 1) == 0){
                            for(n=0; n < (data2 >> 1); n++){
                                if(block_data[(x_pos + (y_pos * 20 * map_size_x)) * 6] != 0x83)
                                    block_data[((x_pos + n+1 + (y_pos * 20 * map_size_x)) * 6)] = block_type;
                            }
                        }
                        else{
                            for(n=0; n < (data2 >> 1); n++){
                                if(block_data[(x_pos + (y_pos * 20 * map_size_x)) * 6] != 0x83)
                                    block_data[((x_pos + ((y_pos + n+1) * 20 * map_size_x)) * 6)] = block_type;
                            }
                        }
                        //printf("\n");
                        break;
                    case 0x1:   // prize
                        data_size += 5;
                        data_bits = (unsigned char*)realloc(data_bits, data_size);
                        
                        data2 = 0;
                        for(n=0; n < 5; n++){
                            if(bitpos > 7){
                                bitpos = 0;
                                fread(&data1, 1, 1, rom);
                                //printf("data1 = %02X\n", data1);
                            }
                            data_bits[i+n] = (data1 >> (7-bitpos)) & 1;
                            data2 += (data_bits[i+n] << 4-n);
                            bitpos++;
                        }
                        i += 5;
                        //printf("    quantity = %X\n    direction = %X\n", data2 >> 1, data2 & 1);
                        
                        if((data2 & 1) == 0){
                            for(n=0; n <= (data2 >> 1); n++){
                                data_size += 5;
                                data_bits = (unsigned char*)realloc(data_bits, data_size);
                                data3 = 0;
                                for(c=0; c < 5; c++){
                                    if(bitpos > 7){
                                        bitpos = 0;
                                        fread(&data1, 1, 1, rom);
                                        //printf("data1 = %02X\n", data1);
                                    }
                                    data_bits[i+c] = (data1 >> (7-bitpos)) & 1;
                                    data3 += (data_bits[i+c] << 4-c);
                                    bitpos++;
                                }
                                i += 5;
                                if(block_data[((x_pos + n + (y_pos * 20 * map_size_x)) * 6)] != 0x83){
                                    block_data[((x_pos + n + (y_pos * 20 * map_size_x)) * 6)] = block_type;
                                    block_data[((x_pos + n + (y_pos * 20 * map_size_x)) * 6) + 1] = data3;
                                }
                                //printf("    prize = %02X\n", data3);
                            }
                        }
                        else{
                            for(n=0; n <= (data2 >> 1); n++){
                                data_size += 5;
                                data_bits = (unsigned char*)realloc(data_bits, data_size);
                                data3 = 0;
                                for(c=0; c < 5; c++){
                                    if(bitpos > 7){
                                        bitpos = 0;
                                        fread(&data1, 1, 1, rom);
                                        //printf("data1 = %02X\n", data1);
                                    }
                                    data_bits[i+c] = (data1 >> (7-bitpos)) & 1;
                                    data3 += (data_bits[i+c] << 4-c);
                                    bitpos++;
                                }
                                i += 5;
                                if(block_data[((x_pos + ((y_pos + n) * 20 * map_size_x)) * 6)] != 0x83){
                                    block_data[((x_pos + ((y_pos + n) * 20 * map_size_x)) * 6)] = block_type;
                                    block_data[((x_pos + ((y_pos + n) * 20 * map_size_x)) * 6) + 1] = data3;
                                }
                                //printf("    prize = %02X\n", data3);
                            }
                        }
                        //printf("\n");
                        break;
                    case 0x3:   // ghost
                        data_size += 31;
                        data_bits = (unsigned char*)realloc(data_bits, data_size);
                        
                        data2 = 0;
                        for(n=0; n < 31; n++){
                            if(bitpos > 7){
                                bitpos = 0;
                                fread(&data1, 1, 1, rom);
                                //printf("data1 = %02X\n", data1);
                            }
                            data_bits[i+n] = (data1 >> (7-bitpos)) & 1;
                            data2 += (data_bits[i+n] << 30-n);
                            bitpos++;
                        }
                        i += 31;
                        //printf("    quantity = %X\n    direction = %X\n", data2 >> 28, (data2 >> 27) & 1);
                        
                        if(block_data[(x_pos + (y_pos * 20 * map_size_x)) * 6] != 0x83){
                            block_data[((x_pos + (y_pos * 20 * map_size_x)) * 6)] = block_type;
                            block_data[((x_pos + (y_pos * 20 * map_size_x)) * 6) + 1] = (data2 >> 19) & 0xFF;
                            block_data[((x_pos + (y_pos * 20 * map_size_x)) * 6) + 2] = (data2 >> 8) & 0xFF;
                            block_data[((x_pos + (y_pos * 20 * map_size_x)) * 6) + 3] = (data2 >> 16) & 0x7;
                            block_data[((x_pos + (y_pos * 20 * map_size_x)) * 6) + 4] = data2 & 0xFF;
                        }
                        
                        if(((data2 >> 27) & 1) == 0){
                            for(n=0; n < (data2 >> 28); n++){
                                if(block_data[((x_pos + n+1 + (y_pos * 20 * map_size_x)) * 6)] != 0x83){
                                    block_data[((x_pos + n+1 + (y_pos * 20 * map_size_x)) * 6)] = block_type;
                                    block_data[((x_pos + n+1 + (y_pos * 20 * map_size_x)) * 6) + 1] = (data2 >> 19) & 0xFF;
                                    block_data[((x_pos + n+1 + (y_pos * 20 * map_size_x)) * 6) + 2] = (data2 >> 8) & 0xFF;
                                    block_data[((x_pos + n+1 + (y_pos * 20 * map_size_x)) * 6) + 3] = (data2 >> 16) & 0x7;
                                    block_data[((x_pos + n+1 + (y_pos * 20 * map_size_x)) * 6) + 4] = data2 & 0xFF;
                                }
                            }
                        }
                        else{
                            for(n=0; n < (data2 >> 28); n++){
                                if(block_data[((x_pos + ((y_pos + n+1) * 20 * map_size_x)) * 6)] != 0x83){
                                    block_data[((x_pos + ((y_pos + n+1) * 20 * map_size_x)) * 6)] = block_type;
                                    block_data[((x_pos + ((y_pos + n+1) * 20 * map_size_x)) * 6) + 1] = (data2 >> 19) & 0xFF;
                                    block_data[((x_pos + ((y_pos + n+1) * 20 * map_size_x)) * 6) + 2] = (data2 >> 8) & 0xFF;
                                    block_data[((x_pos + ((y_pos + n+1) * 20 * map_size_x)) * 6) + 3] = (data2 >> 16) & 0x7;
                                    block_data[((x_pos + ((y_pos + n+1) * 20 * map_size_x)) * 6) + 4] = data2 & 0xFF;
                                }
                            }
                        }
                        
                        //printf("\n");
                        break;
                    case 0x4:   // telepad
                        data_size += 25;
                        data_bits = (unsigned char*)realloc(data_bits, data_size);
                        
                        if(block_data[(x_pos + (y_pos * 20 * map_size_x)) * 6] != 0x83)
                            block_data[(x_pos + (y_pos * 20 * map_size_x)) * 6] = block_type;
                        
                        data2 = 0;
                        for(n=0; n < 25; n++){
                            if(bitpos > 7){
                                bitpos = 0;
                                fread(&data1, 1, 1, rom);
                                //printf("data1 = %02X\n", data1);
                            }
                            data_bits[i+n] = (data1 >> (7-bitpos)) & 1;
                            data2 += (data_bits[i+n] << 24-n);
                            bitpos++;
                        }
                        i += 25;
                        
                        if(block_data[(x_pos + (y_pos * 20 * map_size_x)) * 6] != 0x83){
                            block_data[((x_pos + (y_pos * 20 * map_size_x)) * 6) + 1] = (data2 >> 17);
                            block_data[((x_pos + (y_pos * 20 * map_size_x)) * 6) + 2] = (data2 >> 9) & 0xFF;
                            block_data[((x_pos + (y_pos * 20 * map_size_x)) * 6) + 3] = data2 & 0xFF;
                            block_data[((x_pos + (y_pos * 20 * map_size_x)) * 6) + 4] = (data2 >> 8) & 1;
                        }
                        //printf("\n");
                        break;
                    case 0xA:   // cannon/vanishing
                    case 0xC:   // drill
                        data_size += 5;
                        data_bits = (unsigned char*)realloc(data_bits, data_size);
                        
                        data2 = 0;
                        for(n=0; n < 5; n++){
                            if(bitpos > 7){
                                bitpos = 0;
                                fread(&data1, 1, 1, rom);
                                //printf("data1 = %02X\n", data1);
                            }
                            data_bits[i+n] = (data1 >> (7-bitpos)) & 1;
                            data2 += (data_bits[i+n] << 4-n);
                            bitpos++;
                        }
                        i += 5;
                        //printf("    quantity = %X\n    direction = %X\n", data2 >> 1, data2 & 1);
                        
                        if((data2 & 1) == 0){
                            for(n=0; n <= (data2 >> 1); n++){
                                data_size += 4;
                                data_bits = (unsigned char*)realloc(data_bits, data_size);
                                data3 = 0;
                                for(c=0; c < 4; c++){
                                    if(bitpos > 7){
                                        bitpos = 0;
                                        fread(&data1, 1, 1, rom);
                                        //printf("data1 = %02X\n", data1);
                                    }
                                    data_bits[i+c] = (data1 >> (7-bitpos)) & 1;
                                    data3 += (data_bits[i+c] << 3-c);
                                    bitpos++;
                                }
                                i += 4;
                                if(block_data[((x_pos + n + (y_pos * 20 * map_size_x)) * 6)] != 0x83){
                                    block_data[((x_pos + n + (y_pos * 20 * map_size_x)) * 6)] = block_type;
                                    block_data[((x_pos + n + (y_pos * 20 * map_size_x)) * 6) + 1] = data3;
                                }
                            }
                        }
                        else{
                            for(n=0; n <= (data2 >> 1); n++){
                                data_size += 4;
                                data_bits = (unsigned char*)realloc(data_bits, data_size);
                                data3 = 0;
                                for(c=0; c < 4; c++){
                                    if(bitpos > 7){
                                        bitpos = 0;
                                        fread(&data1, 1, 1, rom);
                                        //printf("data1 = %02X\n", data1);
                                    }
                                    data_bits[i+c] = (data1 >> (7-bitpos)) & 1;
                                    data3 += (data_bits[i+c] << 3-c);
                                    bitpos++;
                                }
                                i += 4;
                                if(block_data[((x_pos + ((y_pos + n) * 20 * map_size_x)) * 6)] != 0x83){
                                    block_data[((x_pos + ((y_pos + n) * 20 * map_size_x)) * 6)] = block_type;
                                    block_data[((x_pos + ((y_pos + n) * 20 * map_size_x)) * 6) + 1] = data3;
                                }
                            }
                        }
                        //printf("\n");
                        break;
                    case 0xB:   // lift
                        if(block_data[(x_pos + (y_pos * 20 * map_size_x)) * 6] != 0x83)
                            block_data[(x_pos + (y_pos * 20 * map_size_x)) * 6] = block_type;
                        //printf("\n");
                        break;
                    case 0x10:  // hidden passage
                        data_size += 5;
                        data_bits = (unsigned char*)realloc(data_bits, data_size);
                        
                        data2 = 0;
                        for(n=0; n < 5; n++){
                            if(bitpos > 7){
                                bitpos = 0;
                                fread(&data1, 1, 1, rom);
                                //printf("data1 = %02X\n", data1);
                            }
                            data_bits[i+n] = (data1 >> (7-bitpos)) & 1;
                            data2 += (data_bits[i+n] << 4-n);
                            bitpos++;
                        }
                        i += 5;
                        //printf("    quantity = %X\n    direction = %X\n", data2 >> 1, data2 & 1);
                        
                        if((data2 & 1) == 0){
                            for(n=0; n <= (data2 >> 1); n++){
                                data_size += 3;
                                data_bits = (unsigned char*)realloc(data_bits, data_size);
                                data3 = 0;
                                for(c=0; c < 3; c++){
                                    if(bitpos > 7){
                                        bitpos = 0;
                                        fread(&data1, 1, 1, rom);
                                        //printf("data1 = %02X\n", data1);
                                    }
                                    data_bits[i+c] = (data1 >> (7-bitpos)) & 1;
                                    data3 += (data_bits[i+c] << 2-c);
                                    bitpos++;
                                }
                                i += 3;
                                if(block_data[((x_pos + n + (y_pos * 20 * map_size_x)) * 6)] != 0x83){
                                    block_data[((x_pos + n + (y_pos * 20 * map_size_x)) * 6)] = block_type;
                                    block_data[((x_pos + n + (y_pos * 20 * map_size_x)) * 6) + 1] = data3;
                                }
                            }
                        }
                        else{
                            for(n=0; n <= (data2 >> 1); n++){
                                data_size += 3;
                                data_bits = (unsigned char*)realloc(data_bits, data_size);
                                data3 = 0;
                                for(c=0; c < 3; c++){
                                    if(bitpos > 7){
                                        bitpos = 0;
                                        fread(&data1, 1, 1, rom);
                                        //printf("data1 = %02X\n", data1);
                                    }
                                    data_bits[i+c] = (data1 >> (7-bitpos)) & 1;
                                    data3 += (data_bits[i+c] << 2-c);
                                    bitpos++;
                                }
                                i += 3;
                                if(block_data[((x_pos + ((y_pos + n) * 20 * map_size_x)) * 6)] != 0x83){
                                    block_data[((x_pos + ((y_pos + n) * 20 * map_size_x)) * 6)] = block_type;
                                    block_data[((x_pos + ((y_pos + n) * 20 * map_size_x)) * 6) + 1] = data3;
                                }
                            }
                        }
                        //printf("\n");
                        break;
                    case 0x8:   // WTF?!
                    case 0xD:   // freezes game
                    case 0xE:   // freezes game
                    case 0xF:   // freezes game
                    default:
                        printf("\nFound block-type 0x%02X at 0x%06X\n", block_type-0x80, (unsigned int) ftell(rom));
                        system("PAUSE");
                }
                
                data_size += x_bits;
                data_bits = (unsigned char*)realloc(data_bits, data_size);
                x_pos = 0;
                y_pos = 0;
                for(n=0; n < x_bits; n++){
                    if(bitpos > 7){
                        bitpos = 0;
                        fread(&data1, 1, 1, rom);
                    }
                    data_bits[i+n] = (data1 >> (7-bitpos)) & 1;
                    x_pos += (data_bits[i+n] << x_bits-n-1);
                    bitpos++;
                }
                i += x_bits;
            }
        }
    }
    int void_counter = 0;
    for(n=0; n < (grid_size * 6); n += 6){
        // compress the empty space for the new kcm format:
        if (block_data[n] == 0) {
            void_counter += 1;
        } else {
            if (void_counter > 0) {
                while (void_counter >= 0x80) {
                    WriteData(0x7F);
                    void_counter -= 0x80;
                }
                if (void_counter > 0) {
                    WriteData(void_counter - 1);
                    void_counter = 0;
                }
            }
            WriteData(block_data[n]);
            WriteData(block_data[n+1]);
            WriteData(block_data[n+2]);
            WriteData(block_data[n+3]);
            WriteData(block_data[n+4]);
        }    
    }

    if (void_counter > 0) {
        while (void_counter >= 0x80) {
            WriteData(0x7F);
            void_counter -= 0x80;
        }
        if (void_counter > 0) {
            WriteData(void_counter - 1);
        }
    }
    
    free(block_data);
    free(data_bits);
}



void Decompress(FILE* rom, unsigned short size)
{
    int compressed_data_start;
    int compressed_data_size;
    int address_input_data;
    int address_stop;
    int address_key_data;
    unsigned char *input_data;      // compressed level data
    unsigned char *key_data;        // store all the individual 1's and 0's of key data
    unsigned short in1; // input byte
    unsigned short in2; // extra input byte for long references
    unsigned short in3;
    unsigned char bitpos;
    unsigned short keybit;
    unsigned short unit;    // keep track of how many blocks we have when decompressing
    unsigned short key;     // key data
    unsigned short count;   // counter
    
    fseek(rom, 0, SEEK_SET);
    compressed_data_start = ftell(rom);
    fread(&address_input_data, 2, 1, rom);
    address_input_data = swap_endian(address_input_data, 2) + 2;
    address_stop = address_input_data;
    address_key_data = ftell(rom);  // only needed if debugging
    
    unit=0;
    bitpos=0;
    for(n=0; unit < size && address_key_data < address_stop; n++){
        fread(&key, 2, 1, rom);
        key = swap_endian(key, 2);
        fseek(rom, -2, SEEK_CUR);
        keybit = (((key << bitpos) & 0x8000) >> 15);    // get bit
        bitpos++;
        switch(keybit){
            case 1:     // direct copy
                #ifdef DEBUG
                printf("%05X %05X %X  direct          u-%04X-%04X\n", address_key_data, address_input_data, bitpos, unit, ftell(dump));// system("PAUSE");
                #endif
                unit++; // increase block count
                address_key_data = ftell(rom);
                fseek(rom, address_input_data, SEEK_SET);
                //output_size++;
                //output_data = realloc(output_data, output_size);
                fread(&in1, 1, 1, rom);
                WriteData(in1);
                //fwrite(&in1, 1, 1, dump);
                address_input_data = ftell(rom);
                fseek(rom, address_key_data, SEEK_SET);
                break;
            case 0:     // reference copy
                keybit = (((key << bitpos) & 0x8000) >> 15);
                bitpos++;
                switch(keybit){
                    case 0:     // short-range reference
                        n += 2;
                        keybit = (((key << bitpos) & 0x8000) >> 15);
                        bitpos++;
                        address_key_data = ftell(rom);
                        fseek(rom, address_input_data, SEEK_SET);
                        fread(&in1, 1, 1, rom); // get source
                        #ifdef DEBUG
                        printf("%05X %05X %X  ref-short       u-%04X-%04X  s-%04X  c-%04X\n", address_key_data, address_input_data, bitpos, unit, ftell(dump), in1, keybit+2);// system("PAUSE");
                        #endif
                        if(in1 != 0){
                            for(count=keybit+2; count > 0; count--){
                                SeekData(-in1, SEEK_CUR);
                                in3 = ReadData();
                                SeekData(in1-1, SEEK_CUR);
                                WriteData(in3);
                                //fseek(dump, -in1, SEEK_CUR);
                                //fread(&in3, 1, 1, dump);
                                //fseek(dump, in1-1, SEEK_CUR);
                                //fwrite(&in3, 1, 1, dump);
                            }
                        }
                        else{
                            unit--;
                            //in3=0;
                            for(count=0; count < keybit+1; count++)
                                WriteData(0);
                            //fwrite(&in3, 1, keybit+1, dump);
                        }
                        //else
                        //  fwrite(&in3, 1, count, dump);
                        output_size += (keybit+2);
                        output_data = (unsigned char*)realloc(output_data, output_size);
                        unit += (keybit+2);     // increase block count
                        address_input_data++;
                        fseek(rom, address_key_data, SEEK_SET);
                        break;
                    case 1:     // long-range reference
                        n += 6;
                        keybit = (((key << bitpos) & 0xE000) >> 13);
                        bitpos += 3;
                        count = (((key << bitpos) & 0xC000) >> 14);
                        bitpos += 2;
                        switch(count){
                            case 3:     // large copy
                                address_key_data = ftell(rom);
                                fseek(rom, address_input_data, SEEK_SET);
                                fread(&in1, 1, 1, rom);     // source
                                fread(&in2, 1, 1, rom);     // number of bytes to copy
                                count=in2;
                                in3=0;
                                #ifdef DEBUG
                                printf("%05X %05X %X  ref-long-large  u-%04X-%04X  s-%04X  c-%04X\n", address_key_data, address_input_data, bitpos, unit, ftell(dump), in1+(keybit<<8), in2);// system("PAUSE");
                                #endif
                                if(in1+(keybit<<8) != 0){
                                    for(; count > 0; count--){
                                        SeekData(-in1 - (keybit<<8), SEEK_CUR);
                                        in3 = ReadData();
                                        SeekData(in1-1 + (keybit<<8), SEEK_CUR);
                                        WriteData(in3);
                                        //fseek(dump, -in1 - (keybit<<8), SEEK_CUR);
                                        //fread(&in3, 1, 1, dump);
                                        //fseek(dump, in1-1 + (keybit<<8), SEEK_CUR);
                                        //fwrite(&in3, 1, 1, dump);
                                    }
                                }
                                else if(count > 0)
                                {
                                    unit--;
                                    //fwrite(&in3, 1, count-1, dump);
                                    for(; count > 1; count--)
                                        WriteData(in3);
                                }
                                output_size += (in2);
                                output_data = (unsigned char*)realloc(output_data, output_size);
                                unit += (in2);      // increase block count
                                address_input_data += 2;
                                fseek(rom, address_key_data, SEEK_SET);
                                break;
                            default:    // small copy
                                address_key_data = ftell(rom);
                                fseek(rom, address_input_data, SEEK_SET);
                                fread(&in1, 1, 1, rom); // source
                                count += 3;         // setting up counter for writing blocks
                                in2 = count;        // keeping a backup for later use
                                in3=0;
                                #ifdef DEBUG
                                printf("%05X %05X %X  ref-long-small  u-%04X-%04X  s-%04X  c-%04X\n", address_key_data, address_input_data, bitpos, unit, ftell(dump), in1+(keybit<<8), in2);// system("PAUSE");
                                #endif
                                if(in1+(keybit<<8) != 0){
                                    for(; count > 0; count--){
                                        SeekData(-in1 - (keybit<<8), SEEK_CUR);
                                        in3 = ReadData();
                                        SeekData(in1-1 + (keybit<<8), SEEK_CUR);
                                        WriteData(in3);
                                        //fseek(dump, -in1 - (keybit<<8), SEEK_CUR);
                                        //fread(&in3, 1, 1, dump);
                                        //fseek(dump, in1-1 + (keybit<<8), SEEK_CUR);
                                        //fwrite(&in3, 1, 1, dump);
                                    }
                                }
                                else{
                                    unit--;
                                    //fwrite(&in3, 1, count-1, dump);
                                    for(; count > 1; count--)
                                        WriteData(in3);
                                }
                                output_size += in2;
                                output_data = (unsigned char*)realloc(output_data, output_size);
                                unit += in2;        // increase block count
                                address_input_data++;
                                fseek(rom, address_key_data, SEEK_SET);
                                break;
                        };
                };
        };
        if(bitpos > 7){
            bitpos &= 7;
            fseek(rom, 1, SEEK_CUR);
        }
        in1 = 0;
        in2 = 0;
        in3 = 0;
        keybit = 0;
        count = 0;
        //printf("\n");
    }
    
    // Fill in the rest with zeros
    if(unit < size){
        //in3 = 0;
        //fwrite(&in3, 1, size-unit, dump);
        for(; unit < size; unit++)
            WriteData(0);
    }
    
    //output_data = realloc(output_data, size);
    //output_size = size;
    
    compressed_data_size = address_input_data - compressed_data_start;
    // printf("COMPRESSED DATA SIZE:   %i bytes\n", compressed_data_size);
    // printf("DECOMPRESSED DATA SIZE: %i bytes\n", size);
    // printf("RATIO:                  %3.01f %c\n", (float)size / (float)compressed_data_size * 100, '%');
    // printf("\n\n");
    //system("PAUSE");
    //free(key_data);
}

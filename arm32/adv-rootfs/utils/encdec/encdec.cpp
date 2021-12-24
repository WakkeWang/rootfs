#include <iostream>
#include <string>
#include <fstream>
#include <openssl/ssl.h>  
#include <openssl/aes.h>  

using namespace std;    

#define RELESE(P) 		\
    if (P) 				\
    { 					\
        delete P; 		\
        P = NULL; 		\
    }

#define RELESE_ARRAY(P) \
    if (P) 				\
    { 					\
        delete[] P; 	\
        P = NULL; 		\
    }

static unsigned char encdec_key[] = { 93, 30, 248, 134, 147, 238, 45, 98, 166, 213, 200, 219, 152, 78, 151, 172, 163, 207, 93, 149, 92, 246, 81, 60, 227, 148, 143, 194, 89, 19, 145, 100 };
static unsigned char btIV[] = { 251, 249, 237, 13, 161, 251, 105, 42, 255, 132, 161, 124, 56, 210, 124, 185 };

static void print_app_usage(char *app_name)
{
    printf("Usage:\n");
    printf("  %s [OPTIONS] in_file out_file\n", app_name);
	printf("Valid options:\n");
	printf("  -e  : encrypt in_file, outout out_file\n");
	printf("  -d  : decrypt in_file, outout out_file\n");
	printf("Example:\n");
	printf("  %s -e in_file out_file\n", app_name);
	printf("  %s -d in_file out_file\n", app_name);
}

int AesEncryptFile(std::string in_file_path, std::string out_file_path,   
                       const char *encrypt_key, int encrypt_chunk_size = 16)  
{  
    ifstream fin(in_file_path.c_str(), ios::binary);  
    ofstream fout(out_file_path.c_str(), ios::binary);  
	unsigned char iv[AES_BLOCK_SIZE];
	
    if (!fin)  
    {  
        cout << "Can not open fin file." << endl;  
        return -1;  
    }  
    if (!fout)  
    {  
        cout << "Can not open fout file." << endl;  
        return -1;  
    }  
  
    AES_KEY aeskey;
    memcpy(iv, btIV, sizeof(iv));
#if 0 //+= 
    unsigned char aes_keybuf[32];  
    memset(aes_keybuf, 0, sizeof(aes_keybuf));  
    strcpy((char *)aes_keybuf, encrypt_key);    
    AES_set_encrypt_key(aes_keybuf, 256, &aeskey);
#else
    if (AES_set_encrypt_key(encdec_key, 256, &aeskey) < 0) {
        cout << "Unable to set encrypt key in AES." << endl;
        return -1;
    }
#endif
    
    char *in_data  = new char[encrypt_chunk_size + 1];  
    char *out_data = new char[encrypt_chunk_size + 1];  

    while (! fin.eof())  
    {  
    	memset(in_data, 0, encrypt_chunk_size + 1);
        fin.read(in_data, encrypt_chunk_size);
        AES_cbc_encrypt((const unsigned char *)in_data, (unsigned char *)out_data, encrypt_chunk_size, &aeskey, iv, AES_ENCRYPT);
        fout.write(out_data, encrypt_chunk_size);
    }
  
    fout.close();  
    fin.close();  
  
    RELESE_ARRAY(in_data);  
    RELESE_ARRAY(out_data);  
  
    return 0;  
}

int AesDecryptFile(std::string in_file_path, std::string out_file_path,   
                       const char *dencrypt_key, int encrypt_chunk_size = 16)  
{  
    ifstream fin(in_file_path.c_str(), ios::binary);  
    ofstream fout(out_file_path.c_str(), ios::binary);  
	unsigned char iv[AES_BLOCK_SIZE];
  
    if (!fin)  
    {  
        cout << "Can not open fin file." << endl;  
        return -1;  
    }  
    if (!fout)  
    {  
        cout << "Can not open fout file." << endl;  
        return -1;  
    }  
  
    AES_KEY aeskey;  
    memcpy(iv, btIV, sizeof(iv));
#if 0 //+= 
    unsigned char aes_keybuf[32];  
    memset(aes_keybuf, 0, sizeof(aes_keybuf));
    strcpy((char *)aes_keybuf, dencrypt_key);    
    AES_set_decrypt_key(aes_keybuf, 256, &aeskey);
#else    
    if (AES_set_decrypt_key(encdec_key, 256, &aeskey) < 0) {
        cout << "Unable to set decrypt key in AES." << endl;
        return -1;
    }
#endif
  
    char *in_data  = new char[encrypt_chunk_size + 1];  
    char *out_data = new char[encrypt_chunk_size + 1];  
    
    while (! fin.eof())  
    {
    	memset(in_data, 0, encrypt_chunk_size + 1);
        fin.read(in_data, encrypt_chunk_size);
        AES_cbc_encrypt((unsigned char *)in_data,  (unsigned char *)out_data, encrypt_chunk_size, &aeskey, iv, AES_DECRYPT);
      	if (fin.gcount() > 0)
      	{
        	fout.write(out_data, strlen(out_data));  
    	}
    }
  
    fout.close();  
    fin.close();  
  
    RELESE_ARRAY(in_data);  
    RELESE_ARRAY(out_data);  
  
    return 0;  
}

int main(int argc, char *argv[])
{
    if (argc < 3) 
    {
		print_app_usage(argv[0]);
        return -1;
    }
	
	if (strcmp(argv[1], "-e") == 0)
	{
		AesEncryptFile(argv[2], argv[3], "12345678abcdefgh");  
	}
	else if (strcmp(argv[1], "-d") == 0)
	{
		AesDecryptFile(argv[2], argv[3], "12345678abcdefgh");
	}
	else
	{
		print_app_usage(argv[0]);
        return -1;
	}

    return 0;  
}

#ifndef _BYAUDIO_FILE_API_H
#define _BYAUDIO_FILE_API_H

#if (TARGET_PLATFORM==PLATFORM_ANDROID)
#include <unistd.h>
#include <dirent.h>
#endif

#if (TARGET_PLATFORM != PLATFORM_WIN32)
#include <dirent.h>
#endif

#include <stdio.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <stdlib.h>
#include "global.h"

#if (TARGET_PLATFORM == PLATFORM_WIN32)
BOOL WinIsDir(const char *pDir)
{
	char szCurPath[500];
	ZeroMemory(szCurPath, 500);
	sprintf_s(szCurPath, 500, "%s//*", pDir);
	WIN32_FIND_DATAA FindFileData;
	ZeroMemory(&FindFileData, sizeof(WIN32_FIND_DATAA));

	HANDLE hFile = FindFirstFileA(szCurPath, &FindFileData); /**< find first file by given path. */

	if (hFile == INVALID_HANDLE_VALUE)
	{
		FindClose(hFile);
		return FALSE; /** ��������ҵ���һ���ļ�����ôû��Ŀ¼ */
	}
	else
	{
		FindClose(hFile);
		return TRUE;
	}

}

BOOL WinCreateDir(const char * DirName)
{
	BOOL flag = true;
	if (!WinIsDir(DirName)){
		if (!CreateDirectoryA(DirName, NULL)){
			flag = false;
		}
	}
	return flag;
}

BOOL WinDeleteAllFile(const char * DirName)
{
	//	CFileFind tempFind;		//����һ��CFileFind�����������������
	char szCurPath[MAX_PATH];		//���ڶ���������ʽ
	_snprintf(szCurPath, MAX_PATH, "%s//*.*", DirName);	//ƥ���ʽΪ*.*,����Ŀ¼�µ������ļ�
	WIN32_FIND_DATAA FindFileData;
	ZeroMemory(&FindFileData, sizeof(WIN32_FIND_DATAA));
	HANDLE hFile = FindFirstFileA(szCurPath, &FindFileData);
	BOOL IsFinded = TRUE;
	while (IsFinded)
	{
		IsFinded = FindNextFileA(hFile, &FindFileData);	//�ݹ������������ļ�
		if (strcmp(FindFileData.cFileName, ".") && strcmp(FindFileData.cFileName, "..")) //�������"." ".."Ŀ¼
		{
			string strFileName = "";
			strFileName = strFileName + DirName + "//" + FindFileData.cFileName;
			string strTemp;
			strTemp = strFileName;
			if (!WinIsDir(strFileName.c_str())){
				DeleteFileA(strTemp.c_str());
			}
		}
	}
	FindClose(hFile);
	return TRUE;
}
#endif


//����Ŀ¼ ����-1��ʾ����ʧ�ܣ����ط�-1��ʾ�����ɹ�
int byaudio_create_dir(const char* dir)
{
	int status = 0;
#if (TARGET_PLATFORM == PLATFORM_WIN32)
	if (WinCreateDir(dir)){
		status = 1;
	}
#else
	if(mkdir(dir, S_IRWXU | S_IRWXG | S_IROTH | S_IXOTH) != -1){
		status = 1;
	}
#endif
	return status;
}


void byaudio_delete_all_file(const char *dir, int depth)
{
#if (TARGET_PLATFORM == PLATFORM_WIN32) 
	WinDeleteAllFile(dir);
#else
	DIR *dp;    //������FILE*
	struct dirent *entry;   //entry->d_type���ļ�����
	//��¼���ļ���ص�һЩ��Ϣ
	struct stat statbuf;

	//opendir()����һ��Ŀ¼������һ��Ŀ¼����
	//�ɹ��򷵻�һ��ָ��DIR�ṹ��ָ��
	if ((dp = opendir(dir)) == NULL){
		kefu_print_log_debug("audio_kefu","cannot open directory:%s\n", dir);
		return;
	}
	chdir(dir); //������Ŀ¼���ĵ�dir
	//readdir()����һ��ָ�룬��ָ��ָ��Ľṹ�ﱣ����dp����һ��Ŀ¼����й�����
	while ((entry = readdir(dp)) != NULL)
	{
		//��ȡһЩ���ļ���ص���Ϣ
		lstat(entry->d_name, &statbuf);
		//��ΪĿ¼
		if (S_ISDIR(statbuf.st_mode)){
			//�ų���ǰĿ¼���ϼ�Ŀ¼��������ѭ��
			if (strcmp(".", entry->d_name) == 0 || strcmp("..", entry->d_name) == 0){
				continue;
			}
			kefu_print_log_debug("audio_kefu","delete %*s%s/\n", depth, "", entry->d_name);
			byaudio_delete_all_file(entry->d_name, depth + 4);
		}
		else{
			kefu_print_log_debug("audio_kefu","%*s%s\n", depth, "", entry->d_name);
			int flag = remove(entry->d_name);
		}
	}
	//ϵͳ���ã����ܾ���cdһ��
	chdir("..");
	//�ر�Ŀ¼�����ͷ���ص���Դ
	closedir(dp);
#endif
}

int byaudio_read_file(string dir, string name, char** output)
{
	kefu_print_log_debug("audio_kefu", "byaudio_read_file");
	int flag = 0;
	if (!dir.empty() && !name.empty())
	{
		kefu_print_log_debug("audio_kefu", "byaudio_read_file -> dir = %s, name = %s", dir.c_str(), name.c_str());
		string fileName = dir + "/" + name;
		FILE* fp = fopen(fileName.c_str(), "r");
		if (fp != NULL){
			kefu_print_log_debug("audio_kefu", "byaudio_read_file -> fp != NULL");
			fseek(fp, 0, SEEK_END); //��λ���ļ�ĩ 
			kefu_print_log_debug("audio_kefu", "byaudio_read_file -> SEEK_END");
			int len = (int)ftell(fp); //�ļ�����
			if (*output != NULL){
				kefu_print_log_debug("audio_kefu", "byaudio_read_file -> delete *output");
				delete[] *output;
				*output = NULL;
			}
			kefu_print_log_debug("audio_kefu", "byaudio_read_file -> SEEK_SET");
			fseek(fp, 0, SEEK_SET); //��λ���ļ���ͷ 
			kefu_print_log_debug("audio_kefu", "byaudio_read_file -> new char");
			char* temp = new char[len + 1];
			int readSize = (int)fread(temp, sizeof(char), len, fp);
			kefu_print_log_debug("audio_kefu", "byaudio_read_file -> fread, len =%d", readSize);
			temp[len] = '\0';
			*output = temp;
			kefu_print_log_debug("audio_kefu", "byaudio_read_file -> fclose");
			fclose(fp);
			fp = NULL;
			flag = 1;
		}
	}
	kefu_print_log_debug("audio_kefu", "byaudio_read_file flag = %d", flag);
	return flag;
}
#endif
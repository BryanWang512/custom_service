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
		return FALSE; /** 如果不能找到第一个文件，那么没有目录 */
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
	//	CFileFind tempFind;		//声明一个CFileFind类变量，以用来搜索
	char szCurPath[MAX_PATH];		//用于定义搜索格式
	_snprintf(szCurPath, MAX_PATH, "%s//*.*", DirName);	//匹配格式为*.*,即该目录下的所有文件
	WIN32_FIND_DATAA FindFileData;
	ZeroMemory(&FindFileData, sizeof(WIN32_FIND_DATAA));
	HANDLE hFile = FindFirstFileA(szCurPath, &FindFileData);
	BOOL IsFinded = TRUE;
	while (IsFinded)
	{
		IsFinded = FindNextFileA(hFile, &FindFileData);	//递归搜索其他的文件
		if (strcmp(FindFileData.cFileName, ".") && strcmp(FindFileData.cFileName, "..")) //如果不是"." ".."目录
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


//创建目录 返回-1表示创建失败，返回非-1表示创建成功
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
	DIR *dp;    //类似于FILE*
	struct dirent *entry;   //entry->d_type：文件类型
	//记录和文件相关的一些信息
	struct stat statbuf;

	//opendir()：打开一个目录并建立一个目录流，
	//成功则返回一个指向DIR结构的指针
	if ((dp = opendir(dir)) == NULL){
		kefu_print_log_debug("audio_kefu","cannot open directory:%s\n", dir);
		return;
	}
	chdir(dir); //将工作目录更改到dir
	//readdir()返回一个指针，该指针指向的结构里保存着dp中下一个目录项的有关资料
	while ((entry = readdir(dp)) != NULL)
	{
		//获取一些与文件相关的信息
		lstat(entry->d_name, &statbuf);
		//若为目录
		if (S_ISDIR(statbuf.st_mode)){
			//排除当前目录和上级目录，避免死循环
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
	//系统调用，功能就像cd一样
	chdir("..");
	//关闭目录流，释放相关的资源
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
			fseek(fp, 0, SEEK_END); //定位到文件末 
			kefu_print_log_debug("audio_kefu", "byaudio_read_file -> SEEK_END");
			int len = (int)ftell(fp); //文件长度
			if (*output != NULL){
				kefu_print_log_debug("audio_kefu", "byaudio_read_file -> delete *output");
				delete[] *output;
				*output = NULL;
			}
			kefu_print_log_debug("audio_kefu", "byaudio_read_file -> SEEK_SET");
			fseek(fp, 0, SEEK_SET); //定位到文件开头 
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
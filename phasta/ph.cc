#include "ph.h"
#include <cstdio>
#include <cstdlib>
#include <stdarg.h>
#include <cassert>
#include <sstream>
#include <iostream>
#include <fstream>

/* OS-specific things try to stay here */
#include <sys/stat.h>
#include <unistd.h>
#include <errno.h>

#include <PCU.h>

namespace ph {

void fail(const char* format, ...)
{
  va_list ap;
  va_start(ap, format);
  vfprintf(stderr, format, ap);
  va_end(ap);
  fprintf(stderr,"\n");
  abort();
}

enum {
  DIR_MODE = S_IRWXU | S_IRWXG | S_IROTH | S_IXOTH
};

void checkErrno(const char* where)
{
  if (errno) {
    fprintf(stderr,"errno = %d on rank %d at %s\n",
        errno, PCU_Comm_Self(), where);
  }
}

static bool my_mkdir(const char* name)
{
  fprintf(stderr,"rank %d making directory \"%s\"\n",
      PCU_Comm_Self(), name);
  errno = 0;
  int err = mkdir(name, DIR_MODE);
  if ((err == -1) && (errno == EEXIST)) {
    errno = 0;
    err = 0;
    fprintf(stderr,"rank %d overwriting directory \"%s\"\n",
        PCU_Comm_Self(), name);
    return false;
  }
  assert(!err);
  return true;
}

static void my_chdir(const char* name)
{
  int err = chdir(name);
  assert(!err);
}

void goToStepDir(int step)
{
  std::stringstream ss;
  ss << step;
  std::string s = ss.str();
  if (!PCU_Comm_Self())
    my_mkdir(s.c_str());
  PCU_Barrier();
  my_chdir(s.c_str());
}

enum {
  DIR_FANOUT = 2048
};

std::string setupOutputDir()
{
  checkErrno("setupOutputDir");
  std::stringstream ss;
  ss << PCU_Comm_Peers() << "-procs_case/";
  std::string s = ss.str();
  if (!PCU_Comm_Self())
    my_mkdir(s.c_str());
  PCU_Barrier();
  return s;
}

void setupOutputSubdir(std::string& path)
{
  checkErrno("setupOutputSubdir");
  if (PCU_Comm_Peers() <= DIR_FANOUT)
    return;
  int self = PCU_Comm_Self();
  int subSelf = self % DIR_FANOUT;
  int subGroup = self / DIR_FANOUT;
  std::stringstream ss;
  ss << path << subGroup << '/';
  path = ss.str();
  if (!subSelf)
    my_mkdir(path.c_str());
  PCU_Barrier();
}

void writeAuxiliaryFiles(std::string path, int timestep)
{
  std::string numpePath = path;
  numpePath += "numpe.in";
  std::ofstream numpe(numpePath.c_str());
  assert(numpe.is_open());
  numpe << PCU_Comm_Peers() << '\n';
  numpe.close();
  std::string numstartPath = path;
  numstartPath += "numstart.dat";
  std::ofstream numstart(numstartPath.c_str());
  assert(numstart.is_open());
  numstart << timestep << '\n';
  numstart.close();
}

}

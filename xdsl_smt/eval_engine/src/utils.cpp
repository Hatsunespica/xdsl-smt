#ifndef Utils_H
#define Utils_H

#include <fcntl.h>
#include <iostream>
#include <sstream>
#include <string>
#include <sys/mman.h>
#include <unistd.h>
#include <vector>

std::vector<std::string> split_whitespace(const std::string &input) {
  std::vector<std::string> result;
  std::istringstream iss(input);
  std::string word;
  while (iss >> word) {
    result.push_back(word);
  }
  return result;
}

template <typename D>
void write_vecs(const std::string &fname,
                const std::vector<std::tuple<D, D, D>> &x) {
  const size_t total_size =
      x.size() * D::N * (sizeof(unsigned) + sizeof(unsigned long)) * 3;

  int fd = open(fname.c_str(), O_CREAT | O_RDWR, 0666);
  if (fd == -1) {
    std::cerr << "open\n";
    exit(1);
  }

  if (ftruncate(fd, static_cast<off_t>(total_size)) == -1) {
    std::cerr << "ftruncate\n";
    close(fd);
    exit(1);
  }

  unsigned char *ptr = static_cast<unsigned char *>(
      mmap(nullptr, total_size, PROT_WRITE, MAP_SHARED, fd, 0));
  if (ptr == MAP_FAILED) {
    std::cerr << "mmap\n";
    exit(1);
  }

  unsigned int offset = 0;
  for (auto &[x0, x1, x2] : x) {
    x0.serialize(ptr, offset);
    x1.serialize(ptr, offset);
    x2.serialize(ptr, offset);
  }

  munmap(ptr, total_size);
  close(fd);
}

template <typename D>
std::vector<std::tuple<D, D, D>> read_vecs(const std::string &fname,
                                           unsigned int num_elemnts) {
  const size_t total_size =
      num_elemnts * D::N * (sizeof(unsigned) + sizeof(unsigned long)) * 3;

  int fd = open(fname.c_str(), O_RDONLY);
  if (fd == -1) {
    std::cerr << "open\n";
    exit(1);
  }

  unsigned char *ptr = static_cast<unsigned char *>(
      mmap(nullptr, total_size, PROT_READ, MAP_SHARED, fd, 0));
  if (ptr == MAP_FAILED) {
    std::cerr << "mmap\n";
    close(fd);
    exit(1);
  }

  std::vector<std::tuple<D, D, D>> vecs;
  vecs.reserve(num_elemnts);

  unsigned int offset = 0;
  for (unsigned int x = 0; x < num_elemnts; ++x)
    vecs.push_back({D::deserialize(ptr, offset), D::deserialize(ptr, offset),
                    D::deserialize(ptr, offset)});

  munmap(ptr, total_size);
  close(fd);

  return vecs;
}

#endif

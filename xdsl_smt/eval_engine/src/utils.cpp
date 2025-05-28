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

const std::string makeVecFname(const std::string &dirPath, unsigned int bw,
                               unsigned long samples) {
  return dirPath + "bw " + std::to_string(bw) + " samples " +
         std::to_string(samples);
}

template <typename D>
void write_vecs(const std::string &fname,
                const std::vector<std::tuple<D, D, D>> &x, bool append) {
  const size_t data_size =
      x.size() * D::N * (sizeof(unsigned) + sizeof(unsigned long)) * 3;

  int fd = open(fname.c_str(), O_RDWR | O_CREAT, 0666);
  if (fd == -1) {
    std::cerr << "open\n";
    exit(1);
  }

  off_t offset_position = 0;

  if (append) {
    offset_position = lseek(fd, 0, SEEK_END);
    if (offset_position == -1) {
      std::cerr << "lseek\n";
      close(fd);
      exit(1);
    }
  }

  if (ftruncate(fd, offset_position + static_cast<off_t>(data_size)) == -1) {
    std::cerr << "ftruncate\n";
    close(fd);
    exit(1);
  }

  // Align offset to page boundary
  long page_size = sysconf(_SC_PAGE_SIZE);
  off_t aligned_offset = offset_position & ~(page_size - 1);
  off_t delta = offset_position - aligned_offset;
  size_t map_size = data_size + static_cast<size_t>(delta);

  unsigned char *map_base = static_cast<unsigned char *>(
      mmap(nullptr, map_size, PROT_WRITE, MAP_SHARED, fd, aligned_offset));
  if (map_base == MAP_FAILED) {
    std::cerr << "mmap\n";
    close(fd);
    exit(1);
  }

  unsigned char *ptr = map_base + delta;
  unsigned int offset = 0;
  for (auto &[x0, x1, x2] : x) {
    x0.serialize(ptr, offset);
    x1.serialize(ptr, offset);
    x2.serialize(ptr, offset);
  }

  munmap(ptr, data_size);
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

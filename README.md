# threadpool-cpp

This repository contains a straightforward implementation of a thread pool using pure C++20 standard library features. The thread pool allows for efficient management and execution of multiple concurrent tasks, making it a valuable tool for boosting the performance of multithreaded applications.

## 1. Features

- [ ] **Modern C++20**: Utilizes the latest features of C++20 for enhanced performance and simplicity.
- [ ] **Dynamic Task Management**: Easily add tasks to the pool and have them executed by available threads.
- [ ] **Thread Safety**: Ensures safe concurrent execution of tasks.
- [ ] **Scalable**: Automatically manages the number of threads based on the system's capabilities.

## 2. Getting Started

### 2.1. Prerequisites

1. A C++20 compatible compiler (e.g., GCC 10+, Clang 10+, MSVC 2019+)
2. CMake (optional, for building examples and tests)

### 2.2. Building

To build the project, you can use the following CMake commands:

```sh
cmake -B build && cmake --build build && sudo cmake --install build
```
or, step-by-step:
```sh
cmake -B build
```
```sh
cmake --build build
```
```sh
sudo cmake --install build
```

## 3. Usage

Here is a basic example of how to use the thread pool:

```cpp
#include <threadpool-cpp/threadpool-cpp.h>

#include <thread>
#include <iostream>

int main(int, char*[]) {
    using namespace tp = threadpoolcpp;
    
    int threads = std::thread::hardware_concurrency() ? std::thread::hardware_concurrency() : 4;
    auto tp::pool(threads); // Create a thread pool with hardware concurrency (or 4 by default) threads
    
    // Add a task to the thread pool
    auto result = pool.enqueue([] {
        return "Hello from the thread pool!";
    });

    std::cout << result.get() << std::endl; // Prints: Hello from the thread pool!

    return 0;
}
```

## 4. Documentation

- Code Documentation: Inline comments and documentation are provided within the source code.
- Examples: Check the examples directory for more usage examples.

## 5. Contributing

We welcome contributions! Please fork the repository and submit pull requests.

## 6. License

This project is licensed under the MIT License. See the LICENSE file for more details.


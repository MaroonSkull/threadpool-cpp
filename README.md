# threadpool-cpp

This repository contains a straightforward implementation of a thread pool using pure C++20 standard library features. The thread pool allows for efficient management and execution of multiple concurrent tasks, making it a valuable tool for boosting the performance of multithreaded applications.

## Features

- Modern C++20: Utilizes the latest features of C++20 for enhanced performance and simplicity.
- Dynamic Task Management: Easily add tasks to the pool and have them executed by available threads.
- Thread Safety: Ensures safe concurrent execution of tasks.
- Scalable: Automatically manages the number of threads based on the system's capabilities.

## Getting Started

### Prerequisites

A C++20 compatible compiler (e.g., GCC 10+, Clang 10+, MSVC 2019+)
CMake (optional, for building examples and tests)

### Building

To build the project, you can use the following CMake commands:

```sh
mkdir build
cd build
cmake ..
cmake -B .
```

## Usage

Here is a basic example of how to use the thread pool:

```cpp
#include "ThreadPool.h"
#include <iostream>

int main() {
    ThreadPool pool(4); // Create a thread pool with 4 threads

    auto result = pool.enqueue([] {
        return "Hello from the thread pool!";
    });

    std::cout << result.get() << std::endl; // Prints: Hello from the thread pool!

    return 0;
}
```

## Documentation

- Code Documentation: Inline comments and documentation are provided within the source code.
- Examples: Check the examples directory for more usage examples.

## Contributing
We welcome contributions! Please fork the repository and submit pull requests.

## License
This project is licensed under the MIT License. See the LICENSE file for more details.


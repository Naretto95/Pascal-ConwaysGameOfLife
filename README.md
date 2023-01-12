# Pascal-ConwaysGameOfLife

This repository contains an implementation of Conway's Game of Life, a cellular automaton simulation, written in Pascal. The simulation takes place on a two-dimensional grid of cells, each of which can be in one of two states: alive or dead. The state of each cell is determined by the states of its neighbors, according to a set of rules.

## How to Use
1. Clone the repository to your local machine
2. Open the project in your preferred Pascal IDE (e.g. Lazarus)
3. Build and run the program

## Rules of the Game
1. Any live cell with fewer than two live neighbors dies, as if by underpopulation.
2. Any live cell with two or three live neighbors lives on to the next generation.
3. Any live cell with more than three live neighbors dies, as if by overpopulation.
4. Any dead cell with exactly three live neighbors becomes a live cell, as if by reproduction.

## License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

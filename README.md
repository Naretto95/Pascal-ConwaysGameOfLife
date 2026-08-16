# Pascal Game of Life

An energy- and age-driven cellular automaton written in Object Pascal, inspired by Conway's Game of Life. It runs on a 20x20 toroidal grid (edges wrap around) and simulates patches of "grass" that grow, age, and reproduce based on a small energy budget rather than the classic birth/survival neighbor-count rules.

Originally written as a school assignment in French; this version has been rewritten with clear English naming, a proper CLI argument parser, and a working save/load format.

## Simulation rules

Each cell holds an age, an energy level, and a life state. Every generation:

1. A living cell older than `MAX_AGE` (5) dies; otherwise it ages by one.
2. If its energy is above `REPRODUCTION_ENERGY` (10), it spends `REPRODUCTION_COST` (10) energy to spawn new cells on every dead cell in its 3x3 neighborhood (Moore neighborhood, wrapping around the grid edges).
3. Otherwise, it gains `ENERGY_GAIN` (4) energy for the next generation.

New cells start with `INITIAL_ENERGY` (1) energy and age 0.

## Requirements

- [Free Pascal](https://www.freepascal.org/) (`fpc`) or [Lazarus](https://www.lazarus-ide.org/)

## Building and running

```bash
fpc gameoflife.pas
./gameoflife
```

Or open `gameoflife.pas` in Lazarus and run it directly.

You'll be prompted for the number of starting cells and their coordinates, then for how many generations to simulate. The grid is printed after every generation (`h` = alive, `.` = dead).

## Command-line options

```
gameoflife [-i <input file>] [-o <output file>]
```

- `-i <file>` — load the starting cells from a file instead of typing them in.
- `-o <file>` — save the final state and generation count to a file once the simulation finishes.

Saved files can be reused as input for a later run, e.g.:

```bash
./gameoflife -o save.txt
./gameoflife -i save.txt
```

### Save file format

```
ViePosition = [(x,y) (x,y) ...]
NombreGeneration = <n>
```

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

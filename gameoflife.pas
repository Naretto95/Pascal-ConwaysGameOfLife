{
  Game of Life - an energy/age driven cellular automaton
  --------------------------------------------------------
  Each cell of a toroidal N x N grid holds a bit of "grass" that can be
  alive or dead. A living cell ages every generation and dies of old age
  once it passes MAX_AGE. While alive it accumulates energy each turn;
  once its energy exceeds REPRODUCTION_ENERGY it spends REPRODUCTION_COST
  energy to spawn new grass on every dead cell in its Moore neighborhood.

  Usage:
    gameoflife [-i <input file>] [-o <output file>]

    -i  Load the initial live cells from a file previously written by -o,
        instead of entering them from the keyboard.
    -o  After the simulation finishes, save the final live cells and the
        number of generations run to a file.
}
program GameOfLife;

{$mode objfpc}{$H+}

uses
  SysUtils;

const
  GRID_SIZE           = 20;
  MAX_CELLS           = GRID_SIZE * GRID_SIZE;
  ENERGY_GAIN         = 4;
  MAX_AGE             = 5;
  REPRODUCTION_ENERGY = 10;
  REPRODUCTION_COST   = 10;
  INITIAL_ENERGY      = 1;

type
  TCell = record
    Age, Energy: Integer;
    Alive: Boolean;
  end;

  TPosition = record
    X, Y: Integer;
  end;

  TGrid = array[0..GRID_SIZE - 1, 0..GRID_SIZE - 1] of TCell;

  { Index 0 is repurposed to store how many positions follow, keeping the
    same fixed-size-array trick as the original assignment. }
  TPositionList = array[0..MAX_CELLS] of TPosition;

  TArguments = record
    InputFile, OutputFile: string;
    HasInput, HasOutput: Boolean;
  end;

{ Parses "-i <file>" and "-o <file>" command-line switches, in any order. }
function ParseArguments: TArguments;
var
  I: Integer;
  Args: TArguments;
begin
  Args.HasInput := False;
  Args.HasOutput := False;

  I := 1;
  while I <= ParamCount do
  begin
    if (ParamStr(I) = '-i') and (I < ParamCount) then
    begin
      Args.InputFile := ParamStr(I + 1);
      Args.HasInput := True;
      Inc(I, 2);
    end
    else if (ParamStr(I) = '-o') and (I < ParamCount) then
    begin
      Args.OutputFile := ParamStr(I + 1);
      Args.HasOutput := True;
      Inc(I, 2);
    end
    else
      Inc(I);
  end;

  Result := Args;
end;

{ Builds a grid from a list of initial live-cell positions.
  Positions[0].X stores how many entries follow. }
function CreateGrid(const Positions: TPositionList): TGrid;
var
  Row, Col, Count, I: Integer;
  Grid: TGrid;
begin
  for Row := 0 to GRID_SIZE - 1 do
    for Col := 0 to GRID_SIZE - 1 do
    begin
      Grid[Row][Col].Age := 0;
      Grid[Row][Col].Energy := 0;
      Grid[Row][Col].Alive := False;
    end;

  Count := Positions[0].X;
  for I := 1 to Count do
    with Grid[Positions[I].Y][Positions[I].X] do
    begin
      Energy := INITIAL_ENERGY;
      Age := 0;
      Alive := True;
    end;

  Result := Grid;
end;

{ Prompts the user to type initial live-cell coordinates on the torus grid;
  negative or out-of-range coordinates wrap around. }
function ReadPositionsFromKeyboard: TPositionList;
var
  Count, I: Integer;
  Positions: TPositionList;
begin
  WriteLn('How many live cells do you want to start with?');
  WriteLn('Enter a number no greater than ', MAX_CELLS, ':');
  repeat
    ReadLn(Count);
  until (Count >= 0) and (Count <= MAX_CELLS);

  Positions[0].X := Count;
  for I := 1 to Count do
  begin
    WriteLn('Cell ', I, ' - X coordinate:');
    ReadLn(Positions[I].X);
    Positions[I].X := ((Positions[I].X mod GRID_SIZE) + GRID_SIZE) mod GRID_SIZE;

    WriteLn('Cell ', I, ' - Y coordinate:');
    ReadLn(Positions[I].Y);
    Positions[I].Y := ((Positions[I].Y mod GRID_SIZE) + GRID_SIZE) mod GRID_SIZE;

    WriteLn(Count - I, ' cell(s) left to enter.');
  end;

  Result := Positions;
end;

{ Loads a position list previously written by SavePositions. }
function LoadPositions(const FileName: string): TPositionList;
var
  F: TextFile;
  Line, Content, Token: string;
  OpenPos, ClosePos, CommaPos, Count: Integer;
  Positions: TPositionList;
begin
  AssignFile(F, FileName);
  Reset(F);
  Content := '';
  while not Eof(F) do
  begin
    ReadLn(F, Line);
    Content := Content + Line;
  end;
  CloseFile(F);

  OpenPos := Pos('[', Content) + 1;
  ClosePos := Pos(']', Content) - 1;
  Content := Copy(Content, OpenPos, ClosePos - OpenPos + 1);

  Count := 0;
  while Pos('(', Content) > 0 do
  begin
    OpenPos := Pos('(', Content) + 1;
    ClosePos := Pos(')', Content);
    Token := Copy(Content, OpenPos, ClosePos - OpenPos);
    CommaPos := Pos(',', Token);

    Inc(Count);
    Positions[Count].X := StrToInt(Copy(Token, 1, CommaPos - 1));
    Positions[Count].Y := StrToInt(Copy(Token, CommaPos + 1, Length(Token)));

    Delete(Content, 1, ClosePos);
  end;

  Positions[0].X := Count;
  Result := Positions;
end;

{ Saves the live cells and the iteration count to a text file, using the
  format LoadPositions expects: "ViePosition = [(x,y) (x,y) ...]" followed
  by "NombreGeneration = n". }
procedure SavePositions(const Grid: TGrid; Iterations: Integer; const FileName: string);
var
  F: TextFile;
  Row, Col: Integer;
  First: Boolean;
begin
  AssignFile(F, FileName);
  Rewrite(F);
  First := True;

  Write(F, 'ViePosition = [');
  for Row := 0 to GRID_SIZE - 1 do
    for Col := 0 to GRID_SIZE - 1 do
      if Grid[Row][Col].Alive then
      begin
        if not First then
          Write(F, ' ');
        First := False;
        Write(F, '(', Col, ',', Row, ')');
      end;
  WriteLn(F, ']');
  WriteLn(F, 'NombreGeneration = ', Iterations);

  CloseFile(F);
end;

{ Renders the grid to the console: 'h' for a live cell, '.' for a dead one. }
procedure PrintGrid(const Grid: TGrid);
var
  Row, Col: Integer;
begin
  for Row := 0 to GRID_SIZE - 1 do
  begin
    for Col := 0 to GRID_SIZE - 1 do
      if Grid[Row][Col].Alive then
        Write(' h')
      else
        Write(' .');
    WriteLn;
  end;
end;

{ Wakes up the dead neighbors of (Row, Col) in its Moore neighborhood on the
  torus grid, and charges the source cell REPRODUCTION_COST energy if at
  least one neighbor was spawned. }
procedure SpreadToNeighbors(Row, Col: Integer; var Grid: TGrid);
var
  DR, DC, NR, NC, Spawned: Integer;
begin
  Spawned := 0;
  for DR := -1 to 1 do
    for DC := -1 to 1 do
    begin
      NR := ((Row + DR) mod GRID_SIZE + GRID_SIZE) mod GRID_SIZE;
      NC := ((Col + DC) mod GRID_SIZE + GRID_SIZE) mod GRID_SIZE;
      if not Grid[NR][NC].Alive then
      begin
        Grid[NR][NC].Alive := True;
        Grid[NR][NC].Energy := INITIAL_ENERGY;
        Grid[NR][NC].Age := 0;
        Inc(Spawned);
      end;
    end;

  if Spawned > 0 then
    Dec(Grid[Row][Col].Energy, REPRODUCTION_COST);
end;

{ Advances the whole grid by one generation: aging cells that get too old
  die, well-fed cells reproduce into their neighborhood, the rest just
  gain energy. Reproduction reads neighbor state from the grid as it is
  being built, so cells processed earlier in the pass can influence ones
  processed later within the same generation. }
procedure StepGeneration(var Grid: TGrid);
var
  Row, Col: Integer;
  Previous: TGrid;
begin
  Previous := Grid;
  for Row := 0 to GRID_SIZE - 1 do
    for Col := 0 to GRID_SIZE - 1 do
      if Previous[Row][Col].Alive then
      begin
        if Previous[Row][Col].Age < MAX_AGE then
          Inc(Grid[Row][Col].Age)
        else
          Grid[Row][Col].Alive := False;

        if Previous[Row][Col].Energy > REPRODUCTION_ENERGY then
          SpreadToNeighbors(Row, Col, Grid)
        else
          Inc(Grid[Row][Col].Energy, ENERGY_GAIN);
      end;
end;

{ Runs the simulation for the given number of generations, printing the
  grid after each step. }
procedure RunSimulation(var Grid: TGrid; Iterations: Integer);
var
  I: Integer;
begin
  for I := 1 to Iterations do
  begin
    StepGeneration(Grid);
    WriteLn('Generation #', I);
    PrintGrid(Grid);
  end;
end;

var
  Grid: TGrid;
  Positions: TPositionList;
  Args: TArguments;
  Iterations: Integer;
  Dummy: string;

begin
  Args := ParseArguments;

  if Args.HasInput then
    Positions := LoadPositions(Args.InputFile)
  else
    Positions := ReadPositionsFromKeyboard;

  Grid := CreateGrid(Positions);
  PrintGrid(Grid);

  Write('How many generations do you want to run? ');
  ReadLn(Iterations);

  if Iterations > 0 then
  begin
    RunSimulation(Grid, Iterations);
    if Args.HasOutput then
      SavePositions(Grid, Iterations, Args.OutputFile);
  end;

  Write('Press Enter to exit...');
  ReadLn(Dummy);
end.

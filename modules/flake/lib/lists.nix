{lib, ...}: let
  /**
  slice a list from start index to end index (supports negative indices)

  # Inputs

  `start`
  : start index inclusive

  `end`
  : end index exclusive

  `list`
  : the list to slice

  # Type

  ```nix
  slice :: Int -> Int -> [ Any ] -> [ Any ]
  ```

  # Example

  ```nix
  slice 1 3 [ "a" "b" "c" "d" ]
  => [ "b" "c" ]

  slice (-2) (-1) [ "a" "b" "c" "d" ]
  => [ "c" ]

  slice 0 (-1) [ "a" "b" "c" "d" ]
  => [ "a" "b" "c" ]
  ```
  */
  slice = start: end: list: let
    real = x:
      if x < 0
      then lib.max ((builtins.length list) + x) 0
      else x;
  in
    lib.sublist (real start) ((real end) - (real start)) list;

  /**
  slice a list from start index to the end of the list

  # Inputs

  `start`
  : start index inclusive

  `list`
  : the list to slice

  # Type

  ```nix
  sliceFrom :: Int -> [ Any ] -> [ Any ]
  ```

  # Example

  ```nix
  sliceFrom 2 [ "a" "b" "c" "d" ]
  => [ "c" "d" ]

  sliceFrom (-2) [ "a" "b" "c" "d" ]
  => [ "c" "d" ]
  ```
  */
  sliceFrom = start: list: slice start (builtins.length list) list;

  /**
  slice a list from the beginning to end index

  # Inputs

  `end`
  : end index exclusive

  `list`
  : the list to slice

  # Type

  ```nix
  sliceTo :: Int -> [ Any ] -> [ Any ]
  ```

  # Example

  ```nix
  sliceTo 2 [ "a" "b" "c" "d" ]
  => [ "a" "b" ]

  sliceTo (-1) [ "a" "b" "c" "d" ]
  => [ "a" "b" "c" ]
  ```
  */
  sliceTo = end: list: slice 0 end list;
in {
  inherit slice sliceFrom sliceTo;
}

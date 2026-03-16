# Contributing
Contributions are welcome via pull requests.

## Guidelines
- Simplicity: Keep the code simple and explicit.
- Style: -Follow standard Elixir formatting (mix format or make fmt).
- Testing: New functionality must include unit tests for the interpreter or Ecto schemas.
- Safety: Avoid String.to_atom/1 with unvalidated user input. The interpreter must only use atoms for known primitives or words explicitly defined in the dictionary to prevent memory exhaustion.
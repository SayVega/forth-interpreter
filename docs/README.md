# Forth Interpreter

## Prerequisites
- Erlang/OTP 28+

- Elixir 1.19+

- PostgreSQL 18+

- Make (Optional).

## Instalation & Usage

Clone the repository:
``` bash
git clone https://github.com/SayVega/forth-interpreter.git
cd forth-interpreter
```

### Using make
Install dependencies, config DB and compile:
```bash
make setup
```
Run the server:
```bash
make server
```
The app will be available at `http://localhost:4000`

### Using mix (manual)
Run setup:
```bash
mix setup
```
Compile the project:
```bash
mix compile
```
Run the server:
```bash
mix phx.server
```
The app will be available at `http://localhost:4000`
## Interpreter
This section describes the core architecture and execution logic of the system.

### Execution Flow
The interpreter operates on a stack-based architecture (LIFO). Internally, the stack is stored reversed (`[top | rest]`) to allow O(1) push and pop operations.
### Core Vocabulary
The interpreter supports a specific set of native primitives. Words are case-insensitive and must be separated by whitespace.

| Category | Supported Words |
|----------|-----------------|
| Arithmetic    | +, -, *, /, MOD                        |
| Stack Ops     | DUP, DROP, OVER, SWAP, ROT, NIP, TUCK  |
| Double Stack  | 2DUP, 2DROP, 2SWAP, 2OVER              |
| Comparison    | <, >, =                                |
| Logic/Bitwise | AND, OR, NOT, INVERT                   |
### Word definition
The system allows the dictionary to be extended during runtime:

Syntax: `: NAME <implementation> ;`

## Testing & Error Handling

### Tests
The project features a suite of tests focused on the core interpreter logic and database integrity. This ensures that Forth evaluations are processed correctly and that results are properly persisted in PostgreSQL.

```bash
# Using make
make test
# Using mix
mix test
```

### Reliability
- Interpreter error codes
    - `unknown word: <name>`: The word used is neither a native primitive nor a previously defined word in the dictionary.
    - `stack underflow`: A binary operator was called with fewer elements on the stack than required.
    - `division by zero`: Triggered during / or MOD operations when the divisor is 0.
    - `invalid word definition`: Attempting to use an integer as a word name or using ; prematurely.
    - `unterminated definition`: The program ended before a : definition was closed with ;.
    - `already defining a word`: Nesting definitions (using : while another definition is still open) is not supported.
- Web Safety
    - File Constraints: Restricts uploads to 100KB and enforces UTF-8 encoding.
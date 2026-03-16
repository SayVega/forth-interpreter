# Forth Interpreter (Elixir)

A minimal interpreter for the Forth programming language implemented in Elixir.

It supports execution of Forth programs with integer arithmetic, stack
manipulation, and user-defined words.

The evaluator is available through a web interface built with Phoenix
LiveView, where users can upload programs, run evaluations, view results,
and browse the history of previous executions.

Programs and their executions are persisted in PostgreSQL.

## Documentation

Detailed documentation is available [`here`](docs/README.md)
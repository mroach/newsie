Development
===========


Running the linter
------------------

```shell
make check
```

This will run [credo], check code formatting, and check type specs.


Testing multiple Elixir versions
--------------------------------

The library is configured with GitHub workflows to test against multiple
versions of Elixir to ensure wide compatibility.

To locally run tests against a specific Elixir version, use the `docker/test` make task and specify the Elixir version to use.

```shell
make docker/test ELIXIR_VER=1.7
```

[credo]: https://github.com/rrrene/credo

# CookesAuction

To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

To send emails:

```
> mix cookes.email --test # sends the latest past sale to the test list
> mix cookes.email        # sends upcoming sales to the test list
> mix cookes.email --prod # sends upcoming sales to the prod list
```

To process images:

```
> mix cookes.images --src ~/path/to/images # defaults to putting processed files in :src/upload
> mix cookes.images --src ~/path/to/images --dest ~/path/to/destination
```

To insert a sale into the FTS index:

```
> mix cookes.fts --sale 123 # the sale ID
```


## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix

## Fly.io

  * [SFTP](https://fly.io/docs/elixir/advanced-guides/sqlite3/#copying-an-existing-database-to-a-fly-volume)
  * [iex into a running app](https://fly.io/docs/elixir/the-basics/iex-into-running-app/)

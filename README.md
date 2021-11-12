# `yarn` 1.x installed through `nix` issue (see [issue](https://github.com/NixOS/nixpkgs/issues/145634))

## Steps to reproduce

1. make sure to install `nixpkgs.yarn` & `nixpkgs.fnm` (or `nvm`)
2. Clone the repo
3. Run `fnm use --install-if-missing` to install the version from `.nvmrc` file
4. Validate that you get the correct version `node -v` & `which node` should
   point to the `node` coming from `fnm`
5. Run `yarn start`, it shouldn't run & you will get this error

```
error nix-yarn-issue@1.0.0: The engine "node" is incompatible with this module. Expected version ">= 16". Got "14.18.1"
error Commands cannot run with an incompatible environment.
info Visit https://yarnpkg.com/en/docs/cli/run for documentation about this command.
```

6. Run this command

```shell
yarn env | grep -E "\"(NODE|npm_node_execpath|npm_config_user_agent)\""
```

The output should look like this

```
"NODE": "/nix/store/d37aprv8pxqpslag1yq6n0q2q0fnpqwg-nodejs-14.18.1/bin/node",
"npm_node_execpath": "/nix/store/d37aprv8pxqpslag1yq6n0q2q0fnpqwg-nodejs-14.18.1/bin/node",
"npm_config_user_agent": "yarn/1.22.17 npm/? node/v14.18.1 darwin x64",
```

The problem is that `nix` sets the `NODE` environment variable to the `nix` node
executable, which then `yarn` picks up and sets
[`npm_node_execpath`](https://github.com/yarnpkg/yarn/blob/3119382885ea373d3c13d6a846de743eca8c914b/src/util/execute-lifecycle-script.js#L80)
to the same value.

This problem doesn't happen if `yarn` is installed using `homebrew` or directly
`curl -o- -L https://yarnpkg.com/install.sh | bash`.

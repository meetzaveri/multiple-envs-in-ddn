### Case Study: Managing multiple environments in Hasura DDN

<img width="1027" alt="Screenshot 2025-03-04 at 2 49 50 PM" src="https://github.com/user-attachments/assets/dbdb4946-6995-4b61-a395-0955aadea0bf" />

This repo contains case study for managing multiple environments such as QA, prod and staging in Hasura DDN paritcularly for users using MySQL connector.

This case study is only applicable to cater below use case

- User uses MySQL connector. In MySQL connector , the root fields are generated based on database name rather than schema name.
- The connection string/URL contains different database name per environment.
- The database across different environments contains identical schema underneath it.

Steps to create this setup yourselves are described below.

#### Create supergraph(s) per env and it's respective subgraph(s)

- Create multiple supergraph(s) per environment. Just create a new supergraph file by cloning the original `supergraph.yaml`.

- Create respective subgraph(s) for each environment and reference it in it's parent supergraph . You can create subgraph via this [command](https://hasura.io/docs/3.0/reference/cli/commands/ddn_subgraph_init) `ddn subgraph init <subgraph-name>`. So you can then change `staging-supergraph.yaml` and update it to include only mysql_staging subgraph for e.g.

  ```
  kind: Supergraph
  version: v2
  definition:
    subgraphs:
      - globals/subgraph.yaml
      - mysql_staging/subgraph.yaml
  ```

#### Add typeName prefix for each subgraph

- Add typeName prefix to avoid future types conflict which would arise in supergraph build since your database across environments would still contain identical schema underneath it.

  - To add typeName prefix, please visit your subgraph.yaml file in your respective subgraph, and there add `graphqlTypeNamePrefix: <prefix_you_want_to_attach>_` to existing subgraph definition such as

  - Here's the code

  ```
  definition:
    name: staging
    generator:
      rootPath: .
      graphqlTypeNamePrefix: staging_
  ...
  ```

#### Create Contexts for each environment

- Create new context for each environment. You can run `ddn context create-context <name>` to create context or just update `.hasura/context.yaml` manually add new contexts.

  - Like I added something like

  ```
  staging:
    supergraph: ../staging-supergraph.yaml
    subgraph: ../mysql_staging/subgraph.yaml
    localEnvFile: ../staging.env
  qa:
    supergraph: ../qa-supergraph.yaml
    subgraph: ../mysql_qa/subgraph.yaml
    localEnvFile: ../qa.env
  ```

  Alongside you'll need create new .env files for each environments (as shown in code above) such that Hasura DDN will only create relevant env vars in that env file.

  - Since the `docker-start` script is using `.env` file as part of spinning up container services , you'll need to create additional scripts for each environments. For example in staging script you'll need to use `staging.env` as value to `--envfile` and so on,

  ```
  scripts:
    docker-start:
      bash: HASURA_DDN_PAT=$(ddn auth print-access-token) PROMPTQL_SECRET_KEY=$(ddn auth print-promptql-secret-key) docker compose -f compose.yaml --env-file .env up --build --pull always
      powershell: $Env:HASURA_DDN_PAT = ddn auth print-access-token; $Env:PROMPTQL_SECRET_KEY = ddn auth print-promptql-secret-key; docker compose -f compose.yaml --env-file .env up --build --pull always
    # additional scripts for each environments and change value of flag wherever necessary
    docker-start-staging:
      bash: HASURA_DDN_PAT=$(ddn auth print-access-token) PROMPTQL_SECRET_KEY=$(ddn auth print-promptql-secret-key) docker compose -f compose.yaml --env-file staging.env up --build --pull always
      powershell: $Env:HASURA_DDN_PAT = ddn auth print-access-token; $Env:PROMPTQL_SECRET_KEY = ddn auth print-promptql-secret-key; docker compose -f compose.yaml --env-file staging.env up --build --pull always
    docker-start-qa:
      bash: HASURA_DDN_PAT=$(ddn auth print-access-token) PROMPTQL_SECRET_KEY=$(ddn auth print-promptql-secret-key) docker compose -f compose.yaml --env-file qa.env up --build --pull always
      powershell: $Env:HASURA_DDN_PAT = ddn auth print-access-token; $Env:PROMPTQL_SECRET_KEY = ddn auth print-promptql-secret-key; docker compose -f compose.yaml --env-file qa.env up --build --pull always
  ```

  - When you want to switch between different envs, just set current context using `ddn context set-current-context <context>`.

#### Add connector to your environments or essentialy in your subgraph(s)

- Add connector to each of your environments. Since you've added contexts, you can switch between contexts (essentially switch between environments) and then add connector for specific subgraph/context and also perform subsequent actions such as introspection and adding models/commands.

  - Say you are in `staging` context, you can add connector with unique name say for `staging` subgraph, you can name connector as `mysql_staging`.
  - Main benefit of using context is that you don't need to link subgraph path as values to CLI command as it will take from context value set in `.hasura/context.yaml` .

- Now once connector has been initialized, you can introspect it with `ddn connector introspect <connector-name> [flags]` ([ref](https://hasura.io/docs/3.0/reference/cli/commands/ddn_connector_introspect)). Subsequently you can track your models/commands once introspection is successful and perform supergraph builds.

Note : If you are switching between contexts, make sure to run `ddn supergraph build local` each time you switch context.

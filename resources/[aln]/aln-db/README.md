# aln-db (ALN3)

Database contract for ALN3 using oxmysql.

## Requires
- `oxmysql` ensured before this resource.

## Features
- Additive migrations
- Schema migration tracking table: `aln3_schema_migrations`
- Query wrappers (scalar/single/query/insert/update/transaction)
- Startup migration runner

## Exports
- `exports['aln-db']:IsReady() -> bool`
- `exports['aln-db']:RunMigrations() -> bool`
- `exports['aln-db']:Scalar(q, params)`
- `exports['aln-db']:Single(q, params)`
- `exports['aln-db']:Query(q, params)`
- `exports['aln-db']:Insert(q, params)`
- `exports['aln-db']:Update(q, params)`
- `exports['aln-db']:Transaction(stmts)`

## Dev console commands
- `aln_db_ping`
- `aln_db_migrations`

# Server

_work in progress_

Builds and serves production data

---

## Preparing the database

💡 *general note*: any of the scripts in the `/scripts` directory must be executed from within `/scripts`. Make sure you `cd scripts` before you run them. (This is because `load-dotenv.sh` expects your `.env` file to be at a specific relative path.)

### Initialize

- Create a new Postgres database, e.g. `internet_explorer`
- Initialize the database with `psql -d internet_explorer -f init-db.sql`

### Load source data

- Load OpenAddresses
  - Download the region containing the state you need
  - Load the state with `./scripts/load-addresses.sh [path to state directory]`
- TODO load other source data

### Create derived data

TODO

# Base Vagrant

## First time setup

1. Clone down repo locally

2. Install [Vagrant](https://www.vagrantup.com/downloads.html) and [VirtualBox](https://www.virtualbox.org/wiki/Downloads) on your local machine.

2. Create the following entry in your ```/etc/hosts``` file:
```192.168.33.2 localtest```

3. Copy ```html/localsettings.php.example``` to ```html/localsettings.php``` (if in a vagrant environment, this step can be skipped, as the file get generated automatically)

4. Rename ```scripts/localconfig.sh.example``` to ```scripts/localconfig.sh``` and propagate the appropriate fields

5. Run `./scripts/fetch_live_db.sh` to retrieve the live database

6. [Ensure python-pip is installed](https://pip.readthedocs.org/en/stable/installing/), then install requirements file ```pip install -r scripts/requirements/dev.txt```


## Running

Ensure ```scripts/db.sql``` is the latest dump of the live DB (run ```./scripts/fetch_live_db.sh```)

In your terminal, navigate to the root of your repo and run
```bash
vagrant up
```

To re-create the environment entirely, run
```bash
vagrant destroy -f; vagrant up
```

Post running ```vagrant up```, if all commands have been followed correctly, you should be able to browse the site locally at http://localtest/.

If you have any questions regarding setup, please [email Jason Sayre](mailto:jason@jasonsayre.com).

Note: All vagrant commands are run from the root of the repo.

## Tools and Commands

```fab reup``` - Fetches live database, recreates environment

```./scripts/fetch_live_db.sh``` - Fetches the live database and drops it under ```scripts/db.sql```

```./scripts/update-assets.sh``` - Fetches the production assets

```vagrant halt; vagrant up --provision``` - Re-runs provisioner (bootstrap.sh), recreates database

#### Tools provided for you within the vagrant environment

```rebuilddb``` - Destroys and re-creates the database, running all .sql files in ```scripts/sql/``` against the database

```logs``` - Watches all error logs live from that point forward

```dumpdb``` - Dumps the database in it's current state to ```scripts/dump.sql```. The repo is set to ignore all files under scripts called dump.sql and dump*.sql.


## Development practices

- Passwords and sensitive information should always be git ignored. If you need, create a *.example file with a skeleton of the information that it requires.

- The live database is never to be committed to the repo under any circumstance.

- SQL is to be written outside of the database. This can be exported within the vagrant machine by running ```dumpdb``` as root. It will place a ```dump.sql``` in the ```scripts/``` directory. Comparing two such dumps, one post changes, you can derive the database changes that need to be written out. Custom SQL is to be placed in ```scripts/sql/*.sql```. These are loaded into the dev environment automatically upon start. For a list of all SQL commands see "Tools and Commands". SQL changes and additions are to be run against the staging server first, they can then be manually run against production.

Android backups
===============

Two tiny bash scripts to initialize Termux and perform backups with rsync.


Installation
------------

From your phone launch Termux and run:

```bash
cd && mkdir -p scripts && cd scripts
curl -O -s -S -L https://raw.githubusercontent.com/lliendo/android-backups/master/scripts/termux-init.sh
chmod u+x termux-init.sh && ./termux-init.sh
```

After this you might want to also get the backup script:

```bash
curl -O -s -S -L https://raw.githubusercontent.com/lliendo/android-backups/master/scripts/termux-backup.sh
chmod u+x termux-backup.sh
```

Usage: `./scripts/termux-backup SOURCE_PATH USERNAME@HOST:DESTINATION_PATH ID_RSA_PATH`

Example: `./scripts/termux-backup.sh $HOME/storage backup@redstar.local: id_rsa`


Licence
-------

android-backups is distributed under the [GNU GPLv3](https://www.gnu.org/licenses/gpl-3.0.txt) license.


Authors
-------

* Lucas Liendo.

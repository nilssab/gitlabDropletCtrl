# gitlabDropletCtrl

Ruby and Bash scripts to spin up/down a Digital Ocean droplet and configure gitlab.\
Using the below commands, you can easily and safely backup and delete the gitlab droplet, to deploy it only when needed.

**Usage:**
- **Droplets** 
  - You need to set up SSH keypairs with DigitalOcean first.

  - Put your DigitalOcean API token in a file named 'tokenDO'.

  - Create a droplet with `ruby ./spinupDigitalOcean.rb` this will track the used server in the file 'dropletID'. _#chmod +x first if scripts are non-executable_

  - Remove with `ruby ./deleteDigitalOcean.rb`, only do this after backing up the gitlab data.

  - If you create too many Droplets, you can use `ruby cullDigitalOcean.rb` to remove all droplets that aren't tracked.\
    Do no do this if you have other DigitalOcean Droplets beside gitlab.

- **Setup**
  - Run following commands to move over the needed files:\
    `scp gitlab* root@<droplet ip or url>:/root`\
    `scp docker-compose.yml root@<droplet ip or url>:/root`\
    `scp <config.tar.gz path> root@<droplet ip or url>:/root` _#if you are restoring a backup_\
    `scp <gitlab backup path> root@<droplet ip or url>:/root` _#if you are restoring a backup_

  - ssh into the droplet /root folder.

  - If restoring a backup: change version in docker-compose.yml from `:latest` to the version of the backup. \
    For example: `gitlab/gitlab-ee:13.5.3-ee.0`  _#note the .0 that is appended to the version tags._

  - Run `bash ./gitlabBaseSetupBash`

  - If restoring a backup:\
    `tar -xcvf <config.tar.gz>` \
    `mv <gitlab backup file> /root/gitlab/data/backups`\
    `docker ps` _#To check the `<name of container>` (ID), you only need to enter some of the first letters_\
    `docker exec -it <name of container> gitlab-ctl stop unicorn`\
    `docker exec -it <name of container> gitlab-ctl stop puma`\
    `docker exec -it <name of container> gitlab-ctl stop sidekiq`\
    `docker exec -it <name of container> gitlab-backup restore`\
    `docker restart <name of container>`

- **Creating a backup**
  - ssh in to the droplet and run the commands below:\
    `tar -czvf config.tar.gz ./gitlab/config`\
    `docker ps` _# to check the `<container name>`, again, only some of the first letters are needed_\
    `docker exec -t <container name> gitlab-backup create`\
    `cp ./gitlab/data/backups/<backup file> .`\
    `scp <backup-file> <backup server>:</path>`\
    `scp config.tar.gz <backup server>:</path>`
  - If you are removing the droplet
    `./githubDown`\
    exit ssh\
    `ruby ./deleteDigitalOcean`

- **Updating gitlab**
  - Stop gitlab:\
    SSH in to the Droplet /root\
    `./gitlabDown`

  - Update the docker image:\
    `docker image pull gitlab/gitlab-ee`

  - Start gitlab:\
    `./gitlabUp`

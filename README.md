# gitlabDropletCtrl

Ruby and Bash scripts to spin up/down a Digital Ocean droplet and configure gitlab.\
Using the below commands, you can easily and safely backup and delete the gitlab droplet, to deploy it only when needed.
The main objective is to lower cost and be able to have the server down as much as possible.

**Usage:**
- **Droplets** 
  - You need to set up SSH keypairs with DigitalOcean first.

  - Put your DigitalOcean API token in a file named 'tokenDO'.

  - Create a droplet with `ruby ./spinupDigitalOcean.rb` this will track the used server in the file 'dropletID'. 

  - Remove with `ruby ./deleteDigitalOcean.rb`, only do this after backing up the gitlab data.\

  - If you create too many Droplets, you can use `ruby cullDigitalOcean.rb` to remove all droplets that aren't tracked.\
    Do no do this if you have other DigitalOcean Droplets beside gitlab.

- **Setup**
  - Run following commands to move over the needed files:\
    `scp gitlab* root@<droplet ip or url>:/root`\
    `scp docker-compose.yml root@<droplet ip or url>:/root`\
    `scp <config.tar.gz path> root@<droplet ip or url>:/root` _#if you are restoring a backup_\
    `scp <gitlab backup path> root@<droplet ip or url>:/root` _#if you are restoring a backup_

  - ssh into the droplet /root folder.

  - you need to update the urls in docker-compose.yml to match your hostname url. Don't forget to direct any DNS hostnames to the new droplet IP
  
  - If restoring a backup: change version in docker-compose.yml from `:latest` to the version of the backup. \
    For example: `gitlab/gitlab-ee:13.5.3-ee.0`  _#note the .0 that is appended to the version tags._\
    run `tar -xcvf <config.tar.gz>` _this is needed before gitlabBaseSetupBash, since it starts the docker image, and then the files need to be there_\
    _#Obious "TODO:" here: make a different script for backup restoration that just does things differently_
    
  - Run `bash ./gitlabBaseSetupBash`\
    _#chmod +x first if scripts are non-executable_

  - If restoring a backup:\
    
    `mv <gitlab backup file> /root/gitlab/data/backups`\
    `chmod 755 /root/gitlab/data/backups/<gitlab backup file>`
    `docker ps` _#To check the `<name of container>` (ID), you only need to enter some of the first letters_\
    `docker exec -it <name of container> gitlab-ctl stop unicorn`\
    `docker exec -it <name of container> gitlab-ctl stop puma`\
    `docker exec -it <name of container> gitlab-ctl stop sidekiq`\
    `docker exec -it <name of container> gitlab-backup restore`\
    `docker restart <name of container>`

- **Creating a backup**
  - ssh in to the droplet and run the commands below:\
    `docker ps` _# to check the `<container name>`, again, only some of the first letters are needed_\
    `docker exec -t <container name> gitlab-backup create`\
    `cp ./gitlab/data/backups/<backup file> .`\
    `tar -czvf config.tar.gz ./gitlab/config`\
    `scp <backup-file> <backup server>:</path>`\
    `scp config.tar.gz <backup server>:</path>`
  - If you are also removing the droplet _#please make sure your backups have been successfully transferred_\
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

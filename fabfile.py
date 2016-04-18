import os
import time

from fabric.api import env, run, cd, lcd, local, sudo, hosts
from fabric.utils import error


###############################
# Configuration variables
#

# This will be the same as the repo's name
PROJECT_NAME   = 'localtest'

# Repo dirs on server
STAGE_PATH     = '/home/stagedir/'
PROD_PATH      = '/home/proddir/'

# Respective repos
STAGE_BRANCH   = 'staging'
PROD_BRANCH    = 'production'

# Hostnames as defined locally
STAGE_HOSTNAME = 'stagehostname'
PROD_HOSTNAME  = 'prodhostname'

#
# End config
###############################


def _is_git_repo(path):
    with lcd(path):
        return os.system('git rev-parse') == 0


def _get_git_branch(path):
    with lcd(path):
        return local('git rev-parse --abbrev-ref HEAD', capture=True)


def _error_if_dirty(repo_name, path):
    with lcd(path):
        if local('git status --porcelain', capture=True):
            error('\033[91mRepo "{}" is dirty.\033[0m'.format(repo_name))


colorize_errors = True

LOCAL_PATH = local('git rev-parse --show-toplevel')
LOCAL_BRANCH = _get_git_branch(LOCAL_PATH)

env.use_ssh_config = True


def reup():
    print('\033[92mFetching live database...\033[0m')
    local('scripts/fetch_live_db.sh')
    print('\033[92mRebuilding vagrant environment...\033[0m')
    local('vagrant destroy -f; vagrant up')
    print('\033[92mRebuild complete\033[0m')


@hosts(STAGE_HOSTNAME)
def stage():
    stageAns = raw_input("\033[92m\n\nWARNING: You are about to deploy to stage.\n\n\033[0m\nIf you're sure you want the \"\033[92m{0}\033[0m\" branch \nto be live please type \"\033[93mSTAGE\033[0m\" in all caps and hit enter:\n\n".format(STAGE_BRANCH))
    if stageAns == "STAGE":
        ensure_branch(STAGE_BRANCH)
        dirty_check()
        local_push(STAGE_BRANCH)
        remote_pull(STAGE_BRANCH, STAGE_PATH)
        remote_postpull(STAGE_PATH)
        remote_fixperms(STAGE_PATH)
    else:
        print('\033[92mDeployment cancelled\033[0m')


@hosts(PROD_HOSTNAME)
def deploy():
    deployAns = raw_input("""\033[91m
    _________________________________________________

      ____       _               _     _           _
     / ___| ___ (_)_ __   __ _  | |   (_)_   _____| |
    | |  _ / _ \| | '_ \ / _` | | |   | \ \ / / _ \ |
    | |_| | (_) | | | | | (_| | | |___| |\ V /  __/_|
     \____|\___/|_|_| |_|\__, | |_____|_| \_/ \___(_)
                         |___/
    _________________________________________________

     WARNING: You are about to deploy to production.
\n\033[0m\nIf you're sure you want the \"\033[92m{0}\033[0m\" branch \nto be live please type \"\033[91mPRODUCTION\033[0m\" in all caps and hit enter:\n\n""".format(PROD_BRANCH))
    if deployAns == "PRODUCTION":
        ensure_branch(PROD_BRANCH)
        dirty_check()
        local_push(PROD_BRANCH)
        remote_pull(PROD_BRANCH, PROD_PATH)
        remote_fixperms(PROD_PATH)
    else:
        print('\033[92mDeployment cancelled\033[0m')


def ensure_branch(branch):
    if LOCAL_BRANCH != branch:
        error('\033[91m{} repo is on branch "{}". Deployment must occur from the '
              '"{}" branch\033[0m'.format(PROJECT_NAME, LOCAL_BRANCH, branch))


def dirty_check():
    _error_if_dirty(PROJECT_NAME, LOCAL_PATH)


def local_push(branch):
    local('git push origin ' + branch + ':' + branch)


def remote_pull(branch, path):
    with cd(path):
        run('git fetch --all --prune')
        run('git checkout ' + branch)
        run('git pull')


def remote_postpull(path):
    with cd(path):
        run('./scripts/stage-postpull.sh')

def remote_fixperms(path):
    with cd(path):
        run('./scripts/fixperms.sh')


def dumpdb(path):
    with cd(path):
        run('. scripts/stage/stage-dbconfig.sh && mysqldump -h $LIVE_MYSQL_HOST $LIVE_MYSQL_DB -u $LIVE_MYSQL_USER -p$LIVE_MYSQL_PASS --add-drop-table --quick --compress --single-transaction --skip-comments --verbose --hex-blob > %sbackup/db.sql' % BACKUP_PATH)

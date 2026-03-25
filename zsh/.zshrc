# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="startship"

#
# Configure Starship prompt
#
eval "$(starship init zsh)"
export STARSHIP_CONFIG="$HOME/.config/starship.toml"


# https://www.reddit.com/r/Ghostty/comments/1hx75mj/move_between_words_in_nvim_with_optionarrowsleft/
# https://stackoverflow.com/questions/10194094/how-to-make-alt-arrow-keys-move-by-word-in-zsh
# bindkey "^[[1;3D" backward-word # Alt + Left
# bindkey "^[[1;3C" forward-word  # Alt + Right


#
# Variables
#
export BROWSER="/usr/bin/brave"

export AWS_DEFAULT_REGION="ap-southeast-2" 
export AWS_REGION="ap-southeast-2"

# Composer
# This will allow us to link to packages without symlinks so they can be used within docker containers
export COMPOSER_MIRROR_PATH_REPOS=1

#
# PATH
#
export PATH="$HOME/.config/composer/vendor/bin:$PATH" 

#
# Aliases
#

## Neovim
alias vim='nvim'

## Git
alias degit="rm -rf .git"

### This will safely delete local branches that have been removed from the remote. Make sure you don’t have unmerged work on those branches before deleting. 
alias git-prune-local="git branch -vv | awk '/: gone]/{print $1}' | xargs git branch -d"

## Docker

source /Users/rob/.docker/init-zsh.sh || true # Added by Docker Desktop

### Docker Stop All Containers
dstop() { docker stop $(docker ps -a -q); }

### Docker Compose Up and remote into it
alias dcu="docker-compose up -d"

### Docker Compose Down
alias dcd="docker-compose down"

## PHP

### Composer
alias ci="composer install --prefer-dist"
alias cda="composer dump-autoload --optimize"
alias cgu="composer global update"
alias cgl="composer global show -i"
alias cri="rm -rf vendor && composer install --prefer-dist --ignore-platform-reqs"

### Laravel
alias artisan="php artisan"

### Laravel Pint
alias pint="vendor/bin/pint"

### Laravel Sail
alias sail="bash vendor/bin/sail"
alias sa="bash vendor/bin/sail artisan"

### Laravel Vapor
alias vapor="php vendor/bin/vapor"

### Run PhpUnit for faster local performance
alias phpunit="vendor/bin/phpunit --order-by=defects --stop-on-failure"

### Run alias for Pest
alias pest="vendor/bin/pest"

### Run alias for phpstan
alias phpstan="vendor/bin/phpstan --memory-limit=4G" 

### Run alias for Pint
alias pp="pint --dirty"
alias ppp="pint --dirty && phpstan"

### Tail log file
alias tlog="echo > storage/logs/laravel.log && tail -n 50 -f storage/logs/laravel.log"

### Clear the log file
alias clog="echo > storage/logs/laravel.log"

##
## NodeJS

alias np="npm run"

### Create a new Nextjs App with tailwindcss as the default
alias next="yarn create next-app --tailwind with-tailwindcss-app"

### PNPM
alias pn="pnpm"

alias pnx="pnpx"

### Model Context Protocol Inspector
alias mcp="npx @modelcontextprotocol/inspector"

### Cloudflare Agents
alias agent="npm create cloudflare@latest -- --template cloudflare/agents-starter"

### Cloudflare Workers
alias wrangler="npx wrangler"

## Utilities

### Ngrok
alias ngrok-start="ngrok http http://localhost"

# pnpm
export PNPM_HOME="/Users/rob/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# Vite+ bin (https://viteplus.dev)
. "$HOME/.vite-plus/env"

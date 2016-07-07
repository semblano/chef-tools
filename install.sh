
path=$(pwd)
ln -s $path/chef-tools /usr/local/bin

cat >> ~/.bashrc << '_EOF'

## Autocompletation for chef-tools
export CHEFTOOLSOPT="deploy bootstrap"
_chef-tools() {
  local cur prev opts
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"
  opts="$CHEFTOOLSOPT"

  case "${prev}" in
    chef-tools)
      export CHEFTOOLSOPT="deploy bootstrap"
    ;;
    deploy)
      export CHEFTOOLSOPT="--environment --node-list --zone --parallel --update-version --help"
    ;;
    bootstrap)
      export CHEFTOOLSOPT="--environment --node-list --domain --yes --help"
    ;;
  esac
  COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
}
complete -F _chef-tools chef-tools
_EOF

exec bash

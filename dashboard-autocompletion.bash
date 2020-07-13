#/usr/bin/env bash
# keep in sync with dashboard.sh
# words to complete are all secondary commands (here eg. boot)
# script is the main function name (here: dashboard)

# TODO: Fuzzy matching for tickets
# ref. https://superuser.com/questions/561451/is-there-a-shell-which-supports-fuzzy-completion-as-in-sublime-text
# ref. https://github.com/mgalgs/fuzzy_bash_completion/blob/master/fuzzy_bash_completion

# ref. https://opensource.com/article/18/3/creating-bash-completion-script
_dashboard_completions()
{
  if [ ${#COMP_WORDS[@]} -eq 3 ] && { [ "${COMP_WORDS[1]}" == "delete" ] || [ "${COMP_WORDS[1]}" == "open" ] || [ "${COMP_WORDS[1]}" == "warmup" ] || [ "${COMP_WORDS[1]}" == "calabash" ]; }; then
    LIST_OF_REPOS=`query_list_of_repos`
    local local_repositories=($(compgen -W "$LIST_OF_REPOS" "${COMP_WORDS[2]}"))
    COMPREPLY=("${local_repositories[@]}")
    return
  elif [ ${#COMP_WORDS[@]} -ne 2 ]; then
    ## Fix for recurring autocompletion, 1 argument was already passed
    return
  fi

  # keep the suggestions in a local variable, so we can postprocess it
  local suggestions=($(compgen -W "copy delete delete-batch view open boot patch-boot patch-close warmup install calabash" "${COMP_WORDS[1]}"))

  # if [ "${#suggestions[@]}" == "1" ]; then
  #   1 autocompletion found
  # else
  #   display suggestions
  #   COMPREPLY=("${suggestions[@]}")
  # fi

  COMPREPLY=("${suggestions[@]}")
}

complete -F _dashboard_completions dashboard

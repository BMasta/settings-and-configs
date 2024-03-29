# elapsed time color:       #ffff00
# git color:                #ff672b
# dir icon color:           #ffff00
# workdir color:            #58c686
# prompt sign err color:    #ff0000
# prompt sign ok color:     #ffeb3b
# python blue color:        #4584b6
# python yellow color:      #ffde57

# git:                      \ue65d
# branch:                   \ue727
# dot-like separator:       \u22c5
# directory:                \uf4d3
# prompt sign:              \uf101
# python sign               \ue73c

function __timer_start {
    timer=${timer:-$SECONDS}
}

function __timer_stop {
    ELAPSED=$((SECONDS - timer))
    unset timer
}

function __plen () {
   local ps len
   ps="$(perl -pe 's|\\\[.*?\\\]||g' <<<"${PS1}X")"
   len="$(wc -m <<<"${ps@P}")"
   printf '%s\n' "$((len-2))"
}

# sets or leaves blank the prompt parts based on current conditions
function __smart_prompt {
    SP_ELAPSED=""
    SP_PYTHON_ICON=""
    SP_PYTHON_VENV=""
    SP_DIR_ICON=""
    SP_WORKDIR=""
    SP_GIT_ICON=""
    SP_GIT_REPO=""
    SP_GIT_RH_SEP=""
    SP_GIT_HEAD=""
    SP_GIT_IP_SEP=""
    SP_GIT_INNER_PATH=""
    SP_PSIGN=""

    # assemble time elapsed string
    if [ -n "$ELAPSED" ] && [ "$ELAPSED" -gt 9 ]; then
        SP_ELAPSED+="[${ELAPSED}s] "
    fi

    # assemble custom python venv
    if [ -n "$VIRTUAL_ENV" ]; then
        SP_PYTHON_ICON+=$'\ue606 '
        SP_PYTHON_VENV+="${VIRTUAL_ENV##*/} "
    fi

    # assemble context
    if git rev-parse --is-inside-work-tree &> /dev/null; then
        local git_subdir
        
        # set git icon
        SP_GIT_ICON+=$'\ue65d '
        
        # set repo
        SP_GIT_REPO+="$(git rev-parse --show-toplevel | xargs basename)"

        # set repo/head separator
        SP_GIT_RH_SEP+=$'\u22c5'

        # set head (branch or tag or short hash)
        SP_GIT_HEAD+="$(git symbolic-ref -q --short HEAD || \
                       git describe --tags --exact-match 2> /dev/null || \
                       git rev-parse --short HEAD) "

        # set subdir + color if not in root
        git_subdir="$(git rev-parse --show-prefix)"
        if [ -n "$git_subdir" ]; then
            # set inner path separator
            SP_GIT_IP_SEP+=$'| '
            SP_GIT_INNER_PATH+="${git_subdir%?} "
        fi
    else
        # set dir icon
        SP_DIR_ICON+=$'\uf4d3 '

        # set workdir path
        SP_WORKDIR+="$(dirs +0) "
    fi

    # assemble prompt sign
    SP_PSIGN=$'\uf101 '
}

SP_PYTHON_FG_COLOR=$'\e[38;2;69;132;182m'
SP_ORANGE=$'\e[38;2;255;103;43m'
SP_GREEN=$'\e[38;2;88;198;134m'
SP_DARK_YELLOW=$'\e[38;2;255;235;59m'
SP_LIGHT_YELLOW=$'\e[38;2;255;255;0m'
SP_DEFAULT_COLOR=$'\e[m'

trap '__timer_start' DEBUG

PS1=""
PROMPT_COMMAND="
    if [ \$? = 0 ]; then 
        SP_STATUS_COLOR=\$'\e[38;2;255;235;59m';
    else 
        SP_STATUS_COLOR=\$'\e[38;2;255;0;0m';
    fi;
    __smart_prompt
    __timer_stop"


PS1+='\['; PS1+="$SP_LIGHT_YELLOW"; PS1+='\]'
PS1+='${SP_ELAPSED}'

export VIRTUAL_ENV_DISABLE_PROMPT=1
PS1+='\['; PS1+="$SP_PYTHON_FG_COLOR"; PS1+='\]'
PS1+='${SP_PYTHON_ICON}'
PS1+='${SP_PYTHON_VENV}'

PS1+='\['; PS1+="$SP_ORANGE"; PS1+='\]'
PS1+='${SP_GIT_ICON}'

PS1+='\['; PS1+="$SP_ORANGE"; PS1+='\]'
PS1+='${SP_GIT_REPO}'

PS1+='\['; PS1+="$SP_DARK_YELLOW"; PS1+='\]'
PS1+='${SP_GIT_RH_SEP}'

PS1+='\['; PS1+="$SP_ORANGE"; PS1+='\]'
PS1+='${SP_GIT_HEAD}'

PS1+='\['; PS1+="$SP_DARK_YELLOW"; PS1+='\]'
PS1+='${SP_GIT_IP_SEP}'

PS1+='\['; PS1+="$SP_GREEN"; PS1+='\]'
PS1+='${SP_GIT_INNER_PATH}'

PS1+='\['; PS1+="$SP_LIGHT_YELLOW"; PS1+='\]'
PS1+='${SP_DIR_ICON}'

PS1+='\['; PS1+="$SP_GREEN"; PS1+='\]'
PS1+='${SP_WORKDIR}'

# status color needs to be set at runtime
PS1+='\['; PS1+='${SP_STATUS_COLOR}'; PS1+='\]'
PS1+='${SP_PSIGN}'

PS1+='\['; PS1+="$SP_DEFAULT_COLOR"; PS1+='\]'

unset time_c fs_icon_c git_c workdir_c err_c ok_c \
        dir_icon workdir prompt_sign_ok prompt_sign_err sp_part

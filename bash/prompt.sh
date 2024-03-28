function __timer_start {
    timer=${timer:-$SECONDS}
}

function __timer_stop {
    ELAPSED=$((SECONDS - timer))
    unset timer
}

function __smart_prompt {
    # elapsed time color:       #ffff00
    # git color:                #ff672b
    # dir icon color:           #ffff00
    # workdir color:            #58c686
    # prompt sign err color:    #ff0000
    # prompt sign ok color:     #ffeb3b

    # git:                      \ue65d
    # branch:                   \ue727
    # dot-like separator:       \u22c5
    # directory:                \uf4d3
    # prompt sign:              \uf101

    SMART_PROMPT=""

    # assemble time elapsed string
    if [ -n "$ELAPSED" ] && [ "$ELAPSED" -gt 9 ]; then
        SMART_PROMPT+=$'\e[38;2;255;255;0m'
        SMART_PROMPT+="[${ELAPSED}s] "
    fi

    # assemble context
    if git rev-parse --is-inside-work-tree &> /dev/null; then
        local git_subdir
        
        # set git icon
        SMART_PROMPT+=$'\e[38;2;255;103;43m\ue65d '
        
        # set repo
        SMART_PROMPT+=$'\e[38;2;255;103;43m'
        SMART_PROMPT+="$(git rev-parse --show-toplevel | xargs basename)"

        # set repo/head separator
        SMART_PROMPT+=$'\e[38;2;255;235;59m\u22c5'

        # set head (branch or tag or short hash)
        SMART_PROMPT+=$'\e[38;2;255;103;43m'
        SMART_PROMPT+="$(git symbolic-ref -q --short HEAD || \
                       git describe --tags --exact-match 2> /dev/null || \
                       git rev-parse --short HEAD) "

        # set subdir + color if not in root
        git_subdir="$(git rev-parse --show-prefix)"
        if [ -n "$git_subdir" ]; then
            # set inner path separator
            SMART_PROMPT+=$'\e[38;2;255;235;59m| '

            SMART_PROMPT+=$'\e[38;2;88;198;134m'
            SMART_PROMPT+="${git_subdir%?} "
        fi
    else
        # set dir icon
        SMART_PROMPT+=$'\e[38;2;255;255;0m\uf4d3 '

        # set workdir path
        SMART_PROMPT+=$'\e[38;2;88;198;134m'
        SMART_PROMPT+="$(dirs +0) "
    fi

    SMART_PROMPT+="$PROMPT_SIGN "

    # set color for the command
    SMART_PROMPT+=$'\033[m'
}



#dir_icon=$'\uf4d3'
#prompt_sign=$'\uf101'

trap '__timer_start' DEBUG

PROMPT_COMMAND="
    if [ \$? = 0 ]; then 
        PROMPT_SIGN=\$'\e[38;2;255;235;59m\uf101';
    else 
        PROMPT_SIGN=\$'\e[38;2;255;0;0m\uf101';
    fi;
    __smart_prompt
    __timer_stop"

PS1='${SMART_PROMPT}'                       

unset time_c fs_icon_c git_c workdir_c err_c ok_c
unset dir_icon workdir prompt_sign_ok prompt_sign_err

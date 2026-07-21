#!/usr/bin/env bash
# ui.sh — pure-CLI two-level menu (blocks → items). No curses, just colors.

SEP_LEN=62

section_header() {
    local title=$1
    local line
    line="$(printf '═%.0s' $(seq 1 "$SEP_LEN"))"
    printf '\n%s%s%s\n' "${COLOR_BOLD}${COLOR_CYAN}" "$line" "$COLOR_OFF"
    printf '%s  ▶ %s%s\n' "${COLOR_BOLD}${COLOR_CYAN}" "$title" "$COLOR_OFF"
    printf '%s%s%s\n\n' "${COLOR_BOLD}${COLOR_CYAN}" "$line" "$COLOR_OFF"
}

run_header() {
    local title=$1
    local fill_len=$(( SEP_LEN - 8 - ${#title} ))
    (( fill_len < 4 )) && fill_len=4
    local fill
    fill="$(printf '─%.0s' $(seq 1 "$fill_len"))"
    printf '\n%s  ── %s %s%s\n\n' "${COLOR_BOLD}${COLOR_CYAN}" "$title" "$fill" "$COLOR_OFF"
}

# ui_visible_blocks — fills UI_BLOCKS with the ordered blocks that have at
# least one visible item (registry order).
ui_visible_blocks() {
    UI_BLOCKS=()
    local id block known
    for id in "${ITEMS[@]}"; do
        item_visible "$id" || continue
        block=${ITEM_BLOCK[$id]}
        for known in "${UI_BLOCKS[@]}"; do
            [[ "$known" == "$block" ]] && continue 2
        done
        UI_BLOCKS+=("$block")
    done
}

# ui_block_items <block> — fills UI_BLOCK_ITEMS with the block's visible ids.
ui_block_items() {
    UI_BLOCK_ITEMS=()
    local id
    for id in "${ITEMS[@]}"; do
        [[ "${ITEM_BLOCK[$id]}" == "$1" ]] || continue
        item_visible "$id" || continue
        UI_BLOCK_ITEMS+=("$id")
    done
}

# main_menu — level 1. Sets UI_CHOSEN_BLOCK. Returns 1 when the operator quits.
main_menu() {
    ui_visible_blocks
    local choice i block id total installed
    while true; do
        section_header "setup-linux"
        i=1
        for block in "${UI_BLOCKS[@]}"; do
            ui_block_items "$block"
            total=${#UI_BLOCK_ITEMS[@]}
            installed=0
            for id in "${UI_BLOCK_ITEMS[@]}"; do
                item_installed "$id" && (( installed += 1 ))
            done
            printf '  %s[%d]%s  %-16s %s%d item(ns), %d instalado(s)%s\n' \
                "$COLOR_BOLD" "$i" "$COLOR_OFF" "$block" \
                "$COLOR_DIM" "$total" "$installed" "$COLOR_OFF"
            (( i += 1 ))
        done
        printf '\n  %s[Q]%s  sair\n\n' "$COLOR_BOLD" "$COLOR_OFF"
        read -rp "  Escolha: " choice || return 1
        printf '\n'
        case "${choice,,}" in
            q) return 1 ;;
            '') ;;
            *)
                if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#UI_BLOCKS[@]} )); then
                    # shellcheck disable=SC2034  # consumed by setup.sh
                    UI_CHOSEN_BLOCK=${UI_BLOCKS[choice-1]}
                    return 0
                fi
                printf '  %sOpção inválida.%s\n' "$COLOR_RED" "$COLOR_OFF"
                ;;
        esac
    done
}

# item_menu <block> — level 2: toggle items, confirm to run. Sets
# UI_SELECTED_ITEMS on confirm. Returns 1 when the operator goes back.
item_menu() {
    local block=$1
    ui_block_items "$block"
    local ids=("${UI_BLOCK_ITEMS[@]}")
    declare -A marked=()
    local id choice i box status n valid
    for id in "${ids[@]}"; do marked[$id]=0; done

    while true; do
        run_header "$block"
        i=1
        for id in "${ids[@]}"; do
            box="[ ]"
            (( marked[$id] )) && box="${COLOR_GREEN}[x]${COLOR_OFF}"
            status=""
            item_installed "$id" && status="  ${COLOR_GREEN}✓${COLOR_OFF}${COLOR_DIM} instalado${COLOR_OFF}"
            printf '  %s[%d]%s %s %s%s\n' \
                "$COLOR_BOLD" "$i" "$COLOR_OFF" "$box" "${ITEM_DESC[$id]}" "$status"
            (( i += 1 ))
        done
        printf '\n  %snúmeros alternam a marcação (ex: 1 3 4)%s\n' "$COLOR_DIM" "$COLOR_OFF"
        printf '  %s[A]%s todos   %s[N]%s nenhum   %s[C]%s confirmar e executar   %s[V]%s voltar\n\n' \
            "$COLOR_BOLD" "$COLOR_OFF" "$COLOR_BOLD" "$COLOR_OFF" \
            "$COLOR_BOLD" "$COLOR_OFF" "$COLOR_BOLD" "$COLOR_OFF"
        read -rp "  Opção: " choice || return 1
        printf '\n'
        case "${choice,,}" in
            a) for id in "${ids[@]}"; do marked[$id]=1; done ;;
            n) for id in "${ids[@]}"; do marked[$id]=0; done ;;
            v) return 1 ;;
            c)
                UI_SELECTED_ITEMS=()
                for id in "${ids[@]}"; do
                    (( marked[$id] )) && UI_SELECTED_ITEMS+=("$id")
                done
                if (( ${#UI_SELECTED_ITEMS[@]} == 0 )); then
                    printf '  %sNada marcado.%s\n' "$COLOR_YELLOW" "$COLOR_OFF"
                else
                    return 0
                fi
                ;;
            *)
                valid=1
                for n in $choice; do
                    if [[ "$n" =~ ^[0-9]+$ ]] && (( n >= 1 && n <= ${#ids[@]} )); then
                        id=${ids[n-1]}
                        marked[$id]=$(( 1 - marked[$id] ))
                    else
                        valid=0
                    fi
                done
                (( valid )) || printf '  %sOpção inválida.%s\n' "$COLOR_RED" "$COLOR_OFF"
                ;;
        esac
    done
}

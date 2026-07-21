#!/usr/bin/env bash
# ui.sh — whiptail checklist menu.

# show_menu — prints the selected item ids (whiptail quoting) to stdout.
# Returns non-zero when the operator cancels. Items start unchecked; the
# block name prefixes each entry since whiptail has no section headers.
show_menu() {
    local entries=() id status
    for id in "${ITEMS[@]}"; do
        item_visible "$id" || continue
        status=""
        item_installed "$id" && status=" ✓"
        entries+=("$id" "[${ITEM_BLOCK[$id]}] ${ITEM_DESC[$id]}$status" OFF)
    done

    local rows cols list_height height width
    rows=$(tput lines 2>/dev/null || echo 30)
    cols=$(tput cols 2>/dev/null || echo 100)
    list_height=$(( rows - 12 ))
    (( list_height > 22 )) && list_height=22
    (( list_height < 5 )) && list_height=5
    height=$(( list_height + 8 ))
    width=$(( cols - 6 ))
    (( width > 100 )) && width=100
    (( width < 60 )) && width=60

    whiptail --title "setup-linux" \
        --checklist "Selecione os itens (espaço marca, Enter confirma):" \
        "$height" "$width" "$list_height" \
        "${entries[@]}" \
        3>&1 1>&2 2>&3
}

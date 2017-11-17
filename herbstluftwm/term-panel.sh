#!/bin/bash

herbstclient pad 0 15

panel_dir="$(dirname "$0")"
util_dir="$panel_dir/util"
plaintext="$util_dir/plaintext"

function uniq_linebuffered() {
  awk '$0 != l { print ; l=$0 ; fflush(); }' "$@"
}

# disable cursor
echo -ne "\e[?25l"

# SGR vars
Esc="$(echo -e '\e')"
b="$Esc[1m" rb="$Esc[22m"
i="$Esc[3m" ri="$Esc[23m"
u="$Esc[4m" ru="$Esc[24m"
n="$Esc[7m" rn="$Esc[27m"
r="$Esc[m"
#fg="$Esc[31m"
#sg="$Esc[38:5:244m"
#col_curr='38:5:174'

#fg="$Esc[31m"
#sg="$Esc[38:5:244m"
#fg="$Esc[38:2:255;85;255m"
#sg="$Esc[38:2:85:255:255m"
#col_curr='38:2:255:85:255'

#fg="$Esc[38:2:255;119;153m"
#sg="$Esc[38:2:150:150:150m"
#col_curr='38:2:255:119:153'

# Orange
#col_curr='38:2:255:68:34'
# Bluish
col_curr='38:2:68:119:170'

fg="$Esc[${col_curr}m"
sg="$Esc[38:2:150:150:150m"

cols=$(TERM=xterm tput cols)

{
  #--- Emit events --------------------
  mpc idleloop player &

  while true; do echo tick; sleep 20; done &
  while true; do echo occasionally; sleep 200; done &

  while true; do
    date +"date"$'\t'"%H:%M$sg %a %Y-%m-%d$r"
    sleep 1 || break
  done > >(uniq_linebuffered) &

  herbstclient --idle

} 2>/dev/null | {
  # Default values for the panel-drawing part
  TAGS=( $(herbstclient tag_status 0) x )
# visible=true

  windowtitle=""

  Default="--"
  sep=""

  # fields of the right panel
  date="$Default"
  brightstatus="$Default"
  batstatus="$Default"
  thermstatus="$Default"
  nowplayingsym="♫"
  nowplaying="$Default"
# wicdstatus="$Default"
  pacstatus="$Default"

  while true; do
    #--- Draw panel -------------------
    L=" "

  # N=( $(for i in "${TAGS[@]}"; do [ "${i:0:1}" = "." ]; echo $?; done) )
  # braille="$($util_dir/braille 0      0         0    0 "${N[0]}" "${N[3]}"      0    "${N[6]}" \
  #                              0 "${N[1]}" "${N[4]}" 0 "${N[2]}" "${N[5]}" "${N[7]}" "${N[8]}")"
  # L="$L ${braille} "

    # Tags
 #  symbols=( x ➊ ➋ ➌ ➍ ➎ ➏ ➐ ➑ ➒ ➓ )
 #  for i in "${TAGS[@]}"; do
 #    S="${symbols[${i:1}]} "
 #    case ${i:0:1} in
 #      '.')                            ;; # Empty
 #      ':')  L="$L$r$Esc[38:5:238m$S"  ;; # Not empty
 #    # '+')                            ;; # Viewed on this monitor, not focused
 #      '#')  L="$L$r$sg$S"             ;; # Viewed on this monitor, is focused
 #    # '-')                            ;; # Viewed on other monitor, not focused
 #    # '%')                            ;; # Viewed on other monitor, is focused
 #      '!')  L="$L$r$Esc[31m$S"        ;; # Contains urgent window
 #       * )  L="$L$r$Esc[30m$S"        ;; # Default
 #    esac
 #  done
 #  L="$L$r"

    next=""
    for i in "${TAGS[@]}"; do
     forced_sym=""
     [ x$next != x ] && forced_sym="$next"
   # skip="" next="" sym="⮁"
     skip="" next="" sym=" "
     case ${i:0:1} in
       '.')  skip=1                                                           ;;
       ':')  color="38:5:240" sym="$Esc[38:5:240m$sym"                        ;;
     # '#')  color="1"        sym="$Esc[7;38:5:31m⮀"  next="$Esc[38:5:31m⮀" ;;
     # '#')  color="1"        sym="$Esc[7;38:5:31m▌"  next="$Esc[38:5:31m▌" ;;
   #   '#')  color="1"        sym="$Esc[7;38:5:174m▌"  next="$Esc[38:5:174m▌" ;;
       '#')  color="1"        sym="$Esc[7;${col_curr}m▌" next="$Esc[${col_curr}m▌" ;;
       '!')  color=""         sym="$Esc[31m$sym"                              ;;
       'x')                   sym="$Esc[38:5:240m$sym"                        ;;
        * )  color=""         sym="$Esc[30m$sym"                              ;;
     esac
     [ x"$forced_sym" != x ] && sym="$forced_sym"
     if [ x"$skip" == x ]; then
       L="$L$sym $Esc[${color}m${i:1} $r"
     else
       next="$forced_sym"  # save again
     fi
    done
    L="$L$r"

    # Then, the right panel
#   R=""
#   R="$R $fg ♫ $r$nowplaying"   # ♫
#   R="$R $fg ⚡ $r$batstatus"    # ⚡
#   R="$R $fg ☀ $r$brightstatus" # ☀
#   R="$R $fg ⽕ $r$thermstatus" # ♨☕
# # R="$R $fg ⌬ $r$wicdstatus"   # ⌬🌐
#   R="$R $fg ᗧ $r$pacstatus"    # ᗧ
#   R="$R $fg ⌚ $r$date"         # ⌚

    R=""
#   R="$R $fg 🔊 $r$nowplaying"   # ♫ 🔊
    R="$R $fg $nowplayingsym $r$nowplaying"   # ♫ 🔊
    R="$R $batstatus"    # ⚡
    R="$R $fg 💡 $r$brightstatus" # ☀
    R="$R $fg 🌡 $r$thermstatus"  # 🔥♨☕
    R="$R $fg 📦 $r$pacstatus"    # ᗧ
    R="$R $fg 🕓 $r$date"         # ⌚

  # Brightness    🔅  🔆  💡             |
  # Volume/Music  🔇  🔈  🔉  🔊          |
  # Power         🔋  🔌  🗲             |
  # Search?       🔍                   |
  # E-mail        📧  📨  📩  🖂  🖄       |
  # Mounts?       💾  💿  📁  📂  🗀  🗁  🖿 |
  # Packages      📦                   |
  # Temperature   🔥  ㊋

  # L_len=$(plaintext <<<"$L" | $util_dir/displaywidth)
  # R_len=$(plaintext <<<"$R" | $util_dir/displaywidth)

  # # Title
  # space_left=$((cols - (L_len + 2) - (R_len + 2)))

  # wt="${windowtitle:0:$((space_left - 4))}"
  # cjk_count_wt="$($util_dir/displaywidth <<<"$wt")"
  # space_left=$((space_left - cjk_count_wt))

  # ((${#wt} >= space_left - 4)) && wt="${wt}…"
  # L="$L  $wt"

    L_len=$($util_dir/helper display-width "$($plaintext <<<"$L")")
    R_len=$($util_dir/helper display-width "$($plaintext <<<"$R")")

    # Title
    space_left=$((cols - (L_len + 2) - (R_len + 2) - 3))
    wt="$($util_dir/helper trim-title "$windowtitle" $space_left)"
    wt_len=$($util_dir/helper display-width "$wt")

    L="$L  $wt"
    padding=$((cols - (L_len + 2) - (R_len + 2) - wt_len - 3))

  # printf "\r%s%$((space_left - ${#wt} - 2))s%s\e[K" "$L" "" "$R"
    printf "\r$r%s%${padding}s%s\e[K" "$L" "" "$R"


    #--- Read event -------------------
    IFS=$'\t' read -ra cmd || break

    case "${cmd[0]}" in
      tag*)
        TAGS=( $(herbstclient tag_status 0) x )
        ;;

      quit_panel|reload)
        echo "\rexiting..."
        exit
        ;;

      focus_changed|window_title_changed)
        windowtitle="${cmd[@]:2}"
        ;;

      date)
        date="${cmd[@]:1}"
        ;;

      brightness)
        brightstatus="$(printf "%d$sg%%$r" $(backlight.sh '?'))"
        ;;

      tick)
        batstatus="$( t='/sys/class/power_supply/BAT1/'
                      curr=$(cat $t/charge_now)
                      full=$(cat $t/charge_full_design)
                      full2=$(cat $t/charge_full)
                      status=$(cat $t/status)
                      min=1100000
                      percent=$(printf '100 * (%d - %d) / %d\n' $curr $min $full | bc)
                      percent=$(cat $t/capacity)

                      color=$( ([ "$percent" -le 10 ] && echo -e '\e[48:5:160m\e[1m') ||
                               ([ "$percent" -le 25 ] && echo -e '\e[33;1m') ||
                               (true                  && echo -e '') )

                      case "$status" in
                    #   Full|Unknown)  printf "$sg%s$r" "$status" ;;
                    #   *)  printf "$sg%s: $r$color%d$sg%%$r$sg$r" "$status" $percent ;;
                        Charging|Full|Unknown) printf "$fg$color 🔌 $r%d$sg%%$r" $percent ;;
                        Discharging)           printf "$fg$color 🔋 $r%d$sg%%$r" $percent ;;
                      esac )"

        thermstatus="$( t='/sys/class/thermal/thermal_zone0'
                        curr=$(cat $t/temp)
                        degrees=$(printf '%d / 1000\n' $curr | bc)
                        printf "%d$sg°C$r" $degrees )"

      # wicdstatus="$( essid=$(wicd-cli -d --wireless \
      #                      | grep Essid | cut -d' ' -f2-)
      #                [ -z "$essid" ] && essid='--'
      #                printf '%s' $essid )"
        ;;

    # occasionally)
    #   pacstatus="$(checkupdates | wc -l)"
    #   ;;

      mpd_player|player)
        status="$(mpc status | head -n 2 | tail -n 1 | grep -o '[a-z]\+' | head -n 1)"
        case "$status" in
          playing) nowplayingsym="⯈" ;;
          paused)  nowplayingsym="⏸" ;;
          stopped) nowplayingsym="⯀" ;;
          *)       nowplayingsym="♫" ;;
        esac
        nowplaying="$(mpc current -f "[%artist% - ][%title%|%file%]")"
        ;;
    esac
  done
}


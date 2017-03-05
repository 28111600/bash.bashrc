
# [ -z "$PS1" ] && return

shopt -s checkwinsize

# set variable identifying the chroot you work in (used in the prompt below)
if test -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ; then
	debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if test -n "$force_color_prompt" ; then
	if test -x /usr/bin/tput && tput setaf 1 >&/dev/null; then
		# We have color support; assume it's compliant with Ecma-48
		# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
		# a case would tend to support setf rather than setaf.)
		color_prompt=yes
	else
		color_prompt=
	fi
fi

if test "$color_prompt" = yes ; then
	PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w \$\[\033[00m\] '
else
	PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
	PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
;;
*)
;;
esac

if test -x /usr/lib/command-not-found -o -x /usr/share/command-not-found/command-not-found ; then
	function command_not_found_handle {
		# check because c-n-f could've been removed in the meantime
		if test -x /usr/lib/command-not-found ; then
			/usr/lib/command-not-found -- "$1"
			return $?
		elif [ -x /usr/share/command-not-found/command-not-found ]; then
			/usr/share/command-not-found/command-not-found -- "$1"
			return $?
		else
			printf "%s: command not found\n" "$1" >&2
			return 127
		fi
	}
fi

# PROFILE START

function welcome() {
	local upSeconds=$(/usr/bin/cut -d. -f1 /proc/uptime)
	local secs=$((upSeconds%60))
	local mins=$((upSeconds/60%60))
	local hours=$((upSeconds/3600%24))
	local days=$((upSeconds/86400))
	local uptime=$(printf "%d days, %02d:%02d:%02d" "$days" "$hours" "$mins" "$secs")

	local who=$(w -h | grep -c -E "pts|tty" )



	# calculate rough CPU and GPU temperatures:
	local cpuTempC
	local cpuTempF
	local gpuTempC
	local gpuTempF
	if test[ -f "/sys/class/thermal/thermal_zone0/temp" ]; then
		local cpuTempC=$(($(cat /sys/class/thermal/thermal_zone0/temp)/1000)) && local cpuTempF=$((cpuTempC*9/5+32))
	else
		local cpuTempC='?' && local cpuTempF='?'
	fi

	local memFree=$(($(grep MemFree /proc/meminfo | awk {'print $2'})/1024))
	local memTotal=$(($(grep MemTotal /proc/meminfo | awk {'print $2'})/1024))

	echo -e "
	\033[32m .~~. .~~. \033[32m$(date)
	\033[32m '. \ ' ' / .' \033[32m$(uname -srm)\033[31m
	\033[31m .~ .~~~..~.
	\033[31m : .~.'~'.~. : \033[37mUptime.....: $uptime
	\033[31m ~ ( ) ( ) ~ \033[37mMemory.....: $memFree Mb / $memTotal Mb
	\033[31m( : '~'.~.'~' : ) \033[37mProcesses..: $(ps ax | wc -l | tr -d " ") / $who users
	\033[31m ~ .~ ~. ~ \033[37mIP Address.: $(ip route get 8.8.8.8 2> /dev/null | head -1 | cut -d' ' -f8)
	\033[37m ( \033[34m | | \033[37m )
	\033[37m '~ ~'
	\033[37m *--~-~--* \033[33m Temperature: CPU: $cpuTempC°C / $cpuTempF°F
	"
}

if shopt -q login_shell; then
	welcome
fi
# PROFILE END


oh-my-posh init pwsh --config "/usr/share/oh-my-posh/themes/powerlevel10k_rainbow.omp.json" | Invoke-Expression
Import-Module Terminal-Icons

function lcat { /bin/cat $args; }
function cat { bat -pp $args; }
function 1 { Set-Location ..; }
function 2 { Set-Location ../..; }
function 3 { Set-Location ../../..; }
function 4 { Set-Location ../../../..; }
function 5 { Set-Location ../../../../..; }
function 6 { Set-Location ../../../../../..; }
function 7 { Set-Location ../../../../../../..; }
function 8 { Set-Location ../../../../../../../..; }
function 9 { Set-Location ../../../../../../../../..; }
function _ { sudo $args; }
function mounts { findmnt -a $args; }
function afind { ack -il $args; }
function egrep { egrep --color=auto $args; }
function fgrep { fgrep --color=auto $args; }
function gc1 { git clone --recursive --depth=1 $args; }
function globurl { noglob urlglobber $args; }
function grep { grep --color=auto $args; }
function md { mkdir -p $args; }
function rd { rmdir $args; }
function lls { /bin/ls $args; }
function ls { eza --color=auto $args; }
function l { eza -lZbah --icons $args; }
function la { eza -lZabgh --icons $args; }
function ll { eza -lZbg --icons $args; }
function lsa { eza -lbagR --icons $args; }
function lst { eza -lTabgh --icons $args; }
function diff { diff --color $args; }
function dd { dd status=progress $args; }
function xz { xz -v $args; }
function a { source .venv/bin/activate; }
function makedev { make -f Makefile.devel $args; }
function cmake { cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON $args; }

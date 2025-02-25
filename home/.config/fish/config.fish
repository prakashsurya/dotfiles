alias c=clear
alias g=git
alias s=ssh
alias v=nvim

fish_add_path /opt/homebrew/bin

if status is-interactive
    # Commands to run in interactive sessions can go here
    fish_vi_key_bindings
end

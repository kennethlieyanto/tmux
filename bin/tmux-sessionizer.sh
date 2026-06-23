#!/usr/bin/env bash
project_directories=(
  ~/Projects/work
  ~/Projects/personal
  ~/Projects/github
  ~/Projects/godot
  ~/Projects/playground
)

other_directories=(
  ~/.config/nvim
  ~/.local/share/chezmoi
  ~/Music
  ~/Vaults/notes
  ~/Vaults/sp-notes
)

if [[ $# -eq 1 ]]; then
  selected=$1
else
  # Build find command with only existing directories
  find_dirs=()
  for dir in "${project_directories[@]}"; do
    expanded_dir=$(eval echo "$dir")
    if [[ -d $expanded_dir ]]; then
      find_dirs+=("$expanded_dir")
    fi
  done

  if [[ ${#find_dirs[@]} -gt 0 ]]; then
    project_results=$(find "${find_dirs[@]}" -mindepth 1 -maxdepth 1 -type d 2>/dev/null)
  else
    project_results=""
  fi

  # Add the other_directories directly
  for dir in "${other_directories[@]}"; do
    expanded_dir=$(eval echo "$dir")
    project_results+=$'\n'"$expanded_dir"
  done

  # Use fzf to select from combined list
  selected=$(echo -e "$project_results" | fzf)
fi

echo "Selected directory: $selected"

if [[ -z $selected ]]; then
  exit 0
fi

selected_name=$(basename "$selected" | tr . _)
tmux_running=$(pgrep tmux)

if [ ! $tmux_running ]; then
  tmux new-session -s "$selected_name" -c "$selected"
  exit 0
fi

if [ -z "$TMUX" ]; then
  tmux new-session -A -s "$selected_name" -c "$selected"
  exit 0
fi

if ! tmux has-session -t "$selected_name" 2>/dev/null; then
  tmux new-session -ds "$selected_name" -c "$selected"
fi

tmux switch-client -t "$selected_name"

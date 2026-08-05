#!/usr/bin/env fish
# Everforest (dark medium) palette for the Tide prompt.
# Re-runnable: sets universal vars, then reloads tide. Run with `fish ~/.config/fish/everforest-tide.fish`.

# ── palette ──────────────────────────────────────────────────────────
set -l bg      2D353B  # bg0 — segment background
set -l fg      D3C6AA
set -l red     E67E80
set -l orange  E69875
set -l yellow  DBBC7F
set -l green   A7C080
set -l aqua    83C092
set -l blue    7FBBB3
set -l purple  D699B6
set -l grey    859289
set -l grey_dim 4F585E

# ── every segment background to the everforest bg ────────────────────
for seg in aws bun cmd_duration context crystal direnv direnv_denied distrobox \
           docker elixir gcloud git git_unstable git_urgent go java jobs kubectl \
           nix_shell node os php private_mode pulumi pwd python ruby rustc shlvl \
           status status_failure terraform time toolbox zig \
           vi_mode_default vi_mode_insert vi_mode_replace vi_mode_visual
    set -U tide_{$seg}_bg_color $bg
end

# ── foreground colors ────────────────────────────────────────────────
set -U tide_os_color                $fg
set -U tide_pwd_color_dirs          $blue
set -U tide_pwd_color_anchors       $aqua
set -U tide_pwd_color_truncated_dirs $grey

set -U tide_git_color_branch        $green
set -U tide_git_color_upstream      $aqua
set -U tide_git_color_untracked     $blue
set -U tide_git_color_dirty         $yellow
set -U tide_git_color_staged        $yellow
set -U tide_git_color_stash         $green
set -U tide_git_color_conflicted    $red
set -U tide_git_color_operation     $red

set -U tide_character_color         $green
set -U tide_character_color_failure $red

set -U tide_status_color            $green
set -U tide_status_color_failure    $red

set -U tide_cmd_duration_color      $yellow
set -U tide_context_color_default   $orange
set -U tide_context_color_ssh       $orange
set -U tide_context_color_root      $red
set -U tide_jobs_color              $aqua
set -U tide_time_color              $grey
set -U tide_shlvl_color             $orange
set -U tide_private_mode_color      $fg

# language / tool segments
set -U tide_node_color      $green
set -U tide_python_color    $aqua
set -U tide_java_color      $orange
set -U tide_go_color        $blue
set -U tide_rustc_color     $orange
set -U tide_ruby_color      $red
set -U tide_php_color       $blue
set -U tide_elixir_color    $purple
set -U tide_crystal_color   $fg
set -U tide_bun_color       $fg
set -U tide_zig_color       $yellow
set -U tide_toolbox_color   $purple
set -U tide_direnv_color    $yellow
set -U tide_distrobox_color $purple
set -U tide_nix_shell_color $blue

# cloud / infra segments
set -U tide_aws_color       $orange
set -U tide_docker_color    $blue
set -U tide_kubectl_color   $blue
set -U tide_gcloud_color    $blue
set -U tide_pulumi_color    $yellow
set -U tide_terraform_color $purple

# vi mode
set -U tide_vi_mode_color_default $grey
set -U tide_vi_mode_color_insert  $aqua
set -U tide_vi_mode_color_replace $green
set -U tide_vi_mode_color_visual  $orange

# frame / separators
set -U tide_prompt_color_frame_and_connection  $grey_dim
set -U tide_prompt_color_separator_same_color  $grey

# ── reload so the running prompt picks it up ─────────────────────────
if functions -q tide
    tide reload
end

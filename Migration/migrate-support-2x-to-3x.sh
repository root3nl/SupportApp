#!/bin/zsh --no-rcs

# Support 2.x to 3.x Configuration Migration
#
#
# Copyright 2026 Root3 B.V. All rights reserved.
#
# Converts a Support 2.x property list or configuration profile to the
# Support App 3.x schema. The migrated configuration renders the same
# rows, info items and buttons as the 2.x app produced: defaults for
# unset info items are preserved, hide-toggles are honored and button
# row sizing matches the legacy LegacyContentView layout (3-up buttons
# become ButtonSmall, 2-up buttons become Button).
#
# Usage:
#   migrate-support-2x-to-3x.sh -i <input> [-o <output>] [--to-plist]
#                               [--dry-run]
#
#   -i, --input <path>   Source .plist or .mobileconfig (required).
#   -o, --output <path>  Destination path. Defaults to <input>-3x.<ext>
#                        next to the input file.
#       --to-plist       For .mobileconfig input, write a bare .plist of
#                        the migrated nl.root3.support payload instead
#                        of a full configuration profile.
#       --dry-run        Print migrated XML to stdout, do not write.
#   -h, --help           Show usage.
#
# Wiki references:
#   https://github.com/root3nl/SupportApp/wiki/Migrating-Support-2.x-to-3.x
#   https://github.com/root3nl/SupportApp/wiki/Configuration
#
# REQUIREMENTS: macOS with /usr/libexec/PlistBuddy and /usr/bin/plutil.
#
# THE SOFTWARE IS PROVIDED BY ROOT3 B.V. "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO
# EVENT SHALL ROOT3 B.V. BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
# IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# ------------------    edit the variables below this line    ------------------

# Enable debugging
#set -x

# Exit on error
setopt err_exit pipe_fail typeset_silent

# Path to PlistBuddy. Used to read and write keys in plist files.
plist_buddy="/usr/libexec/PlistBuddy"

# PayloadType identifying the Support App payload in a .mobileconfig.
support_payload_type="nl.root3.support"

# ---------------------    do not edit below this line    ----------------------

# -----------------------------------------------------------------------------
# Helpers
# -----------------------------------------------------------------------------

# Print a usage summary to stdout.
usage() {
  cat <<EOF
Usage: $(basename "$0") -i <input> [-o <output>] [--to-plist] [--dry-run]

  -i, --input <path>    Source .plist or .mobileconfig (required)
  -o, --output <path>   Destination path (default: <input-stem>-3x.<ext>)
      --to-plist        For .mobileconfig input, write a bare .plist of
                        the migrated nl.root3.support payload
      --dry-run         Print migrated XML to stdout, do not write
  -h, --help            Show this help
EOF
}

# Print an error to stderr and exit non-zero.
die() {
  print -u2 -- "error: $*"
  exit 1
}

# Print a warning to stderr but keep running.
warn() {
  print -u2 -- "warning: $*"
}

# -----------------------------------------------------------------------------
# Argument parsing
# -----------------------------------------------------------------------------

input_file=""
output_file=""
to_plist=0
dry_run=0

while (( $# )); do
  case "$1" in
    -i|--input)   input_file="${2:-}"; shift 2 ;;
    -o|--output)  output_file="${2:-}"; shift 2 ;;
    --to-plist)   to_plist=1; shift ;;
    --dry-run)    dry_run=1; shift ;;
    -h|--help)    usage; exit 0 ;;
    *)            die "unknown argument: $1" ;;
  esac
done

if [[ -z "${input_file}" ]]; then
  usage >&2
  exit 1
fi

if [[ ! -f "${input_file}" ]]; then
  die "input not found: ${input_file}"
fi

# Validate the input is parseable as a plist.
plutil -lint "${input_file}" >/dev/null \
  || die "input is not a valid plist: ${input_file}"

# Detect input format by file extension.
input_ext="${input_file:e:l}"
case "${input_ext}" in
  plist)        input_kind="plist" ;;
  mobileconfig) input_kind="mobileconfig" ;;
  *) die "unsupported extension: .${input_ext}" ;;
esac

# Determine output path when not provided.
if [[ -z "${output_file}" && ${dry_run} -eq 0 ]]; then
  stem="${input_file:h}/${input_file:t:r}"
  if [[ "${input_kind}" == "mobileconfig" && ${to_plist} -eq 1 ]]; then
    output_file="${stem}-3x.plist"
  else
    output_file="${stem}-3x.${input_ext}"
  fi
fi

# -----------------------------------------------------------------------------
# Working copy
# -----------------------------------------------------------------------------

# Create an isolated working directory and ensure cleanup on exit.
tmp_dir=$(mktemp -d -t support-migrate)
trap 'rm -rf "${tmp_dir}"' EXIT

work_file="${tmp_dir}/work"
cp "${input_file}" "${work_file}"
plutil -convert xml1 "${work_file}"

# -----------------------------------------------------------------------------
# Locate the target preference dict
# -----------------------------------------------------------------------------

# For .plist the target is the root dict (empty prefix). For .mobileconfig
# we locate the PayloadContent entry whose PayloadType matches the Support
# App and use that as the prefix for every PlistBuddy path.
prefix=""

if [[ "${input_kind}" == "mobileconfig" ]]; then
  found_index=""
  i=0
  while :; do
    ptype=$("${plist_buddy}" \
      -c "Print :PayloadContent:${i}:PayloadType" \
      "${work_file}" 2>/dev/null) || break
    if [[ "${ptype}" == "${support_payload_type}" ]]; then
      found_index="${i}"
      break
    fi
    (( ++i ))
  done

  if [[ -z "${found_index}" ]]; then
    die "no PayloadContent entry with PayloadType=${support_payload_type}"
  fi

  prefix="PayloadContent:${found_index}:"
fi

# -----------------------------------------------------------------------------
# PlistBuddy helpers
# -----------------------------------------------------------------------------

# Run a PlistBuddy command, showing all output.
pb() {
  "${plist_buddy}" -c "$1" "${work_file}"
}

# Run a PlistBuddy command, suppressing output and ignoring failure.
pb_silent() {
  "${plist_buddy}" -c "$1" "${work_file}" >/dev/null 2>&1 || true
}

# Return the value of a key under the prefix dict, or empty string.
pb_get() {
  "${plist_buddy}" -c "Print :${prefix}$1" "${work_file}" 2>/dev/null \
    || true
}

# Return success if a key exists under the prefix dict.
pb_exists() {
  "${plist_buddy}" -c "Print :${prefix}$1" "${work_file}" \
    >/dev/null 2>&1
}

# Delete a key under the prefix dict, ignoring missing keys.
pb_delete() {
  pb_silent "Delete :${prefix}$1"
}

# Return success if a boolean key under the prefix dict is true.
pb_bool_true() {
  local value
  value=$(pb_get "$1")
  [[ "${value}" == "true" ]]
}

# -----------------------------------------------------------------------------
# Known 2.x key catalog
# -----------------------------------------------------------------------------

# Info item slot keys in the 2.x schema.
info_keys=(
  InfoItemOne InfoItemTwo InfoItemThree
  InfoItemFour InfoItemFive InfoItemSix
)

# Defaults applied when an info slot is absent (matches Preferences.swift).
typeset -A info_defaults=(
  InfoItemOne   ComputerName
  InfoItemTwo   MacOSVersion
  InfoItemThree Uptime
  InfoItemFour  Storage
  InfoItemFive  ""
  InfoItemSix   ""
)

# Button row dimensions in the 2.x schema.
button_rows=(First Second)
button_slots=(Left Middle Right)
button_props=(Title Subtitle Type Link Symbol)

# Extension dimensions in the 2.x schema.
extension_letters=(A B)
extension_props=(Title Value Symbol Type Link Alert)

# Row/button visibility toggles in the 2.x schema.
hide_keys=(
  HideFirstRowInfoItems HideSecondRowInfoItems HideThirdRowInfoItems
  HideFirstRowButtons   HideSecondRowButtons
)

# 3.x keys that pass through unchanged when present in the source.
pass_through=(
  Title FooterText ErrorMessage ShowWelcomeScreen
  StatusBarIconNotifierEnabled Logo LogoDarkMode NotificationIcon
  StatusBarIcon StatusBarIconAllowsColor StatusBarIconSFSymbol
  CustomColor CustomColorDarkMode UptimeDaysLimit PasswordType
  PasswordExpiryLimit PasswordLabel StorageLimit UpdateText
  OpenAtLogin DisablePrivilegedHelperTool DisableConfiguratorMode
  OnAppearAction Rows
)

# Build a set of recognised keys for the "unknown key" warning.
typeset -A known
for key in "${info_keys[@]}" "${hide_keys[@]}" "${pass_through[@]}"; do
  known[${key}]=1
done
for row in "${button_rows[@]}"; do
  for prop in "${button_props[@]}"; do
    for slot in "${button_slots[@]}"; do
      known[${row}Row${prop}${slot}]=1
    done
  done
done
for letter in "${extension_letters[@]}"; do
  for prop in "${extension_props[@]}"; do
    known[Extension${prop}${letter}]=1
  done
done
# Standard configuration profile payload metadata.
for key in PayloadType PayloadIdentifier PayloadUUID PayloadVersion \
           PayloadDisplayName PayloadDescription PayloadOrganization \
           PayloadEnabled PayloadScope; do
  known[${key}]=1
done

# -----------------------------------------------------------------------------
# Inspect source keys
# -----------------------------------------------------------------------------

# Collect the top-level keys of the target preference dict by parsing
# PlistBuddy's printed output. Direct children appear indented by exactly
# four spaces.
source_keys=()
dict_print=$(pb "Print :${prefix%:}" 2>/dev/null || pb "Print")
while IFS= read -r line; do
  [[ "${line}" =~ '^    ([A-Za-z0-9_]+) = ' ]] || continue
  source_keys+="${match[1]}"
done <<<"${dict_print}"

# Detect whether any 2.x keys are present at all.
has_legacy_keys=0
for key in "${source_keys[@]}"; do
  case "${key}" in
    InfoItem*|*RowTitle*|*RowSubtitle*|*RowType*|*RowLink*|*RowSymbol*\
    |Extension*|Hide*Row*)
      has_legacy_keys=1 ;;
  esac
done

if (( ! has_legacy_keys )); then
  warn "no 2.x keys found in source — nothing to migrate"
fi

# Warn about source keys we do not recognise.
for key in "${source_keys[@]}"; do
  if [[ -z "${known[${key}]:-}" ]]; then
    warn "unknown key '${key}' — passing through unchanged"
  fi
done

# -----------------------------------------------------------------------------
# Build the 3.x Rows array
# -----------------------------------------------------------------------------

# If the source already declares a Rows array, leave it alone and just
# strip the 2.x keys below. This is defensive — a fully migrated source
# should not be passed through the script.
rows_pre_exists=0
if pb_exists "Rows"; then
  rows_pre_exists=1
  warn "'Rows' already present — leaving as-is, only stripping 2.x keys"
fi

# Append one info row to the working Rows array.
# Arguments: key1, key2, hide_key.
add_info_row() {
  local key1="$1"
  local key2="$2"
  local hide_key="$3"

  if pb_bool_true "${hide_key}"; then
    return 0
  fi

  local items=()
  local key
  local value
  for key in "${key1}" "${key2}"; do
    if pb_exists "${key}"; then
      value=$(pb_get "${key}")
    else
      value="${info_defaults[${key}]}"
    fi
    if [[ -n "${value}" ]]; then
      items+="${value}"
    fi
  done

  (( ${#items} > 0 )) || return 0

  pb_silent "Add :${prefix}Rows:${row_idx} dict"
  pb_silent "Add :${prefix}Rows:${row_idx}:Items array"

  local item_idx=0
  for value in "${items[@]}"; do
    pb_silent "Add :${prefix}Rows:${row_idx}:Items:${item_idx} dict"
    pb_silent \
      "Add :${prefix}Rows:${row_idx}:Items:${item_idx}:Type string ${value}"
    (( ++item_idx ))
  done

  (( ++row_idx ))
}

# Append one button row to the working Rows array.
# Arguments: row_name (First|Second), hide_key.
add_button_row() {
  local row_name="$1"
  local hide_key="$2"

  if pb_bool_true "${hide_key}"; then
    return 0
  fi

  # Collect populated slots in left-to-right order.
  local slot_titles=() slot_subs=() slot_syms=() slot_links=() slot_types=()
  local populated_count=0
  local slot
  local title
  local link
  for slot in "${button_slots[@]}"; do
    title=$(pb_get "${row_name}RowTitle${slot}")
    link=$(pb_get "${row_name}RowLink${slot}")
    if [[ -z "${title}" && -z "${link}" ]]; then
      continue
    fi
    slot_titles+="${title}"
    slot_subs+="$(pb_get "${row_name}RowSubtitle${slot}")"
    slot_syms+="$(pb_get "${row_name}RowSymbol${slot}")"
    slot_links+="${link}"
    slot_types+="$(pb_get "${row_name}RowType${slot}")"
    (( ++populated_count ))
  done

  (( populated_count > 0 )) || return 0

  # Match LegacyContentView: 3 buttons render as ButtonSmall, otherwise
  # the regular Button type.
  local button_type
  if (( populated_count >= 3 )); then
    button_type="ButtonSmall"
  else
    button_type="Button"
  fi

  pb_silent "Add :${prefix}Rows:${row_idx} dict"
  pb_silent "Add :${prefix}Rows:${row_idx}:Items array"

  local item_idx=0
  local i=1
  local item_path
  while (( i <= populated_count )); do
    item_path="${prefix}Rows:${row_idx}:Items:${item_idx}"
    pb_silent "Add :${item_path} dict"
    pb_silent "Add :${item_path}:Type string ${button_type}"
    if [[ -n "${slot_titles[${i}]}" ]]; then
      pb_silent "Add :${item_path}:Title string ${slot_titles[${i}]}"
    fi
    if [[ -n "${slot_subs[${i}]}" ]]; then
      pb_silent \
        "Add :${item_path}:Subtitle string ${slot_subs[${i}]}"
    fi
    if [[ -n "${slot_syms[${i}]}" ]]; then
      pb_silent "Add :${item_path}:Symbol string ${slot_syms[${i}]}"
    fi
    if [[ -n "${slot_links[${i}]}" ]]; then
      pb_silent "Add :${item_path}:Action string ${slot_links[${i}]}"
    fi
    if [[ -n "${slot_types[${i}]}" ]]; then
      pb_silent \
        "Add :${item_path}:ActionType string ${slot_types[${i}]}"
    fi
    (( ++item_idx ))
    (( ++i ))
  done

  (( ++row_idx ))
}

# Append one extension row to the working Rows array.
# Arguments: letter (A|B).
add_extension_row() {
  local letter="$1"

  local title
  local link
  title=$(pb_get "ExtensionTitle${letter}")
  link=$(pb_get "ExtensionLink${letter}")
  if [[ -z "${title}" && -z "${link}" ]]; then
    return 0
  fi

  pb_silent "Add :${prefix}Rows:${row_idx} dict"
  pb_silent "Add :${prefix}Rows:${row_idx}:Items array"

  local item_path="${prefix}Rows:${row_idx}:Items:0"
  pb_silent "Add :${item_path} dict"
  pb_silent "Add :${item_path}:Type string Extension"

  if [[ -n "${title}" ]]; then
    pb_silent "Add :${item_path}:Title string ${title}"
  fi

  local subtitle
  local symbol
  local action_type
  subtitle=$(pb_get "ExtensionValue${letter}")
  symbol=$(pb_get "ExtensionSymbol${letter}")
  action_type=$(pb_get "ExtensionType${letter}")

  if [[ -n "${subtitle}" ]]; then
    pb_silent "Add :${item_path}:Subtitle string ${subtitle}"
  fi
  if [[ -n "${symbol}" ]]; then
    pb_silent "Add :${item_path}:Symbol string ${symbol}"
  fi
  if [[ -n "${link}" ]]; then
    pb_silent "Add :${item_path}:Action string ${link}"
  fi
  if [[ -n "${action_type}" ]]; then
    pb_silent "Add :${item_path}:ActionType string ${action_type}"
  fi

  # Derive ExtensionID from the action when it looks like a reverse-DNS
  # bundle identifier. Warn otherwise so the admin can fill it in.
  if [[ -n "${link}" && "${link}" == *.* \
        && "${link}" != */* && "${link}" != *:* ]]; then
    pb_silent "Add :${item_path}:ExtensionID string ${link}"
  else
    warn "Extension${letter}: could not derive ExtensionID — set it manually"
  fi

  (( ++row_idx ))
}

if (( ! rows_pre_exists )); then
  pb_silent "Add :${prefix}Rows array"
  row_idx=0

  add_info_row InfoItemOne   InfoItemTwo  HideFirstRowInfoItems
  add_info_row InfoItemThree InfoItemFour HideSecondRowInfoItems
  add_info_row InfoItemFive  InfoItemSix  HideThirdRowInfoItems

  add_button_row First  HideFirstRowButtons
  add_button_row Second HideSecondRowButtons

  add_extension_row A
  add_extension_row B

  # Drop the Rows array entirely if nothing was migrated into it.
  if (( row_idx == 0 )); then
    pb_delete "Rows"
  fi
fi

# -----------------------------------------------------------------------------
# Strip 2.x keys from the preference dict
# -----------------------------------------------------------------------------

for key in "${info_keys[@]}"; do
  pb_delete "${key}"
done
for row in "${button_rows[@]}"; do
  for prop in "${button_props[@]}"; do
    for slot in "${button_slots[@]}"; do
      pb_delete "${row}Row${prop}${slot}"
    done
  done
done
for letter in "${extension_letters[@]}"; do
  for prop in "${extension_props[@]}"; do
    pb_delete "Extension${prop}${letter}"
  done
done
for key in "${hide_keys[@]}"; do
  pb_delete "${key}"
done

# -----------------------------------------------------------------------------
# Finalise output
# -----------------------------------------------------------------------------

# With --to-plist on a .mobileconfig input, extract just the migrated
# preference dict and replace the working file with it.
if [[ "${input_kind}" == "mobileconfig" && ${to_plist} -eq 1 ]]; then
  extracted="${tmp_dir}/extracted.plist"
  "${plist_buddy}" -x -c "Print :${prefix%:}" "${work_file}" \
    > "${extracted}"
  mv "${extracted}" "${work_file}"
fi

plutil -convert xml1 "${work_file}"
plutil -lint "${work_file}" >/dev/null \
  || die "migrated output failed plutil -lint (internal bug)"

# plutil indents XML with tabs; rewrite to 4-space indentation.
spaced_file="${tmp_dir}/spaced"
expand -t 4 "${work_file}" > "${spaced_file}"
mv "${spaced_file}" "${work_file}"

if (( dry_run )); then
  cat "${work_file}"
else
  mv "${work_file}" "${output_file}"
  print -- "wrote: ${output_file}"
fi

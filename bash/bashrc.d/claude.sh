# Claude Code
#
# The single source of truth for the model — config.sh deliberately holds none,
# because this file is deployed verbatim into ~/.bashrc.d/ and cannot source it.
#
# "default" is not a model alias: it clears any override and takes the account's
# runtime default, so it does not go stale the way a pinned release does. Also
# valid: best, fable, opus, sonnet, haiku, opusplan, opus[1m], sonnet[1m], or a
# full model ID.
#
# Pin one only on purpose. This variable outranks the `model` key in every
# settings file, so a value here silently beats whatever /model saves.
export ANTHROPIC_MODEL="${ANTHROPIC_MODEL:-default}"
export CLAUDE_CUSTOM_INSTRUCTIONS="$HOME/.config/CLAUDE.md"

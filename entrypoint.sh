#!/bin/bash
set -e

# Ensure permissions on mounted volumes for the antigravity user
sudo mkdir -p "${HOME}/.gemini/antigravity-cli" "${HOME}/.antigravity" /workspace 2>/dev/null || true
sudo chown -R "$(id -u):$(id -g)" "${HOME}/.gemini" "${HOME}/.antigravity" /workspace 2>/dev/null || true
sudo chmod -R u+rwX "${HOME}/.gemini" "${HOME}/.antigravity" /workspace 2>/dev/null || true

AGY_BIN="${HOME}/.local/bin/agy"
[[ -x "$AGY_BIN" ]] || AGY_BIN=$(command -v agy || true)

if [[ -z "$AGY_BIN" || ! -x "$AGY_BIN" ]]; then
    echo "[ERROR] 'agy' binary not found in PATH or ~/.local/bin."
    echo "Attempting to install 'agy'..."
    curl -fsSL https://antigravity.google/cli/install.sh | bash
    AGY_BIN="${HOME}/.local/bin/agy"
fi

# Manage toggleable plugins
manage_plugins() {
    # 1. Built-in toggle for rmyndharis/antigravity-skills
    if [[ "${ENABLE_COMMUNITY_SKILLS:-false}" == "true" ]]; then
        echo "--> Community skills plugin (rmyndharis/antigravity-skills) is ENABLED."
        "$AGY_BIN" plugin install https://github.com/rmyndharis/antigravity-skills 2>/dev/null || true
        "$AGY_BIN" plugin enable antigravity-skills 2>/dev/null || true
    elif [[ "${ENABLE_COMMUNITY_SKILLS:-false}" == "false" ]]; then
        "$AGY_BIN" plugin disable antigravity-skills 2>/dev/null || true
    fi

    # 2. Support custom list of plugins via AGY_PLUGINS (comma-separated URLs)
    if [[ -n "${AGY_PLUGINS:-}" ]]; then
        IFS=',' read -ra PLUGIN_LIST <<< "$AGY_PLUGINS"
        for plugin in "${PLUGIN_LIST[@]}"; do
            plugin_trimmed=$(echo "$plugin" | xargs)
            if [[ -n "$plugin_trimmed" ]]; then
                echo "--> Installing custom plugin: $plugin_trimmed"
                "$AGY_BIN" plugin install "$plugin_trimmed" 2>/dev/null || true
            fi
        done
    fi
}

PORT="${AGY_HUB_PORT:-4400}"
NAME_ARGS=()
if [[ -n "${AGY_INSTANCE_NAME:-}" ]]; then
    NAME_ARGS=("--remote-control-name" "${AGY_INSTANCE_NAME}")
fi

TOKEN_FILE="${HOME}/.gemini/jetski-standalone-oauth-token"

case "$1" in
    login)
        echo "=============================================================="
        echo "  Antigravity Remote Control Initial Authentication"
        echo "=============================================================="
        echo "Please open the URL displayed below in your browser and complete"
        echo "the sign-in process with your Google account."
        echo "Once authenticated, your session token will be saved to your volume."
        echo "=============================================================="
        manage_plugins
        exec "$AGY_BIN" --remote-control --hub-port "$PORT" "${NAME_ARGS[@]}"
        ;;
    run)
        echo "=============================================================="
        echo "  Starting Antigravity Remote Control Headless Daemon"
        if [[ -n "${AGY_INSTANCE_NAME:-}" ]]; then
            echo "  Instance Name : ${AGY_INSTANCE_NAME}"
        fi
        echo "  Hub Port      : ${PORT}"
        echo "=============================================================="

        manage_plugins

        if [[ ! -s "$TOKEN_FILE" ]]; then
            echo ""
            echo "[WARNING] No authentication token found at:"
            echo "  $TOKEN_FILE"
            echo ""
            echo "First-time sign-in required! You can either:"
            echo "  1. Authenticate interactively now via terminal URL/code prompt below, OR"
            echo "  2. Run the dedicated login command:"
            echo "       docker compose run --rm antigravity login"
            echo "--------------------------------------------------------------"
        fi

        exec "$AGY_BIN" --remote-control --hub-port "$PORT" "${NAME_ARGS[@]}"
        ;;
    *)
        exec "$@"
        ;;
esac

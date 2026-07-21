#!/usr/bin/env bash
set -euo pipefail

echo "Installing dbconnect..."

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

mkdir -p "$HOME/.config/dbconnect"
mkdir -p "$HOME/.config/fish/functions"

cp "$REPO_ROOT/dbconnect/dbconnect.fish" "$HOME/.config/fish/functions/dbconnect.fish"

if [ ! -f "$HOME/.config/dbconnect/connections.toml" ]; then
  cat > "$HOME/.config/dbconnect/connections.toml" <<'TOML'
# Local dbconnect configuration
# Bu dosya sadece lokal ortamında bulunmalıdır.
# Gerçek DB/server şifrelerini repo'ya, prompt'a, Teams'e veya loglara yazma.
# Dosya izni chmod 600 olmalıdır.
#
# Örnek section formatı:
#
# [connection_name]
# type = "postgres|snowflake|mongodb"
# host = ""
# port = ""
# local_port = ""
# dbname = ""
# user = ""
# password = ""
# schema = ""
# jumper = ""
# uri = ""
#
# Snowflake için örnek alanlar:
# account = ""
# warehouse = ""
# role = ""
# authenticator = ""
# private_key_file = ""
# insecure_mode = ""
TOML
  echo "Created $HOME/.config/dbconnect/connections.toml"
else
  echo "$HOME/.config/dbconnect/connections.toml already exists, skipping creation."
fi

chmod 600 "$HOME/.config/dbconnect/connections.toml"
chmod 644 "$HOME/.config/fish/functions/dbconnect.fish"

echo ""
echo "dbconnect installed successfully."
echo ""
echo "Next steps:"
echo "1. Edit your local DB connection file:"
echo "   vi ~/.config/dbconnect/connections.toml"
echo ""
echo "2. If SSH tunnel is needed, update your local SSH config manually:"
echo "   vi ~/.ssh/config"
echo "   chmod 600 ~/.ssh/config"
echo ""
echo "3. Test examples:"
echo "   dbconnect -c <connection_name> -q 'SELECT 1'"
echo "   dbconnect -c <connection_name> -q 'db.runCommand({ping:1})'"
echo ""
echo "Security reminder:"
echo "- Do not commit ~/.config/dbconnect/connections.toml"
echo "- Do not share DB passwords, SSH keys, tokens or connection strings with AI"

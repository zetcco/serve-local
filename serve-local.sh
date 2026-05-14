#!/usr/bin/env zsh

# Check if correct number of arguments are passed
if [[ "$#" -ne 2 ]]; then
    echo "⚠️  Usage: serve-local <domain> <port>"
    echo "💡 Example: serve-local test.bijira.dev 8080"
    exit 1
fi

DOMAIN=$1
PORT=$2
# Unique tag to ensure we safely remove ONLY the line we added to /etc/hosts
TAG="# temp-local-proxy-by-zsh" 

echo "🔒 Setting up temporary proxy: https://$DOMAIN -> localhost:$PORT"

# 1. Add mapping to /etc/hosts
# We use sudo tee to append without needing to run the whole script as root
echo "127.0.0.1 $DOMAIN $TAG" | sudo tee -a /etc/hosts > /dev/null
echo "✅ Added $DOMAIN to /etc/hosts"

# 2. Create a temporary Caddyfile
TEMP_CADDYFILE=$(mktemp)
cat <<EOF > "$TEMP_CADDYFILE"
$DOMAIN {
    tls internal
    reverse_proxy localhost:$PORT
}
EOF

# 3. Define the cleanup function
cleanup() {
    echo "\n🛑 Stopping proxy and cleaning up..."
    
    # Safely remove our specific line from /etc/hosts
    grep -v "$DOMAIN $TAG" /etc/hosts | sudo tee /etc/hosts.tmp > /dev/null
    sudo mv /etc/hosts.tmp /etc/hosts
    
    # Delete the temporary Caddyfile
    rm -f "$TEMP_CADDYFILE"
    
    echo "🧹 Cleanup complete. Everything is back to normal. Bye!"
    exit 0
}

# 4. Catch the Ctrl+C signal (SIGINT) to trigger the cleanup function safely
trap cleanup SIGINT EXIT

# 5. Run Caddy with the temporary config (using the caddyfile adapter!)
echo "🚀 Starting Caddy... (Press Ctrl+C to stop)"
sudo caddy run --config "$TEMP_CADDYFILE" --adapter caddyfile

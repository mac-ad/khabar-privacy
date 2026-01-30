#!/usr/bin/env bash

set -e

# === FILL THESE PLACEHOLDERS WITH YOUR VALUES ===
AWS_USER='your-aws-username'
AWS_HOST='your-aws-host-or-ip'

AWS_KEY_PATH='/path/to/your/key.pem'
AWS_DESTINATION_PATH='/home/your-aws-username/your-project-directory/'
# ================================================

SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Deploying to AWS..."
echo "AWS User: $AWS_USER"
echo "AWS Host: $AWS_HOST"
echo "AWS Key Path: $AWS_KEY_PATH"

# copying project files to AWS (edit excludes and paths as needed)
echo "Copying the project..."
rsync -avz --exclude 'deploy_to_aws_script/' --exclude 'package.json' --exclude 'package-lock.json' -e "ssh -i $AWS_KEY_PATH" . $AWS_USER@$AWS_HOST:$AWS_DESTINATION_PATH

# copy nginx config to AWS (optional: update the config filename/location as required)
echo -e "\n\nReplacing the nginx config for frontend..."
scp -i "$AWS_KEY_PATH" -v "$SCRIPT_PATH/YOUR_NGINX_CONFIG_FILENAME" $AWS_USER@$AWS_HOST:$AWS_DESTINATION_PATH/YOUR_NGINX_CONFIG_FILENAME

# remove the old nginx config
echo -e "\n\nRemoving the old nginx config..."
ssh -i "$AWS_KEY_PATH" "$AWS_USER@$AWS_HOST" "sudo rm -f /etc/nginx/sites-enabled/YOUR_NGINX_CONFIG_FILENAME"

# move nginx config to correct location
echo -e "\n\nMoving the nginx config to correct location..."
ssh -i "$AWS_KEY_PATH" "$AWS_USER@$AWS_HOST" "sudo mv $AWS_DESTINATION_PATH/YOUR_NGINX_CONFIG_FILENAME /etc/nginx/sites-available/YOUR_NGINX_CONFIG_FILENAME"

# create a symlink to the nginx config
echo -e "\n\nCreating a symlink to the nginx config..."
ssh -i "$AWS_KEY_PATH" "$AWS_USER@$AWS_HOST" "sudo ln -sf /etc/nginx/sites-available/YOUR_NGINX_CONFIG_FILENAME /etc/nginx/sites-enabled/YOUR_NGINX_CONFIG_FILENAME"

# Reload nginx
echo -e "\n\nReloading nginx..."
ssh -i "$AWS_KEY_PATH" "$AWS_USER@$AWS_HOST" "sudo nginx -t"

# restart nginx
echo "Restarting nginx..."
ssh -i "$AWS_KEY_PATH" "$AWS_USER@$AWS_HOST" "sudo systemctl restart nginx"

echo "Deployment complete!"

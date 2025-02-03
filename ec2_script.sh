#!/bin/bash -xeu

set -x

echo "Setting up EC2 Instance"

# Variables
REPO_URL="https://github.com/abdulraziqadvani/Angular-Full-Stack.git"
TARGET_DIR="fullstack-angular-app"
ENV_FILE=".env"

generate_mongodb_uri() {
  local db_name="$1"  # The database name passed as an argument

  # MongoDB connection details
  local username="admin"
  local password="admin123"
  local host="cluster0-shard-00-00.jqqim.mongodb.net:27017,cluster0-shard-00-01.jqqim.mongodb.net:27017,cluster0-shard-00-02.jqqim.mongodb.net:27017"
  local replica_set="atlas-valm6p-shard-0"
  local auth_source="admin"
  local retry_writes="true"
  local app_name="Cluster0"

  # Generate the connection URI
  local uri="mongodb://${username}:${password}@${host}/${db_name}?replicaSet=${replica_set}&authSource=${auth_source}&retryWrites=${retry_writes}&w=majority&appName=${app_name}"

  # Return the URI
  echo "$uri"
}

echo "nameserver 8.8.8.8" >> /etc/resolv.conf
echo "nameserver 1.1.1.1" >> /etc/resolv.conf

curl -sL https://deb.nodesource.com/setup_20.x -o nodesource_setup.sh
bash nodesource_setup.sh
apt update -y
apt install nodejs jq -y
apt-get install curl git -y

echo "Node.js and npm installed successfully."

# Step 1: Clone the repository
git clone $REPO_URL $TARGET_DIR

# Step 2: Navigate to the cloned repository
cd $TARGET_DIR || { echo "Failed to navigate to $TARGET_DIR"; exit 1; }

mv .env.sample .env

# Step 3: Update the .env file
if [ -f $ENV_FILE ]; then
  # Use sed to modify existing keys
  mongodb_uri=$(generate_mongodb_uri "angularfullstack")
  mongodb_test_uri=$(generate_mongodb_uri "angularfullstack-test")
  sed -i "s|^MONGODB_URI=.*|MONGODB_URI=${mongodb_uri}|" ${ENV_FILE}
  sed -i "s|^MONGODB_TEST_URI=.*|MONGODB_TEST_URI=${mongodb_test_uri}|" ${ENV_FILE}
fi

echo ".env file updated successfully."

npm i

echo "Project modules installed successfully."

npm run dev

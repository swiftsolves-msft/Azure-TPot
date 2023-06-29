# Remove existing T-Pot installation directory if it exists
sudo rm -rf tpotce

 

# Clone T-Pot repository
git clone https://github.com/telekom-security/tpotce.git

 

# Navigate to installer directory
cd tpotce/iso/installer

 

# Make the installation script executable
chmod +x install.sh

 

# Run the installation script
sudo ./install.sh
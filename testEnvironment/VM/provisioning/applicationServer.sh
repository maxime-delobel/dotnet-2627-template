echo "Installing dependencies"
dnf install dotnet-sdk-10.0 git -y

echo "Cloning the repo"
git clone https://github.com/maxime-delobel/dotnet-2627-template.git

echo "Launching dotnet application on port 5001"
dotnet run --project /home/vagrant/dotnet-2627-template/src/Rise.Server --urls "http://0.0.0.0:5001" &


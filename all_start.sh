cd App_Docker_Compose
docker compose build --no-cache
docker compose up -d
cd ..
cd Jenkins_Docker_Compose
docker compose build --no-cache
docker compose up -d
cd ..
cd Monitoring_Docker_Compose
docker compose build --no-cache
docker compose up -d
cd ..
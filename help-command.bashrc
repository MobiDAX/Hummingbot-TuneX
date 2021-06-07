docker build --tag  gitlab.tunex.io:5050/trading-bot/hummingbot .
docker run -it --name bot  -e "STRATEGY=pure_market_making" -e "CONFIG_FILE_NAME=conf_pure_market_making_strategy_0.yml" -e "CONFIG_PASSWORD=gfhjkm"  --mount "type=bind,source=$(pwd)/conf,destination=/conf/" --mount "type=bind,source=$(pwd)/logs,destination=/logs/"  gitlab.tunex.io:5050/trading-bot/hummingbot

docker run -it --name hummingbot-instance_1 --mount "type=bind,source=$(pwd)/conf,destination=/conf/" --mount "type=bind,source=$(pwd)/logs,destination=/logs/" -e "STRATEGY=pure_market_making" -e "CONFIG_FILE_NAME=conf_pure_market_making_strategy_1.yml" -e "CONFIG_PASSWORD=gfhjkm" docker.pkg.github.com/tunex-io/hummingbot/internal-hummingbot:0.0.1
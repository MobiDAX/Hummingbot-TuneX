# HummingBot deploy in swarm

## Prerequisites

Assuming, that you have Docker in swarm mode: https://docs.docker.com/engine/swarm/

IMPORTANT: Suppose you have **opendax-project** deployed from gitlab.tunex.io (should be used your own project name)

### Getting Docker image

Login to private Docker registry first using your Gitlab account credentials:

```
docker login gitlab.tunex.io:5050 
```

Pull 0.22 version run following command:

```
docker pull gitlab.tunex.io:5050/reference-project/hummingbot-tunex:0.22
```

### Preparing barong api_keys

Use setter of your **opendax-project** for next steps

1. Turn on 2FA for user that will be used as bot

![2FA](https://gitlab.tunex.io/reference-project/hummingbot-tunex/-/raw/master/images/profile_mobiweb.jpg)

2. Create new api_key

![add key](https://gitlab.tunex.io/reference-project/hummingbot-tunex/-/raw/master/images/keys_mobiweb.jpg)

3. Save key and secret

![add key](https://gitlab.tunex.io/reference-project/hummingbot-tunex/-/raw/master/images/key_mobiweb.jpg)

### Configuring bots

Change with your data and copy conf_global.yml and conf_pure_market.yml in conf directory templates
1. Create **config/hummingbot/conf_swarm** where will be configuring *.*yaml files; create **config/hummingbot/logs** and  **config/hummingbot/data**


   1.1 Copy conf directory [templates](https://gitlab.tunex.io/reference-project/hummingbot-tunex/-/tree/master/templates/conf_0.22)
   to **config/hummingbot/conf_swarm**. Create strategy (*.*yaml file) for each pairs on opendax-project trading market inside 
   **conf_swarm** using conf_pure_market.yml template

   For convinient the strategy can be named like "conf_eth-eur_0.yml" for the pair eth-eur (of cource if it used on trading 
   market)

   1.2 Configure conf_global.yml template and write params:
    trading_pair_splitter 
    key_file_path 
    log_file_path 

    
    for trading_pair_splitter all values used on trading market with split '|'; 
    example: ```trading_pair_splitter: ETH|USD|BTC|OZTG|USDT|EUR ```
    for key_file_path must be: 
    ```key_file_path: conf_swarm/ ``` as created folder
    write ```log_file_path: logs/```  


2. Start bot for manage secure configuration

```
docker run -it --name namebot --mount "type=bind,source=$(pwd)/conf,destination=/conf/" --mount "type=bind,source=$(pwd)/logs,destination=/logs/" --mount "type=bind,source=$(pwd)/data,destination=/data/" gitlab.tunex.io:5050/reference-project/hummingbot-tunex:0.22
```
where namebot is bot name  due to conf_namebot.yaml - > for example: ```docker run -it --name eth-eur_0 --mount ...``` due to conf_eth-eur_0.yaml

3. Using command ```connect openware``` (due to parameter maker_market in conf_pure_market.yml ) add api key and api/ranger urls in configuration. Close hummingbot ```exit``` and remove docker container ```docker rm config_bot```.


## Configuring for running bots in swarm

3. Create **bots.yaml.erb** inside /opendax-project/templates/compose wth all strategys for all markets You have (it’s number of various conf_pure_market.yml inside /pathTo/container_name/conf_swarm)
You should create services for easch market strategy inside bots.yaml.erb and configure: image, volumes, environment, deploy for each other.
**Important:** write label name for the node of swarm where bots wil be running in (for example: [node.labels.status == bots] )

```
    deploy: 
        placement:
            constraints:  [node.labels.status == bots]

```
 
For example, You have markets strategy for 3 pairs (eth-usd,btc-usdt,eth-btc) and use one strategy for each pair, so Your file will looks like:


```
version: '3.6'

services:
  bot-ethusd-0:
    image: gitlab.tunex.io:5050/trading-bot/hummingbot:0.22
    restart: always
    stdin_open: true
    tty: true
    volumes:
      - ../config/hummingbot/conf_swarm/:/conf/
      - ../config/hummingbot/logs/:/logs/
    environment:
      - STRATEGY=pure_market_making
      - CONFIG_FILE_NAME=conf_eth-usd_0.yml
      - CONFIG_PASSWORD=password
    
    deploy:
      resources:
        limits:
          memory: 320M
      placement:
        constraints: [node.labels.status == bots]

  
  bot-btc-usdt-0:
    image: gitlab.tunex.io:5050/trading-bot/hummingbot:0.22
    restart: always
    stdin_open: true
    tty: true
    volumes:
      - ../config/hummingbot/conf_swarm/:/conf/
      - ../config/hummingbot/logs/:/logs/
    environment:
      - STRATEGY=pure_market_making
      - CONFIG_FILE_NAME=conf_btc-usdt_0.yml
      - CONFIG_PASSWORD=password
      
    deploy:
      resources:
        limits:
          memory: 320M
      placement:
        constraints: [node.labels.status == bots]

  bot-ethbtc-0:
    image: gitlab.tunex.io:5050/trading-bot/hummingbot:0.22
    restart: always
    stdin_open: true
    tty: true
    volumes:
      - ../config/hummingbot/conf_swarm/:/conf/
      - ../config/hummingbot/logs/:/logs/
    environment:
      - STRATEGY=pure_market_making
      - CONFIG_FILE_NAME=conf_eth-btc_0.yml
      - CONFIG_PASSWORD=password
      
    deploy:
      resources:
        limits:
          memory: 320M
      placement:
        constraints: [node.labels.status == bots]
```
4. Take list of nodes in swarm:
```
   docker node ls
```
add label to one of the node:

```
   docker node update --label-add status=bots [node-name]
```

5. Run bots:

```
   docker stack deploy -c compose/bots.yaml [node-name]
```

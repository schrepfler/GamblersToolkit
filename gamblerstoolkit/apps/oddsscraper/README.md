# OddsScrapr
Modular GenServer for fault tolerent webscraping of odds data from various popular sites and bookmakers.
The Scraper is set to scraper MLB odds and can be configured to any sport.

## Installation
* Install Ubuntu, Erlang and Elixir on your computer.
* Install Phantom.js or Chrome headless Browser
* Install xvfb

## Start PhantomJs in Bash (you may use Chrome if you like) 
> sudo screen -S phantomJS
> <screen> xvfb-run phantomjs --wd
  
If you use Chrome Headless Browser or selenium then you have to configure it in config/config.ex
Change the line: 
> config: hound, driver: chromedriver ( or selenium)

# Functions

### MlbOdds.Oracle
The Oracle is a Genserver which acts as a resgistry for dynamically supervised scrapers

#### Functions
> Function: odds_axlotl(agent)
> Arity: (1)
>> agent:  A scraping agent in the MlbOdds NameSpace,  located in the scrapers folder
>> eg:  MlbOdds.SBRAgent
